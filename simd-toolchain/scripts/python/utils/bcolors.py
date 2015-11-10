import test_ansi

class bcolors:
    PURPLE = '\033[95m' if test_ansi.enable_ansi else ''
    BLUE   = '\033[94m' if test_ansi.enable_ansi else ''
    GREEN  = '\033[92m' if test_ansi.enable_ansi else ''
    YELLOW = '\033[93m' if test_ansi.enable_ansi else ''
    RED    = '\033[91m' if test_ansi.enable_ansi else ''
    ENDC   = '\033[0m'  if test_ansi.enable_ansi else ''
    BOLD   = '\033[1m'  if test_ansi.enable_ansi else ''
