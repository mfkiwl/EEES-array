from bcolors import bcolors

def print_purple(s):
    print bcolors.PURPLE+s+bcolors.ENDC

def print_blue(s):
    print bcolors.BLUE+s+bcolors.ENDC

def print_green(s):
    print bcolors.GREEN+s+bcolors.ENDC

def print_yellow(s):
    print bcolors.YELLOW+s+bcolors.ENDC

def print_red(s):
    print bcolors.RED+s+bcolors.ENDC

def write_purple(s, f):
    f.write(bcolors.PURPLE+s+bcolors.ENDC)

def write_blue(s, f):
    f.write(bcolors.BLUE+s+bcolors.ENDC)

def write_green(s, f):
    f.write(bcolors.GREEN+s+bcolors.ENDC)

def write_yellow(s, f):
    f.write(bcolors.YELLOW+s+bcolors.ENDC)

def write_red(s, f):
    f.write(bcolors.RED+s+bcolors.ENDC)

def purple_str(s): return bcolors.PURPLE+s+bcolors.ENDC
def blue_str(s):   return bcolors.BLUE+s+bcolors.ENDC
def green_str(s):  return bcolors.GREEN+s+bcolors.ENDC
def yellow_str(s): return bcolors.YELLOW+s+bcolors.ENDC
def red_str(s):    return bcolors.RED+s+bcolors.ENDC
def bold_str(s):   return bcolors.BOLD+s+bcolors.ENDC
