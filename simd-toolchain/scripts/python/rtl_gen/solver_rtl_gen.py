import os
import sys
import stat
import shutil
import utils
import json
from utils.template_utils import render_template
from rtl_tools import rc_synthesis
VERBOSE = False

_rtl_sim_driver='''#!/bin/env python
import os, sys, subprocess
from optparse import OptionParser
import zipfile
import tempfile
import shutil

d = '%s'
if d not in sys.path: sys.path.append(d)
from simulation.solver_rtl_sim import *
from arch_config.arch_config import read_arch_config

def read_config_bin_ar(bin_ar):
    conf=None
    try:
        RB_WD = tempfile.mkdtemp()
        zfd = zipfile.ZipFile(bin_ar, 'r')
        zfd.extractall(RB_WD)
        cfg, stab, arch_config = None, None, None
        for r,_,fl in os.walk(RB_WD):
            for f in fl:
                if f.endswith('.json'):
                    if cfg: raise RuntimeError('Too many CFG files in Binary Archive')
                    cfg = os.path.join(r, f)
        if cfg: 
            conf=read_arch_config(cfg)
    finally:
        if RB_WD: shutil.rmtree(RB_WD)
    return conf

if __name__ == '__main__':
    #get top-level RTL dir
    RTL_dir=os.path.split(os.path.split(os.path.realpath(__file__))[0])[0]

    parser = OptionParser('Usage: %%prog [options] application')
    parser.add_option("--verbose", action="store_true", help="Run verbose mode")
    parser.add_option("-o", dest="sim_out", default='rtl-sim-out',
                      help="Output directory (default=rtl-sim-out)")
    parser.add_option('--rtl-flow', help='tool for RTL simulation (def=vsim)',
                      dest='rtl_flow', default='vsim')
    parser.add_option('--rtl-dir', help='Folder containing the generated RTL',
                      dest='rtl_dir', default=RTL_dir)
    parser.add_option('--gui', help='Simulate with GUI',
                      dest='gui', action='store_true')
    (opts, args) = parser.parse_args()
    
    if len(args) <1:
        print 'No archive specified'
        exit(-1)
    if len(args) >1:
        print 'Too many archives specified'
        exit(-1)
    bin_ar=args[0]


    VERBOSE = opts.verbose
    sim_out = os.path.abspath(opts.sim_out)
    sim_wd = rtl_path = opts.rtl_dir
    flow=opts.rtl_flow
    
    cfg=read_config_bin_ar(bin_ar)

    sim_cc, sim_exe = sim_utils.get_rtl_tools(flow)

    # Check if it is necessary to compile the simulation libraries
    check_and_compile_solver_rtl(rtl_path, sim_wd, flow, sim_cc)

    clean_solver_rtl_simulation(sim_wd)
    app_name = sys_utils.get_path_basename(bin_ar)
    setup_solver_mem_files(bin_ar, sim_wd)
    
    # Run the actual simulation
    run_solver_rtl_simulation(sim_exe, sim_wd, flow, rtl_path, cfg, gui=opts.gui)
    
    #move files to output
    move_dump_files(sim_wd, sim_out)
'''


