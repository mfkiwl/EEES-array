import os
import sys
import zipfile
import traceback
import tempfile
import shutil
from utils import sys_utils

def get_rtl_tools(flow):
    """Return a tuple: (verilog compiler, simulator)"""
    if flow == 'vsim':       return 'vsim', 'vsim'
    elif flow == 'iverilog': return 'iverilog', 'vvp'
    elif flow == 'ncsim':    return 'ncvlog', 'ncsim'
    else: raise RuntimeError('Unknow RTL flow "%s"'%flow)
