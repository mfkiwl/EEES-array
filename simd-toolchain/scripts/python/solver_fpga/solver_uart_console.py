import os, sys, cmd, glob, re
from optparse import OptionParser
from solver_host import SolverHost
d = os.path.join(os.path.dirname(__file__), '..')
if d not in sys.path: sys.path.append(d)
from utils.cmd_shell import *


class SolverUARTConsole(BaseShell):
    tool_msg = \
'''
================================================================================
=                           Solver UART Console                                =
================================================================================

To get help on how to use this tool, type "help"
To leave this program, press Ctrl+D or type "exit"
'''
    def __init__(self, port, baudrate):
        BaseShell.__init__(self)
        self.xm = xmodem.XModem(port=port, baudrate=baudrate)
        self.host = SolverHost(self.xm.send_data, self.xm.receive_data)
        self.add_alias('restart', 'reset')

    def preloop(self):pass
    def do_echo(self, line):
        try:
            self.host.send('a')
            d = self.host.receive()
            if d[0] == 0x01: print('Slave: %s'%str(d[1:]))
        except xmodem.XModemError as e:
            print_red(str(e))
    def do_bootloop(self, line):
        try: self.host.load_bootloop()
        except xmodem.XModemError as e: print_red(str(e))

    def do_reset(self, line):
        try: self.host.reset_slave()
        except xmodem.XModemError as e: print_red(str(e))

    def do_run(self, line):
        "run: start slave execution"
        try: self.host.start_slave()
        except xmodem.XModemError as e: print_red(str(e))

    def do_load(self, line):
        "load <file-list>: load memory files to slave"
        try:
            self.host.reset_slave()
            flist = line.split()
            for f in flist:
                if not os.path.isfile(f) or not os.access(f, os.R_OK):
                    return print_red('Cannot access file %s'%f)
                c = self.host.load_mem_file(f)
                print '%d words loaded from %s'%(c, f)
        except xmodem.XModemError as e: print_red(str(e))
    
    def do_dump(self, line):
        "dump cp|pe start size: dump slave data memory content"
        c = line.split()
        if len(c) < 3: return print_red('Usage: dump cp|pe start size')
        if c[0] == 'cp':   m = 2
        elif c[0] == 'pe': m = 4
        if not m: return print_red('Usage: dump cp|pe start size')
        try:
            d = self.host.get_mem_content(m, int(c[1]), int(c[2]), 4)
            for i in d: print '%08x'%i
        except xmodem.XModemError as e: print_red(str(e))
        except:print_red("Unexpected error: %s"%str(sys.exc_info()))

    def do_status(self, line):
        try:
            c, cfg, t = self.host.check_slave_status()
            print('Cycle:      %d'%c)
            print('Config:     0x%x'%cfg)
            print('Task Ready: %d'%t)
        except xmodem.XModemError as e:
            print_red(str(e))

    def do_write(self, line):
        "write val: write bytearray(val) to slave"
        d = bytearray(line.strip())
        try:
            self.host.send(d)
        except xmodem.XModemError as e:
            print_red(str(e))

    def do_read(self, line):
        try:
            d = self.host.receive()
            if d[0] == 0x01: print('Text: %s'%str(d[1:]))
            else:
                for i in d: print i
        except xmodem.XModemError as e:
            print_red(str(e))

    def do_stop(self, line):
        try:
            self.host.stop_slave()
        except xmodem.XModemError as e:
            print_red(str(e))

def parse_options():
    parser = OptionParser('Usage: %prog')
    parser.add_option("--port", dest="port", default="/dev/ttyUSB0",
                      help="Serial port name (/dev/ttyUSB0)")
    parser.add_option("--baudrate", dest="baudrate", type="int",
                      default=115200, help="Serial port baudrate (115200)")
    parser.add_option("--solver-prefix", dest="solver_prefix",
                      help="Specify installation path to Solver toolchain"\
                          " (default=$SOLVER_HOME)")
    parser.add_option("--solver-py-path", dest="solver_py_path",
                      help="Specify path to Solver Python modules"\
                          " (default=$SOLVER_HOME/lib/solver/python)")

    (opts, args) = parser.parse_args()
    if ('SOLVER_HOME' not in os.environ) and not opts.solver_prefix\
            and not opts.solver_py_path:
        raise RuntimeError("Solver installation path not specified")
    if not opts.solver_prefix and 'SOLVER_HOME' in os.environ:
        opts.solver_prefix = os.environ['SOLVER_HOME']
    if not opts.solver_py_path:
        opts.solver_py_path\
            = os.path.join(opts.solver_prefix, 'lib', 'solver', 'python')
    if opts.solver_py_path not in sys.path: sys.path.append(opts.solver_py_path)
    return (opts, args)

if __name__ == '__main__':
    (opts, args) = parse_options()
    from utils import xmodem
    from utils.print_color import *
    p = SolverUARTConsole(opts.port, opts.baudrate)
    p.cmdloop(SolverUARTConsole.tool_msg)
