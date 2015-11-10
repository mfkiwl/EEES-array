#!/usr/bin/env python
import getopt, os, sys, shutil, subprocess, optparse, tempfile, string, random
import glob
import zipfile
import traceback
from optparse import OptionParser
from optparse import OptionGroup

GEN_WD  = None
VERBOSE = False
CWD     = os.getcwd()

def parse_options():
    parser = OptionParser('Usage: %prog [options] config.json')
    # General options
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose",
                      default=False, help="Run in verbose mode")
    # Output options
    parser.add_option("-o", dest="gen_dir", help='Output path')
    parser.add_option("--target",choices=['generic','xilinx'],default='generic',
                      help='Target platform: generic (default), xilinx')
    parser.add_option("--synth-lib", help='ASIC technology library config file')
    parser.add_option("--xil-pcore", action="store_true", dest="xil_pcore",
                      default=False, help="Generate Xilinx pcore package")
    parser.add_option("--xil-sys-type", dest="xil_sys_type", default="axilite",
                      help="Interface type for Xilinx pcore (default=axilite)")
    parser.add_option("--sys-addr-size", dest="sys_adr_size", default="1M",
                      help="System address space size (default=1M)")

    # Tool options
    tool_opts = OptionGroup(parser, "Tool Options")
    tool_opts.add_option("--solver-prefix", dest="solver_prefix",
                         help="Specify installation path to Solver toolchain"\
                             " (default=$SOLVER_HOME)")
    tool_opts.add_option("--solver-py-path", dest="solver_py_path",
                         help="Specify path to Solver Python modules"\
                             " (default=$SOLVER_HOME/lib/solver/python)")
    tool_opts.add_option("--solver-rtl-root", dest="solver_rtl_root",
                         help="Specify path to Solver RTL root directory"\
                             " (default=$SOLVER_HOME/share/solver/rtl)")

    # Target options
    tgt_opts = OptionGroup(parser, "Target Options")
    parser.add_option_group(tool_opts)
    (opts, args) = parser.parse_args()
    if not opts.solver_prefix:
        opts.solver_prefix = os.path.abspath(
            os.path.join(os.path.dirname(__file__), '..'))
    if not opts.solver_py_path:
        opts.solver_py_path\
            = os.path.join(opts.solver_prefix, 'lib', 'solver', 'python')
    if not opts.solver_rtl_root:
        opts.solver_rtl_root\
            = os.path.join(opts.solver_prefix, 'share', 'solver', 'rtl')
    
    return (opts, args)

if __name__ == '__main__':
    rc = 0
    keep = False
    (opts, args) = parse_options()
    VERBOSE = opts.verbose

    if len(args) < 1:
        print >>sys.stderr, '%s: no configuration file'%sys.argv[0]
        exit(-1)
    if len(args) > 1:
        print >>sys.stderr, '%s: too many configuration files'%sys.argv[0]
        exit(-1)

    opts.solver_py_path = os.path.abspath(os.path.expanduser(opts.solver_py_path))
    opts.solver_rtl_root = os.path.abspath(
        os.path.expanduser(opts.solver_rtl_root))
    if opts.solver_py_path not in sys.path: sys.path.append(opts.solver_py_path)
    from arch_config.arch_config import read_arch_config
    from rtl_gen import solver_rtl_gen

    cfg = read_arch_config(args[0])
    
    tgt_attr = '%db-%dstage'%(cfg.cp.datapath['data_width'],
                              cfg.cp.datapath['pipe_stage'])
    if cfg.cp.datapath['explicit_bypass']: tgt_attr += '-bypass'
    tgt_rtl_root = os.path.join(opts.solver_rtl_root,'core',cfg.name,tgt_attr)

    if not opts.gen_dir:
        opts.gen_dir = os.path.join(
            os.path.abspath(CWD), 'RTL-%s-%s'%(cfg.name, tgt_attr))
    rtl_path = [os.path.join(opts.solver_rtl_root, 'common'),
                os.path.join(opts.solver_rtl_root, 'memory'),
                os.path.join(opts.solver_rtl_root, 'top'), tgt_rtl_root]

    solver_rtl_gen.VERBOSE = VERBOSE
    if opts.xil_pcore:
         solver_rtl_gen.generate_xil_pcore(
             cfg, out_dir=opts.gen_dir, rtl_path=rtl_path, target=opts.target,
             def_path=(os.path.join(opts.solver_rtl_root, 'define'),),
             sys_path=os.path.join(opts.solver_rtl_root, 'system'))
         shutil.copy2(args[0], os.path.join(opts.gen_dir, 'arch.json'))
    else:
        solver_rtl_gen.generate_rtl_package(
            cfg, opts.gen_dir, rtl_path=rtl_path,
            tb_path  = (os.path.join(opts.solver_rtl_root, 'testbench'),),
            def_path = (os.path.join(opts.solver_rtl_root, 'define'),),
            target=opts.target, tb_module='simd_top_testbench', lib='work',
            asic_lib_cfg=opts.synth_lib)
        shutil.copy2(args[0], os.path.join(opts.gen_dir, 'arch.json'))

