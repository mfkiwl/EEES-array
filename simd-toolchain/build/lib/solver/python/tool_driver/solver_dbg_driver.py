#!/usr/bin/env python
import os, sys
import pickle
import logging
from operator import itemgetter
from optparse import OptionParser
from optparse import OptionGroup

d = os.path.join(os.path.dirname(__file__), '..', 'lib', 'solver', 'python')

if d not in sys.path: sys.path.append(d)
from utils.solver_bin import *
from utils.print_color import *
from utils.cmd_shell import BaseShell
from simulation.sim_context import SolverSimContext

def _block_str(b): return '%s.B%d'%(b[0], b[1])
def _func_info_str(f):
    return '%s: start=%d, size=%d, %d blocks'%(
        f['name'], f['start'], f['size'], len(f['blocks']))
def _dobj_info_str(d):
    return '%s: start=%d, size=%d [%s]'%(
        d['name'], d['start'], d['size'], 'pe' if d['vector'] else 'cp')

class SolverDbgShell(BaseShell):
    tool_msg = \
'''
=======================================
=        Solver Debugging Shell       =
=======================================

To get help on how to use this tool, type "help"
To leave this program, press Ctrl+D or type "exit"
'''
    def check_context_command(f):
        def check_run(self, args):
            if not self.__curr_ctx: return print_red('No program loaded yet')
            return f(self, args)
        return check_run

    def __init__(self, program=None):
        BaseShell.__init__(self)
        self.add_alias('restart', 'reset')
        self.add_alias('break',   'breakpoint')
        self.add_alias('b',       'breakpoint')
        self.add_alias('ctx',     'context')
        self.add_alias('mem',     'memory')
        self.__contexts = {}
        self.__curr_ctx = None
        self.__verbose = False
        self.__trace = False
        if program:
            self.__curr_ctx = SolverSimContext(program)
            self.__curr_ctx.load_program(program)
            self.__curr_ctx.set_verbose(self.__verbose)

    def set_verbose(self, v):
        self.__verbose = v
        if self.__curr_ctx: self.__curr_ctx.set_verbose(v)

    def has_error(self):
        return self.__curr_ctx and self.__curr_ctx.has_error()

    def preloop(self): self.set_verbose(True)

    def do_quiet(self, args):
        "quiet: suppress execution messages"
        self.set_verbose(False)

    def do_trace(self, args):
        "trace: enable trace in stepping"
        self.__trace = not self.__trace
        if self.__trace: print 'Trace ON'
        else:            print 'Trace OFF'

    def do_verbose(self, args):
        "verbose: enable execution messages"
        self.set_verbose(True)

    def do_load(self, args):
        "load file [name]: load a program from file"
        if not args: return print_red('No program specified')
        s = args.split()
        if len(s) > 2: return print_red('Usage: load file [name]')
        program, name = s[0], s[1] if len(s)==2 else None
        try:
            self.__curr_ctx = SolverSimContext(program, self.__verbose)
            if not name: name = self.__curr_ctx.get_program_name()
            self.__contexts[name] = self.__curr_ctx
            SolverDbgShell.prompt = '[%s] >> '%name
        except IOError: print_red('Cannot open %s'%str(program))
    def do_reload(self, args):
        "reload name: reload a simulation instance"
        if not args: return print_red('Usage: reload name')
        if args not in self.__contexts:
            return print_red('No instance named "%s"'%args)
        p = self.__contexts[args].get_program_path()
        self.__contexts[args] = SolverSimContext(p, self.__verbose)
        if args == self.__curr_ctx.get_program_name():
            self.__curr_ctx = self.__contexts[args]

    def __print_contexts(self):
        for n, c in sorted(self.__contexts.iteritems()):
            s = '%s: %s (%s)'%(n, c.get_program_name(), c.get_program_path())
            if c == self.__curr_ctx: print_green('* %s '%s)
            else: print(s)

    def do_list(self, args):
        "list: list available simulation instances"
        self.__print_contexts()

    def do_switch(self, args):
        "switch [name]: switch to a simulation instance"
        if args not in self.__contexts:
            print_red('No instance named "%s"'%args)
            if self.__contexts:
                print('Available instances:')
                self.__print_contexts()
            return
        self.__curr_ctx = self.__contexts[args]
        SolverDbgShell.prompt = '[%s] >> '%self.__curr_ctx.get_program_name()
        if self.__verbose:
            print 'Switch to %s (%s)'%(
                self.__curr_ctx.get_program_name(),
                self.__curr_ctx.get_program_path())

    def __print_instr_list(self, addr_list):
        for a in addr_list:
            print '@%d CP: <%s>  ||  PE: <%s>'%(
                a, self.__curr_ctx.get_instr_str('cp', a),
                self.__curr_ctx.get_instr_str('pe', a))
    @check_context_command
    def do_print(self, args):
        if not args: return print_red('Usage: print address|func [block]')
        al, f, b = [], None, None
        try: return self.__print_instr_list([int(args, 0), ])
        except ValueError: pass
        r = args.split(':')
        if len(r) == 2:
            try:return self.__print_instr_list(range(int(r[0],0),int(r[1],0)+1))
            except ValueError: pass
        s = args.split()
        try: return self.__print_instr_list([int(x, 0) for x in s])
        except ValueError: pass
        if len(s) > 2: return print_red('Usage: print address|func [block]')
        if self.__curr_ctx.has_function(s[0]):
            f = self.__curr_ctx.get_function(s[0])
            if len(s) == 2:
                try:
                    bid = int(s[1], 0)
                    if bid not in f['blocks']:
                        return print_red('No BB %d in %s'%(bid, s[0]))
                    b = f['blocks'][bid]
                except ValueError:
                    return print_red('Unknown address: %s'%args)
        else: return print_red('Unknown address: %s'%args)
        if b: al = range(b['start'], b['start']+b['size'])
        else: al = range(f['start'], f['start']+f['size'])
        if al and f: print '%s%s:'%(f['name'], '.B%d'%b['id'] if b else '')
        self.__print_instr_list(al)
    def help_print(self): print 'print  addr|func [block]: get instruction info'

    @check_context_command
    def do_info(self, args):
        if not args:
            fk = self.__curr_ctx.func_keys()
            if fk:
                print('Functions (%d):'%len(fk))
                for f in fk:
                    print '- '+_func_info_str(self.__curr_ctx.get_function(f))
            dk = self.__curr_ctx.dobj_keys()
            if dk:
                print('Data objects (%d):'%len(dk))
                for d in dk:
                    print '- '+_dobj_info_str(self.__curr_ctx.get_data_object(d))
            return
        for a in args.split():
            if self.__curr_ctx.has_function(a):
                print('-- Function - '
                      + _func_info_str(self.__curr_ctx.get_function(a)))
            elif self.__curr_ctx.has_data_object(a):
                print('-- Object - ' +
                      _dobj_info_str(self.__curr_ctx.get_data_object(a)))
            else: print_red('Cannot find information about %s'%a)
    def help_info(self):
        print "info [funcs|objs|name]: get program object information"

    @check_context_command
    def do_reset(self, args):
        self.__curr_ctx.reset()
    def help_reset(self): print "reset: reset simulator"

    @check_context_command
    def do_step(self, args):
        pc = self.__curr_ctx.get_pc()
        self.__curr_ctx.clear_sim_trace()
        if self.__trace: self.__curr_ctx.set_full_trace(True)
        if self.__curr_ctx.run(1) == 1:
            if self.__trace:
                print self.__curr_ctx.read_sim_trace()
            elif self.__verbose:
                print 'PC=%d -- CP: <%s>  ||  PE: <%s>'%(
                    pc, self.__curr_ctx.get_instr_str('cp', pc),
                    self.__curr_ctx.get_instr_str('pe', pc))
        self.__curr_ctx.set_full_trace(False)
    def help_step(self): print 'Run simulator for one cycle'

    @check_context_command
    def do_run(self, args):
        if not args: n = self.__curr_ctx.run()
        else:
            try: s = int(args, 0)
            except ValueError: return print_red('Invalid argument %s'%args)
            if self.__trace: self.__curr_ctx.set_full_trace(True)
            n = self.__curr_ctx.run(s)
            if self.__trace:
                print self.__curr_ctx.read_sim_trace()
        if self.__verbose:
            if self.__verbose: print '%d cycles simulated'%n
            if self.__curr_ctx.finished(): print('Finished')
            if self.__curr_ctx.has_error():
                print_red('Has error, PC=%d'%self.__curr_ctx.get_pc())
    def help_run(self): print "start/continue simulation"

    @check_context_command
    def do_clearbreakpoint(self, args):
        self.__curr_ctx.clear_pc_traps()
    def help_clearbreakpoint(self): print "clearbreakpoint : delete breakpoints"

    @check_context_command
    def do_breakpoint(self, args):
        if not args:
            bp = self.__curr_ctx.get_pc()
            if self.__verbose: print('Set breakpoint at current pc')
        else:
            try:
                bp = int(args.strip(), 0)
            except ValueError:
                s = args.strip().split()
                func, bb, end = s[0].strip(), None, False
                if len(s) > 3:
                    return print_red('Usage: breakpoint [pc]|[func [bb] [end]]')
                if len(s) == 3:
                    if s[2] != 'end': return print_red('Unknow argument %'%s[2])
                    end = True
                    try: bb = int(s[1])
                    except:print_red('Unknow argument %'%s[1])
                elif len(s) == 2:
                    if s[1] == 'end': end = True
                    else:
                        try: bb = int(s[1])
                        except:print_red('Unknow argument %'%s[1])
                bp = self.__curr_ctx.get_program_address(func, bb, end)
        if self.__verbose:
            adr_inf = self.__curr_ctx.get_program_addr_info(bp)
            pos = ' (in %s)'%_block_str(adr_inf) if adr_inf else ''
            print('Set breakpoint at %d %s'%(bp, pos))
        self.__curr_ctx.add_pc_trap(bp)
    def help_breakpoint(self):
        print "breakpoint [pc]|[func [bb] [end]]: set a program breakpoint"

    def do_status(self, line):
        print 'Settings:'
        print '>> verbose = '+str(self.__verbose)
        print '>> trace = '+str(self.__trace)
        if not self.__curr_ctx: return print_yellow('No program loaded yet')
        print 'Program: %s (%s)'%(
            self.__curr_ctx.get_program_name(),self.__curr_ctx.get_program_path())
        if self.__curr_ctx.finished():  print_yellow('-- Finished')
        if self.__curr_ctx.has_error(): print_red('-- Has ERROR')
        pc = self.__curr_ctx.get_pc()
        cycle = self.__curr_ctx.get_cycle()
        adr_inf = self.__curr_ctx.get_program_addr_info(pc)
        print('--<< PC = %d%s'%(
                pc, ' (in %s)'%_block_str(adr_inf) if adr_inf else ''))
        print('--<< Cycle = %d'%(cycle))
    def help_status(self): print "status: check simulation status"

    @check_context_command
    def do_memory(self, args):
        usage = 'Usage memory <cp|pe start [size]>|<obj name [size]>'
        if not args: return print_red(usage)
        try: comp, start, size, o = self.__get_mem_address(args)
        except ValueError as e:
            m = str(e)
            return print_red(m if m else usage)
        if comp != 'cp' and comp != 'pe':
            return print_red('Unknown component "%s" ("cp" or "pe")'%comp)
        if size == 0: return
        vals = self.__curr_ctx.get_memory(comp, range(start, start+size))
        if not vals: return
        if o: print('Value of %s:'%o['name'])
        aw = max([len(str(x[0])) for x in vals])
        for (i, x) in vals:
            if comp == 'cp':
                print 'CP[{0:{aw}}] = 0x{1:08x} ({2})'.format(i, x, x, aw=aw)
            else:
                print 'PE[{0:{aw}}] = {1}'.format(
                    i, ', '.join(['0x{0:08x} ({1})'.format(v, v) for v in x]),
                    aw = aw)
    def help_memory(self):
        print "memory <cp|pe start [size]>|<object name [size]>: get memory values"

    @check_context_command
    def do_context(self, args):
        comp, idx = 'cp', []
        if args:
            s = [s.strip() for s in args.split()]
            try: int(s[0], 0)
            except ValueError:
                comp = s[0]
                s = s[1:]
            if s: idx = [int(i, 0) for i in s]
        if comp != 'cp' and comp != 'pe':
            return print_red('Unknown component "%s" ("cp" or "pe")'%comp)
        vals = self.__curr_ctx.get_context(comp, idx)
        if not vals: return
        aw = max([len(str(x[0])) for x in vals])
        for (i, x) in vals:
            if comp == 'cp':
                print 'CP[{0:{aw}}] = 0x{1:08x} ({2})'.format(i, x, x, aw=aw)
            else:
                print 'PE[{0:{aw}}] = {1}'.format(
                    i, ', '.join(['0x{0:08x} ({1})'.format(v, v) for v in x]),
                    aw = aw)
    def help_context(self):
        print "context [cp|pe] [id list]: get context (RF and bypass regs) values"

    @check_context_command
    def __get_mem_address(self, args):
        s = [s.strip() for s in args.split()]
        if len(s) != 2 and len(s) != 3: raise ValueError
        comp, start, size, o = 'cp', 0, 0, None
        if s[0] == 'obj':
            try:
                o = self.__curr_ctx.get_data_object(s[1])
            except KeyError: raise ValueError('No object named "%s"'%s[1])
            comp = 'pe' if o['vector'] else 'cp'
            start = o['start']/4
            size  = int(s[2],0) if len(s) == 3 else o['size']/4
            if comp == 'pe':
                pe_size = self.__curr_ctx.get_pe_size()
                start, size = start/pe_size, size/pe_size
        else:
            comp = s[0]
            start, size = int(s[1], 0), int(s[2],0) if len(s) == 3 else 1
        return comp, start, size, o

def parse_options():
    parser = OptionParser('Usage: %prog [options] binary_archive')
    # General options
    parser.add_option("-v", "--verbose", action="store_true",
                      help="Run in verbose mode")
    parser.add_option("-c", "--file", dest="cmd_file",
                      help="Run command file instead of the interactive shell")
    parser.add_option("--init", dest="init_file",
                      help="Run command file before starting the shell")
    (opts, args) = parser.parse_args()
    return (opts, args)

if __name__ == '__main__':
    rc = 0
    keep = False
    (opts, args) = parse_options()
    p = SolverDbgShell()
    if opts.verbose: p.set_verbose(True)
    if opts.cmd_file:
        with open(opts.cmd_file) as f: cmds = f.readlines()
        for c in cmds: p.onecmd(c)
        exit(p.has_error())
    if opts.init_file:
        with open(opts.init_file) as f: cmds = f.readlines()
        for c in cmds: p.onecmd(c)
    p.cmdloop(SolverDbgShell.tool_msg)


