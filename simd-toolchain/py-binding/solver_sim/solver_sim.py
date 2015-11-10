from ctypes import cdll
import ctypes
import os
import sys

if sys.platform.startswith('win'):
    libname = os.path.join(os.path.dirname(__file__), 'solver_sim.dll')
elif sys.platform.startswith('darwin'):
    libname = os.path.join(os.path.dirname(__file__), 'libsolver_sim.dylib')
else:
    libname = os.path.join(os.path.dirname(__file__), 'libsolver_sim.so')

lib = cdll.LoadLibrary(libname)

lib.create_target_from_cfg.restype  = ctypes.c_void_p
lib.create_target_from_cfg.argtypes = [ctypes.c_char_p]

lib.create_target_from_string.restype  = ctypes.c_void_p
lib.create_target_from_string.argsypes = [ctypes.c_char_p]

lib.delete_target.restype  = None
lib.delete_target.argtypes = [ctypes.c_void_p]

lib.create_simulator.restype  = ctypes.c_void_p
lib.create_simulator.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]

lib.delete_simulator.restype  = None
lib.delete_simulator.argtypes = [ctypes.c_void_p]

lib.has_error.restype  = ctypes.c_bool
lib.has_error.argtypes = [ctypes.c_void_p]

lib.clear_error.restype  = None
lib.clear_error.argtypes = [ctypes.c_void_p]

lib.set_max_simulation_cycle.restype  = None
lib.set_max_simulation_cycle.argtypes = [ctypes.c_void_p, ctypes.c_ulonglong]

lib.set_trace_level.restype  = None
lib.set_trace_level.argtypes = [ctypes.c_void_p, ctypes.c_uint]

lib.set_log_level.restype  = None
lib.set_log_level.argtypes = [ctypes.c_void_p, ctypes.c_uint]

lib.add_sim_instr.restype  = ctypes.c_bool
lib.add_sim_instr.argtypes = [ctypes.c_void_p, ctypes.c_char_p]

lib.add_sim_data.restype  = ctypes.c_bool
lib.add_sim_data.argtypes = [ctypes.c_void_p, ctypes.c_char_p]

lib.add_sim_data_binary.restype  = ctypes.c_bool
lib.add_sim_data_binary.argtypes = [ctypes.c_void_p, ctypes.c_char_p]

lib.reset_simulator.restype  = None
lib.reset_simulator.argtypes = [ctypes.c_void_p]

lib.run_simulator.restype  = None
lib.run_simulator.argtypes = [ctypes.c_void_p]

lib.run_simulator_cycle.restype  = None
lib.run_simulator_cycle.argtypes = [ctypes.c_void_p, ctypes.c_ulonglong]

lib.add_pc_trap.restype  = None
lib.add_pc_trap.argtypes = [ctypes.c_void_p, ctypes.c_uint]

lib.remove_pc_trap.restype  = None
lib.remove_pc_trap.argtypes = [ctypes.c_void_p, ctypes.c_uint]

lib.clear_pc_trap.restype  = None
lib.clear_pc_trap.argtypes = [ctypes.c_void_p]

lib.run_simulator_pc_trap.restype  = None
lib.run_simulator_pc_trap.argtypes = [ctypes.c_void_p, ctypes.c_ulonglong]

lib.get_simulation_cycle.restype  = ctypes.c_ulonglong
lib.get_simulation_cycle.argtypes = [ctypes.c_void_p]

lib.get_max_cycle.restype  = ctypes.c_ulonglong
lib.get_max_cycle.argtypes = [ctypes.c_void_p]

lib.get_program_counter.restype  = ctypes.c_uint32
lib.get_program_counter.argtypes = [ctypes.c_void_p]

lib.simulation_finished.restype  = ctypes.c_bool
lib.simulation_finished.argtypes = [ctypes.c_void_p]

lib.get_scalar_mem_val.restype  = ctypes.c_uint32
lib.get_scalar_mem_val.argtypes = [ctypes.c_void_p, ctypes.c_uint]

lib.get_scalar_ctx_val.restype  = ctypes.c_uint32
lib.get_scalar_ctx_val.argtypes = [ctypes.c_void_p, ctypes.c_uint]

lib.get_vector_mem_val.restype  = None
lib.get_vector_ctx_val.restype  = None

lib.print_errors.restype  = None
lib.print_errors.argtypes = [ctypes.c_void_p]

lib.get_vector_len.restype  = ctypes.c_uint
lib.get_vector_len.argtypes = [ctypes.c_void_p]

lib.get_cp_ctx_size.restype  = ctypes.c_uint
lib.get_cp_ctx_size.argtypes = [ctypes.c_void_p]

lib.get_pe_ctx_size.restype  = ctypes.c_uint
lib.get_pe_ctx_size.argtypes = [ctypes.c_void_p]

lib.get_cp_dmem_size.restype  = ctypes.c_uint
lib.get_cp_dmem_size.argtypes = [ctypes.c_void_p]

