#!/usr/bin/env python
import os, sys, string, re, subprocess, fnmatch, filecmp, datetime, shutil
import tempfile
import time
from itertools import repeat
from optparse import OptionParser
import multiprocessing
from multiprocessing import Pool
md = os.path.join(os.path.dirname(__file__), '..')
if md not in sys.path: sys.path.append(md)
from utils.print_color import *
from solver_program.solver_mem_utils import read_vlog_hexdump
from solver_program.solver_mem_utils import compare_vlog_hexdump
from simulation import solver_rtl_sim

RUN_IGNORED = False
VALGRIND = False

class ToolTestCase(object):
    tool_path = ''
    solver_root = ''
    cc_driver_opts = ''
    rtl_wd = None
    def __init__(self, test_name, filename):
        self.name = test_name
        self.rtl = None
        self.filename = filename
        self.dirname = os.path.split(os.path.abspath(filename))[0]
        self.template_dict = {'S_AS':'s-as', 'S_SIM':'s-sim', 'S_CG':'s-cg',
                              'S_CC':'s-cc', 'S_RUN_SIM':'s-run-sim',
                              'S_RTL_GEN':'s-rtl-gen',
                              'FILE':filename, 'FILEDIR':self.dirname}
        if ToolTestCase.solver_root:
            self.template_dict['SOLVER_ROOT'] = ToolTestCase.solver_root
        self.test_command = []
        self.mem_strict = False

    def add_test_command(self, tool, args, err=None, out=None, out_files=None,
                         mem_dumps=None, mem_objs=None):
        if tool != ':RTL:':
            tool = string.Template(tool).safe_substitute(self.template_dict)
            tool = os.path.join(ToolTestCase.tool_path, tool)
        args = string.Template(args).safe_substitute(self.template_dict)
        if 's-cc' in tool:
            args += ' --solver-path=%s'%ToolTestCase.tool_path
        expected_err = [string.Template(e).safe_substitute(
                self.template_dict) for e in err]
        expected_out = [string.Template(o).safe_substitute(
                self.template_dict) for o in out]
        out_files = [string.Template(of).safe_substitute(
                self.template_dict) for of in out_files]
        mem_dumps = [string.Template(d).safe_substitute(
                self.template_dict) for d in mem_dumps]
        mem_objs = [string.Template(d).safe_substitute(
                self.template_dict) for d in mem_objs]
        self.test_command.append(
            (tool, args, expected_err, expected_out, out_files, mem_dumps, mem_objs))

    def set_rtl(self, args):
        args = string.Template(args).safe_substitute(self.template_dict)
        self.rtl = args.split()

    def check_ofiles(self, out_files):
        succ = True
        for of in out_files:
            s = of.split(':')
            if len(s) == 2:
                of = os.path.abspath(s[0])
                rf = os.path.join(self.dirname, s[1])
            else:
                n = os.path.split(os.path.abspath(of))[1]
                rf = os.path.join(self.dirname, n+'.ref')
            if not os.path.isfile(of):
                print_red('Cannot find expected output file %s'%of)
                succ = False
            elif not os.path.isfile(rf):
                print_red('No reference file provided for %s'%of)
                succ = False
            else:
                ostr = open(of).read().split('\n')
                rstr = open(rf).read().split('\n')
                for i, rl in enumerate(rstr):
                    if rl and ostr[i] != rl:
                        print_red('Output file %s does not match reference'\
                                      ' in ln%d'%(of, i+1))
                        print('ref="%s", out="%s"'%(rl, ostr[i]))
                        succ = False
                        break
        return succ

    def check_mobjs(self, mem_objs):
        succ = True
        for mo in mem_objs:
            s = mo.split(':')
            if len(s) == 2:
                sym = s[0]
                rf = os.path.join(self.dirname, s[1])
            else: rf = os.path.join(self.dirname, mo+'.ref')
            if not os.path.isfile(rf):
                print_red('No reference file provided for %s'%mo)
                succ = False
            # else:
            #     dump = read_vlog_hexdump(md)
            #     dref = read_vlog_hexdump(rf)
            #     diff = compare_vlog_hexdump(dump=dump, ref=dref,
            #                                 ignore_undef=not self.mem_strict)
            #     if len(diff) > 0:
            #         print_red('Memory dump %s does not match reference'\
            #                       ' in %d locations'%(md, len(diff)))
            #         succ = False
            #         if len(diff) < 64:
            #             for adr, val in sorted(diff.iteritems()):
            #                 if (val[0]!=None):
            #                     print_yellow('Miss-match @%d, out=%d, ref=%d'%(
            #                         adr, val[0], val[1]))
            #                 else:
            #                     print_yellow('Miss-match @%d, out=undef, ref=%d'%(
            #                         adr, val[1]))
            #             break
        return succ

    def check_mdumps(self, mem_dumps):
        succ = True
        for md in mem_dumps:
            s = md.split(':')
            if len(s) == 2:
                md = os.path.abspath(s[0])
                rf = os.path.join(self.dirname, s[1])
            else:
                n = os.path.split(os.path.abspath(md))[1]
                rf = os.path.join(self.dirname, n+'.ref')
            if not os.path.isfile(md):
                print_red('Cannot find expected memory dump %s'%md)
                succ = False
            elif not os.path.isfile(rf):
                print_red('No reference file provided for %s'%md)
                succ = False
            else:
                dump = read_vlog_hexdump(md)
                dref = read_vlog_hexdump(rf)
                diff = compare_vlog_hexdump(dump=dump, ref=dref,
                                            ignore_undef=not self.mem_strict)
                if len(diff) > 0:
                    print_red('Memory dump %s does not match reference'\
                                  ' in %d locations'%(md, len(diff)))
                    succ = False
                    if len(diff) < 64:
                        for adr, val in sorted(diff.iteritems()):
                            if (val[0]!=None):
                                print_yellow('Miss-match @%d, out=%d, ref=%d'%(
                                    adr, val[0], val[1]))
                            else:
                                print_yellow('Miss-match @%d, out=undef, ref=%d'%(
                                    adr, val[1]))
                        break
        return succ

    def run_command(self, tool, args, expected_err, expected_out, out_files,
                    mem_dumps, mem_objs):
        out, err = '', ''
        if tool == ':RTL:':
            bin_ar, arch_config, rtl_root = args.split()
            of = tempfile.TemporaryFile()
            ef = tempfile.TemporaryFile()
            solver_rtl_sim.run_solver_bin_ar(
                bin_ar=bin_ar, arch_config=arch_config, rtl_root=rtl_root,
                run_root=ToolTestCase.rtl_wd, sim_out=os.getcwd(),
                flow=opts.rtl_flow, stdout=of, stderr=ef)
        else:
            c = ['valgrind', '-q', '--leak-check=full'] if VALGRIND else []
            c += [tool,] + args.split()
            if tool.endswith('s-cc'): c += ToolTestCase.cc_driver_opts
            out, err = subprocess.Popen(
                c, stderr=subprocess.PIPE, stdout=subprocess.PIPE).communicate()
        succ = True
        for e in expected_err:
            if err.find(e) == -1:
                succ = False
                print_red('Failed case "%s" in file "%s":'%(
                        self.name, self.filename))
                print_yellow('Expecting "%s" in stderr'%e)
        for e in expected_out:
            if err.find(e) == -1:
                succ = False
                print_red('Failed case "%s" in file "%s":'%(
                        self.name, self.filename))
                print_yellow('Expecting "%s" in stdout'%e)
        if not expected_out or len(expected_out) == 0:
            if out:
                print_red('Unexpected stdout:\n%s'%out)
                succ = False
        if not expected_err or len(expected_err) == 0:
            if err:
                print_red('Unexpected stderr:\n%s'%err)
                succ = False
        if not self.check_ofiles(out_files): succ = False
        if not self.check_mdumps(mem_dumps): succ = False
        if not succ and tool == ':RTL:':
            of.seek(0)
            ef.seek(0)
            o, e = of.read(), ef.read()
            if o:
                print_yellow('RTL stdout:')
                print(o)
            if e:
                print_yellow('RTL stderr:')
                print(e)
            print of.read()
        return succ

    def run_command_sequence(self, verbose):
        for (tool, args, exp_err, exp_out, out_files, mem_dumps, mem_objs)\
                in self.test_command:
            if not self.run_command(
                tool, args, exp_err, exp_out, out_files, mem_dumps, mem_objs):
                return False
        return True

    def __str__(self):
        s = 'Test: %s\n'%self.name
        for i, c in enumerate(self.test_command):
            s += '--[%4d] Tool: %s\n         Args: %s\n'%(i, c[0], c[1])
        return s

