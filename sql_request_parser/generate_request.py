import jinja2 
import yaml
from yaml.loader import SafeLoader


def generate_request(folder: str, file_name: str, context_config_path: str)-> str:
    """generate sql query from template and context

    Args:
        folder (str): template folder path
        file_name (str): template name
        context_config_path (str): path to the config.yaml

    Returns:
        str: sql query
    """
    jinja_context = _load_context(context_config_path)
    sql = _get_template(folder, file_name, jinja_context)
    print(sql)
    return sql

def _get_template(folder: str, file_name: str, jinja_context: dict) -> str:
    """get templates for jinja 

    Args:
        folder (str): template folder path
        file_name (str): template name
        jinja_context (dict): context dict for jinja 

    Returns:
        str: _description_
    """
    templateLoader = jinja2.FileSystemLoader(searchpath=folder)
    templateEnv = jinja2.Environment(loader=templateLoader)
    template = templateEnv.get_template(file_name)
    template_string = template.render({"params": jinja_context})
    return template_string


def _cast_list_to_tuples(context: dict)-> dict:
    """cast dict values to tuple if they are lists

    Args:
        context (dict): context dict

    Returns:
        dict: context dict with list casted to tuples
    """
    for key, val in context.items():
        if isinstance(val, list):
            context[key] = tuple(val)
        if isinstance(val, dict):
            context[key] = _cast_list_to_tuples(val)
    return context


def _load_context(file_name: str)->dict:
    """loads context from config.yaml

    Args:
        file_name (str): path of the .yaml

    Returns:
        dict: context for jinja
    """
    with open(file_name) as f:
        data = yaml.load(f, Loader=SafeLoader)
    return _cast_list_to_tuples(data)



if __name__=="__main__":
    generate_request("templates", "insert_alteal_payload.sql", "config.yaml")
