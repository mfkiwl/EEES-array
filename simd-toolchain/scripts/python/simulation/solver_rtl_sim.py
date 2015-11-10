import os
import sys
import shutil
import sim_utils
import glob
from solver_program.solver_mem_utils import read_vlog_hexdump
from solver_program.solver_mem_utils import write_vlog_hexdump
from solver_program.solver_mem_utils import extract_mem_init
from utils import sys_utils
from arch_config.arch_config import read_arch_config
from rtl_gen import solver_rtl_gen

VERBOSE = False

def join_pe_dmem_dump(path, num_pe, pat='pe{0}.dmem.dump'):
    d = [read_vlog_hexdump(os.path.join(path, pat.format(i)))
         for i in range(num_pe)]
    join_d = {}
    for k in d[0].keys():
        for i in range(num_pe):
            join_d[k*num_pe + i] = d[i][k] if k in d[i] else None
    return join_d

def compile_vsim_lib(compile_script, run_path, vsim='vsim',
                     stdout=None, stderr=None):
    cs = os.path.abspath(compile_script)
    if not os.access(cs, os.R_OK):
        raise RuntimeError('Invalid compilation script "%s"'%compile_script)
    cwd = os.getcwd()
    sys_utils.mkdir_p(run_path)
    os.chdir(run_path)
    try:
        if sys_utils.run_command('%s -c -do %s'%(vsim, cs),
                                 stdout=stdout, stderr=stderr):
            raise RuntimeError('Cannot compile Modelsim library')
    finally:
        os.chdir(cwd)

def run_vsim(run_script, run_path, vsim='vsim',
             stdout=None, stderr=None, gui=False):
    if not os.path.isdir(run_path):
        raise RuntimeError('Invalid simulation path')
    rs = os.path.abspath(run_script)
    if not os.access(rs, os.R_OK):
        raise RuntimeError('Invalid simulation script "%s"'%run_script)
    cwd = os.getcwd()
    os.chdir(run_path)
    try:
        if gui:
            visible=""
        else:
            visible="-c"
        if sys_utils.run_command('%s %s -do %s'%(vsim, visible, rs),
                                 stdout=stdout, stderr=stderr):
            raise RuntimeError('Modelsim simulation is not successful')
    finally:
        os.chdir(cwd)

def compile_iverilog_lib(filelist, run_path, inc_path, libname='work',
                         ivlog='iverilog',stdout=None, stderr=None):
    fl = os.path.abspath(filelist)
    if not os.access(fl, os.R_OK):
        raise RuntimeError('Invalid file list "%s"'%filelist)

    
    cmd = ivlog + ' -c %s -o %s'%(fl, libname)
    for p in inc_path: cmd += ' -I%s'%os.path.abspath(p)
    cwd = os.getcwd()
    sys_utils.mkdir_p(run_path)
    os.chdir(run_path)
    try:
        if sys_utils.run_command(cmd, stdout=stdout, stderr=stderr):
            raise RuntimeError('Cannot compile Icarus Verilog library')
    finally:
        os.chdir(cwd)

def run_iverilog(run_path, libname='work', vvp='vvp', stdout=None, stderr=None):
    if not os.path.isdir(run_path):
        raise RuntimeError('Invalid simulation path')
    cwd = os.getcwd()
    os.chdir(run_path)
    if not os.access(libname, os.X_OK):
        raise RuntimeError('Invalid simulation module "%s"'%libname)
    try:
        if sys_utils.run_command('%s %s'%(vvp, libname),
                                 stdout=stdout, stderr=stderr):
            raise RuntimeError('Icarus Verilog simulation is not successful')
    finally:
        os.chdir(cwd)