_rc_synth_driver = '''#!/bin/env python
import os, sys, shutil, json, subprocess, tempfile, glob, collections, multiprocessing
from optparse import OptionParser

d = '%s'
if d not in sys.path: sys.path.append(d)
from rtl_tools import rc_synthesis

if d not in sys.path: sys.path.append(d)
from rtl_tools import rc_synthesis
from utils import sys_utils
from simulation.solver_rtl_sim import setup_solver_mem_files

AppConfig = collections.namedtuple(
    'AppConfig', ['binary', 'run_dir', 'design', 'tcsh_rc','verbose'])

def_synth=os.path.join(os.path.abspath(os.path.dirname(__file__)), 'synth.json')
VERBOSE = False
KEEP    = False

def _get_run_name(design, clk_period, clk_gating):
    return '{0}-{1}{2}-rc-run'.format(
        design.synth_module, clk_period, '-cg' if clk_gating else'')

def estimate_application_power(app_config):
    bin_ar = os.path.abspath(app_config.binary)
    app_name = sys_utils.get_path_basename(bin_ar)
    if VERBOSE: print('Processing {0} ({1})'.format(app_name, bin_ar))
    app_dir = os.path.join(app_config.run_dir, 'sim', app_name)
    cds_lib = os.path.join(app_config.run_dir, 'cds.lib')
    sys_utils.mkdir_p(app_dir)
    cwd = os.getcwd()
    os.chdir(app_dir)
    try:
        if VERBOSE: print('-- [%%s] Running post-synthesis simulation'%%app_name)
        setup_solver_mem_files(bin_ar, app_dir)
        rc_synthesis.run_post_synth_sim(
            app_config.design.sim_module, app_config.tcsh_rc,
            app_dir, app_config.run_dir, cds_lib)
        for f in glob.glob(os.path.join(app_dir, 'nc*.log')):os.remove(f)
        if VERBOSE: print('-- [%%s] Estimating power with RC'%%app_name)
        rc_synthesis.run_rc_power_analysis(
            app_config.tcsh_rc, app_dir, app_config.run_dir)
        for f in glob.glob(os.path.join(app_dir, 'rc.log*')):os.remove(f)
        for f in glob.glob(os.path.join(app_dir, 'rc.cmd*')):os.remove(f)
    finally: os.chdir(cwd)

if __name__ == '__main__':
    parser = OptionParser('Usage: %%prog [options] [application list]')
    parser.add_option("--verbose", action="store_true", help="Run verbose mode")
    parser.add_option("--keep", action="store_true", help='Keep temp files')
    parser.add_option("--parallel", action="store_true", help='Run in parallel')
    parser.add_option("--rerun", action="store_true", help='Rerun everything')
    parser.add_option("--no-clk-gating", action="store_false",
                      dest='clk_gating', default=True, help='Keep temp files')
    parser.add_option("--clk-period", type="int", default=10000,
                        help="Clock period in ps")
    parser.add_option("--effort",choices=['low','medium','high'],default='high',
                      help='Synthesis effort level (default=high)')
    parser.add_option("--synth", default=def_synth,
                      help='Design synthesis configurations')
    parser.add_option("-o", dest="out_dir", default='synth-out',
                      help="Output directory (default=synth-out)")
    parser.add_option("--synth-lib", help="Override synthesis library option")
    (opts, args) = parser.parse_args()
    VERBOSE, KEEP = opts.verbose, opts.keep
    opts.out_dir = os.path.abspath(opts.out_dir)
    with open(opts.synth) as f: synth = json.load(f)
    design = rc_synthesis.RTLDesign(**synth['design'])
    tech_lib = json.load(opts.synth_lib) if opts.synth_lib \
        else rc_synthesis.TechLib(**synth['tech_lib'])

    sys_utils.mkdir_p(opts.out_dir)
    rc_run_dir = os.path.join(
        opts.out_dir,
        _get_run_name(design, opts.clk_period, opts.clk_gating))
    sys_utils.mkdir_p(rc_run_dir)
    rc_synthesis.generate_rc_scripts(design, tech_lib, opts.clk_period,
                                     opts.clk_gating, opts.effort, rc_run_dir)
    tcsh_rc = '/home/eda/share/cadence_cds_2012_lnx.csh'
    rc_synthesis.check_and_synthesis(
        design, rc_run_dir, tcsh_rc, opts.rerun, VERBOSE)
    if opts.parallel:
        app_cfg = [AppConfig(binary=b, run_dir=rc_run_dir, design=design,
                             tcsh_rc=tcsh_rc, verbose=VERBOSE) for b in args]
        pool = multiprocessing.Pool(processes=multiprocessing.cpu_count(),
                                    initializer=os.nice, initargs=[1])
        pool.map(estimate_application_power, app_cfg)
    else:
        for bin_ar in args:
            estimate_application_power(
                AppConfig(binary=bin_ar, run_dir=rc_run_dir,
                          design=design, tcsh_rc=tcsh_rc, verbose=VERBOSE))
'''

def process_template_dir(d, suffix, out_path, cfg, target, **kargs):
    f_list = []
    for r, d, fl in os.walk(d):
        for f in fl:
            if f.endswith(suffix):
                tp = os.path.join(r, f)
                op = os.path.join(out_path, f)
                if VERBOSE: print('-- Processing %s'%tp)
                ostr = render_template(tp, cfg=cfg, target=target,
                                           kargs=kargs)
                if len(ostr.strip()) > 0:
                    with open(op, 'w') as of:
                        of.write(ostr)
                        f_list.append(f)
    return f_list