def run_on_file(file_path, comment_prefix, verbose=False):
    cmd_mark = comment_prefix*3
    f=open(file_path)
    lines=f.read().split('\n')
    f.close()
    test_cases = []
    curr_case = None
    curr_tool = None
    curr_args = ''
    curr_err = []
    curr_out = []
    curr_out_files = []
    curr_mem_dumps, curr_mem_objs = [], []
    for line in lines:
        m = re.match("^\s*%s(\w+):\s*(.*)"%cmd_mark,line)
        if m:
            cmd = m.group(1)
            arg = m.group(2).strip()
            if not RUN_IGNORED and cmd == 'IGNORE':
                break
            elif cmd == 'BEGIN':
                curr_case = ToolTestCase(arg, file_path)
            elif cmd == 'END':
                if curr_case:
                    if curr_tool:
                        curr_case.add_test_command(
                            curr_tool, curr_args, curr_err, curr_out,
                            curr_out_files, curr_mem_dumps, curr_mem_objs)
                    if not opts.run_rtl:
                        if not curr_case.rtl: test_cases.append(curr_case)
                    elif curr_case.rtl: test_cases.append(curr_case)
                    curr_case = None
                    curr_tool = None
                    curr_args = ''
                    curr_err = []
                    curr_out = []
                curr_out_files = []
                curr_mem_dumps, curr_mem_objs = [], []
            elif cmd == 'TOOL':
                if curr_case and curr_tool:
                    curr_case.add_test_command(
                        curr_tool, curr_args, curr_err, curr_out,
                        curr_out_files, curr_mem_dumps, curr_mem_objs)
                curr_tool = arg
                curr_args = ''
                curr_err = []
                curr_out = []
                curr_out_files = []
            elif cmd == 'RTL':
                if curr_case and curr_tool:
                    curr_case.add_test_command(
                        curr_tool, curr_args, curr_err, curr_out,
                        curr_out_files, curr_mem_dumps, curr_mem_objs)
                curr_tool = ':RTL:'
                curr_args = arg
                curr_err = []
                curr_out = []
                curr_out_files = []
                curr_case.set_rtl(arg)
            elif cmd == 'ARGS':  curr_args = arg
            elif cmd == 'ERR':   curr_err.append(arg)
            elif cmd == 'OUT':   curr_out.append(arg)
            elif cmd == 'OFILE': curr_out_files.append(arg)
            elif cmd == 'MDUMP': curr_mem_dumps.append(arg)
            elif cmd == 'MOBJ':  curr_mem_objs.append(arg)
            elif cmd == 'MSTRICT': curr_case.mem_strict = True
    #end for line in lines
    fail_counter = 0
    for c in test_cases:
        if verbose:
            print_purple('Running test case "%s"'%c.name)
            sys.stdout.write(str(c))
        if not c.run_command_sequence(verbose):
            print_red('%s FAILED!'%c.name)
            fail_counter += 1
        elif verbose:
            print_green('Passed!')
    return fail_counter, len(test_cases)

