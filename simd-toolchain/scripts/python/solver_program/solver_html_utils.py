import os, sys
import shutil
from utils.template_utils import *
from utils import sys_utils
import solver_json_utils

def generate_solver_program_html(info_fpath, template_dir, out_dir,
                                 p_name=None):
    if not p_name: p_name = sys_utils.get_path_basename(info_fpath)
    p_info = solver_json_utils.read_solver_json_info(info_fpath)

    template_dir = os.path.abspath(template_dir)
    out_dir = os.path.abspath(out_dir)
    sys_utils.mkdir_p(out_dir)
    sys_utils.copy_if_newer(os.path.join(template_dir, 'css'),    out_dir)
    sys_utils.copy_if_newer(os.path.join(template_dir, 'js'),     out_dir)
    sys_utils.copy_if_newer(os.path.join(template_dir, 'images'), out_dir)

    funcs = sorted(p_info['functions'].items(), key= lambda x: x[1]['address'])
    dobjs = sorted(p_info['data_objects'].items(),
                   key= lambda x: x[1]['address'])
    homepage = render_template(os.path.join(template_dir, 'index.html'),
                               program_name=p_name, program=p_info, funcs=funcs,
                               dobjs=dobjs)
    with open(os.path.join(out_dir, 'index.html'), 'w') as f: f.write(homepage)
    for f in funcs:
        funcpage = render_template(os.path.join(template_dir, 'func.html'),
                                   func=f[1], funcs=funcs)
        with open(os.path.join(out_dir, 'func_%s.html'%f[1]['name']), 'w') as f:
            f.write(funcpage)
        