def generate_vsim_compile_script(top, lib='work'):
    do_str = '''if [file exists %s] {
    vdel -all
}

vlib %s

'''%(lib, lib)

    rtl_path = os.path.join(top, 'verilog')
    tb_path  = os.path.join(top, 'testbench')
    def_path = os.path.join(top, 'define')
    for r, d, fl in os.walk(rtl_path):
        for f in fl:
            do_str += 'vlog -quiet +incdir+%s %s\n'%(def_path,os.path.join(r,f))
    for r, d, fl in os.walk(tb_path):
        for f in fl:
            do_str += 'vlog -quiet +incdir+%s %s\n'%(def_path,os.path.join(r,f))
    return do_str + 'quit\n'

def generate_vsim_run_script(top, tb_module='simd_top_testbench', lib='work'):
    do_str = '''onbreak {resume}

if { [file exists %s]  == 0 } {
    puts stderr "Library \\\"%s\\\" not found, please run compilation first."
    exit -code 1
}

if { [file exists cp.imem_init]  == 0 } {
    puts stderr "Cannot find cp.imem_init, aborting."
    exit -code 1
}

vsim -quiet -nostdout -novopt %s.%s

run -all
run -all
quit
'''%(lib, lib, lib, tb_module)
    return do_str

def generate_file_list(top, tb_module='simd_top_testbench', lib='work'):
    fl_str = ''

    rtl_path = os.path.join(top, 'verilog')
    tb_path  = os.path.join(top, 'testbench')
    for r, d, fl in os.walk(rtl_path):
        for f in fl: fl_str += '%s\n'%os.path.join(r,f)
    for r, d, fl in os.walk(tb_path):
        for f in fl:
            fl_str += '%s\n'%os.path.join(r,f)
    return fl_str

def generate_rtl_package(
    cfg, out_dir, rtl_path, tb_path, def_path, target='generic',
    tb_module='simd_top_testbench', lib='work', asic_lib_cfg=None,
    synth_module='core_top',
    core_path='simd_top_testbench.inst_simd_top.inst_core_top'):
    """
    Use configuration cfg to generate a complete Solver RTL package in out_dir.
    The output package contains:
    def/
        Folder containing the definition files for RTL and testbench.
    verilog/
        Folder containing the Verilog source files.
    testbench/
        Folder containing the testbench files.

    Keyword arguments:
    cfg      -- A valid Solver configuration object
    out_dir  -- Path to the output directory
    rtl_path -- A list of paths to the RTL source files. Every .v file under
                the specified paths is treated as a RTL source template file.
    tb_path  -- A list of paths to the testbench files. Every .v file under
                the specified paths is treated as a testbench template file.
    def_path -- A list of paths to the definition files. Every .v file under
                the specified paths is treated as a definition template file.
    """
    global VERBOSE
    if os.path.exists(out_dir) and os.path.isdir(out_dir):
        shutil.rmtree(out_dir)
    utils.sys_utils.mkdir_p(out_dir)
    rtl_p = os.path.join(out_dir, 'verilog')
    tb_p  = os.path.join(out_dir, 'testbench')
    def_p = os.path.join(out_dir, 'define')
    mis_p = os.path.join(out_dir, 'misc')
    utils.sys_utils.mkdir_p(os.path.join(out_dir, 'verilog'))
    utils.sys_utils.mkdir_p(os.path.join(out_dir, 'define'))
    utils.sys_utils.mkdir_p(os.path.join(out_dir, 'testbench'))
    utils.sys_utils.mkdir_p(os.path.join(out_dir, 'misc'))
    if VERBOSE: print('Generating RTL for %s'%cfg.name)
    if VERBOSE: print('Output is written to %s'%out_dir)

    rtl_list = []
    for d in rtl_path: rtl_list += process_template_dir(
        d, '.v', rtl_p, cfg, target)

    tb_list = []
    for d in tb_path: tb_list += process_template_dir(
        d, '.v', tb_p, cfg, target)

    def_list = []
    for d in def_path: def_list += process_template_dir(
        d, '.v', def_p, cfg, target)

    with open(os.path.join(mis_p, 'vsim.compile.do'), 'w') as f:
        if VERBOSE: print('Generating Modelsim compilation script')
        f.write(generate_vsim_compile_script(os.path.abspath(out_dir), lib))
    with open(os.path.join(mis_p, 'vsim.run.do'), 'w') as f:
        if VERBOSE: print('Generating Modelsim simulation script')
        f.write(generate_vsim_run_script(
                os.path.abspath(out_dir),tb_module,lib))
    with open(os.path.join(mis_p, 'rtl-sim'), 'w') as f:
        f.write(_rtl_sim_driver%os.path.abspath(
                os.path.join(os.path.dirname(__file__), '..')))
    os.chmod(os.path.join(mis_p, 'rtl-sim'), stat.S_IRWXU)
    with open(os.path.join(mis_p, 'files.txt'), 'w') as f:
        if VERBOSE: print('Generating RTL file list')
        f.write(generate_file_list(os.path.abspath(out_dir)))
    if not asic_lib_cfg or target != 'generic': return
    # Generate RTL synthesis scripts
    with open(asic_lib_cfg) as f: t_lib = rc_synthesis.TechLib(**json.load(f))
    syn_vlogs = []
    post_sim_tb = [os.path.abspath(os.path.join(tb_p, tb)) for tb in tb_list]
    for fn in rtl_list:
        with open(os.path.join(rtl_p, fn)) as f:
            syn = True
            pragmas = [l.split()[1:] for l in f.readlines()
                       if l.strip().startswith('///:SYNTH:')]
            for p in pragmas:
                if '-asic' in p: syn = False
            if syn: syn_vlogs.append(os.path.abspath(os.path.join(rtl_p, fn)))
            else: post_sim_tb.append(os.path.abspath(os.path.join(rtl_p, fn)))
    design = rc_synthesis.RTLDesign(
        synth_module=synth_module, sim_module=tb_module, tcf_path=core_path,
        hdls=syn_vlogs, testbench=post_sim_tb, hdl_dirs=[os.path.abspath(def_p)])
    enc = utils.json_utils.NamedtupleEncoder()
    synth_cfg = enc.encode({'design':design, 'tech_lib':t_lib})
    with open(os.path.join(mis_p, 'synth.json'), 'w') as f: f.write(synth_cfg)
    with open(os.path.join(mis_p, 'run-rc-synth'), 'w') as f:
        f.write(_rc_synth_driver%os.path.abspath(
                os.path.join(os.path.dirname(__file__), '..')))
    os.chmod(os.path.join(mis_p, 'run-rc-synth'), stat.S_IRWXU)
    

