import sys, os
from stat_utils import *
from code_stat import *
d = os.path.join(os.path.dirname(__file__), '..')
if d not in sys.path: sys.path.append(d)
from arch_config import *
from solver_program import solver_bin

class SimulationStat(object):
    def __init__(self, name):
        self.name       = name
        self.code_freq  = {}
        self.code_pred  = {}
        self.instr_stat = {}
        self.code_stat  = None
        self.arch       = None
        self.prog       = None
        self.__stat = {}
        self.__ignored_func = set(['__start'])

    def get_func_stat(self, func, key):
        if not self.prog: raise ValueError('No program infomation')
        f = self.prog[func]
        s, e = f['start'], f['start']+f['size']
        c = 0
        for adr in range(s, e):
            freq = self.code_freq.get(adr, 0)
            if freq == 0: continue
            i_stat = self.instr_stat.get(adr)
            if not i_stat:
                if key == 'cycles': c += freq
                continue
            cc = i_stat[key]
            if key.startswith('pe_'):
                if not self.arch: raise ValueError('No target information')
                c += cc * (freq*self.arch.pe.size - self.code_pred.get(adr, 0))
            else: c += cc * freq
        return c

    def __getitem__(self, key):
        if key in self.__stat: return __stat[key]
        if not self.prog:
            if self.code_stat: return code_stat.get_dyn_stat(key)
            else: raise ValueError('No stat found')
        func_list = [f for f in self.prog.func_iterkeys()
                     if f not in self.__ignored_func]
        c = 0
        for f in func_list:
            c += self.get_func_stat(f, key)
        return c
        
    def __str__(self):
        s  = 'Simulation statistics of: %s\n'%self.name
        s += '==========================' + '='*len(self.name) + '\n'
        if self.arch:
            s += '\nTarget Architecture\n'
            s += '-------------------\n'
            s += str(self.arch) + '\n'
        if self.code_stat:
            s += '\nSimulated program\n'
            s += '-----------------\n'
            s += str(self.code_stat) + '\n'
        return s

    def ignore_function(self, f): self.__ignored_func.add(f)

def parse_simulation_stat(sim_stat_lns, n):
    stat = SimulationStat(n)
    cf_begin, cf_end = section_index('code frequency', sim_stat_lns)
    if not cf_begin or not cf_end:
        raise ValueError('No code frequency section found')

    for f in sim_stat_lns[cf_begin+1:cf_end]:
        s = f.split(':')
        a, c = int(s[0]), int(s[1])
        stat.code_freq[a] = c
        if len(s) > 2:
            ci = 3 if s[2].isdigit() else 2
            if s[2].isdigit(): stat.code_pred[a] = int(s[2])
            if len(s) >= ci: stat.instr_stat[a] = InstrStat(*s[ci:])
    return stat

def process_sim_dir(sim_dir, stat_file='sim.stat.txt', arch_file = 'arch.json',
                    cg_stat='codegen.stat.txt', ignore_func=['__start']):
    if not os.path.isdir(sim_dir):
        print('Invalid sim directory')
        return
    dl = os.listdir(sim_dir)
    if stat_file not in dl:
        print('No sim statistics file (%s) found in %s'%(stat_file, sim_dir))
        return
    sim_stat_lns = [l.strip() for l in
                    open(os.path.join(sim_dir, stat_file)).read().split('\n')
                    if l.strip()]
    stat = parse_simulation_stat(sim_stat_lns, sim_dir)
    if cg_stat in dl:
        code_stat_lns = [l.strip() for l in
                         open(os.path.join(sim_dir, cg_stat)).read().split('\n')
                         if l.strip()]
        code_stat = parse_code_stat(code_stat_lns, ignore_func)
        for n, f in code_stat.functions.items():
            for b in f.basic_blocks:
                b.freq = stat.code_freq[b.address] if b.address\
                    in stat.code_freq else 0
        stat.code_stat = code_stat
    if arch_file in dl:
        stat.arch = arch_config.read_arch_config(
            os.path.join(sim_dir, arch_file))
    for f in dl:
        if f.endswith('.stab'):
            stat.prog = solver_bin.read_solver_stab(os.path.join(sim_dir, f))
    return stat

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage sim_stat.py <sim_dir>')
        exit(-1)
    stat = process_sim_dir(sys.argv[1])
    print stat
