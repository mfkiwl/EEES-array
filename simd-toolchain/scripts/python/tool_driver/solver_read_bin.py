#!/usr/bin/env python
import os, sys
import pickle
from operator import itemgetter
from optparse import OptionParser
from optparse import OptionGroup

VERBOSE   = False
CWD       = os.getcwd()

def parse_options():
    parser = OptionParser('Usage: %prog [options] binary_archive')
    # General options
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose",
                      default=False, help="Run in verbose mode")
    parser.add_option("--branch-trace", dest="br_trace",
                      help="Branch trace file")
    parser.add_option("--exe-stat", help="Execution statistics file")
    parser.add_option("--solver-py-path", dest="solver_py_path",
                      help="Specify path to Solver Python modules"\
                          " (default=${BIN}/../lib/solver/python)")
    parser.add_option("--dump", dest="dump",
                      help="Specify file to save the result")
    parser.add_option("--load", dest="load",
                      help="Specify program dump file to read")
    parser.add_option("--cfg", dest="cfg", action="append",
                      default=[], help="Specify functions to save CFG")
    parser.add_option("--report", dest="report", action="append",
                      choices=['info', 'call', 'cross-func-br', 'branch',
                               'func-prof'],
                      default=[], help="Specify content of global report")
    parser.add_option("--prof-func", action="append", default=[],
                      help="Specify functions for detailed profiling")
    parser.add_option("--locate-pc", action="append", default=[],
                      help="Locate instruction in program by address")
    (opts, args) = parser.parse_args()
    if not opts.solver_py_path:
        opts.solver_py_path = os.path.join(
            os.path.dirname(__file__), '..', 'lib', 'solver', 'python')
    opts.solver_py_path=os.path.abspath(os.path.expanduser(opts.solver_py_path))
    return (opts, args)

if __name__ == '__main__':
    rc = 0
    keep = False
    (opts, args) = parse_options()
    VERBOSE = opts.verbose
    if not args and not opts.load:
        print >>sys.stderr, '%s: no input file'%sys.argv[0]
        exit(-1)
    if len(args) > 1:
        print >>sys.stderr, 'Too many input files: there should be only one'
        exit(-1)
    if opts.solver_py_path not in sys.path: sys.path.append(opts.solver_py_path)
    from solver_program.solver_bin import *
    import simulation
    if args:
        if not os.path.isfile(args[0]) or not os.access(args[0],os.R_OK):
            print >>sys.stderr, 'Cannot read input file %s'%args[0]
            exit(-1)
        if VERBOSE: print('Reading binary archive %s'%args[0])
        program = read_solver_bin(args[0])
    else:
        if VERBOSE: print('Loading from %s'%opts.load)
        with open(opts.load) as f: program = pickle.load(f)
    if VERBOSE: print 'Loaded program %s'%program.get_archive_name()
    if opts.br_trace:
        program.clear_trace_info()
        read_branch_trace(program, opts.br_trace)
        program.init_exe_stat()
    if opts.exe_stat:
        with open(opts.exe_stat) as f:
            stat_lns = f.read().splitlines()
        exe_stat = simulation.sim_stat.parse_simulation_stat(
            stat_lns, program.get_archive_name())
        program.load_exe_stat(exe_stat)
            
    for r in opts.report:
        if r == 'info':  print program
        elif r == 'call':
            print program.get_cross_func_br_sequence(callonly=True)
        elif r == 'cross-func-br':
            print program.get_cross_func_br_sequence(callonly=False)
        elif r == 'branch': print program.get_branch_sequence()
        elif r == 'func-prof':
            f_prof = program.get_func_exe_time()
            f_call = program.get_func_called_count()
            tt = sum(f_prof.values())
            fw = max(map(len, f_prof.keys()))
            cw = len(str(max(f_call.values())))
            tw = len(str(max(f_prof.values())))
            precentage = {}
            for f, t in f_prof.items():
                if t > 0: precentage[f] = float(t) / tt
            print "==== %s Overall Profile ===="%program.get_archive_name()
            print "Total cycles = %d"%tt
            for f, p in sorted(precentage.items(),
                               key=itemgetter(1), reverse=True):
                print '{0:{fw}} | {1:<{cw}} | {2:<{tw}} | {3:.2%}'.format(
                    f, f_call[f], f_prof[f], p, fw=fw, cw=cw, tw=tw)
    for f in opts.prof_func:
        print '\n==== %s() Profile ===='%f
        p = program.get_func_profile(f)
        tt = sum([t['exe'] for t in p.values()])
        tw = len(str(max([t['exe'] for t in p.values()])))
        cw = len(str(max([t['count'] for t in p.values()])))
        iw = len(str(max(p.keys())))
        precentage = {}
        for b, t in p.items():
            if t['exe'] > 0: precentage[b] = float(t['exe']) / tt
        print 'Total cycles = %d'%tt
        for i, pp in sorted(precentage.iteritems(),
                           key=itemgetter(1), reverse=True):
            print 'BB{0:<{iw}} | {1:<{cw}} | {2:<{tw}} | {3:.2%}'.format(
                i, p[i]['count'], p[i]['exe'], pp, iw=iw, cw=cw, tw=tw)

    for pc in opts.locate_pc:
        print '%s is in %s'%(pc, str(program.get_block_by_addr(int(pc, 0))))

    if opts.dump:
        if VERBOSE: print('Dumping program to %s'%opts.dump)
        with open(opts.dump, 'w') as f: pickle.dump(program, f)
    for f in opts.cfg:
        with open('%s.%s.cfg.dot'%(program.get_archive_name(), f), 'w') as df:
            df.write(program.get_cfg_dot(f, True))
    
