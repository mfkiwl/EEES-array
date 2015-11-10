import os, sys

def gen_vsim_compile_script(vlog_files, def_dirs, lib='work',
                            vlog_opts='', quit_done=True):
    do_str = '''if [file exists %s] {
    vdel -all -lib %s
}

vlib %s

'''%(lib, lib, lib)

    def_str = ''
    for d in def_dirs: def_str += ' +incdir+%s'%os.path.abspath(d)

    compile_str = 'vlog %s -work %s %s {0}\n'%(vlog_opts, lib, def_str)
    for f in vlog_files: do_str += compile_str.format(os.path.abspath(f))
    if quit_done: do_str += 'quit\n'
    return do_str

def gen_vsim_run_script(tb_module, vsim_opts='',
                        lib='work', run_time=None, quit_done=True):
    do_str = '''onbreak {resume}

if { [file exists %s]  == 0 } {
    puts stderr "Library \\\"%s\\\" not found, please run compilation first."
    exit -code 1
}

if { [file exists cp.imem_init]  == 0 } {
    puts stderr "Cannot find cp.imem_init, aborting."
    exit -code 1
}

vsim %s -novopt %s.%s

run -all

'''%(lib, lib, vsim_opts, lib, tb_module)

    if run_time: do_str += 'run %s\n'%str(run_time)
    else: do_str += 'run -all\n'
    if quit_done: do_str += 'quit\n'
    return do_str
