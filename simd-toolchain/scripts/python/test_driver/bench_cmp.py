import os, sys, shutil
import tempfile
import subprocess
import multiprocessing
from optparse import OptionParser
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from utils.print_color import *
from utils.tab_utils import *
from utils.sys_utils import *
from simulation import *
import bench_tool

VERBOSE=False

LARGER_BETTER_STAT = []

def cmp_bench_stat(stats, base_rev):
    stat_diff = []
    rkeys = [k for k in stats.keys() if k != base_rev]
    base_stat = stats[base_rev]
    for a, (stat, cfg) in base_stat.iteritems():
        if VERBOSE: print_green('Comparing: '+', '.join(cfg['stat']))
        for arch, app_stats in stat.iteritems():
            for app, st in app_stats.iteritems():
                for i in cfg['stat']:
                    b_val = st.code_stat.get_dyn_stat(i)
                    for k in rkeys:
                        k_val=stats[k][a][0][arch][app].code_stat.get_dyn_stat(i)
                        if b_val != k_val:
                            stat_diff.append((k, a, arch, app, i))
    return stat_diff

def check_clone_hg_repo(repo, dest):
    global VERBOSE
    if VERBOSE: print('Check and clone from %s to %s'%(repo, dest))
    tf = tempfile.TemporaryFile()
    if os.path.exists(dest):
        if os.path.isdir(dest) and os.path.isdir(os.path.join(dest, '.hg')):
            r, _ = subprocess.Popen(['hg', 'paths', 'default', '-R', dest],
                                    stdout=subprocess.PIPE).communicate()
            if r.strip() == repo:
                subprocess.Popen(['hg', 'pull', '-R', dest], stdout=tf).wait()
                return
        shutil.rmtree(dest)
    subprocess.Popen(['hg', 'clone', repo, dest], stdout=tf).wait()
    bd = os.path.join(dest, 'build')
    if os.path.exists(bd):
        if not os.path.isdir(bd):os.remove(bd)
        else: return
    os.mkdir(bd)

def checkout_and_build(repo, run_dir, rev=None, opt_level=3):
    global VERBOSE
    '''Check out a repository and build a specified revision'''
    tf = tempfile.TemporaryFile()
    b_env = {'CC':'clang','CXX':'clang++','PATH':os.environ['PATH']}
    if VERBOSE: print('Repository: '+repo)
    cwd = os.getcwd()
    co_dir = os.path.join(run_dir, 'cmp_repo')
    check_clone_hg_repo(repo, co_dir)
    if rev:
        subprocess.Popen(['hg','update','-C','-r',rev,'-R', co_dir],
                         stdout=tf).wait()
    bd = os.path.join(co_dir, 'build')
    os.chdir(bd)
    subprocess.Popen(['cmake', '..'], env=b_env, stdout=tf).wait()
    rc = subprocess.Popen(
        ['make', '-j%d'%multiprocessing.cpu_count()], stdout=tf).wait()
    os.chdir(cwd)
    if rc != 0:
        raise RuntimeError('Cannot build rev %s'%('tip' if not rev else rev))
    sd = os.path.join(run_dir, 'cmp_repo', 'solver')
    cc_cmd = os.path.join(bd, 'bin', 's-cc')\
        +' --solver-path=%s'%os.path.join(bd, 'bin')\
        +' --solver-inc-path=%s'%os.path.join(sd, 'include')\
        +' --solver-lib-path=%s'%os.path.join(sd, 'lib')\
        + ' -O%d '%opt_level
    sim_cmd = os.path.join(bd, 'bin', 's-run-sim')\
        +' --solver-path=%s'%os.path.join(bd, 'bin')
    return (cc_cmd, sim_cmd)

