#!/usr/bin/env python
import getopt, os, sys, shutil, subprocess, optparse, tempfile, string, random
import glob
import zipfile
import traceback
from optparse import OptionParser
from optparse import OptionGroup

SIM_WD    = None
VERBOSE   = False
CWD       = os.getcwd()

class SimDrvError(Exception):
    def __init__(self, desc):
        self.desc = desc
    def __str__(self):
        return str(self.desc)

def get_cwd_path(p):
    if os.path.isabs(p): return p
    return os.path.abspath(os.path.join(CWD, p))

def find_exe_path(exe_name, preset_path):
    nbin = os.path.join(preset_path, exe_name)
    return nbin if os.path.isfile(nbin) and os.access(nbin, os.X_OK) else None

def find_tools(opts):
    s_sim_bin   = find_exe_path('s-sim', opts.solver_path)
    return (s_sim_bin, )

def generate_id(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for x in range(size))

def run_simulation(opts, bin_ar, tools):
    global SIM_WD
    SIM_WD = tempfile.mkdtemp()
    s_sim_bin = tools[0]
    if not os.access(bin_ar, os.R_OK):
        raise SimDrvError('Cannot open binary archive %s'%bin_ar)
    try:
        if VERBOSE: print('Reading binary archive %s'%bin_ar)
        zfd = zipfile.ZipFile(bin_ar, 'r')
        zfd.extractall(SIM_WD)
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
        traceback.print_tb(sys.exc_info()[2])
        raise SimDrvError('failed to open binary archive %s'%bin_ar)
    finally:
        if zfd: zfd.close()

    bin_dir = os.listdir(SIM_WD)[0]
    arch_cfg = None
    arch_opt = ''
    cp_imem = []
    pe_imem = []
    cp_dmem = []
    pe_dmem = []
    prog    = None
    for root, d, files in os.walk(SIM_WD):
        for f in files:
            if f == 'asm.s': shutil.copy(os.path.join(root, f), 'asm.s')
            if f == 'arch.json':
                arch_cfg = os.path.join(root, f)
                shutil.copy(arch_cfg, 'arch.json')
            if f == 'arch.opt':
                arch_opt = open(os.path.join(root, f)).read()
                shutil.copy(os.path.join(root, f), 'arch.opt')
            if f == 'stat.txt':
                shutil.copy(os.path.join(root, f), 'codegen.stat.txt')
            if f.endswith('.cfg') or f.endswith('.stab'):
                shutil.copy(os.path.join(root, f), f)
                if f.endswith('.stab'): prog = read_solver_stab(f)
            if f.endswith('cp.imem_init'): cp_imem.append(os.path.join(root, f))
            if f.endswith('cp.dmem_init'): cp_dmem.append(os.path.join(root, f))
            if f.endswith('pe.imem_init'): pe_imem.append(os.path.join(root, f))
            if f.endswith('pe.dmem_init'): pe_dmem.append(os.path.join(root, f))
    sim_opt = arch_opt
    if VERBOSE:            sim_opt += ' -verbose'
    if opts.max_cycle > 0: sim_opt += ' -max-cycle %d'%opts.max_cycle
    if opts.full_trace:    sim_opt += ' -trace-level=full'
    elif opts.br_trace:    sim_opt += ' -trace-level=branch'
    if opts.sim_stat:      sim_opt += ' -print-stat'
    if opts.ddump:
        os.mkdir('dump')
        sim_opt += ' -dump-dmem -dump-dmem-prefix %s'%os.path.join(
            'dump', opts.ddump_prefix)
    if arch_cfg: sim_opt += ' -arch-cfg %s'%arch_cfg
    for f in cp_imem: sim_opt += ' -imem 0:cp:%s'%f
    for f in pe_imem: sim_opt += ' -imem 0:pe:%s'%f
    for f in cp_dmem: sim_opt += ' -dmem 0:cp:%s'%f
    for f in pe_dmem: sim_opt += ' -dmem 0:pe:%s'%f
    for f in opts.cp_dbin:
        s = f.split(':')
        if len(s) != 2: raise ValueError('Invalid binary init "%s"'%f)
        bp = get_cwd_path(s[1])
        if prog and prog.has_data_object(s[0]):
            if VERBOSE: print('Initialization %s with %s'%(s[0], bp))
            sim_opt+=' -dbin 0:cp:%d:%s'%(
                prog.get_data_object(s[0])["start"],bp)
        else: sim_opt += ' -dbin 0:cp:%s:%s'%(s[0], bp)
    for f in opts.pe_dbin:
        s = f.split(':')
        if len(s) != 2: raise ValueError('Invalid binary init "%s"'%f)
        bp = get_cwd_path(s[1])
        if prog and prog.has_data_object(s[0]):
            if VERBOSE: print('Initialization %s with %s'%(s[0], bp))
            sim_opt+=' -dbin 0:pe:%d:%s'%(
                prog.get_data_object(s[0])["start"], bp)
        else: sim_opt += ' -dbin 0:pe:%s:%s'%(s[0], bp)

    if VERBOSE: print('Start running s-sim with arguments: %s'%sim_opt)
    cm = [s_sim_bin,] + sim_opt.split()
    rc = -1
    simlog = tempfile.TemporaryFile()
    try:
        sp = subprocess.Popen(cm, stdout=simlog)
        rc = sp.wait()
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
        traceback.print_tb(sys.exc_info()[2])
    finally:
        simlog.seek(0)
        log_lns = simlog.readlines()
        sim_stat = ''
        log_str = ''
        stat_ln = False
        for l in log_lns:
            if stat_ln:
                if l == '>> END Simulation statistics\n': stat_ln = False
                else: sim_stat += l
            elif l == '>> BEGIN Simulation statistics\n':stat_ln = True
            else: log_str += l
        if VERBOSE:
            print('='*80)
            print log_str
            print('='*80)
        if log_str:
            with open('sim.log.txt', 'w') as f: f.write(log_str)
        if sim_stat:
            with open('sim.stat.txt', 'w') as f: f.write(sim_stat)
    return rc


