import os
import sys
import time
import errno
import traceback
import subprocess
import hashlib
import shutil
import json

def find_exe_path(exe_name, exe_path):
    """
    Check if there is an executable named exe_name in the exe_path. Return the
    full path of the executable if it exists and it is accessible.
    If not, return None.
    """
    nbin = os.path.join(exe_path, exe_name)
    return nbin if os.path.isfile(nbin) and os.access(nbin, os.X_OK) else None

def find_tools(tools, prefix):
    "Find all the executables specified in tools in the prefix path"
    return tuple([find_exe_path(t, prefix) for t in tools])

def get_path_basename(p):
    """
    Get the basename without extension of a path.
    For example, '/a/b/c.t.ext' returns 'c.t'.
    """
    return os.path.basename(os.path.splitext(p)[0])

def mkdir_p(d):
    "Create a new director with path d. Does nothing if d already exists"
    try:
        os.makedirs(d)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

def remove_p(f):
    "Remove file f. Does nothing if f does not exist."
    try:
        os.remove(f)
    except OSError as exception:
        if exception.errno != errno.ENOENT:
            raise

def run_command(sh_cmd, stdout=None, stderr=None, timeout=None):
    """
    Execute a command using subprocess module, and return the return-code of
    the command.
    """
    if type(sh_cmd) != list: sh_cmd = sh_cmd.split()
    rc = -1
    try:
        sp = subprocess.Popen(sh_cmd, stdout=stdout, stderr=stderr)
        ts = 0.2
        while sp.poll() == None:
            time.sleep(0.2)
            ts += 0.2
            if timeout and ts > timeout:
                os.kill(sp.pid, signal.SIGTERM)
                raise RuntimeError('Timeout running "%s"'%sh_cmd)
        rc = sp.returncode
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
        traceback.print_tb(sys.exc_info()[2])
    return rc

def folder_latest_mtime(d):
    mt = os.path.getmtime(d)
    for r, d, fl in os.walk(d):
        for f in fl: mt = max(mt, os.path.getmtime(os.path.join(r, f)))
    return mt

def md5_file(name, chunk_size=128):
    """
    Get the md5 hash value of the content of a file.

    Arguments:
    name       -- Path to the input file.
    chunk_size -- Number of blocks (128 bytes) to be process in one iteration.
                  Default value is 128. Can be tune for better performance.
    """
    m = hashlib.md5()
    with open(name,'rb') as f:
        for chunk in iter(lambda: f.read(chunk_size*m.block_size), b''):
            m.update(chunk)
    return m.hexdigest()

def parse_size_str(sz_str):
    try: s = int(sz_str)
    except ValueError:
        istr = sz_str
        n = ''
        while istr and istr[0].isdigit() or istr[0] == '.':
            n += istr[0]
            istr = istr[1:]
        istr = istr.strip().lower()
        try: n = float(n)
        except ValueError: raise ValueError('Cannot interpret %s'%sz_str)
        if istr == 'k' or istr == 'kb':   s = n * 1024
        elif istr == 'm' or istr == 'mb': s = n * 1024*1024
        elif istr == 'g' or istr == 'gb': s = n * 1024*1024*1024
        elif istr == 't' or istr == 'tb': s = n * 1024*1024*1024*1024
        elif istr == 'p' or istr == 'pb': s = n * 1024*1024*1024*1024*1024
        else: raise ValueError('Cannot interpret %s'%sz_str)
        if not s.is_integer(): raise ValueError('Invalid size %s'%sz_str)
        s = int(s)
    if s < 0: raise ValueError('Invalid size %s'%sz_str)
    return int(s)

def build_file_hash(file_list):
    """
    Build a dict that contains the MD5 hash of files in file_list
    """
    file_hash = {}
    for f in file_list:
        file_hash[os.path.abspath(f)] = md5_file(f)
    return file_hash

def copy_if_newer(src, prefix):
    d = os.path.basename(src)
    dest = os.path.join(prefix, d)
    mkdir_p(dest)
    rd = src[src.find(src[:src.rfind(d)]):]
    for r,_, fl in os.walk(src):
        t = os.path.join(dest, r[r.find(rd)+len(rd):].lstrip(os.sep))
        mkdir_p(t)
        for f in fl:
            fp = os.path.join(r, f)
            dp = os.path.join(t, f)
            if os.path.exists(dp):
                if os.path.getmtime(fp) > os.path.getmtime(dp):
                    shutil.copy(fp, dp)
            else: shutil.copy(fp, dp)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print 'Usage: sys_utils <command> [options]'
        exit(0)

    if sys.argv[1] == 'copy-if-newer':
        if len(sys.argv) != 4:
            print 'Usage: sys_utils copy-if-newer <src> <prefix>'
            exit(0)
        copy_if_newer(sys.argv[2], sys.argv[3])
    else: print 'Unknow command %s'%sys.argv[1]