def parse_options():
    parser = OptionParser('Usage: %prog [options] <bench_dir>')
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose",
                      default=False, help="Run in verbose mode")
    parser.add_option("--print-cmd", action="store_true", dest="print_cmd",
                      default=False, help="Print detailed commands")
    parser.add_option("--run-dir", dest="run_dir",
                      default=os.path.abspath('cmp-run'),
                      help="Path to run directory (default=./cmp-run)")
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
    parser.add_option("--working-build-dir", dest="build_dir", default='build',
                      help="Path to build directory (default=build)")
    parser.add_option("-r", action="append", dest="revs", default=[],
                      help="Add a revision to run")
    parser.add_option("-B", action="append", dest="baseline", default='tip',
                      help="Baseline revision")
    if ('SOLVER_LLVM_PATH' not in os.environ) and not opts.llvm_path:
        raise RuntimeError("LLVM for Solver path not specified")
    return parser.parse_args()

if __name__ == '__main__':
    opts, args = parse_options()
    # Set default paths
    if not opts.llvm_path:
        opts.llvm_path = os.environ['SOLVER_LLVM_PATH']
    VERBOSE = opts.verbose

    if len(args) != 1:
        print('Usage: run_bench.py <app_dir>')
        exit(-1)

    repo, _ = subprocess.Popen(['hg', 'root'], stdout=subprocess.PIPE).communicate()
    repo = os.path.abspath(repo.strip())
    if not os.path.isdir(repo):
        print >>sys.stderr, "Cannot find hg repository"
        exit(-1)

    solver_path = build_dir if os.path.isabs(opts.build_dir)\
        else os.path.join(repo, opts.build_dir)
    solver_path = os.path.join(solver_path, 'bin')

    wc_tools = find_tools(('s-cc', 's-run-sim'), solver_path)
    if not wc_tools[0]:
        print('s-cc from working copy not found')
        exit(-1)
    else:
        cc_cmd = wc_tools[0] + ' --solver-llvm-path=%s'%opts.llvm_path\
            +' --solver-path=%s'%solver_path\
            +' --solver-inc-path=%s'%os.path.join(repo, 'solver', 'include')\
            +' --solver-lib-path=%s'%os.path.join(repo, 'solver', 'lib')\
            + ' -O%d'%opts.opt_level
    if not wc_tools[1]:
        print('s-run-sim rom working copy not found')
        exit(-1)
    else: sim_cmd = wc_tools[1] + ' --solver-path=%s'%solver_path
    wc_tools=(cc_cmd, sim_cmd)

    if opts.baseline not in opts.revs: opts.revs.append(opts.baseline)
    if not opts.revs: opts.revs.append('tip')
    if VERBOSE: print 'Revisions: '+', '.join(opts.revs)
    if VERBOSE: print 'Baseline = '+ opts.baseline

    if opts.print_cmd: bench_tool.VERBOSE = True
    bench_tool.run_opts = opts.__dict__
    bench_dir = os.path.abspath(args[0])
    rev_stat = {}
    if not os.path.exists(opts.run_dir): os.mkdir(opts.run_dir)
    for r in opts.revs:
        if VERBOSE: print_blue('Running revision %s'%r)
        t = checkout_and_build(repo, opts.run_dir, rev=r)
        rev_stat[r] = bench_tool.run_bench_dir(bench_dir, t)
    if VERBOSE: print_blue('Running working copy')
    rev_stat['working-copy'] = bench_tool.run_bench_dir(bench_dir, wc_tools)
    s_diff = cmp_bench_stat(rev_stat, opts.baseline)
    if not s_diff and VERBOSE: print('No difference')
    if s_diff:
        b_stat = rev_stat[opts.baseline]
        for (k, a, arch, app, i) in s_diff:
            b_val = b_stat[a][0][arch][app].code_stat.get_dyn_stat(i)
            k_val = rev_stat[k][a][0][arch][app].code_stat.get_dyn_stat(i)
            p = (k_val - b_val)*100.0/b_val
            color_func = green_str if p < 0 or i in LARGER_BETTER_STAT\
                else red_str
            print '%s, %s, %s, %s, %s: %s'%(
                bold_str(i), k, a, arch, app, 
                color_func('%.2f%% (%d/%d)'%(p, k_val, b_val)))

