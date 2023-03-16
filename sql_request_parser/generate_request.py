import jinja2 
import yaml
from yaml.loader import SafeLoader


def generate_request(folder: str, file_name: str, context_config_path: str)-> str:
    """get templates for jinja 
    Parameters
    ----------
    folder : str
        template folder
    file_name : str
        template file
    context_config_path : str
        config.yaml to load the jinja context from
    Returns
    -------
    str
        Returns template string
    """
    jinja_context = _load_context(context_config_path)
    sql = _get_template(folder, file_name, jinja_context)
    print(sql)
    return sql

def _get_template(folder: str, file_name: str, jinja_context: dict) -> str:
    """get templates for jinja 
    Parameters
    ----------
    folder : str
        template folder
    file_name : str
        template file
    jinja_context : dict
        Jinja context
    Returns
    -------
    str
        Returns template string
    """
    templateLoader = jinja2.FileSystemLoader(searchpath=folder)
    templateEnv = jinja2.Environment(loader=templateLoader)
    template = templateEnv.get_template(file_name)
    template_string = template.render({"params": jinja_context})
    return template_string


def _cast_list_to_tuples(context: dict)-> dict:
    """cast dict values to tuple if they are lists
    Parameters
    ----------
    context : dict
    Returns
    -------
    dict
        Returns the input dict modified
    """
    for key, val in context.items():
        if isinstance(val, list):
            context[key] = tuple(val)
        if isinstance(val, dict):
            context[key] = _cast_list_to_tuples(val)
    return context


def _load_context(file_name: str)->dict:
    """loads context from config.yaml
    Parameters
    ----------
    file_name : str
         path of the config.yaml
    Returns
    ----------
    dict
        context dict
    """
    with open(file_name) as f:
        data = yaml.load(f, Loader=SafeLoader)
    return _cast_list_to_tuples(data)



if __name__=="__main__":
    generate_request("templates", "insert_alteal_payload.sql", "config.yaml")