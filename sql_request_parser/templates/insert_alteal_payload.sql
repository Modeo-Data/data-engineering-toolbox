DROP TABLE IF EXISTS datawarehouse_prod.alteal_payload ON CLUSTER default;
​
CREATE TABLE IF NOT EXISTS datawarehouse_prod.alteal_payload ON CLUSTER default (
  device_id String,
  device_name String,
  device_payload_uid String,
  group_id String,
  iot_entity String,
  group_name String,
  group_category String,
  batiment_related String,
  station_id Nullable(String),
  payload_id String,
  payload_source Nullable(String),
  payload_date DateTime('Europe/Paris'),
  metrics_id String,
  sensor_name String,
  metrics_value_string Nullable(String),
  metrics_value_numeric Nullable(Float64),
  metrics_unit String,
  time_spent Nullable(Int32),
  confort_type String,
  shift String,
  etage Nullable(String),
  orientation Nullable(String),
  typologie Nullable(String),
  parent_list String
)
    ENGINE = ReplicatedReplacingMergeTree
    order by (payload_id, metrics_id);
​
DROP TABLE IF EXISTS datawarehouse_prod.distributed_alteal_payload ON CLUSTER default;
​
CREATE TABLE IF NOT EXISTS datawarehouse_prod.distributed_alteal_payload ON CLUSTER default AS datawarehouse_prod.alteal_payload ENGINE = Distributed(
  default,
  datawarehouse_prod,
  alteal_payload,
  murmurHash3_64(device_id)
);
​
INSERT INTO datawarehouse_prod.distributed_alteal_payload
​
WITH
-- Get parent group info from distributed_groups_descendants
    parent_info as (
      select
        descendants as group_id,
        arrayDistinct(
          groupArray(_id)
        ) as parent_list
      from
        datawarehouse_prod.distributed_groups_descendants
      group by
        descendants
    ),
​
    -- Get all buildings data with groups
    batiment_multi as (
      select
        distinct gb.building_id,
        gb.building_name,
        gb.category,
        gb.descendants
      from
        datawarehouse_prod.distributed_global_buildings gb
        inner join datawarehouse_prod.distributed_parent_child_group_ids pcg on gb.parent = pcg.descendants
    ),
​
    client_devices as (
      select
        dvc.device_id as device_id,
        dvc.device_name as device_name,
        dvc.device_payload_uid as device_payload_uid,
        dvc.group_id as group_id,
        dvc.iot_entity as iot_entity,
        dvc.station_id as station_id,
        grp.group_category as group_category,
        grp.group_name as group_name,
        dvc_feat.etage as etage,
        dvc_feat.orientation as orientation,
        dvc_feat.typologie as typologie
      from
        datawarehouse_prod.distributed_global_devices dvc
        left join datawarehouse_prod.distributed_global_devices_features dvc_feat on dvc_feat.device_id = dvc.device_id
        left join datawarehouse_prod.distributed_global_group_name grp on dvc.group_id = grp.group_id
      where
        dvc.iot_entity in {{ params.client.alteal.iot_entity_list }}
    ),
​
    pld_dvc AS (
      select
        dvc.device_id as device_id,
        dvc.device_name as device_name,
        dvc.device_payload_uid as device_payload_uid,
        dvc.group_id as group_id,
        dvc.group_category as group_category,
        dvc.iot_entity as iot_entity,
        dvc.group_name as group_name,
        dvc.station_id as station_id,
        pld.payload_id as payload_id,
        pld.source_type as payload_source,
        toDateTime(FROM_UNIXTIME(pld.time),'Europe/Paris') as payload_date_eur,
        toHour(toDateTime(FROM_UNIXTIME(pld.time),'Europe/Paris')) AS payload_hour,
        pld.metrics_id as metrics_id,
        sns.name as sensor_name,
        sns.unit as metrics_unit,
        if(
          accurateCastOrNull(pld.metrics_value, 'Float64') is null,
          pld.metrics_value,
          null
        ) as metrics_value_string,
        if(
          accurateCastOrNull(pld.metrics_value, 'Float64') is not null,
          CAST(pld.metrics_value as double),
          null
        ) as metrics_value_numeric,
        dvc.etage as etage,
        dvc.orientation as orientation,
        dvc.typologie as typologie
      from
        raw_prod.distributed_mongo_payload_unnested pld
        inner join client_devices dvc on pld.device_uid = dvc.device_payload_uid
        left join raw_prod.distributed_mongo_sensors sns FINAL on pld.metrics_id = sns._id
      where
        in {{ params.client.alteal.sensors_ids_list }}
      order by
        device_id,
        payload_date_eur
    ),
