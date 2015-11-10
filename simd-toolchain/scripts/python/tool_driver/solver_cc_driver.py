#!/usr/bin/env python
import getopt, os, sys, shutil, subprocess, optparse, tempfile, string, random
import glob
import zipfile
import traceback
from optparse import OptionParser
from optparse import OptionGroup

VERBOSE   = False
COMPILER_WD = None

class CompilerDrvError(Exception):
    def __init__(self, desc):
        self.desc = desc
    def __str__(self):
        return str(self.desc)

def find_exe_path(exe_name, preset_path):
    nbin = os.path.join(preset_path, exe_name)
    return nbin if os.path.isfile(nbin) and os.access(nbin, os.X_OK) else None

def find_tools(opts):
    clang_bin  = find_exe_path('clang', opts.llvm_path)
    opt_bin    = find_exe_path('opt', opts.llvm_path)
    llc_bin    = find_exe_path('llc', opts.llvm_path)
    llink_bin  = find_exe_path('llvm-link', opts.llvm_path)
    s_cg_bin   = find_exe_path('s-cg', opts.solver_path)
    s_as_bin   = find_exe_path('s-as', opts.solver_path)
    return (clang_bin, opt_bin, llink_bin, llc_bin, s_cg_bin, s_as_bin)

def generate_id(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for x in range(size))

def get_tmp_filename(src, suffix):
    return 'SCCTMP_%s_%s.%s'%(
        os.path.basename(src).upper().replace('.','_'), generate_id(), suffix)

def process_one_file(src, opts, tool_bin, prefix, suffix, ofn = None):
    if ofn : ofn = os.path.join(prefix, ofn)
    while not ofn:
        of = get_tmp_filename(src, suffix)
        of = os.path.join(prefix, of)
        if not os.path.exists(of):
            ofn = of
            break
    cm = [tool_bin,] + opts + ['-o', ofn] + [src,]
    try:
        err_buf = tempfile.TemporaryFile()
        sp = subprocess.Popen(cm, stderr=err_buf)
        rc = sp.wait()
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()
        raise CompilerDrvError('failed to compile %s using %s'%(src, tool_bin))
    if rc != 0 or not os.access(ofn, os.R_OK):
        err_buf.seek(0)
        e = err_buf.read()
        if e: print >>sys.stderr, e
        ofn_lst = glob.glob(ofn+'*')
        if ofn_lst: return ofn_lst
        raise CompilerDrvError('failed to compile %s using %s'%(src, tool_bin))
    return ofn

def process_files(src_lst, opts, tool_bin, prefix, suffix, ofn = None,
                  stdin=None, stdout=None):
    while not ofn:
        of = get_tmp_filename(tool_bin, suffix)
        of = os.path.join(prefix, of)
        if not os.path.exists(of):
            ofn = of
            break
    cm = [tool_bin,] + opts + ['-o', ofn] + src_lst
    try:
        err_buf = tempfile.TemporaryFile()
        sp = subprocess.Popen(cm, stdout=stdout, stdin=stdin, stderr=err_buf)
        rc = sp.wait()
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()
        raise CompilerDrvError('failed to generate %s using %s'%(ofn, tool_bin))

    if rc != 0 or not os.access(ofn, os.R_OK):
        err_buf.seek(0)
        e = err_buf.read()
        if e: print >>sys.stderr, e
        raise CompilerDrvError('failed to generate %s using %s'%(ofn, tool_bin))
    if stdout: stdout.flush()
    return ofn

def find_all_libs(opts):
    ll_libs = []
    libs = []
    for l in opts.link_libs:
        if l in libs: continue
        bc = 'lib%s.bc'%l
        for p in opts.lib_dirs:
            if os.access(os.path.join(p, bc), os.R_OK):
                ll_libs.append(os.path.join(p, bc))
                libs.append(l)
                break
    sir_libs = []
    for l in opts.link_libs:
        if l in libs: continue
        sl = 'lib%s.sir'%l
        for p in opts.lib_dirs:
            if os.access(os.path.join(p, sl), os.R_OK):
                sir_libs.append(os.path.join(p, sl))
                libs.append(l)
                break
    for l in opts.link_libs:
        if l not in libs: raise CompilerDrvError('failed to find library %s'%l)
    return ll_libs, sir_libs

