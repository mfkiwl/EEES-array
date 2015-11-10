import struct
import os, sys
local_root = os.path.join(os.path.dirname(__file__), '..')
if local_root not in sys.path: sys.path.append(local_root)

from solver_program.solver_mem_utils import read_vlog_hexdump

class SolverHost(object):
    def __init__(self, send, receive):
        self.send = send
        self.receive=receive

    def stop_slave(self):
        self.send('\xFF')

    def write_slave(self, data):
        "write a bytearray to slave"
        self.send(data)

    def read_slave(self, data):
        "read a bytearray from slave"
        self.receive(data)

    def reset_slave(self): self.send('\xFD')
    def start_slave(self): self.send('\xFC')

    def check_slave_status(self):
        self.send(bytearray('\xFE'))
        d = self.receive()
        if d[0] == 0x00:
            i, cycle, cfg, task = struct.unpack('<IIII', buffer(d))
            return cycle, cfg, task
        else: return None, None, None

    def load_bootloop(self):self.send(bytearray('\xFB'))

    def send_mem_content(self, m_type, addr, data, word_size):
        word_type = 'I' if word_size == 4 else 'H'
        head = ((len(data) & 0xFFFFFF) << 8) | m_type
        m = bytearray(struct.pack('<'+'I'*(2), head, addr))
        m += bytearray(struct.pack('<'+word_type*len(data), *data))
        self.send(m)
        return struct.unpack('<I', buffer(self.receive()))[0]

    def load_mem_content(self, mem_file, m_type, word_size):
        d = read_vlog_hexdump(mem_file)
        last_adr = -10
        curr_start = -10
        curr_blk   = []
        c = 0
        for adr in sorted(d.iterkeys()):
            if adr != (last_adr+1):
                if len(curr_blk) > 0:
                    c += self.send_mem_content(
                        m_type, curr_start, curr_blk, word_size)
                curr_blk = []
                curr_start = adr
            curr_blk.append(d[adr])
            last_adr = adr
        if len(curr_blk) > 0:
            c += self.send_mem_content(m_type, curr_start, curr_blk, word_size)
        return c



    def load_mem_file(self, filename):
        if not os.path.isfile(filename) or not os.access(filename, os.R_OK):
            return None
        if filename.endswith('.cp.imem_init'):
            return self.load_mem_content(
                mem_file=filename, m_type=0x1, word_size=4)
        elif filename.endswith('.cp.dmem_init'):
            return self.load_mem_content(
                mem_file=filename, m_type=0x2, word_size=4)
        elif filename.endswith('.pe.imem_init'):
            return self.load_mem_content(
                mem_file=filename, m_type=0x3, word_size=4)
        elif filename.endswith('.pe.dmem_init'):
            return self.load_mem_content(
                mem_file=filename, m_type=0x4, word_size=4)
        elif filename.endswith('.zip'):pass
    
    def get_mem_content(self, mem_type, addr, size, word_size):
        head = ((size & 0xFFFFFF) << 8) | mem_type | 0x10
        m = bytearray(struct.pack('<II', head, addr))
        self.send(m)
        word_type = 'I' if word_size == 4 else 'H'
        d = self.receive()[:-1]
        return struct.unpack('<'+word_type*size, buffer(d))
