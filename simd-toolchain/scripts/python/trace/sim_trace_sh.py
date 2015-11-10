import os, sys, cmd, glob, re
import sim_trace, sim_trace_search
from sim_trace_error import SimTraceError
from optparse import OptionParser
d = os.path.join(os.path.dirname(__file__), '..')
if d not in sys.path: sys.path.append(d)
from utils.print_color import *
from utils.cmd_shell import *

def parse_range(r):
    s = r.split()
    if len(s) != 2:
        s = re.split('[:-~]', r)
    if len(s) != 2:
        return None
    return (int(s[0]) if s[0].strip() else -1,int(s[1]) if s[1].strip() else -1)

class SimTraceShell(BaseShell):
    tool_msg = \
'''
======================================
=    Solver Simulation Trace Shell   =
======================================

To get help on how to use this tool, type "help"
To leave this program, press Ctrl+D or type "exit"
'''

    def set_cycle(self, t):
        if len(self.trace) <= 0:
            print_red('Empty trace')
            return
        if t > self.trace.max_cycle:
            print_yellow('%d > max_cycle, going to the last available cycle'%t)
            t = self.trace.max_cycle
        elif t < 0:
            print_yellow('%d < 0, going to the first available cycle'%t)
            t = 0
        while not self.trace.has(t) and t <= self.trace.max_cycle: t += 1
        if self.trace.has(t):
            self.cycle = t
            self.trace_list[self.trace_name][1] = t
            SimTraceShell.prompt = '[%s] @%d>> '%(self.trace_name, t)
            print_green('At cycle %d'%t)
        else:
            print_red('No available trace found')
            
    def do_loadtrace(self, arg):
        "loadtrace <tracefile> [name]: load a simulation trace in <tracefile>"\
        " and name it 'name' (default='default')"
        if not arg: return print_red('No trace filename specified')
        args = arg.split()
        fn = args[0]
        tn = args[1] if len(args) > 1 else 'default'
        try:
            self.load_trace(fn, tn)
        except IOError:
            print_red('Failed to open %s'%fn)

    def complete_loadtrace(self, text, line, begidx, endidx):
        if not text: completions = self.filelist
        else:
            p = line.split()[-1]
            completions = [f[f.find(text):] for f in self.filelist
                           if f.startswith(p) and os.path.isfile(f)]
        return completions

    def do_instr(self, arg):
        "instr [addr [comp]]: print comp instruction at address addr "
        "(default = pc, all)"
        e = s = self.trace.get(self.cycle).pc
        args = arg.split()
        b = 1
        if len(args) >= 1:
            if args[0].isdigit():
                s = e = int(args[0])
            else:
                r = parse_range(args[0])
                if not r:
                    if len(args)>=2:return print_red('Illegal addr "%s"'%args[0])
                    else: b = 0
                else:
                    s = r[0] if r[0] >= 0 else 0
                    e = r[1] if r[1] > s  else self.trace.max_pc
        comp = args[b] if len(args) == (b+1) else 'all'
        for addr in range(s, e+1):
            if addr > self.trace.max_pc:
                return print_yellow('Trace does not have instruction at %d'%addr)
            try: print '==== @%d: %s'%(
                addr, self.trace.get_instr_str(addr, comp))
            except SimTraceError as e: return print_red('%s'%e.args)

    def do_print(self, arg):
        "print [num [component [stage]]] : print information of cycle num"\
        " (default=current-cycle, all, all)"
        args = arg.split()
        s = e = self.cycle
        b = 1
        if len(args) > 0:
            if args[0] == '.':      pass
            elif args[0].isdigit(): s = e = int(args[0])
            else:
                r = parse_range(args[0])
                if not r:
                    b = 0# print_red('Invalid cycle argument "%s"'%args[0])
                else:
                    s = r[0] if r[0] >= 0 else 0
                    e = r[1] if r[1] > s  else self.trace.max_cycle
        comp  = args[b]   if len(args) >= (b+1) else 'all'
        stage = args[b+1] if len(args) == (b+2) else 'all'
        try:
            if len(self.trace) == 0: raise SimTraceError('Empty trace')
            for c in range(s, e+1):
                if self.trace.has(c):
                    s=self.trace.get(c).stage_str(comp, stage)
                    print '>>>> %d <<<<\n%s'%(c, s)
        except SimTraceError as e: return print_red('%s'%e.args)

    def do_memtrace(self, arg):
        "memtrace <L>|<S>|<A> [[start]:[end]] [CP|PE|ALL]: print memory access"\
        " (L=load, S=store, A=all) trace in [start end] (default=A,"\
        " current-cycle:max, ALL)"
        args = arg.split()
        s, e = self.cycle, self.trace.max_cycle
        b = 1
        if len(args) < 1 or args[0] not in ['L', 'S', 'A']:
            return print_red("A valid access type is required: L, S or A.")
        if len(args) >= 2:
            b = 2
            if args[1] == 'all':
                s, e = 0, self.trace.max_cycle
            else:
                r = parse_range(args[1])
                if r[0] >= 0: s = r[0]
                if r[1] >= s and r[1] <= self.trace.max_cycle: e = r[1]
        comp  = args[b].upper   if len(args) > b else 'ALL'
        try:
            for t in range(s, e+1):
                c = self.trace.get(t)
                if not c.has_mem(addr=None, comp=comp, stage=None): continue
                if comp == 'CP' or comp == 'ALL':
                    for mo in c.memory_ops['CP']:
                        if mo['type'] != 'A': continue
                        s = '<@%d>%s: addr = %10d, data = %10d (0x%08X)'%(t,
                            'Rd' if 'dst' in mo else 'Wr',
                            mo['addr'], mo['data'], int(mo['data'])&0xFFFFFFFF)
                        print s
        except SimTraceError as e: print_red('%s'%e.args)

    def do_goto(self, arg):
        "goto <num>|<expr>: go to cycle <num> or the cycle the matches"\
        " search expression <expr>"
        if len(self.trace) <= 0: return print_red("Empty trace")
        if arg == 'begin': return self.set_cycle(0)
        if arg == 'end'  : return self.set_cycle(self.trace.max_cycle)
        if arg.isdigit() : return self.set_cycle(int(arg))
        try:
            c = sim_trace_search.search_sim_trace(self.trace, self.cycle, arg)
            if c != None: self.set_cycle(c)
            else: print_yellow('No cycle matches "%s"'%arg)
        except SimTraceError as e: print_red('%s'%e.args)

    def do_next(self, arg):
        "next [num]: forward time by num cycles (default=1)"
        step = '1' if not arg else arg
        try:
            t = int(step)
            self.set_cycle(self.cycle + t)
        except ValueError:
            print_red('Invalid argument %s, expecting a number'%arg)

    def do_search(self, arg):
        if len(self.trace) <= 0: return print_red("Empty trace")
        try:
            c = sim_trace_search.search_sim_trace(self.trace, self.cycle, arg)
            if c != None: print 'Found in cycle %d'%c
            else: print_yellow('No result found for "%s"'%arg)
        except SimTraceError as e: print_red('%s'%e.args)

    def help_search(self):
        print 'search <exp>: find the cycle using expression exp'

    def do_back(self, arg):
        "back [num]: go back in time by num cycles (default=1)"
        step = '1' if not arg else arg
        try:
            t = int(step)
            self.set_cycle(self.cycle - t)
        except ValueError:
            print_red('Invalid argument %s, expecting a number'%arg)

    def do_stat(self, arg):  self.trace.print_stat()
    def help_stat(self):     print 'stat: print trace statistics'
    def do_which(self, arg):
        print '%s: %s'%(self.trace_name, self.trace.filename)
    def help_which(self):    print 'which: print current trace file information'

    def do_list(self, arg):
        for n, t in self.trace_list.items():
            print('%s @%d: %s'%(n, t[1], t[0].filename))

    def do_switch(self, trace_name):
        if not trace_name:
            return print_red('No trace name specified')
        if trace_name in self.trace_list:
            self.trace = self.trace_list[trace_name][0]
            self.trace_name = trace_name
            self.set_cycle(self.trace_list[trace_name][1])
        else:
            print_red('No trace named "%s"'%trace_name)
    def complete_switch(self, text, line, begidx, endidx):
        if not text: completions = self.trace_list.keys()
        else:
            completions = [f[f.find(text):] for f in self.trace_list.keys()
                           if f.startswith(text)]
        return completions

    def preloop(self):
        self.cycle = 0
        self.wdlist   = [f for f in os.listdir('.')]
        self.filelist = [f for f in self.wdlist if os.path.isfile(f)]
        self.dirlist  = [f for f in self.wdlist if os.path.isdir(f)]
        self.trace_list = {} #{'default':(sim_trace.SimulationTrace(), 0), }
        self.trace = None    #self.trace_list['default']
        self.trace_name = '' #'default'

    def emptyline(self): pass

    def load_trace(self, filename, trace_name='default'):
        if trace_name not in self.trace_list:
            self.trace_list[trace_name] = [sim_trace.SimulationTrace(), 0]
        self.trace = self.trace_list[trace_name][0]
        self.trace_name = trace_name
        self.trace.read_trace(filename)
        self.set_cycle(self.trace_list[trace_name][1])

if __name__ == '__main__':
    p = SimTraceShell()
    p.cmdloop(SimTraceShell.tool_msg)