def parse_options():
    parser = OptionParser('Usage: %prog [options] binary_archive')
    # General options
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose",
                      default=False, help="Run in verbose mode")
    # Output options
    parser.add_option("--keep", action="store_true",
                      dest="keep", help='Keep temp files')

    # Message and logging
    parser.add_option("--quiet", action="store_true", dest="quite",
                      default=False, help="Suppress all output")
    parser.add_option("-W", action="append", dest="warn_list",
                      help=optparse.SUPPRESS_HELP)
    # Tool options
    tool_opts = OptionGroup(parser, "Tool Options")
    tool_opts.add_option("--solver-path", dest="solver_path",
                         help="Specify path to Solver toolchain"\
                             " (default=$SOLVER_PATH)")
    tool_opts.add_option("--solver-py-path", dest="solver_py_path",
                         help="Specify path to Solver Python modules"\
                          " (default=${BIN}/../lib/solver/python)")
    tool_opts.add_option("--sim-opt", action="append", dest="sim_opts",
                         help="Specify extra options to s-sim")

    # Simulation options
    sim_opts = OptionGroup(parser, "Simulation Options")
    sim_opts.add_option("--max-cycle", type="int", default=1000000000,
                        help="Maximum simulation cycles")
    sim_opts.add_option("--branch-trace", action="store_true", dest="br_trace",
                        default=False, help="Collect taken branch trace")
    sim_opts.add_option("--full-trace", action="store_true", default=False,
                        help="Collect trace in full detail")
    sim_opts.add_option("--sim-stat", action="store_true", default=False,
                        help="Keep simulation statistics")
    sim_opts.add_option("--dump-dmem", action="store_true", dest="ddump",
                        default=False, help="Dump data memory content")
    sim_opts.add_option("--dump-dmem-prefix", dest="ddump_prefix",
                        help="Prefix of data memory dump files", default='dmem')
    sim_opts.add_option("--sim-dir", help="Simulation directory",
                        default='sim-out')
    sim_opts.add_option("--cp-dbin", action="append", default=[],
                        help="Specify CP data binary file")
    sim_opts.add_option("--pe-dbin", action="append", default=[],
                        help="Specify PE data binary file")
    # Target options
    tgt_opts = OptionGroup(parser, "Target Options")
    tgt_opts.add_option("--arch", dest="arch",
                      help="Specify target name")
    tgt_opts.add_option("--arch-cfg", dest="arch_cfg",
                      help="Specify target specification file")
    tgt_opts.add_option("--arch-param", dest="arch_param",
                      help="Specify target parameters")
    parser.add_option_group(tool_opts)
    parser.add_option_group(sim_opts)
    parser.add_option_group(tgt_opts)
    (opts, args) = parser.parse_args()
    if not opts.solver_path: opts.solver_path = os.path.dirname(__file__)
    if not opts.solver_py_path:
        opts.solver_py_path = os.path.join(
            os.path.dirname(__file__), '..', 'lib', 'solver', 'python')
    opts.solver_path = os.path.abspath(os.path.expanduser(opts.solver_path))
    opts.solver_py_path=os.path.abspath(os.path.expanduser(opts.solver_py_path))
    return (opts, args)

if __name__ == '__main__':
    rc = 0
    keep = False
    (opts, args) = parse_options()
    VERBOSE = opts.verbose
    keep = opts.keep
    if not args:
        print >>sys.stderr, '%s: no input file'%sys.argv[0]
        exit(-1)
    if len(args) > 1:
        print >>sys.stderr, 'Too many input files: there should be only one'
        exit(-1)
    if opts.solver_py_path not in sys.path: sys.path.append(opts.solver_py_path)
    from utils.solver_bin import *
    tools = find_tools(opts)
    if os.path.exists(opts.sim_dir):
        if VERBOSE: print('%s already exists, removing it.'%opts.sim_dir)
        if os.path.isdir(opts.sim_dir): shutil.rmtree(opts.sim_dir)
        elif os.path.isfile(opts.sim_dir): os.remove(opts.sim_dir)
    if VERBOSE: print('Creating %s'%opts.sim_dir)
    os.mkdir(opts.sim_dir)
    bin_ar = os.path.abspath(os.path.expanduser(args[0]))
    os.chdir(opts.sim_dir)
    try:
        rc = run_simulation(opts, bin_ar, tools)
        if keep:
            shutil.copytree(SIM_WD, 'tmp')
    except SimDrvError, errmsg:
        print >>sys.stderr, 'ERROR: %s'%str(errmsg)
        rc = -1
    except exceptions.SystemExit:
        pass
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()
        rc = -1
        raise
    finally:
        if SIM_WD:
            if VERBOSE: print('Removing %s'%SIM_WD)
            shutil.rmtree(SIM_WD)
        os.chdir(CWD)
        exit(rc)
