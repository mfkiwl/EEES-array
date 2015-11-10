#!/usr/bin/env python
import sys, os
from optparse import OptionParser
from optparse import OptionGroup
import imp
import inspect

#some simple helper functions, useful to have in template
def imm1(value):
    return value>>8

def imm2(value):
    return value&0xFF

#driver option parser
def parse_options():
    parser = OptionParser("Usage: %prog [options] -i InputFile -o OutputFile arch_conf.json")

    # Input/Output options
    parser.add_option("-i", dest="in_file", help='Input File')
    parser.add_option("-o", dest="out_file", help='Output File')
    parser.add_option("--import", dest='importable', help='Sepcify a python file of which the variables and fuctions will be made available in the template')

     # Tool options
    tool_opts = OptionGroup(parser, "Tool Options")
    tool_opts.add_option("--solver-prefix", dest="solver_prefix",
                         help="Specify installation path to Solver toolchain"\
                             " (default=$SOLVER_HOME)")
    tool_opts.add_option("--solver-py-path", dest="solver_py_path",
                         help="Specify path to Solver Python modules"\
                             " (default=$SOLVER_HOME/lib/solver/python)")

    # Parse
    parser.add_option_group(tool_opts)
    opts, args = parser.parse_args()

    # Defaults
    if not opts.in_file:
        print >>sys.stderr, '%s: no input file specified'%sys.argv[0]
        exit(-1)
    if not opts.out_file:
        opts.out_file=opts.in_file+".asm"
    if not opts.solver_prefix:
        opts.solver_prefix = os.path.abspath(
            os.path.join(os.path.dirname(__file__), '..'))
    if not opts.solver_py_path:
        opts.solver_py_path\
            = os.path.join(opts.solver_prefix, 'lib', 'solver', 'python')

    return (opts, args)


if __name__ == '__main__':

    (opts, args) = parse_options()

    if (len(args)<1):
        print >>sys.stderr, '%s: no configuration file'%sys.argv[0]
        exit(-1)

    if (len(args) > 1):
		print >>sys.stderr, '%s: too many configuration files'%sys.argv[0]
		exit(-1)

    #fix python path
    opts.solver_py_path = os.path.abspath(os.path.expanduser(opts.solver_py_path))
    if opts.solver_py_path not in sys.path: sys.path.append(opts.solver_py_path)
    
    #import config and basic template functionality
    from arch_config.arch_config import read_arch_config
    from utils.template_utils import render_template

    #read the configuration
    cfg= read_arch_config(args[0])

    #import some helper functions which are usefull to have available in the template
    from math import ceil, floor
    from utils.datasection_utils import genDataSection, genRandomDataSection

    #import any user defined vars, functions etc. here
    user_params={}
    if opts.importable:
        if os.path.isfile(os.path.abspath(opts.importable)):
            user_import=imp.load_source('', os.path.abspath(opts.importable))
            for item in inspect.getmembers(user_import):
                if item[0][0:2] != '__':
                    user_params[item[0]]=item[1]
        else:
            print >>sys.stderr, 'WARNING: %s: unable to locate %s, ignoring!'%(sys.argv[0],opts.importable)
       

    with open(opts.out_file, 'wt') as fp:
        fp.write(render_template(opts.in_file, 
                cfg=cfg, 
                dataSection=genDataSection, 
                randomDataSection=genRandomDataSection, 
                pow=pow, 
                ceil=ceil, 
                floor=floor, 
                int=int, 
                float=float, 
                imm1=imm1, 
                imm2=imm2, 
                **user_params))