def generate_xil_pcore(cfg, out_dir, rtl_path, def_path, sys_path,
                       target='xilinx', addr_size='1M', sys_type='axilite',
                       ver='v1_00_a'):
    """
    Use configuration cfg to generate a complete Solver RTL package in out_dir.
    The output package contains:
    def/
        Folder containing the definition files for RTL and testbench.
    verilog/
        Folder containing the Verilog source files.
    testbench/
        Folder containing the testbench files.

    Keyword arguments:
    cfg      -- A valid Solver configuration object
    out_dir  -- Path to the output directory
    rtl_path -- A list of paths to the RTL source files. Every .v file under
                the specified paths is treated as a RTL source template file.
    def_path -- A list of paths to the definition files. Every .v file under
                the specified paths is treated as a definition template file.
    sys_path  -- Path to the system wrapper files. Every .v or .vhd
                 file under the specified path is treated as a system HDL file.
    target -- enable optimization in HDL code for specific target
    addr_size -- size of target address space
    sys_type  -- type of the system interface
    """
    global VERBOSE
    ip_name = 'solver_%dpe_'%cfg.pe.size \
        + cfg.get_tgt_attr().lower().replace('-', '_')
    if VERBOSE: print('IP name: %s'%ip_name)
    utils.sys_utils.mkdir_p(out_dir)
    ip_out_dir = os.path.join(out_dir, 'pcores', ip_name+'_'+ver)
    if os.path.exists(ip_out_dir) and os.path.isdir(ip_out_dir):
        shutil.rmtree(ip_out_dir)
    vlog_p  = os.path.join (ip_out_dir,  'hdl', 'verilog')
    vhdl_p   = os.path.join(ip_out_dir, 'hdl', 'vhdl')
    data_p  = os.path.join (ip_out_dir,  'data')
    utils.sys_utils.mkdir_p(vlog_p)
    utils.sys_utils.mkdir_p(vhdl_p)
    utils.sys_utils.mkdir_p(data_p)
    addr_size = utils.sys_utils.parse_size_str(addr_size)
    if addr_size < 1024*1024:
        print('Address space size should be at least 1M')
        addr_size = 1024*1024
    eff_addr_width = len(bin(addr_size-1)) - 2
    if VERBOSE: print('Generating Xilinx pcore for for %s'%cfg.name)
    if VERBOSE: print('IP output is written to %s'%ip_out_dir)

    sys_path = os.path.join(sys_path, 'xil_pcore', sys_type)
    rtl_path.append(sys_path)
    if VERBOSE: print('System wrapper is in %s'%sys_path)
    top_vhdl = os.path.join(sys_path, 'solver.vhd')
    with open(os.path.join(vhdl_p, '%s.vhd'%ip_name), 'w') as of:
        ostr = render_template(top_vhdl, cfg=cfg, target=target,
                               eff_addr_width=eff_addr_width)
        if ostr: of.write(ostr)
        else: raise RuntimeError('No VHDL wrapper found for %s'%ip_name)
    with open(os.path.join(data_p, '%s_v2_1_0.mpd'%ip_name), 'w') as of:
        ostr = render_template(os.path.join(sys_path, 'solver.mpd'),
                                cfg=cfg, eff_addr_width=eff_addr_width)
        if ostr: of.write(ostr)
        else: raise RuntimeError('No MPD found for %s'%ip_name)

    vlog_list = []
    for d in rtl_path: vlog_list += process_template_dir(
        d, '.v', vlog_p, cfg, target, eff_addr_width=eff_addr_width)

    def_list = []
    for d in def_path: def_list += process_template_dir(
        d, '.v', vlog_p, cfg, target)

    with open(os.path.join(data_p, '%s_v2_1_0.pao'%ip_name), 'w') as of:
        with open(os.path.join(sys_path, 'solver.pao')) as pao_base:
            ostr = pao_base.read()
            for v in vlog_list: ostr+='lib %s_%s %s verilog\n'%(ip_name, ver, v)
            ostr += 'lib %s_%s %s.vhd vhdl\n'%(ip_name, ver, ip_name)
        if ostr: of.write(ostr)
        else: raise RuntimeError('No PAO found for %s'%ip_name)

    drv_path = os.path.join(sys_path, 'driver')
    if not os.path.isdir(drv_path): return
    drv_out_dir = os.path.join(out_dir, 'drivers', ip_name+'_'+ver)
    if VERBOSE: print('Generating driver for %s to %s'%(ip_name, drv_out_dir))
    if os.path.exists(drv_out_dir) and os.path.isdir(drv_out_dir):
        shutil.rmtree(drv_out_dir)
    drv_data_p = os.path.join(drv_out_dir, 'data')
    utils.sys_utils.mkdir_p(drv_data_p)
    with open(os.path.join(drv_data_p, '%s_v2_1_0.mdd'%ip_name), 'w') as of:
        ostr = render_template(os.path.join(drv_path, 'solver_device.mdd'),
                               cfg=cfg, eff_addr_width=eff_addr_width)
        if ostr: of.write(ostr)
        else: raise RuntimeError('No MDD found for %s'%ip_name)
    with open(os.path.join(drv_data_p, '%s_v2_1_0.tcl'%ip_name), 'w') as of:
        ostr = render_template(os.path.join(drv_path, 'solver_device.tcl'),
                               cfg=cfg, eff_addr_width=eff_addr_width)
        if ostr: of.write(ostr)
    drv_src_p = os.path.join(drv_out_dir, 'src')
    drv_src_path = os.path.join(drv_path, 'src')
    utils.sys_utils.mkdir_p(drv_src_p)
    if os.path.isdir(drv_src_path):
        process_template_dir(drv_src_path, '.h', drv_src_p, cfg, target)
        process_template_dir(drv_src_path, '.c', drv_src_p, cfg, target)
        with open(os.path.join(drv_src_p, 'Makefile'), 'w') as of:
            ostr=render_template(os.path.join(drv_src_path, 'Makefile'),cfg=cfg)
            if ostr:
                if VERBOSE:
                    print('-- Processing %s'%os.path.join(drv_src_p,'Makefile'))
                of.write(ostr)
            else: raise RuntimeError('No Makefile found for %s'%ip_name)
    else: raise RuntimeError('No driver source file found for %s'%ip_name)
