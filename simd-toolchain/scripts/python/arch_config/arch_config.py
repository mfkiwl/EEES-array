import os, sys
import json
from solver_baseline import *

def read_arch_config(cfg_filename):
    with open(cfg_filename) as f: cfg = json.load(f)
    if 'arch' not in cfg:
        raise ValueError('Invalid config: no architecture name specified')
    arch = cfg['arch']
    if arch == 'baseline': return Baseline(cfg)
    else: raise ValueError('Unknown architecture "%s"'%arch)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: arch_config.py <config_file>')
        exit(-1)
    a = read_arch_config(sys.argv[1])
    print a
