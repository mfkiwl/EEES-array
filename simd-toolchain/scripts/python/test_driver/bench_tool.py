import os, sys
import subprocess
import time
import json
import glob
from optparse import OptionParser
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from utils.print_color import *
from utils.tab_utils import *
from utils.sys_utils import *
from simulation import *

run_opts = {
    'opt_level' : 3,
    'run_cfg'   : 'run.json',
    'max_cycle' : 10000000
}

VERBOSE = False

def run_app(app_name, app_dir, tools, run_dir, arch_opts='', src_pat='*.c',
            dbin=[]):
    global VERBOSE
    global run_opts
    wd = os.path.join(run_dir, app_name)
    mkdir_p(wd)
    src = glob.glob(os.path.join(app_dir, src_pat))
    cc_cmd  = '%s --cg-stat -O%d %s'%(tools[0],run_opts['opt_level'],arch_opts)
    cc_cmd += ' -o %s'%os.path.join(wd, app_name)
    cc_cmd += ' ' + ' '.join(src)
    app_bin = '%s.zip'%os.path.join(wd, app_name)
    if VERBOSE: print('Compiling %s, command="%s"'%(app_name, cc_cmd))
    try:
        sp = subprocess.Popen(cc_cmd.split())
        rc = sp.wait()
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
        traceback.print_tb(sys.exc_info()[2])

    if not os.access(app_bin, os.R_OK):
        raise RuntimeError('Failed to compile %s'%app_name)

    sim_cmd  = '%s --sim-stat %s'%(tools[1], arch_opts)
    sim_cmd += ' --max-cycle %d'%run_opts['max_cycle']
    sim_cmd += ' --sim-dir %s'%os.path.join(wd, 'sim-out')
    sim_cmd += ' %s'%app_bin
    if dbin: sim_cmd += ' '.join(dbin)
    if VERBOSE: print('Simulating %s, command="%s"'%(app_name, sim_cmd))
    try:
        sp = subprocess.Popen(sim_cmd.split())
        rc = sp.wait()
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
        traceback.print_tb(sys.exc_info()[2])
    return sim_stat.process_sim_dir(os.path.join(wd, 'sim-out'))

def run_config(cfg_path, tools):
    global run_opts
    with open(os.path.join(cfg_path, run_opts['run_cfg'])) as f: c=json.load(f)
    if VERBOSE: print('Target architectures: '+ ', '.join(c['arch']))
    if VERBOSE: print('Applications: '+ ', '.join(c['app']))
    if VERBOSE: print('Running benchmark in %s\n'%run_opts["run_dir"])
    s = time.time()
    bench_stat = {}
    for p in c['arch']:
        af = os.path.join(run_opts['arch_dir'], '%s.json'%p)
        if VERBOSE: print('Target "%s"'%p)
        rd = os.path.join(run_opts['run_dir'], p)
        mkdir_p(rd)
        if not os.access(af, os.R_OK):
            raise RuntimeError('No config file for "%s"'%p)
        acfg = ' --arch-cfg=%s'%af
        if 'arch-param' in c: acfg += ' --arch-param=%s'%c['arch-param']
        bench_stat[p] = {}
        for a in c['app']:
            if VERBOSE: print('-- Running %s'%a)
            dbin = []
            if 'dbin' in c and a in c['dbin']:
                for d in c['dbin'][a]:
                    t = d.split(':')
                    tgt, sym = t[0], t[1]
                    dfile = os.path.abspath(os.path.join(cfg_path, t[2]))
                    dbin.append(' --%s-dbin %s:%s'%(tgt, sym, dfile))
            bench_stat[p][a] = run_app(
                app_name=a, app_dir=os.path.join(cfg_path, a),
                run_dir= rd, tools=tools, arch_opts=acfg, dbin=dbin)
    e = time.time()
    if VERBOSE: print_green(
        'Finished %d applications on %d architectures.'
        ' Elasped time %.2fs'%(len(c['app']), len(c['arch']), e-s))
    return bench_stat, c

def run_bench_dir(bench_dir, tools):
    global VERBOSE
    stat = {}
    for r, d, f in os.walk(bench_dir):
        if run_opts['run_cfg'] in f:
            if VERBOSE: print_green('Running benchmarks in %s'%r)
            stat[os.path.basename(r)] = run_config(r, tools)
    return stat