def setup_solver_mem_files(bin_ar, wd):
    """Setup memory initialization files for RTL simulation."""
    sys_utils.remove_p(os.path.join(wd, 'cp.imem_init'))
    sys_utils.remove_p(os.path.join(wd, 'cp.dmem_init'))
    sys_utils.remove_p(os.path.join(wd, 'pe.imem_init'))
    sys_utils.remove_p(os.path.join(wd, 'pe.dmem_init'))
    extract_mem_init(bin_ar, wd)
    for m in os.listdir(wd):
        if not os.path.isfile(os.path.join(wd, m)): continue
        if m.endswith('.cp.imem_init'):
            shutil.move(os.path.join(wd, m),
                        os.path.join(wd, 'cp.imem_init'))
        elif m.endswith('.cp.dmem_init'):
            shutil.move(os.path.join(wd, m),
                        os.path.join(wd, 'cp.dmem_init'))
        elif m.endswith('.pe.imem_init'):
            shutil.move(os.path.join(wd, m),
                        os.path.join(wd, 'pe.imem_init'))
        elif m.endswith('.pe.dmem_init'):
            shutil.move(os.path.join(wd, m),
                        os.path.join(wd, 'pe.dmem_init'))
    if not os.path.isfile(os.path.join(wd, 'cp.dmem_init')):
        with open(os.path.join(wd, 'cp.dmem_init'),'w') as f: f.write('@0\n0')
    if not os.path.isfile(os.path.join(wd, 'pe.imem_init')):
        with open(os.path.join(wd, 'pe.imem_init'),'w') as f: f.write('@0\n0')
    if not os.path.isfile(os.path.join(wd, 'pe.dmem_init')):
        with open(os.path.join(wd, 'pe.dmem_init'),'w') as f: f.write('@0\n0')

def check_and_compile_solver_rtl(rtl_dir, sim_wd, flow, sim_cc,
                                 stdout=None, stderr=None):
    if flow == 'vsim':
        if not os.path.isdir(os.path.join(sim_wd, 'work')):
            if VERBOSE: print('Compiling Modelsim simulation libraries')
            compile_vsim_lib(os.path.join(rtl_dir,'misc','vsim.compile.do'),
                             sim_wd, vsim=sim_cc, stdout=stdout, stderr=stderr)
    elif flow == 'iverilog':
        if not os.path.isfile(os.path.join(sim_wd, 'work')):
            if VERBOSE: print('Compiling for Icarus Verilog simulation')
            compile_iverilog_lib(
                os.path.join(rtl_dir,'misc','files.txt'), sim_wd,
                (os.path.join(rtl_dir, 'define'),),
                libname='work', ivlog=sim_cc, stdout=stdout, stderr=stderr)
    else: raise RuntimeError('Unknown RTL flow "%s"'%flow)

def clean_solver_rtl_simulation(sim_wd):
    for f in os.listdir(sim_wd):
        fp = os.path.join(sim_wd, f)
        if not os.path.isfile(fp): continue
        if f.endswith('mem_init') or f.endswith('.dump') or f.endswith('.log'):
            os.remove(fp)

def run_solver_rtl_simulation(sim_exe, sim_wd, flow, rtl_dir, cfg,
                              stdout=None, stderr=None, gui=False):
    if flow == 'vsim':
        if VERBOSE: print('Running RTL simulation with Modelsim')
        run_vsim(os.path.join(rtl_dir,'misc','vsim.run.do'),
                 sim_wd, vsim=sim_exe, stdout=stdout, stderr=stderr, gui=gui)
    elif flow == 'iverilog':
        if VERBOSE: print('Running RTL simulation with Icarus Verilog')
        run_iverilog(sim_wd, libname='work', vvp=sim_exe,
                     stdout=stdout, stderr=stderr)
    if cfg.pe.size > 0:
        write_vlog_hexdump(
            join_pe_dmem_dump(sim_wd, cfg.pe.size),
            cfg.pe.datapath['data_width']/4,
            os.path.join(sim_wd, 'pe-array.dmem.dump'))

def get_target_out_dir(tgt_str, tgt_md5, p):
    d = os.path.join(p, '%s-%s'%(tgt_str, tgt_md5))
    succ = False
    cnt = 0
    while not succ:
        sys_utils.mkdir_p(d)
        tgt_sig = os.path.join(d, 'arch.sig')
        if os.path.isfile(tgt_sig):
            with open(tgt_sig) as f: sig = f.read()
            if tgt_md5 == sig: succ = True
            else:
                d = os.path.join(p, '%s-%d'%(tgt_str, cnt))
                cnt += 1
        else:
            with open(tgt_sig, 'w') as f: f.write(tgt_md5)
            succ = True
    return d

def move_dump_files(sim_wd, out_dir):
    sys_utils.mkdir_p(out_dir)
    for f in os.listdir(out_dir):
        fp = os.path.join(out_dir,f)
        if os.path.isfile(fp) and f.endswith('.dump'): os.remove(fp)
    for f in os.listdir(sim_wd):
        fp = os.path.join(sim_wd,f)
        if os.path.isfile(fp) and f.endswith('.dump'): shutil.move(fp, out_dir)

