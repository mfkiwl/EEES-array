import os, sys, cmd, glob, re
from utils.print_color import *
import eval_expr

class BaseShell(cmd.Cmd, object):
    prompt = '>> '
    doc_header='Available commands (type help <topic> for more information):'
    def __init__(self):
        cmd.Cmd.__init__(self)
        self.__aliases = {'quit':'exit'}

    def add_alias(self, alias, command):
        if hasattr(self, 'do_'+alias):
            return print_red('Cannot alias existing command "%s"'%alias)
        if hasattr(self, 'do_'+command): self.__aliases[alias] = command
        elif command in self.__aliases:
            self.__aliases[alias] = self.__aliases[command]
        else: return print_red('Unknown command "%s"'%command)

    def emptyline(self): pass
    def default(self, ln):
        # Forward line starts with ! to system shell
        if ln.startswith('!'):
            os.system(ln[1:])
            return
        c, arg, line = self.parseline(ln)
        # Check and run command aliases
        if c in self.__aliases:
            func = getattr(self, 'do_'+self.__aliases[c])
            if func: return func(arg)
        # See if there is any handler for integer or floating point values
        if hasattr(self, 'int_handler'):
            try: return getattr(self, 'int_handler')(int(ln, 0))
            except ValueError: pass
        if hasattr(self, 'float_handler'):
            try: return getattr(self, 'float_handler')(float(ln))
            except ValueError: pass
        try:
            # See if this is a simple expression that can be evaluated
            print '= %s'%str(eval_expr.eval_expr(ln))
        except: print_red('Unknown command: "%s". Try to type "help"'%ln)

    def do_alias(self, line):
        "alias: how or change command alias"
        if not line:
            for a, b in sorted(self.__aliases.iteritems()):
                print '%s  --  %s'%(a, b)
        else:
            s = line.split()
            if len(s) != 2: return print_red('Usage: alias cmd-alias cmd')
            a, c = s[0], s[1]
            self.add_alias(a, c)
    def do_pwd(self, line):  print os.getcwd()
    def help_pwd(self):      print 'pwd: print working directory'
    def do_help(self, args):
        "help: print help information"
        if not args:
            super(BaseShell, self).do_help(args)
            if len(self.__aliases) <= 0: return
            print 'Command aliases (type help <topic> for more information):'
            print '========================================================='
            help_str = ''
            ln_cnt = 0
            for a in sorted(self.__aliases.keys()):
                if (len(a) + 2) > 80:
                    help_str += '\b'
                    ln_cnt = 0
                ln_cnt += len(a) + 2
                help_str += '  %s'%a
            print help_str
        elif args in self.__aliases:
            print '%s: alias of "%s"\n'%(args, self.__aliases[args])
            super(BaseShell, self).do_help(self.__aliases[args])
        else: super(BaseShell, self).do_help(args)

    def do_exit(self, line): return True
    def help_exit(self):     print 'exit: leave this program'
    def do_EOF(self, line):  return True
    def help_EOF(self):      print 'EOF(Ctrl+D): leave this program'

    def do_ls(self, arg):
        "ls [path]: list directory"
        if not arg: arg = '.'
        try:
            d = os.listdir(arg)
            file_list = [f for f in d if os.path.isfile(f)]
            dir_list  = [f for f in d if os.path.isdir(f)]
            fw = max([len(f) for f in file_list])
            dw = max([len(d) for d in dir_list])
            iw = max(fw, dw) + 4
            ls_str = ''
            ln_cnt = 0
            ln_max = 100/iw
            for d in dir_list:
                ls_str += blue_str('{0:<{w}}'.format(d, w=iw))
                ln_cnt += 1
                if ln_cnt == ln_max:
                    ls_str += '\n'
                    ln_cnt = 0
            for f in file_list:
                ls_str += '{0:<{w}}'.format(f, w=iw)
                ln_cnt += 1
                if ln_cnt == ln_max:
                    ls_str += '\n'
                    ln_cnt = 0
            print ls_str
        except OSError as e:
            print_red('Cannot access %s: %s'%(arg, e.strerror))

    def do_cd(self, line):
        "cd [path]: change working directory to path (default=~)"
        d = os.path.expanduser('~') if not line else line.split()[0]
        td = os.path.abspath(d)
        try:
            os.chdir(td)
            self.wdlist   = [f for f in os.listdir('.')]
            self.filelist = [f for f in self.wdlist if os.path.isfile(f)]
            self.dirlist  = [f for f in self.wdlist if os.path.isdir(f)]
            print_green('%s'%td)
        except OSError as e:
            print_red('cd: %s'%(arg, e.strerror))

    def preloop(self):pass