def run_compiler(opts, input_files, tools):
    global COMPILER_WD
    cc_src   = []
    ll_src  = []
    sir_src = []
    asm_src = []
    if opts.in_lang:
        if opts.in_lang in ['c', 'cxx', 'c++', 'opencl', 'ocl', 'cl']:
            cc_src += input_files
        elif opts.in_lang in ['ll', 'llvm']: ll_src += input_files
        elif opts.in_lang == 'sir': sir_src += input_files
        elif opts.in_lang == 'asm': asm_src += input_files
    else:
        for f in input_files:
            if not os.path.isfile(f) or not os.access(f, os.R_OK):
                raise CompilerDrvError('Failed to read input file %s'%f)
            else:
                e = os.path.splitext(f)[1]
                if e in ['.ll','.bc','.o']: ll_src.append(f)
                elif e == '.sir':           sir_src.append(f)
                elif e == '.s':             asm_src.append(f)
                # Assume everything else is C/C++/OpenCL
                else:                        cc_src.append(f)
    # Compilation pipeline:
    # CC files =[clang]=> LLVM IR files =[llvm-link]=> Linked LLVM IR
    #          =[llc  ]=> Solver IR file =[s-cg]=> Solver assembly
    #          =[s-as ]=> Solver target code
    (clang_bin, opt_bin, llink_bin, llc_bin, s_cg_bin, s_as_bin) = tools
    if VERBOSE: print (clang_bin, opt_bin, llink_bin, llc_bin, s_cg_bin, s_as_bin)
    compile_wd  = COMPILER_WD#tempfile.gettempdir()
    cc_sfx  = 'bc' if not opts.comp_only else 'o'
    # FIXME: isel in LLVM backend need to be fixed for this
    clang_opt = max(1,  opts.opt_level)
    cc_opts = ['-emit-llvm', '-target', 'solver', '-fno-builtin',
               '-c' if not opts.gen_llvm else '-S', '-nobuiltininc',
               '--sysroot', '%s'%opts.solver_target_root,
               '-fomit-frame-pointer','-O%d'%clang_opt]
    if opts.dbg_info: cc_opts.append('-g')
    cl_opts = cc_opts\
        + ['-I' '%s'%opts.solver_inc_path, '-include',\
           '%s/__builtin/opencl/kernel_builtins.h'%opts.solver_inc_path]
    if options.warn_list:
        cc_opts += ['-W%s'%w for w in options.warn_list]
    if cc_src:
        if VERBOSE: print 'Compiling C/C++/OpenCL source files to LLVM IR'
        if opts.comp_only and len(cc_src)>1:
            raise CompilerDrvError('More than one source with -c option')
        gen_ll = []
        for f in cc_src:
            proc_opt = cl_opts if f.endswith('.cl') else cc_opts
            if f.endswith('.c') and '-std=c99' not in proc_opt:
                proc_opt.append('-std=c99')
            if VERBOSE: print('Processing %s, options: %s'%(
                    f, ' '.join(proc_opt)))
            gen_ll.append(process_one_file(
                    f, proc_opt, clang_bin, compile_wd, cc_sfx))
        ll_src    += gen_ll
    if not opts.gen_llvm:
        ll_libs, sir_libs = find_all_libs(opts)
        ll_src += ll_libs
    link_ll = None
    if len(ll_src) > 1:
        # run llvm-link to generate one LLVM IR file
        if VERBOSE: print('Linking LLVM IR files')
        ofn = get_tmp_filename('link_ll', cc_sfx)
        link_ll = process_files(ll_src, ['-S'] if opts.gen_llvm else [],
                                llink_bin, compile_wd, cc_sfx)
    elif len(ll_src) == 1:
        link_ll = ll_src[0]

    if opts.gen_llvm and link_ll:
        of = opts.output_file if opts.output_file.endswith('.ll')\
                else opts.output_file + '.ll'
        shutil.copy(link_ll, of)
        return
    if opts.comp_only and link_ll:
        shutil.copy(link_ll, opts.output_file)
        return

    if link_ll:
        if VERBOSE: print('Compiling LLVM IR to Solver IR')
        ll_opts = ['-march=solver', '-enable-tbaa', '-pre-RA-sched=list-burr',
                   '-O%d'%max(1, opts.opt_level)]
        if VERBOSE: print('Processing %s, options: %s'%(
                link_ll, ' '.join(ll_opts)))
        gen_sir = process_one_file(link_ll, ll_opts, llc_bin, compile_wd, 'sir')
        if opts.gen_solverir:
            of = opts.output_file if opts.output_file.endswith('.sir')\
                else opts.output_file + '.sir'
            if VERBOSE: print('Writing output to %s'%of)
            shutil.copy(gen_sir, of)
            return
        sir_src.append(gen_sir)

    tgt_opts = []
    if opts.arch: tgt_opts.append('-arch=%s'%opts.arch)
    if opts.arch_cfg: tgt_opts.append('-arch-cfg=%s'%opts.arch_cfg)
    if opts.arch_param: tgt_opts.append('-arch-param=%s'%opts.arch_param)
    if VERBOSE: print('Target options: %s'%' '.join(tgt_opts))
    # Search for libraries
    if len(sir_src) > 0: sir_src += sir_libs
    # Generate target assembly
    cg_stat = None
    if len(sir_src) > 0:
        if VERBOSE: print('Generating target assembly')
        cg_opts = tgt_opts[:]
        cg_opts += ['-cfg']
        if opts.html: cg_opts += ['-json']
        if opts.cg_opts:
            for o in opts.cg_opts: cg_opts.append('-%s'%s)
        if opts.cg_stat: cg_opts.append('-print-codegen-stat')
        if opts.no_sched: cg_opts.append('-no-sched')
        if VERBOSE: print('Processing %s, options: %s'%(
                str(sir_src), ' '.join(cg_opts)))
        ofn = get_tmp_filename('gen_asm', 's')
        cg_out = tempfile.TemporaryFile() if opts.cg_stat else None
        gen_asm = process_files(sir_src, cg_opts, s_cg_bin, compile_wd, 's', stdout=cg_out)
        cg_stat = ''
        if cg_out:
            cg_out.seek(0)
            lns = cg_out.readlines()
            if  '>> BEGIN Module Statistics\n' in lns:
                for l in lns[lns.index('>> BEGIN Module Statistics\n')+1:]:
                    if l == '>> END Module Statistics\n': break
                    cg_stat += l
        if opts.out_asm:
            of = opts.output_file if opts.output_file.endswith('.s')\
                else opts.output_file + '.s'
            if VERBOSE: print('Writing output to %s'%of)
            shutil.copy(gen_asm, of)
            if cg_stat: print(cg_stat)
            return
        asm_src.append(gen_asm)
        # Generate archive file of binary code
    if len(asm_src) > 1: raise CompilerDrvError('Too many assembly files')

    if len(asm_src) > 0:
        gen_asm = asm_src[0]
        as_opts = opts.as_opts if opts.as_opts else []
        as_opts += tgt_opts
        bin_prefix = os.path.splitext(opts.output_file)[0] \
            if opts.output_file.endswith('.zip') else opts.output_file
        bin_prefix = os.path.basename(bin_prefix)
        if VERBOSE: print('Generating target binary with %s, options: %s'%(
                gen_asm, ' '.join(as_opts)))
        gen_bin = process_one_file(gen_asm, as_opts, s_as_bin, compile_wd,
                                   'bin', bin_prefix)
        if opts.pe_dmem_init:
            pdp = bin_prefix + '.pe.dmem_init'
            with open(pdp, 'a') as f:
                for df in opts.pe_dmem_init:
                    with open(df) as dd: f.write('\n'+dd.read())
            if pdp not in gen_bin: gen_bin.append(pdp)
        if opts.cp_dmem_init:
            cdp = bin_prefix + '.cp.dmem_init'
            with open(cdp, 'a') as f:
                for df in opts.cp_dmem_init:
                    with open(df) as dd: f.write('\n'+dd.read())
                if cdp not in gen_bin: gen_bin.append(cdp)
        of = opts.output_file if opts.output_file.endswith('.zip')\
            else opts.output_file + '.zip'
        try:
            zfd = zipfile.ZipFile(of, 'w', zipfile.ZIP_DEFLATED)
            if VERBOSE: print('Creating binary archive %s with %s'%(of, str(gen_bin)))
            bin_p = os.path.join(bin_prefix, 'bin')
            for f in gen_bin:
                if VERBOSE: print('-- Adding %s'%os.path.basename(f))
                zfd.write(f, os.path.join(bin_p, os.path.basename(f)))
            if opts.arch_cfg and os.access(opts.arch_cfg, os.R_OK):
                zfd.write(opts.arch_cfg, os.path.join(bin_prefix, 'arch.json'))
            arch_opt_str = ''
            if opts.arch:      arch_opt_str += '-arch %s '%opts.arch
            if opts.arch_param:arch_opt_str += '-arch-param %s '%opts.arch_param

            if arch_opt_str: zfd.writestr(os.path.join(bin_prefix, 'arch.opt'),
                                          arch_opt_str)
            if cg_stat:zfd.writestr(os.path.join(bin_prefix,'stat.txt'),cg_stat)
            if not opts.no_asm: zfd.write(
                gen_asm, os.path.join(bin_prefix, 'asm.s'))
            if os.path.isfile(gen_asm+'.cfg'):
                zfd.write(gen_asm+'.cfg',
                          os.path.join(bin_prefix, bin_prefix+'.cfg'))
            if os.path.isfile(gen_asm+'.stab'):
                zfd.write(gen_asm+'.stab',
                          os.path.join(bin_prefix, bin_prefix+'.stab'))
            if os.path.isfile(gen_asm+'.json'):
                if VERBOSE: print 'Generating HTML output files'
                from solver_program import solver_html_utils
                solver_html_utils.generate_solver_program_html(
                    gen_asm+'.json',
                    os.path.join(opts.solver_target_root, 'html'), 'html',
                    bin_prefix)
                for (r, d, fl) in os.walk('html'):
                    for f in fl:
                        hf = os.path.join(r, f)
                        zfd.write(hf, os.path.join(bin_prefix, hf))
                    
        except:
            print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
            traceback.print_tb(sys.exc_info()[2])
            raise CompilerDrvError('failed to create binary %s'%of)
        finally:
            if zfd: zfd.close()