def bench_stat_tab(stat, stat_keys, hdr_sep='=', hborder='-', vborder='|',
                   corner='+', margin=1):
    if not stat_keys: return ''
    arch  = stat.keys()
    arch.sort()
    bench = stat[arch[0]].keys()
    #for a in arch:
    #    for b in bench: stat[a][b].ignore_function('main')
    stat_tab = [[[str(stat[a][b][k]) for b in bench] for a in arch]
                for k in stat_keys]
    # formatting the table
    key_w   = max([len(k) for k in stat_keys]) + margin*2
    arch_w  = max([len(a) for a in arch]) + margin*2
    # get maximum width of each data column
    bench_w = [[max([len(e) for e in c]) for c in zip(*t)] for t in stat_tab]
    col_w = [max(w) + margin*2 for w in zip(*bench_w)]

    col_w = [max(e) for e in zip([len(b)+margin*2 for b in bench], col_w)]
    # horizontal line
    hline = ''.join([corner, hborder*key_w, corner, hborder*arch_w, corner])
    for w in col_w: hline += hborder*w + corner
    hline += '\n'
    # header separator
    hdr_ln = ''.join([corner, hdr_sep*key_w, corner, hdr_sep*arch_w, corner])
    for w in col_w: hdr_ln += hdr_sep*w + corner
    hdr_ln += '\n'

    t = hline
    # Benchmark header
    bh = ''.join([vborder, ' '*key_w, vborder, ' '*arch_w, vborder])
    for i, b in enumerate(bench):
        bh += aligned_str(b, col_w[i]) + vborder
    t += bh + '\n' + hdr_ln
    for i, k in enumerate(stat_keys):
        for j, a in enumerate(arch):
            l = vborder + aligned_str(k if j == 0 else '', key_w) + vborder\
                + aligned_str(a, arch_w) + vborder
            for z, b in enumerate(stat_tab[i][j]):
                l += aligned_str(b, col_w[z]) + vborder
            t += l +'\n'
            if j != len(arch)-1:
                t += vborder + ' ' * key_w + vborder + hborder * arch_w + corner
                for w in col_w: t += hborder * w + corner
                t += '\n'
        t += hline
    return t

def parse_options():
    parser = OptionParser('Usage: %prog [options] <bench_dir>')
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose",
                      default=False, help="Run in verbose mode")
    parser.add_option("--run-dir", dest="run_dir",
                      default=os.path.abspath('bench-run'),
                      help="Path to run directory (default=./bench-run)")
    parser.add_option("--arch-dir", dest="arch_dir", 
                      default=os.path.abspath('arch'),
                      help="Path to architecture directory (default=./arch)")
    parser.add_option("--run-cfg", dest="run_cfg", default="run.json",
                      help="Name of benchmark config file (default=run.json)")
    parser.add_option("-O", dest="opt_level", type=int, default=3,
                      help="Compiler optimization level (0-3, default=3)")
    parser.add_option("--max-cycle", type="int", dest="max_cycle",
                      default=1000000000, help="Maximum simulation cycles")
    parser.add_option("--solver-llvm-path", dest="llvm_path",
                      help="Path to LLVM tools (default=$SOLVER_LLVM_PATH)")
    parser.add_option("--solver-path", dest="solver_path",
                      help="Path to Solver toolchain (default=$SOLVER_PATH)")
    parser.add_option("--solver-inc-path", dest="solver_inc_path",
                      help="Solver include path (default=$SOLVER_INCLUDE_PATH)")
    parser.add_option("--solver-lib-path", dest="solver_lib_path",
                      help="Solver library path (default=$SOLVER_LIB_PATH)")
    parser.add_option("--solver-target-root", dest="solver_target_root",
                      help="Solver root path (default=$SOLVER_TARGET_ROOT)")
    return parser.parse_args()

if __name__ == '__main__':
    opts, args = parse_options()
    if ('SOLVER_LLVM_PATH' not in os.environ) and not opts.llvm_path:
        raise RuntimeError("LLVM for Solver path not specified")
    if ('SOLVER_PATH' not in os.environ) and not opts.solver_path:
        raise RuntimeError("Solver tool path not specified")
    # if ('SOLVER_INCLUDE_PATH' not in os.environ) and not opts.solver_inc_path:
    #     raise RuntimeError("Solver header path not specified")
    # if ('SOLVER_LIB_PATH' not in os.environ) and not opts.solver_lib_path:
    #     raise RuntimeError("Solver library path not specified")
    if ('SOLVER_TARGET_ROOT' not in os.environ) and not opts.solver_target_root:
        raise RuntimeError("Solver target root path not specified")
    # Set default paths
    if not opts.llvm_path:
        opts.llvm_path = os.environ['SOLVER_LLVM_PATH']
    if not opts.solver_path:
        opts.solver_path = os.environ['SOLVER_PATH']
    # if not opts.solver_inc_path:
    #     opts.solver_inc_path = os.environ['SOLVER_INCLUDE_PATH']
    # if not opts.solver_lib_path:
    #     opts.solver_lib_path = os.environ['SOLVER_LIB_PATH']
    if not opts.solver_target_root:
        opts.solver_target_root = os.environ['SOLVER_TARGET_ROOT']
    VERBOSE = opts.verbose
    if len(args) != 1:
        print('Usage: run_bench.py <app_dir>')
        exit(-1)
    tools = find_tools(('s-cc', 's-run-sim'),
                       os.path.abspath(opts.solver_path))
    if not tools[0]:
        print('s-cc not found')
        exit(-1)
    else:
        cc_cmd = tools[0] + ' --solver-llvm-path=%s'%opts.llvm_path\
            +' --solver-path=%s'%opts.solver_path\
            +' --solver-target-root=%s'%opts.solver_target_root\
            + ' -O%d'%opts.opt_level
    if not tools[1]:
        print('s-run-sim not found')
        exit(-1)
    else:
        sim_cmd = tools[1] + ' --solver-path=%s'%opts.solver_path
    tools=(cc_cmd, sim_cmd)
    run_opts = opts.__dict__
    bench_dir = os.path.abspath(args[0])
    mkdir_p(opts.run_dir)
    stat = run_bench_dir(bench_dir, tools)
    s = stat[os.path.basename(args[0])]
    print bench_stat_tab(s[0], s[1]['stat'])
