import os, sys
import tempfile
import shutil
import zipfile
from solver_sim import SolverSim
from solver_program.solver_bin import *
import utils

class SolverSimContext(object):
    '''Class that controls simulation of a program on a specific architecture'''
    def __init__(self, program, verbose=False):
        self.__program_path = os.path.abspath(program)
        self.__program  = None
        self.__sim      = None
        self.__pc_traps = []
        self.__verbose  = verbose
        self.__load_program(program)
        self.__cycle_limit = 10000000000L
        self.__name = self.__program.get_archive_name() if self.__program\
            else utils.sys_utils.get_path_basename(self.__program_path)

    def set_verbose(self, v): self.__verbose = v
    def get_program_name(self): return self.__name
    def get_program_path(self): return self.__program_path
    def get_program_addr_info(self, adr):
        return self.__program.get_block_by_addr(adr) if self.__program else None
    def get_program_address(self, func, bb, end):
        if not self.__program: return None
        f = self.__program.get_function(func)
        if bb:
            b = f['blocks'][bb]
            adr = b['start']
            if end: adr += b['size']-1
        else:
            adr = f['start']
            if end: adr += f['size']-1
        return adr

    def func_keys(self):
        return self.__program.func_keys() if self.__program else None
    def func_iterkeys(self):
        return self.__program.func_iterkeys() if self.__program else None
    def dobj_keys(self):
        return self.__program.dobj_keys() if self.__program else None
    def dobj_iterkeys(self):
        return self.__program.dobj_iterkeys() if self.__program else None
    def has_function(self, f):
        return self.__program.has_function(f) if self.__program else False
    def get_function(self, f):
        return self.__program.get_function(f) if self.__program else None
    def has_data_object(self, o):
        return self.__program.has_data_object(o) if self.__program else False
    def get_data_object(self, o):
        return self.__program.get_data_object(o) if self.__program else None

    def clear_pc_traps(self): self.__pc_traps = []
    def add_pc_trap(self, pc): self.__pc_traps.append(pc)

    def finished(self):  return self.__sim and self.__sim.finished()
    def has_error(self): return self.__sim and self.__sim.has_error()

    def get_pe_size(self): return self.__sim.pe_size()
    def get_pc(self): return self.__sim.program_counter() if self.__sim else -1
    def get_cycle(self): return self.__sim.cycle()
    def get_context(self, comp, idx):
        if comp == 'cp':
            if not idx: idx = range(self.__sim.cp_ctx_size())
            return [(i, self.__sim.cp_ctx(i)) for i in sorted(idx)
                    if i < self.__sim.cp_ctx_size()]
        else:
            if not idx: idx = range(self.__sim.pe_ctx_size())
            return [(i, self.__sim.pe_ctx(i)) for i in sorted(idx)
                    if i < self.__sim.pe_ctx_size()]
    def get_memory(self, comp, addr):
        if comp == 'cp': return [(i,self.__sim.cp_mem(i)) for i in sorted(addr)]
        else:            return [(i,self.__sim.pe_mem(i)) for i in sorted(addr)]
    def get_instr_str(self, comp, addr):
        if comp == 'cp':   return self.__sim.get_cp_instr_str(addr)
        elif comp == 'pe': return self.__sim.get_pe_instr_str(addr)
        return ''

    def reset(self):
        if self.__sim:
            self.__sim.reset()
            self.__sim.clear_sim_error()

    def run(self, c=None):
        if not self.__sim: raise RuntimeError('Simulator not initialized')
        if not c: c = self.__cycle_limit
        if not self.__pc_traps: n = self.__sim.run(c)
        else:
            n = self.__sim.run_pc_trap(self.__pc_traps, c)
            pc = self.__sim.program_counter()
            if self.__verbose:
                if pc in self.__pc_traps:
                    b = self.get_program_addr_info(pc)
                    print 'Reach breakpoint at %d'%pc,
                    print ' (in %s.B%d)'%(b[0], b[1]) if b else ''
        return n

    def clear_sim_trace(self): self.__sim.clear_sim_trace()
    def set_full_trace(self,t ):  self.__sim.set_full_trace(t)
    def read_sim_trace(self): return self.__sim.read_sim_trace()
    def __load_program(self, program):
        try: self.__program = read_solver_bin(program)
        except RuntimeError: self.__program = None
        try:
            RB_WD = tempfile.mkdtemp()
            zfd = zipfile.ZipFile(program, 'r')
            zfd.extractall(RB_WD)
            self.__sim = None
            bin_prefix = None
            for r,d,fl in os.walk(RB_WD):
                for f in fl:
                    if f == 'arch.json':
                        if self.__verbose:
                            print 'Initializing simulator with config file'
                        self.__sim = SolverSim(os.path.join(r, f))
                    if f.endswith('.cp.imem_init'):
                        bin_prefix = os.path.join(r,f[:f.find('.cp.imem_init')])
            if not self.__sim:
                if self.__verbose:
                    print 'Initializing simulator with default arch'
                self.__sim = SolverSim('baseline')
            if not bin_prefix: raise RuntimeError('No binary file found')
            self.__sim.add_program_init(bin_prefix)
        finally:
            if RB_WD: shutil.rmtree(RB_WD)
        self.__sim.reset()
            