def parse_options():
    parser = OptionParser('Usage: %prog [options] input_files')
    # General options
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose",
                      default=False, help="Run in verbose mode")
    parser.add_option("-g", action="store_true", dest="dbg_info",
                      default=False, help="Produce debugging information")
    # Output options
    parser.add_option("-M", action="store_true", dest="depend",default=False,
                      help='Produce dependency information')
    parser.add_option("-E", action="store_true", dest="pp_only",default=False,
                      help='Stop after preprocessing, do not compile')
    parser.add_option("-c", action="store_true", dest="comp_only",default=False,
                      help='Compile only; do not assemble or link')
    parser.add_option("-S", action="store_true", dest="out_asm",
                      default=False, help='Generate assembly output')
    parser.add_option("-o", dest="output_file", default='out',
                      help="Name/Prefix of the output file(s)")
    parser.add_option("--emit-llvm", action="store_true", dest="gen_llvm",
                      default=False, help='Generate LLVM IR as output')
    parser.add_option("--emit-sir", action="store_true", dest="gen_solverir",
                      default=False, help='Generate Solver IR as output')
    parser.add_option("--keep", action="store_true",
                      dest="keep", help='Keep temp files')
    parser.add_option("--html", action="store_true",help='Generate HTML output')
    # Optimization options
    parser.add_option("-O", type="int", dest="opt_level", default=0,
                      help='Optimization level: 0, 1, 2 or 3 (default=0)')
    # Input options
    parser.add_option("-I", action="append", dest="inc_dirs", default=[],
                      help="Add a directory to header search paths")
    parser.add_option("-L", action="append", dest="lib_dirs", default=[],
                      help="Add a directory to library search paths")
    parser.add_option("-l", action="append", dest="link_libs", default=[],
                      help="Add a library for linker")
    parser.add_option("-X", dest="in_lang", default=None,
                      choices=['c', 'c++', 'cxx', 'opencl', 'ocl', 'cl',
                               'll', 'llvm', 'sir', 'asm'],
                      help="Specify the language of the input files")
    # Message and logging
    parser.add_option("--quiet", action="store_true", dest="quite",
                      default=False, help="Suppress all output")
    parser.add_option("-W", action="append", dest="warn_list",
                      help=optparse.SUPPRESS_HELP)
    # Tool options
    tool_opts = OptionGroup(parser, "Tool Options")
    tool_opts.add_option("--cg-stat", action="store_true", dest="cg_stat",
                      default=False, help="Collect code generation statistics")
    tool_opts.add_option("--no-asm", action="store_true", default=False,
                         help="Don't keep assembly in binary archive")
    tool_opts.add_option("--solver-llvm-path", dest="llvm_path",
                         help="Specify path to LLVM tools"\
                             " (default=$SOLVER_LLVM_PATH)")
    tool_opts.add_option("--solver-path", dest="solver_path",
                         help="Specify path to Solver toolchain"\
                             " (default=$SOLVER_HOME/bin)")
    tool_opts.add_option("--solver-inc-path", dest="solver_inc_path",
                         help="Specify path to Solver headers"\
                             " (default=$SOLVER_INCLUDE_PATH)")
    tool_opts.add_option("--solver-lib-path", dest="solver_lib_path",
                         help="Specify path to Solver libraries"\
                             " (default=$SOLVER_LIB_PATH)")
    tool_opts.add_option("--solver-target-root", dest="solver_target_root",
                         help="Specify path to Solver libraries"\
                             " (default=$SOLVER_TARGET_ROOT)")
    tool_opts.add_option("--clang-opt", action="append", dest="clang_opts",
                         help="Specify extra options to clang")
    tool_opts.add_option("--llc-opt", action="append", dest="llc_opts",
                         help="Specify extra options to llc")
    tool_opts.add_option("--as-opt", action="append", dest="as_opts",
                         help="Specify extra options to s-as")
    tool_opts.add_option("--cg-opt", action="append", dest="cg_opts",
                         help="Specify extra options to s-cg")
    tool_opts.add_option("--no-libc", action="store_true", dest="no_libc",
                         default=False, help="No default C runtime libraries")
    # Target options
    tgt_opts = OptionGroup(parser, "Target Options")
    tgt_opts.add_option("--arch", dest="arch",
                      help="Specify target name")
    tgt_opts.add_option("--arch-cfg", dest="arch_cfg",
                      help="Specify target specification file")
    tgt_opts.add_option("--arch-param", dest="arch_param",
                      help="Specify target parameters")
    tgt_opts.add_option("--no-sched", dest="no_sched", action="store_true",
                        default=False, help="Try to keep IR order in backend")
    tgt_opts.add_option("--cp-dmem", action="append", dest="cp_dmem_init",
                        help="Additional data initialization for CP")
    tgt_opts.add_option("--pe-dmem", action="append", dest="pe_dmem_init",
                        help="Additional data initialization for PE array")
    parser.add_option_group(tool_opts)
    parser.add_option_group(tgt_opts)
    (opts, args) = parser.parse_args()
    solver_prefix = os.path.abspath(
        os.path.join(os.path.dirname(__file__), '..'))
    if ('SOLVER_LLVM_PATH' not in os.environ) and not opts.llvm_path:
        raise CompilerDrvError("LLVM path not specified")
    if not opts.solver_path:
        opts.solver_path = os.path.join(solver_prefix, 'bin')
    if not opts.solver_inc_path:
        opts.solver_inc_path\
            = os.path.join(solver_prefix, 'share', 'solver', 'usr', 'include')
    if not opts.solver_lib_path:
        opts.solver_lib_path\
            = os.path.join(solver_prefix, 'share', 'solver','usr', 'lib')
    if not opts.solver_target_root:
        opts.solver_target_root\
            = os.path.join(solver_prefix, 'share', 'solver')
    if not opts.llvm_path: opts.llvm_path = os.environ['SOLVER_LLVM_PATH']
    opts.llvm_path   = os.path.abspath(os.path.expanduser(opts.llvm_path))
    opts.solver_path = os.path.abspath(os.path.expanduser(opts.solver_path))
    opts.solver_inc_path = os.path.abspath(os.path.expanduser(opts.solver_inc_path))
    opts.solver_lib_path = os.path.abspath(os.path.expanduser(opts.solver_lib_path))
    opts.solver_target_root\
        = os.path.abspath(os.path.expanduser(opts.solver_target_root))
    solver_py_path = os.path.join(solver_prefix, 'lib', 'solver', 'python')
    if solver_py_path not in sys.path: sys.path.append(solver_py_path)

    acfg = opts.arch_cfg
    if acfg and not acfg.endswith('.json'): acfg += '.json'
    if acfg and not os.path.exists(acfg):
        arch_path = os.path.join(opts.solver_target_root, 'arch')
        for r, d, files in os.walk(arch_path):
            for f in files:
                if acfg == f: acfg = os.path.join(r, f)

    if acfg:
        if not os.access(acfg, os.R_OK):
            raise CompilerDrvError('Cannot open config file %s'%opts.arch_cfg)
        opts.arch_cfg = acfg

    if not opts.lib_dirs: opts.lib_dirs = []
    if opts.solver_lib_path not in opts.lib_dirs:
        opts.lib_dirs.append(opts.solver_lib_path)
    if not opts.link_libs: opts.link_libs = []
    if not opts.no_libc and 'c' not in opts.link_libs:
        opts.link_libs.append('c')
    return (opts, args)

if __name__ == '__main__':
    rc = 0
    keep = False
    COMPILER_WD = tempfile.mkdtemp()
    try:
        (options, args) = parse_options()
        VERBOSE = options.verbose
        keep = options.keep
        input_files = [os.path.abspath(f) for f in args]
        if not input_files:
            print >>sys.stderr, '%s: no input files'%sys.argv[0]
            exit(-1)
        tools = find_tools(options)
        if None in tools: raise CompilerDrvError("Cannot find all tools")
        run_compiler(options, input_files, tools)
    except CompilerDrvError, errmsg:
        print >>sys.stderr, 'ERROR: %s'%str(errmsg)
        rc = -1
    except exceptions.SystemExit:
        pass
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()
        rc = -1
        raise
    finally:
        if VERBOSE: print 'Deleting %s'%str(COMPILER_WD)
        shutil.rmtree(COMPILER_WD)
        exit(rc)
