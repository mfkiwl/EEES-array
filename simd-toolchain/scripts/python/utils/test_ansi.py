#!/usr/bin/env python
import sys, os, time, platform

enable_ansi = True

for handle in [sys.stdout, sys.stderr]:
    if (hasattr(handle, "isatty") and handle.isatty()) or \
        ('TERM' in os.environ and os.environ['TERM']=='ANSI'):
        if platform.system()=='Windows' and \
                not ('TERM' in os.environ and os.environ['TERM']=='ANSI'):
            enable_ansi = False
        else:
            enable_ansi = enable_ansi and True
    else:
        enable_ansi = False
    handle.flush()

