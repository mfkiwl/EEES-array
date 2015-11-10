from ctypes import cdll
import ctypes
import os
import sys

if sys.platform.startswith('win'):
    libname = os.path.join(os.path.dirname(__file__), 'solver_codegen.dll')
elif sys.platform.startswith('darwin'):
    libname = os.path.join(os.path.dirname(__file__), 'libsolver_codegen.dylib')
else:
    libname = os.path.join(os.path.dirname(__file__), 'libsolver_codegen.so')

lib = cdll.LoadLibrary(libname)

lib.create_codegen_driver_from_cfg.restype  = ctypes.c_void_p
lib.create_codegen_driver_from_cfg.argtypes = [ctypes.c_char_p, ctypes.c_int]

lib.create_codegen_driver_from_str.restype  = ctypes.c_void_p
lib.create_codegen_driver_from_str.argsypes = [ctypes.c_char_p, ctypes.c_int]

lib.delete_codegen_driver.restype  = None
lib.delete_codegen_driver.argtypes = [ctypes.c_void_p]

lib.set_log_level.restype  = None
lib.set_log_level.argtypes = [ctypes.c_void_p, ctypes.c_uint]

lib.set_cg_bare_mode.restype  = None
lib.set_cg_bare_mode.argtypes = [ctypes.c_void_p, ctypes.c_bool]

lib.set_cg_no_sched.restype  = None
lib.set_cg_no_sched.argtypes = [ctypes.c_void_p, ctypes.c_bool]

lib.init_cg_pipeline.restype  = ctypes.c_bool
lib.init_cg_pipeline.argtypes = [ctypes.c_void_p]

lib.add_sir_source.restype  = ctypes.c_bool
lib.add_sir_source.argtypes = [ctypes.c_void_p, ctypes.c_char_p]

lib.generate_target_code.restype  = ctypes.c_bool
lib.generate_target_code.argtypes = [ctypes.c_void_p]

lib.run_codegen_until.restype  = ctypes.c_bool
lib.run_codegen_until.argtypes = [ctypes.c_void_p, ctypes.c_char_p]

lib.set_pass_log_level.restype  = None
lib.set_pass_log_level.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_uint]

lib.write_target_asm_file.restype  = ctypes.c_bool
lib.write_target_asm_file.argtypes = [ctypes.c_void_p, ctypes.c_char_p]

lib.print_cg_stat.restype  = None
lib.print_cg_stat.argtypes = [ctypes.c_void_p]

lib.print_target_code.restype  = None
lib.print_target_code.argtypes = [ctypes.c_void_p]

lib.print_cg_passes.restype  = None
lib.print_cg_passes.argtypes = [ctypes.c_void_p]

class SolverCodeGen(object):
    '''A code generation driver for a specific target architecture
    Keyword arguments:
    cfg -- The target architecture config file or archtecture name. If cfg is a
           valid path to a file, a target architecture is created based on this
           file. Otherwise cfg is considered an architecture name.
    log_level -- Verbose level
    '''
    def __init__(self, cfg, log_level=0):
        self.__drv = None
        c = ctypes.c_char_p(cfg)
        self.__drv=lib.create_codegen_driver_from_cfg(c, log_level) \
            if os.path.isfile(cfg)\
            else lib.create_codegen_driver_from_str(c, log_level)
        if not self.__drv:
            raise RuntimeError('Failed to create code generation driver')
        self.__tgt_init = False
        self.__init_target()
        self.set_log_level(0)

    def __del__(self):
        if self.__drv: lib.delete_codegen_driver(self.__drv)

    def __init_target(self):
        if not self.__tgt_init:
            self.__tgt_init = lib.init_cg_pipeline(self.__drv)
            if not self.__tgt_init:
                raise RuntimeError('CodeGen pipeline initialization failed')

    def add_ir(self, ir_file):
        '''Add an SIR source file'''
        if not os.path.isfile(ir_file) and os.access(ir_file, os.R_OK):
            raise RuntimeError('Cannot access %s'%str(ir_file))
        self.__init_target()
        if not lib.add_sir_source(self.__drv, ir_file):
            raise RuntimeError('Failed to add SIR in %s'%ir_file)

    def generate_target_code(self):
        self.__init_target()
        if not lib.generate_target_code(self.__drv):
            raise RuntimeError('Target code generation failed')

    def run_codegen_until(self, p):
        self.__init_target()
        if not lib.run_codegen_until(self.__drv, p):
            raise RuntimeError('Target code generation failed')

    def save_target_asm(self, out_file):
        if not lib.write_target_asm_file(self.__drv, out_file):
            raise RuntimeError('Failed to write target assembly to %s'%out_file)

    def print_codegen_stat(self):
        lib.print_cg_stat(self.__drv)

    def print_codegen_passes(self):
        lib.print_cg_passes(self.__drv)

    def set_log_level(self, l):
        lib.set_log_level(self.__drv, l)

    def set_pass_log_level(self, p, l):
        lib.set_pass_log_level(self.__drv, p, l)

def compile_sir_to_target(*args, **kwargs):
    '''compile a list of SIR files into target assembly code.
    The list of input files is specified by positional arguments.

    Keyword arguments:
    arch -- The target architecture string or config file. default to 'baseline'
    out  -- Output file. If not specified, output is discarded.
    log_level -- The verbose level to be set.
    log_pass  -- Enable logging for the given list of passes
    verbose   -- Run in verbose mode
    '''
    if not args:
        raise ValueError('IR files should be given as positional args')
    arch = 'baseline' if 'arch' not in kwargs else kwargs['arch']
    cg = SolverCodeGen(arch)
    for f in args: cg.add_ir(f)
    log_level = int(kwargs['log_level']) if 'log_level' in kwargs else 1
    if 'log_pass' in kwargs:
        for p in kwargs['log_pass']: cg.set_pass_log_level(p, log_level)
    if 'verbose' in kwargs: cg.set_log_level(log_level)
    cg.generate_target_code()
    if 'out' in kwargs: cg.save_target_asm(kwargs['out'])