lib.get_pe_dmem_size.restype  = ctypes.c_uint
lib.get_pe_dmem_size.argtypes = [ctypes.c_void_p]

lib.get_scalar_instr_str.restype = ctypes.c_size_t
lib.get_scalar_instr_str.argtypes = [ctypes.c_void_p, ctypes.c_uint,
                                     ctypes.c_char_p, ctypes.c_size_t]

lib.get_vector_instr_str.restype = ctypes.c_size_t
lib.get_vector_instr_str.argtypes = [ctypes.c_void_p, ctypes.c_uint,
                                     ctypes.c_char_p, ctypes.c_size_t]

lib.get_trace_size.restype = ctypes.c_size_t
lib.get_trace_size.argtypes = [ctypes.c_void_p]

lib.read_out_trace.restype = None
lib.read_out_trace.argtypes = [ctypes.c_void_p,ctypes.c_char_p,ctypes.c_size_t]

lib.clear_trace.restype = None
lib.clear_trace.argtypes = [ctypes.c_void_p]

class SolverSim(object):
    '''A simulator object for a specific target architecture
    Keyword arguments:
    cfg -- The target architecture config file or archtecture name. If cfg is a
           valid path to a file, a target architecture is created based on this
           file. Otherwise cfg is considered an architecture name.
    '''

    DEFAULT_MAX_CYCLE=100000000
    def __init__(self, cfg):
        self.__tgt = None
        self.__sim = None
        c = ctypes.c_char_p(cfg)
        if os.path.isfile(cfg): self.__tgt = lib.create_target_from_cfg(c)
        else: self.__tgt = lib.create_target_from_string(c)
        self.__sim=lib.create_simulator(self.__tgt,0,0) if self.__tgt else None
        if not self.__tgt: raise RuntimeError('Failed to create target')
        elif not self.__sim: raise RuntimeError('Failed to create simulator')

    def __del__(self):
        if self.__tgt: lib.delete_target(self.__tgt)
        if self.__sim: lib.delete_simulator(self.__sim)
    
    def has_error(self):
        if self.__sim: return lib.has_error(self.__sim)
        return True

    def add_instr_init(self, imem_file):
        '''Add an instruction memory init file.

        Note: Filename should end with .cp.imem_init or .pe.imem_init
        '''
        if not os.path.isfile(imem_file) and os.access(imem_file, os.R_OK):
            raise RuntimeError('Cannot access %s'%str(imem_file))
        if imem_file.endswith('.cp.imem_init'): imem_cmd = '0:cp:%s'%imem_file
        elif imem_file.endswith('.pe.imem_init'): imem_cmd = '0:pe:%s'%imem_file
        else: raise RuntimeError('Cannot determine how to use %s'%imem_file)
        if not lib.add_sim_instr(self.__sim, ctypes.c_char_p(imem_cmd)):
            raise RuntimeError('Instruction init with %s failed'%imem_file)

    def add_data_init(self, dmem_file):
        '''Add a data memory init file.

        Note: Filename should end with .cp.dmem_init or .pe.dmem_init
        '''
        if not os.path.isfile(dmem_file) and os.access(dmem_file, os.R_OK):
            raise RuntimeError('Cannot access %s'%str(dmem_file))
        if dmem_file.endswith('.cp.dmem_init'): dmem_cmd = '0:cp:%s'%dmem_file
        elif dmem_file.endswith('.pe.dmem_init'): dmem_cmd = '0:pe:%s'%dmem_file
        else: raise RuntimeError('Cannot determine how to use %s'%dmem_file)
        if not lib.add_sim_data(self.__sim, ctypes.c_char_p(dmem_cmd)):
            raise RuntimeError('Data init with %s failed'%dmem_file)

    def add_data_binary(self, dmem_file, target, address):
        '''Add file as binary initialization for data memoyr

        Keyword Arguments:
        dmem_file: the filename.
        target:   "cp" or "pe"
        address:  address to initialize
        '''
        dcmd = '0:%s:%d:%s'%(target, int(address), os.path.abspath(dmem_file))
        if not lib.add_sim_data_binary(self.__sim, ctypes.c_char_p(dcmd)):
            raise RuntimeError('Data init with %s for %s at %d failed'%(
                    dmem_file, target, int(address)))

    def add_program_init(self, prog):
        '''
        Initialze a program for the simulator. The function looks for the
        following files and load them to corresponding memory locations:
        1. %prog.cp.imem_init
        2. %prog.pe.imem_init
        3. %prog.cp.dmem_init
        4. %prog.pe.dmem_init

        Note: a RuntimeError is thrown if neither 1 or 2 exists.
        '''
        if os.path.isfile(prog) and prog.endswith('zip'): pass
        else:
            imem_init = False
            if os.path.isfile('%s.cp.imem_init'%prog):
                self.add_instr_init('%s.cp.imem_init'%prog)
                imem_init = True
            if os.path.isfile('%s.pe.imem_init'%prog):
                self.add_instr_init('%s.pe.imem_init'%prog)
                imem_init = True
            if not imem_init: raise RuntimeError('No instruction init file')
            if os.path.isfile('%s.cp.dmem_init'%prog):
                self.add_data_init('%s.cp.dmem_init'%prog)
            if os.path.isfile('%s.pe.dmem_init'%prog):
                self.add_data_init('%s.pe.dmem_init'%prog)

    def finished(self):
        "Return True if simulation is finished, otherwise False"
        return lib.simulation_finished(self.__sim)

    def reset(self):
        "Reset the processor."
        lib.reset_simulator(self.__sim)
    def step(self):
        "Run for one cycle"
        return self.run(1)

    def run(self, cycle=None):
        '''Run simulation for given number of cycles. If cycle is not given, it
           runs until the program finishes or the maximum cycle is reached.
        '''
        if lib.simulation_finished(self.__sim): return 0L
        s = lib.get_simulation_cycle(self.__sim)
        if not cycle: lib.run_simulator(self.__sim)
        else: lib.run_simulator_cycle(self.__sim, cycle)
        return lib.get_simulation_cycle(self.__sim) - s

    def run_pc_trap(self, traps, cycle=None):
        '''Run simulation for given number of cycles with PC trap. If cycle is
           not given, it runs until the program finishes or the maximum cycle
           is reached or it is trapped.
        '''
        if lib.simulation_finished(self.__sim): return 0L
        s = lib.get_simulation_cycle(self.__sim)
        if not cycle: cycle = SolverSim.DEFAULT_MAX_CYCLE
        lib.clear_pc_trap(self.__sim)
        for t in traps: lib.add_pc_trap(self.__sim, t)
        lib.run_simulator_pc_trap(self.__sim, cycle)
        return lib.get_simulation_cycle(self.__sim) - s

    def program_counter(self):
        return lib.get_program_counter(self.__sim)

    def cycle(self):
        "Get the current simulation cycle."
        return lib.get_simulation_cycle(self.__sim)

    def set_max_cycle(self, mc):
        "Set the maximum simulation cycle."
        lib.reset_simulator(self.__sim, ctypes.c_ulonglong(mc))

    def cp_mem(self, a):
        "Get the value of a word in CP data memory"
        return lib.get_scalar_mem_val(self.__sim, ctypes.c_uint(a))

    def cp_ctx(self, a):
        "Get the value of a word in CP context (RF + bypass)"
        return lib.get_scalar_ctx_val(self.__sim, ctypes.c_uint(a))

    def pe_mem(self, a):
        "Get the value of a word vector in PE data memory"
        s = self.pe_size()
        v = (ctypes.c_uint*s)(*[0]*s)
        vp = ctypes.cast(v, ctypes.POINTER(ctypes.c_uint*s))
        lib.get_vector_mem_val(ctypes.c_void_p(self.__sim),ctypes.c_uint(a),vp)
        return [i for i in v]

    def pe_ctx(self, a):
        "Get the value of a word vector in PE context (RF + bypass)"
        s = self.pe_size()
        v = (ctypes.c_uint*s)(*[0]*s)
        vp = ctypes.cast(v, ctypes.POINTER(ctypes.c_uint*s))
        lib.get_vector_ctx_val(ctypes.c_void_p(self.__sim),ctypes.c_uint(a),vp)
        return [i for i in v]

    def set_full_trace(self, t=True):
        "Enable or disable full simulation trace."
        lib.set_trace_level(self.__sim, 10 if t else 0)

    def clear_sim_error(self, t=True):
        "Reset simulation error status."
        lib.clear_error(self.__sim)

    def pe_size(self):
        "Get the number of PEs"
        return lib.get_vector_len(self.__sim)

    def cp_ctx_size(self):
        "Get the context size of CP"
        return lib.get_cp_ctx_size(self.__sim)
    def pe_ctx_size(self):
        "Get the context size of PE"
        return lib.get_pe_ctx_size(self.__sim)

    def cp_dmem_size(self):
        "Get the data memory size of CP"
        return lib.get_cp_dmem_size(self.__sim)
    def pe_dmem_size(self):
        "Get the data memory size of PE"
        return lib.get_pe_dmem_size(self.__sim)

    def get_cp_instr_str(self, addr):
        "Get the string of a CP operation"
        buff = ctypes.create_string_buffer(128)
        n = lib.get_scalar_instr_str(self.__sim, addr, buff, 256)
        if not n: raise RuntimeError('Cannot get CP instruction at %d'%addr)
        return buff.value
    def get_pe_instr_str(self, addr):
        "Get the string of a PE operation"
        buff = ctypes.create_string_buffer(128)
        n = lib.get_vector_instr_str(self.__sim, addr, buff, 256)
        if not n: raise RuntimeError('Cannot get PE instruction at %d'%addr)
        return buff.value

    def clear_sim_trace(self): lib.clear_trace(self.__sim)
    def read_sim_trace(self):
        "Read out simulation trace"
        s = lib.get_trace_size(self.__sim)
        buff = ctypes.create_string_buffer(s)
        lib.read_out_trace(self.__sim, buff, s)
        return buff.value
        
