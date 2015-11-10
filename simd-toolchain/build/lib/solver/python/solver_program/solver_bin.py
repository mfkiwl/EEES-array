import os, sys
import zipfile
import tempfile
import shutil
import bisect
import operator
import traceback
from arch_config.arch_config import read_arch_config

class SolverProgram(object):
    def __init__(self, prefix):
        self.__archive       = prefix
        self.__arch          = None
        self.__functions     = {}
        self.__adr_to_func   = {}
        self.__func_adr_keys = []
        self.__start_adr_to_block = {}
        self.__start_adr_keys = []
        self.__data_objects = {}
        self.__symbols = set()
        self.__branch_trace = []

    def get_archive_name(self): return self.__archive

    def set_arch(self, arch):
        self.__arch = read_arch_config(arch)

    def get_arch(self): return self.__arch

    def __getitem__(self, key):
        if type(key) != str: raise TypeError('Key should be str')
        if key in self.__functions:    return self.__functions[key]
        if key in self.__data_objects: return self.__data_objects[key]
        raise KeyError('No function or object named %s'%str(key))

    def func_keys(self):     return self.__functions.keys()
    def func_iterkeys(self): return self.__functions.iterkeys()
    def dobj_keys(self):     return self.__data_objects.keys()
    def dobj_iterkeys(self): return self.__data_objects.iterkeys()

    def get_function(self, fname): return self.__functions[fname]
    def has_function(self, fname): return fname in self.__functions
    def get_data_object(self, oname): return self.__data_objects[oname]
    def has_data_object(self, oname): return oname in self.__data_objects

    def clear_trace_info(self):
        'Clear all statistics from execution traces'
        self.__branch_trace = []
        for n, f in self.__functions.iteritems():
            for k in f['callee'].keys(): f['callee'][k] = 0
            for kb in f['blocks'].keys():
                for k in f['blocks'][kb]['callee']:
                    f['blocks'][kb]['callee'][k] = 0
                for k in f['blocks'][kb]['succ']:
                    f['blocks'][kb]['succ'][k] = 0
                for k in f['blocks'][kb]['pred']:
                    f['blocks'][kb]['pred'][k] = 0

    def add_function(self, fname, start, size):
        if fname in self.__symbols:
            raise ValueError('multiple definition of %s'%fname)
        self.__symbols.add(fname)
        self.__functions[fname] = {'start':start, 'size':size, 'exe':0,
                                   'blocks':{}, 'adr_to_block':{},
                                   'callee':{}, 'name':fname}
        if start in self.__adr_to_func:
            raise ValueError('multiple functions at %d'%start)
        self.__adr_to_func[start] = fname
        bisect.insort(self.__func_adr_keys, start)

    def add_data_object(self, oname, start, size, vect):
        if oname in self.__symbols:
            raise ValueError('multiple definition of %s'%oname)
        self.__symbols.add(oname)
        self.__data_objects[oname] = {'name':oname, 'start':start,
                                      'size':size, 'vector':vect}

    def add_block(self, fname, bid, start, size):
        if bid in self.__functions[fname]['blocks']:
            raise ValueError('multiple definition of B_%d in %s'%(bid,fname))
        self.__functions[fname]['blocks'][bid]\
            = {'id':bid,'start':start, 'size':size,
               'succ':{}, 'pred':{}, 'callee':{}, 'exe':0}
        if start in self.__start_adr_to_block:
            raise ValueError('multiple blocks start at %d in %s'%(start, fname))
        self.__start_adr_to_block[start] = (fname, bid)
        bisect.insort(self.__start_adr_keys, start)

    def add_call(self, caller, bid, callee):
        self.__functions[caller]['callee'][callee] = 0
        self.__functions[caller]['blocks'][bid]['callee'][callee] = 0

    def add_local_branch(self, fname, src, tgt):
        self.__functions[fname]['blocks'][src]['succ'][tgt] = 0
        self.__functions[fname]['blocks'][src]['pred'][src] = 0
    
    def load_exe_stat(self, exe_stat):
        '''Loads a SimulationStat object'''
        for pc, f in sorted(exe_stat.code_freq.iteritems()):
            (func, bb) = self.get_block_by_addr(pc)
            self.__functions[func]['blocks'][bb]['exe'] += f
            

    def address_in_function(self, fname, adr):
        '''Check if a given address is in the function'''
        if fname in self.__functions:
            s = self.__functions[fname]['start']
            e = s + self.__functions[fname]['size']
            if adr >= s and adr < e: return True
        return False

    def get_block_by_addr(self, adr):
        i  = bisect.bisect_left(self.__start_adr_keys, adr)
        i  = len(self.__start_adr_keys)-1 if i>=len(self.__start_adr_keys) else i
        ki = self.__start_adr_keys[i]
        i = i-1 if ki > adr else i
        return self.__start_adr_to_block[self.__start_adr_keys[i]]
    
    def add_taken_branch(self, cycle, src, tgt):
        sb, tb = self.get_block_by_addr(src), self.get_block_by_addr(tgt)
        if sb[0] == tb[0]:
            self.__functions[sb[0]]['blocks'][sb[1]]['succ'][tb[1]] += 1
        else:
            if tb[0] in self.__functions[sb[0]]['callee']:
                self.__functions[sb[0]]['callee'][tb[0]] += 1
                self.__functions[sb[0]]['blocks'][sb[1]]['callee'][tb[0]] += 1
        self.__branch_trace.append((cycle, src, tgt))

    def init_exe_stat(self):
        start_block = self.get_block_by_addr(0)
        self.__functions[start_block[0]]['exe'] = 1
        tr = sorted(self.__branch_trace, key=operator.itemgetter(0))
        for c, s, t in tr:
            sb, tb = self.get_block_by_addr(s), self.get_block_by_addr(t)
            self.__functions[tb[0]]['blocks'][tb[1]]['exe'] += 1
            if sb[0] != tb[0] and tb[0] in self.__functions[sb[0]]['callee']:
                self.__functions[tb[0]]['exe'] += 1

    def get_symbol_str(self, show_bolcks):
        s = '>> Code:'
        for n, f in sorted(self.__functions.iteritems(),
                           key=lambda f:f[1]['start']):
            s += '\nFunction %s @ %d, size = %d, exe = %d\n'%(
                n, f['start'], f['size'], f['exe'])
            if not show_bolcks: continue
            for i, b in sorted(f['blocks'].iteritems(),
                               key=lambda b:b[1]['start']):
                s += '  -- BB %d @ %d size = %d\n'%(i, b['start'], b['size'])
        s += '\n>> Data:\n'
        for n, d in sorted(self.__data_objects.iteritems(),
                           key=lambda d:d[1]['start']):
            s += '%sObject %s @ %d,  size = %d\n'%(
                'Vector ' if d['vector'] else '', n, d['start'], d['size'])
        return s

    def get_cfg_str(self, fname=None):
        s = ''
        fl = [(fname, self.__functions[fname])] if fname else\
            sorted(self.__functions.iteritems(), key=lambda f:f[1]['start'])
        for n, f in fl:
            s += 'CFG of %s:\n'%n
            for i, b in sorted(f['blocks'].iteritems(), key=lambda b:b[1]['start']):
                if len(b['succ']) > 0:
                    e = b['start'] + b['size']
                    for succ in b['succ']:
                        s += '  -- B%d -> B%d'%(i, succ)
                        t = b['succ'][succ]
                        if t > 0: s += ' (%d)'%t
                        if f['blocks'][succ]['start'] == e: s += ' (F)'
                        s +='\n'
            s += '\n'
        return s

    def get_call_graph_str(self, show_bolcks):
        s = ''
        for n, f in sorted(self.__functions.iteritems(),
                           key=lambda f:f[1]['start']):
            if len(f['callee']) > 0:
                s +='Function %s calls:\n'%n
                for c in f['callee']:
                    s += ' -- %s in'%c
                    for i, b in sorted(f['blocks'].iteritems(),
                                       key=lambda b:b[1]['start']):
                        if c in b['callee']: s+=' B%d (%d), '%(i,b['callee'][c])
                    s += '(Total %d)'%f['callee'][c]
                    s +='\n'
        return s

    def get_func_exe_time(self, func_list=None):
        p = {}
        if not func_list: func_list = sorted(self.__functions.keys());
        for f in func_list:
            t = 0
            func = self.__functions[f]
            for bb in func['blocks'].values(): t += bb['exe']
            p[f] = t
        return p

    def get_func_called_count(self, func_list=None):
        '''The number each function in func_list is called.

            Note: we assume block 0 of a function is not in loop.
        '''
        p = {}
        if not func_list: func_list = sorted(self.__functions.keys());
        for f in func_list:
            p[f] = self.__functions[f]['blocks'][0]['exe']\
                / self.__functions[f]['blocks'][0]['size']
        return p

    def get_func_profile(self, func):
        p = {}
        for i, bb in sorted(self.__functions[func]['blocks'].iteritems()):
            p[i] = {'exe':bb['exe'], 'count':bb['exe']/bb['size']}
        return p

    def get_cross_func_br_sequence(self, callonly):
        seq = ''
        tr = sorted(self.__branch_trace, key=operator.itemgetter(0))
        for c, s, t in tr:
            sb, tb = self.get_block_by_addr(s), self.get_block_by_addr(t)
            if sb[0] != tb[0]:
                if callonly and tb[0] not in self.__functions[sb[0]]['callee']:
                    continue
                seq += '@%d %s.B%d->%s.B%d\n'%(c, sb[0], sb[1], tb[0], tb[1])
        return seq

    def get_branch_sequence(self):
        seq = ''
        tr = sorted(self.__branch_trace, key=operator.itemgetter(0))
        for c, s, t in tr:
            sb, tb = self.get_block_by_addr(s), self.get_block_by_addr(t)
            seq += '@%d %s.B%d->%s.B%d\n'%(c, sb[0], sb[1], tb[0], tb[1])
        return seq
    
    def get_cfg_dot(self, fname, draw_call):
        if fname not in self.__functions:
            raise ValueError('No function named %s'%fname)
        f = self.__functions[fname]
        s = 'digraph CFG_%s {\n    node [fontsize = "12"];\n\n'%fname
        for i, b in f['blocks'].iteritems():
            s +='    node%d[ label = "BB %d", shape=rect ];\n'%(i, i)
            for succ in b['succ']:
                s += '    node%d->node%d[weight=10]\n'%(i, succ)
            if not draw_call: continue
            for callee in b['callee']:
                s +='    node__%s_%d[ label = "%s ()", shape=rect, style=filled,'\
                    'fillcolor=lightblue ];\n'%(callee, i, callee)
                s +='    node%d->node__%s_%d[style=dashed, weight=1]\n'%(
                    i, callee, i)
        s += '}\n';
        return s

    def __str__(self):
        return self.get_symbol_str(True)