def solver_rtl_implemented(arch_config, run_root, flow):
    tgt_md5 = sys_utils.md5_file(arch_config)
    cfg = read_arch_config(arch_config)
    tgt_sig = cfg.get_tgt_sig()
    t_wd = os.path.join(os.path.abspath(run_root), '%s-%s'%(tgt_sig, tgt_md5))
    lib_path = os.path.join(t_wd, 'hw-libs')
    sim_wd = os.path.join(lib_path, '%s_wd'%flow)
    if not os.path.isdir(lib_path): return False
    if flow == 'vsim' and not os.path.isdir(os.path.join(sim_wd, 'work')):
        return False
    elif flow == 'iverilog' and not os.path.isfile(os.path.join(sim_wd,'work')):
        return False
    return True

def compile_all_cores(cfg_dir, rtl_root, run_root, target='generic',
                      flow='vsim', stdout=None, stderr=None):
    sim_cc, sim_exe = sim_utils.get_rtl_tools(flow)
    for root, d, files in os.walk(cfg_dir):
        for f in files:
            if not f.endswith('.json'): continue
            arch_cfg = os.path.join(root, f)
            cfg = read_arch_config(arch_cfg)
            tgt_root = os.path.join(rtl_root,'core',cfg.name,cfg.get_tgt_attr())
            if not os.path.isdir(tgt_root): continue
            arch_md5 = sys_utils.md5_file(arch_cfg)
            rtl_path = (os.path.join(rtl_root, 'common'),
                        os.path.join(rtl_root, 'memory'),
                        os.path.join(rtl_root, 'top'), tgt_root)
            t_wd = get_target_out_dir(cfg.get_tgt_sig(), arch_md5, run_root)
            lib_path = os.path.join(t_wd, 'hw-libs')
            solver_rtl_gen.generate_rtl_package(
                cfg, lib_path, rtl_path=rtl_path,
                tb_path  = (os.path.join(rtl_root, 'testbench'),),
                def_path = (os.path.join(rtl_root, 'define'),),
                target=target, tb_module='simd_top_testbench', lib='work')
            sim_wd = os.path.join(lib_path, '%s_wd'%flow)
            # Check if it is necessary to compile the simulation libraries
            check_and_compile_solver_rtl(lib_path, sim_wd, flow, sim_cc,
                                         stdout=stdout, stderr=stderr)

def run_solver_bin_ar(bin_ar, arch_config, rtl_root, run_root, sim_out=None,
                      target='generic', flow='vsim', stdout=None, stderr=None):
    global VERBOSE
    if not os.access(arch_config, os.R_OK):
        raise RuntimeError('Invalid architecture config "%s"'%arch_config)

    arch_md5 = sys_utils.md5_file(arch_config)
    cfg = read_arch_config(arch_config)
    tgt_sig = cfg.get_tgt_sig()
    sim_cc, sim_exe = sim_utils.get_rtl_tools(flow)

    sys_utils.mkdir_p(os.path.abspath(run_root))
    t_wd = get_target_out_dir(cfg.get_tgt_sig(), arch_md5, run_root)
    lib_path = os.path.join(t_wd, 'hw-libs')
    # If RTL folder does not exist, generate it from config file
    if not os.path.isdir(lib_path):
        tgt_rtl_root = os.path.join(rtl_root,'core',cfg.name,cfg.get_tgt_attr())
        rtl_path = (os.path.join(rtl_root, 'common'),
                    os.path.join(rtl_root, 'memory'),
                    os.path.join(rtl_root, 'top'), tgt_rtl_root)
        solver_rtl_gen.generate_rtl_package(
            cfg, lib_path, rtl_path=rtl_path,
            tb_path  = (os.path.join(rtl_root, 'testbench'),),
            def_path = (os.path.join(rtl_root, 'define'),),
            target=target, tb_module='simd_top_testbench', lib='work')
    sim_wd = os.path.join(lib_path, '%s_wd'%flow)
    # Check if it is necessary to compile the simulation libraries
    check_and_compile_solver_rtl(lib_path, sim_wd, flow, sim_cc,
                                 stdout=stdout, stderr=stderr)
    # Setup application files
    clean_solver_rtl_simulation(sim_wd)
    app_name = sys_utils.get_path_basename(bin_ar)
    setup_solver_mem_files(bin_ar, sim_wd)
    # Run the actual simulation
    run_solver_rtl_simulation(sim_exe, sim_wd, flow, lib_path, cfg,
                              stdout=stdout, stderr=stderr, gui=False)
    if not sim_out: sim_out = os.path.join(t_wd, 'sim-out', app_name)
    move_dump_files(sim_wd, sim_out)