def run_file_list((f, comment_prefix, verbose)):
    cwd = os.getcwd()
    e, c = 1, 1
    td = tempfile.mkdtemp()
    try:
        os.chdir(td)
        e,c = run_on_file(f, comment_prefix, verbose)
    finally:
        os.chdir(cwd)
        if os.path.isdir(td): shutil.rmtree(td)
    return e, c

if __name__ == '__main__':
    parser = OptionParser("Usage: %prog [options] <test directory>")
    parser.add_option('--tool-path', help='path to executables under test',
                      dest='tool_path', default='./bin')
    parser.add_option('--solver-root', help='path to solver target files',
                      dest='solver_root')
    parser.add_option('-v', '--verbose', action="store_true",
                      help='run in verbose mode')
    parser.add_option('--keep-tmp', action="store_true",
                      dest='keep_tmp', help='keep the generated files')
    parser.add_option('--test-filename-pattern', help='pattern of test filenames',
                      dest='test_patt', default='*.s')
    parser.add_option('--comment-prefix', help='prefix of line comment',
                      dest='comment_prefix', default='#')
    parser.add_option('--memcheck', action="store_true", dest='memcheck',
                      help='check memory usage using valgrind (def=False)')
    parser.add_option('--run-rtl', action="store_true", dest='run_rtl',
                      help='run cases that needs RTL simulation (def=False)')
    parser.add_option('--rtl-flow', help='tool for RTL simulation (def=vsim)',
                      dest='rtl_flow', default='vsim')
    parser.add_option('--rtl-cc', dest='rtl_cc',
                      help='tool for compiling RTL libraries')
    parser.add_option('--rtl-sim', dest='rtl_sim',
                      help='RTL simulator executable')
    parser.add_option('--run-ignored', action="store_true", dest='run_ignored',
                      help='force to run test cases marked as "IGNORE"')
    parser.add_option('--parallel', action='store_true',
                      help='run with multiple processes')
    opts, args = parser.parse_args()
    if len(args) > 1:
        print('Too many positional arguments!')
    elif not args:
        print('No test directory specified!')
        exit(1)

    if opts.run_ignored: RUN_IGNORED = True
    if opts.memcheck:    VALGRIND = True
    test_path = os.path.abspath(args[0])
    if opts.tool_path: ToolTestCase.tool_path = os.path.abspath(opts.tool_path)
    ToolTestCase.cc_driver_opts = ['--solver-path', ToolTestCase.tool_path]
    if opts.solver_root:
        ToolTestCase.solver_root = os.path.abspath(opts.solver_root)
        ToolTestCase.cc_driver_opts +=\
            ['--solver-inc-path',
             os.path.join(ToolTestCase.solver_root,'usr','include'),
             '--solver-lib-path',
             os.path.join(ToolTestCase.solver_root,'usr','lib'),
             '--solver-target-root', os.path.join(ToolTestCase.solver_root,'usr')]
    w = os.walk(test_path)
    flist = []
    for top, subdirs, files in w:
        flist += [os.path.join(top, f) for f in files
                 if fnmatch.fnmatch(f, opts.test_patt)]
    errs  = 0
    cases = 0
    cwd = os.getcwd()
    twd = [f for f in test_path.split(os.sep) if f != ''][-1]
    utc_datetime = datetime.datetime.now()
    formated_string = utc_datetime.strftime("%Y-%m-%d-%H%M%S")
    twd = 'test_%s_%s'%(twd, formated_string)
    os.mkdir(twd)
    os.chdir(twd)
    if opts.run_rtl:
        ToolTestCase.rtl_wd = os.path.join(twd, 'rtl-run')
        if not opts.rtl_cc:
            rtl_cc = 'vsim' if opts.rtl_flow == 'vsim' else 'iverilog'
        if not opts.rtl_sim:
            rtl_sim = 'vsim' if opts.rtl_flow == 'vsim' else 'vvp'
    start = time.time()
    if opts.parallel:
        pool = Pool(processes=multiprocessing.cpu_count())
        r = pool.map(run_file_list, zip(flist,repeat(opts.comment_prefix),
                                        repeat(opts.verbose)))
        for e, c in r:
            errs  += e
            cases += c
    else:
        for f in flist:
            e, t = run_on_file(f, opts.comment_prefix, opts.verbose)
            errs  += e
            cases += t
    if errs > 0:
        print_red('%d out of %d cases failed(%.2f%%)'%(
                errs, cases, float(errs)*100.0/float(cases)))
    else:
        end = time.time()
        print_green('%d cases passed, elasped time %.2fs'%(cases, end-start))
    os.chdir(cwd)
    if not opts.keep_tmp:
        shutil.rmtree(twd)
    elif opts.verbose:
        print('Files generated during test are kept in directory "%s"'%twd)
    exit(errs)