​
    compute_time_spent as (
      select
        *,
        if(payload_hour > {{ params.client.alteal.day.start_hour }} 
        and payload_hour < {{ params.client.alteal.night.start_hour }}, 'day', 'night') AS shift,
        If(
          neighbor(device_id, -1) = device_id,
          date_diff(
            'second',
            neighbor(payload_date_eur, -1),
            payload_date_eur
          ),
          null
        ) as time_spent
      from
        pld_dvc
    )
    select
      cz.device_id as device_id,
      cz.device_name as device_name,
      cz.device_payload_uid as device_payload_uid,
      cz.group_id as group_id,
      cz.iot_entity as iot_entity,
      cz.group_name as group_name,
      cz.group_category as group_category,
      bat.building_name as batiment_related,
      cz.station_id as station_id,
      cz.payload_id as payload_id,
      cz.payload_source as payload_source,
      cz.payload_date_eur as payload_date,
      cz.metrics_id as metrics_id,
      cz.sensor_name as sensor_name,
      cz.metrics_value_string as metrics_value_string,
      cz.metrics_value_numeric as metrics_value_numeric,
      cz.metrics_unit as metrics_unit,
      cz.time_spent as time_spent,
          IF(cz.metrics_value_numeric >= {{ params.client.alteal.day.inf_confort_zone }} and cz.metrics_value_numeric <= {{ params.client.alteal.day.sup_confort_zone }} and cz.shift = 'day',
             'Température dans la zone de confort - jour',
             IF(cz.metrics_value_numeric >= {{ params.client.alteal.night.inf_confort_zone }} and cz.metrics_value_numeric <= {{ params.client.alteal.night.sup_confort_zone }} and cz.shift = 'night',
                'Température dans la zone de confort - nuit',
                IF((cz.metrics_value_numeric > {{ params.client.alteal.day.sup_confort_zone + params.client.alteal.buffer_zone }} and cz.shift = 'day') OR
                   (cz.metrics_value_numeric > {{ params.client.alteal.night.sup_confort_zone + params.client.alteal.buffer_zone }} and cz.shift = 'night'),
                    'Température supérieure à la zone tampon',
                   IF((cz.metrics_value_numeric < {{ params.client.alteal.day.inf_confort_zone - params.client.alteal.buffer_zone }} and cz.shift = 'day') 
                      OR (cz.metrics_value_numeric < {{ params.client.alteal.night.inf_confort_zone - params.client.alteal.buffer_zone }} and cz.shift = 'night'),
                       'Température inférieure à la zone tampon',
                      IF(cz.metrics_value_numeric >= {{ params.client.alteal.day.inf_confort_zone - params.client.alteal.buffer_zone }} 
                             and cz.metrics_value_numeric < {{ params.client.alteal.day.inf_confort_zone }}
                             and cz.shift = 'day',
                         'Température dans la zone de confort - jour avec tampon de 0.5 degré',
                         IF(cz.metrics_value_numeric >= {{ params.client.alteal.day.sup_confort_zone }} 
                                and cz.metrics_value_numeric < {{ params.client.alteal.day.sup_confort_zone + params.client.alteal.buffer_zone}}
                                and cz.shift = 'day',
                            'Température dans la zone de confort - jour avec tampon de 0.5 degré',
                            IF(cz.metrics_value_numeric >= {{ params.client.alteal.night.inf_confort_zone - params.client.alteal.buffer_zone }} 
                                    and cz.metrics_value_numeric < {{ params.client.alteal.night.inf_confort_zone }}
                                    and cz.shift = 'night',
                               'Température dans la zone de confort - nuit avec tampon de 0.5 degré',
                               IF(cz.metrics_value_numeric >= {{ params.client.alteal.night.sup_confort_zone }} 
                                    and cz.metrics_value_numeric <= {{ params.client.alteal.night.sup_confort_zone + params.client.alteal.buffer_zone}}
                                    and cz.shift = 'night',
                                  'Température dans la zone de confort - nuit avec tampon de 0.5 degré',
                                  'N/A'
                                   )
                                )
                             )
                          )
                       )
                    )
                 )
        ) as confort_type,
      cz.shift as shift,
      cz.etage as etage,
      cz.orientation as orientation,
      cz.typologie as typologie,
      replaceAll(
        replaceAll(
          replaceAll(
            toString(parent_info.parent_list),
            '[',
            ''
          ),
          ']',
          ''
        ),
        '''',
        ''
      ) as parent_list
    FROM
      compute_time_spent cz
    left join parent_info on cz.group_id = parent_info.group_id
    left join batiment_multi bat ON cz.group_id = bat.descendants
    SETTINGS distributed_product_mode = 'global';
Collapse

