import os
import math
from jinja2 import Template
from jinja2 import FileSystemLoader
from jinja2.environment import Environment

def render_template(t, **kargs):
    loader = FileSystemLoader(os.path.dirname(t))
    env = Environment(loader=loader)
    relpath = os.path.relpath(t, os.path.dirname(t))
    tmpl = env.get_template(relpath)
    return tmpl.render(kargs, math=math, max=max, min=min, int=int, float=float)
