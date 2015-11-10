import os
import sys
import zipfile
import traceback
import tempfile
import shutil
from utils import sys_utils

def is_hexdigit(x): return x in '0123456789abcdefABCDEF'

def get_vlog_hexdump_width(filename):
    with open(filename) as f:
        for l in f.readline():
            for t in l.split():
                t = t.strip()
                try:
                    v = int(t, 16)
                    return len(t)
                except ValueError: pass

def read_vlog_hexdump(dump_file, ignore_udef=True, data=None):
    """Read a Verilog Hex dump file, and return a dict containing address:value
pairs.

:param dump_file: path to the Hex dump file.
:param ignore_udef: whether to ignore undefined values (i.e., 'X'). If this is
                    set to False, each entry with underfined value will be
                    mapped to an item with value None in the output
:returns a dict containing address:value pairs."""
    if not data: data = {}
    with open(dump_file) as f:
        lines = [l.strip() for l in f.read().split('\n') if not
                 (l.strip().startswith('//') or l.strip().startswith('#'))]
    addr = 0
    for l in lines:
        for t in l.split():
            if t.startswith('@'): addr = int(t[1:], 16)
            else:
                try: v = int(t, 16)
                except ValueError:
                    if not any([i != 'x' and i != 'X' and
                                not is_hexdigit(i) for i in t]): v = None
                    else: raise ValueError('Illegal hex value "%s"'%t)
                if v != None or not ignore_udef: data[addr] = v
                addr += 1
    return data

def write_vlog_hexdump(dump, dwidth, out_file):
    last_adr = -10
    pat = '{0:0='+str(dwidth)+'x}\n' if dwidth > 0 else '{0:x}\n'
    with open(out_file, 'w') as of:
        for adr in sorted(dump.iterkeys()):
            if adr != (last_adr+1): of.write('@%x\n'%adr)
            last_adr = adr
            d = dump[adr] if dump[adr] != None else 0
            of.write(pat.format(d))

def compare_vlog_hexdump(dump, ref, ignore_undef=True):
    diff = {}
    for adr, val in ref.items():
        if adr not in dump:
            if not ignore_undef: diff[adr] = (None, val)
        elif dump[adr] != val:
            if dump[adr] != None or val != 0 or not ignore_undef:
                diff[adr] = (dump[adr], val)
    return diff

def extract_mem_init(bin_ar, out_path):
    zfd = None
    try:
        zfd = zipfile.ZipFile(bin_ar, 'r')
        for f in zfd.namelist():
            filename = os.path.basename(f)
            if not filename.endswith('mem_init'): continue
            source = zfd.open(f)
            target = file(os.path.join(out_path, filename), "wb")
            shutil.copyfileobj(source, target)
            source.close()
            target.close()
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
        traceback.print_tb(sys.exc_info()[2])
    finally:
        if zfd: zfd.close()

def create_binary_archive(name, out_path, cp_imem, cp_dmem=None,
                          pe_imem=None, pe_dmem=None):
    of = os.path.join(out_path, '%s.zip'%name)
    zfd = None
    try:
        zfd = zipfile.ZipFile(of, 'w')
        bin_p = os.path.join(name, 'bin')
        if not os.access(cp_imem, os.R_OK):
            raise RuntimeError('Failed to open CP i-mem: %s'%cp_imem)
        zfd.write(cp_imem, os.path.join(bin_p, '%s.cp.imem_init'%name))
        if cp_dmem and os.access(cp_dmem, os.R_OK):
            zfd.write(cp_dmem, os.path.join(bin_p, '%s.cp.dmem_init'%name))
        if pe_imem and os.access(pe_imem, os.R_OK):
            zfd.write(pe_imem, os.path.join(bin_p, '%s.pe.imem_init'%name))
        if pe_dmem and os.access(pe_dmem, os.R_OK):
            zfd.write(pe_dmem, os.path.join(bin_p, '%s.pe.dmem_init'%name))
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
        traceback.print_tb(sys.exc_info()[2])
        raise RuntimeError('failed to create binary %s'%of)
    finally:
        if zfd: zfd.close()