def read_solver_stab(stab_filename):
    '''Read a symbol table file'''
    with open(stab_filename) as f:
        lns = f.read().splitlines()
    p = SolverProgram(os.path.basename(os.path.dirname(stab_filename)))
    for l in lns:
        s = l.split(':')
        if s[0] == 'F':   p.add_function(s[1], int(s[2]), int(s[3]))
        elif s[0] == 'B': p.add_block(s[1], int(s[2]), int(s[3]), int(s[4]))
        elif s[0] == 'D': p.add_data_object(s[1], int(s[3]), int(s[4]),
                                            True if s[2]=='V' else False)
        else: raise ValueError('Cannot parse symbol table line %s'%l)
    return p

def read_solver_cfg(p, cfg_filename):
    with open(cfg_filename) as f:
        lns = f.read().splitlines()
    for l in lns:
        s = l.split(':')
        if s[1] == 'c':   p.add_call(s[0], int(s[2]), s[3])
        elif s[1] == 'e': p.add_local_branch(s[0], int(s[2]), int(s[3]))
        else: raise ValueError('Cannot parser CFG line %s'%l)

def read_branch_trace(p, tr_filename):
    with open(tr_filename) as f:
        lns = f.read().splitlines()
    for l in lns:
        s = l.split(':')
        p.add_taken_branch(int(s[0]), int(s[1]), int(s[2]))

def read_solver_bin(bin_ar):
    try:
        RB_WD = tempfile.mkdtemp()
        zfd = zipfile.ZipFile(bin_ar, 'r')
        zfd.extractall(RB_WD)
        cfg, stab, arch_config = None, None, None
        for r,_,fl in os.walk(RB_WD):
            for f in fl:
                if f.endswith('.cfg'):
                    if cfg: raise RuntimeError('Too many CFG files')
                    cfg = os.path.join(r, f)
                elif f.endswith('.stab'):
                    if stab: raise RuntimeError('Too many symbol table files')
                    stab = os.path.join(r, f)
                elif f == 'arch.json':
                    arch_config = os.path.join(r, f)
        if not stab: raise RuntimeError('No symbol table found')
        program = read_solver_stab(stab)
        if cfg: read_solver_cfg(program, cfg)
        if arch_config: program.set_arch(arch_config)
    finally:
        if RB_WD: shutil.rmtree(RB_WD)
    return program
