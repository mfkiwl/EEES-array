import sys, os
from stat_utils import *

class OperationStat(object):
    StatKeyMap = {'N':'bp_wr', 'W':'wb_wr', 'w':'bp_rd', 'R':'reg_wr',
                  'r':'reg_rd','n':'bp_rd', 'F':'flag_wr', 'f':'flag_wr',
                  'c':'comm_rd','i':'imm_rd', 'M':'store', 'm':'load'}
    def __init__(self, op_str):
        self.op_type = 'unknown'
        self.opcode  = 'nop'
        self.__stat = {}
        comp = op_str.split('|')
        self.op_type, self.opcode = comp[0].split('.')
        if len(comp) < 2: return
        for k in comp[1:]:
            try: self.__inc_stat(OperationStat.StatKeyMap[k])
            except KeyError:
                if k.startswith('p'): self.__stat['n_pred'] = int(k[1:])
                else: raise ValueError('Unknow stat key %s in %s'%(k, op_str))

    def __getitem__(self, key):
        return self.__stat[key] if key in self.__stat else 0

    def __inc_stat(self, key, inc=1):
        try: self.__stat[key] += inc
        except KeyError: self.__stat[key] = inc

    def __str__(self):
        if self.op_type == 'v':   t = '<PE>'
        elif self.op_type == 's': t = '<CP>'
        s = '%s%s:'%(t, self.opcode.lower())
        for k, v in sorted(self.__stat.iteritems()):
            if v: s += ' %s=%d'%(k, v)
        return s

class InstrStat(object):
    def __init__(self, *args):
        self.operations = []
        for s in args:
            self.operations.append(OperationStat(s))
    
    def __getitem__(self, key):
        if key == 'cycles': return 1
        t, k = None, key
        if key.startswith('cp_'): t, k = 's', key[3:]
        if key.startswith('pe_'): t, k = 'v', key[3:]
        c = 0
        for o in self.operations:
            if not t: c += o[k]
            elif o.op_type == t: c += o[k]
        return c

    def __str__(self):
        return '     '+'\n  || '.join([str(o) for o in self.operations])

class BasicBlockStat(object):
    def __init__(self):
        self.id = -1
        self.address = 0
        self.freq    = 0
        self.stat    = {}

    def add_stat(self, k, v):
        if k == 'id':        self.id = int(v)
        elif k == 'address': self.address = int(v)
        else: self.stat[k] = int(v)

    def get_stat(self, k, v):
        return self.stat[k]

    def get_dyn_stat(self, k):
        return self.freq * self.stat[k] if k in self.stat else 0

    def get_dyn_cycle(self):
        return self.freq * self.stat['issue_packet']

    def __str__(self):
        s = '>> BB_%d\n'%self.id\
            + 'address : %d\n'%self.address\
            + 'freq : %d\n'%self.freq
        for k, v  in self.stat.items():
            s += '%s : %d\n'%(k, v)
        return s

class FunctionStat(object):
    def __init__(self):
        self.name = None
        self.basic_blocks = []
        self.address  = 0
        self.stat     = {}

    def add_basic_block(self, b):
        self.basic_blocks.append(b)

    def add_stat(self, k, v):
        if k == 'name':      self.name = v
        elif k == 'address': self.address = int(v)
        else: self.stat[k] = int(v)

    def get_stat(self, k):
        if k == 'address': return self.address
        if k in self.stat: return self.stat[k]
        v = 0
        for bb in self.basic_blocks: v += bb.get_stat(k)
        return v

    def get_dyn_stat(self, k):
        if k == 'cycles': return self.get_dyn_cycle()
        v = 0
        for bb in self.basic_blocks: v += bb.get_dyn_stat(k)
        return v

    def get_dyn_cycle(self):
        c = 0
        for b in self.basic_blocks: c += b.get_dyn_cycle()
        return c
        
    def __str__(self):
        s = '>> Function %s()\n'%('%UNKNOWN%' if not self.name else self.name)\
            +'blocks : %d\n'%len(self.basic_blocks)
        for k, v in self.stat.items():
            s += '%s : %d\n'%(k, v)
        for bb in self.basic_blocks:
            s += '\n%s\n'%str(bb)
        return s

class ModuleStat(object):
    def __init__(self):
        self.functions = {}

    def add_function(self, f):
        if f.name: self.functions[f.name] = f
        else: self.functions['$anony_func_%d$'%len(self.functions)] = f

    def get_dyn_stat(self, k):
        v = 0
        for f in self.functions.values(): v += f.get_dyn_stat(k)
        return v

    def __str__(self):
        s = '%d functions: %s\n\n'%(len(self.functions), self.functions.keys())
        for n, f in self.functions.items():
            s += 'Function: %s\n'%n
            s += '----------' + '-'*len(n) + '\n'
            s += 'Cycles = %d\n'%f.get_dyn_cycle()
        return s

def parse_bb_stat(bb_stat_lns):
    bb = BasicBlockStat()
    for l in bb_stat_lns:
        s = l.split(':')
        if len(s) != 2: raise ValueError('Invalid stat line "%s"'%l)
        bb.add_stat(s[0], s[1])
    return bb

def parse_func_stat(func_stat_lns, ignore_func):
    in_block = False
    block_lns = []
    f = FunctionStat()
    for l in func_stat_lns:
        if l == '>> END BB statistics':
            in_block = False
            bb = parse_bb_stat(block_lns)
            if bb: f.add_basic_block(bb)
            block_lns = []
        elif l == '>> BEGIN BB statistics': in_block = True
        elif in_block: block_lns.append(l)
        else:
            s = l.split(':')
            if len(s) != 2: raise ValueError('Invalid stat line "%s"'%l)
            if s[0] == 'name' and s[1] in ignore_func: return None
            f.add_stat(s[0], s[1])
    return f

def parse_code_stat(code_stat_lns, ignore_func):
    stat = ModuleStat()
    s, e = section_index('function statistics', code_stat_lns)
    while s >= 0 and e >= 0:
        func_lns = code_stat_lns[s+1:e]
        f = parse_func_stat(func_lns, ignore_func)
        if f: stat.add_function(f)
        code_stat_lns = code_stat_lns[(e+1):]
        s, e = section_index('function statistics', code_stat_lns)
    return stat
