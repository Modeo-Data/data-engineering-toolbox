import jinja2 
import yaml
from yaml.loader import SafeLoader


def load_context(file_name: str)->dict:
    with open(file_name) as f:
        data = yaml.load(f, Loader=SafeLoader)
    return data


def get_template(folder: str, file_name: str, jinja_context: dict) -> str:
    """get templates for jinja a    
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



if __name__=="__main__":
    jinja_context = load_context('config.yaml')
    print(get_template("templates", "test.sql", jinja_context))