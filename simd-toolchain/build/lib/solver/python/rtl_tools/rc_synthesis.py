import os, sys
import glob
import multiprocessing
import collections
import tempfile
import subprocess
import json
import time
from utils.print_color import *

from utils import sys_utils

is_64b = sys.maxsize > 2**32
RC     = 'rc -64'        if is_64b else 'rc'
NCVLOG = 'ncvlog -64bit' if is_64b else 'ncvlog'
NCELAB = 'ncelab -64bit' if is_64b else 'ncelab'
NCSIM  = 'ncsim  -64bit' if is_64b else 'ncsim'

TechLib = collections.namedtuple(
    'TechLib', ['search_path', 'library', 'lef_lib',
                'cap_tab', 'sim_vlog', 'cds_lib'])

RTLDesign = collections.namedtuple(
    'RTLDesign', ['synth_module', 'sim_module', 'tcf_path', 'hdls',
                  'testbench', 'hdl_dirs'])

def _get_rc_lib_cmd(tech_lib):
    '''Get the commands for setting a specified technology library in RC

    Argument should be a namedtuple TechLib'''
    return '''set_attribute lib_search_path {0}
set_attribute library {1}
set_attribute lef_library {2}
set_attribute cap_table_file {3}
'''.format(tech_lib.search_path, tech_lib.library,
           tech_lib.lef_lib, tech_lib.cap_tab)

def _get_rc_design_setting_cmd(
    design, clk_period, clk_gating=True, effort='high'):
    '''Get the commands for setting a specified technology library in RC

    Argument should be a namedtuple DesignSetting'''
    nc = max(1, multiprocessing.cpu_count()/2)
    setting_str = '''set NUM_CPUS {0}
set MAP_EFF  {1}
set DESIGN   {2}
set PERIOD   {3}

set_attribute fail_on_error_mesg true

set_attr super_thread_servers [string repeat "localhost " ${{NUM_CPUS}}]
'''.format(nc, effort, design.synth_module, clk_period)
    if clk_gating:
        setting_str += '''set_attribute lp_insert_clock_gating true /
set_attr lp_clock_gating_prefix "PREFIX_lp_clock_gating"  /
'''
    return setting_str

def _get_rc_synthesis_cmd(design, out_dir):
    synth_cmd = ''
    if design.hdl_dirs:
        synth_cmd += 'set_attr hdl_search_path {{{0}}}\n'.format(
            ' '.join(design.hdl_dirs))
    for f in design.hdls:
        if f.endswith('.v'): synth_cmd += 'read_hdl -v2001 {0}\n'.format(f)
        else: synth_cmd += 'read_hdl {0}\n'.format(f)
    return synth_cmd + '''
# Elaborate top-level module
elaborate $DESIGN

#Constraints
define_clock  -name iClk -period ${{PERIOD}} [find / -port iClk]
external_delay -input  500 -clock [find / -clock iClk] -edge_rise  [all_inputs]
external_delay -output 500 -clock [find / -clock iClk] -edge_rise  [all_outputs]

set OUT_DIR {0}

##This synthesizes your design
synthesize -to_generic
write_hdl -generic > ${{OUT_DIR}}/netlist/${{DESIGN}}_${{PERIOD}}_generic_synth.v
synthesize -to_mapped -eff $MAP_EFF
## This section writes the mapped design and sdc file
## THESE FILES YOU WILL NEED THEM WHEN SETTING UP THE PLACE & ROUTE
write -mapped > ${{OUT_DIR}}/netlist/${{DESIGN}}_${{PERIOD}}_synth.v
write_sdc     > ${{OUT_DIR}}/netlist/${{DESIGN}}_${{PERIOD}}.sdc

## Report and analyze power and timing
report power  -full_instance_names -flat > ${{OUT_DIR}}/rpt/${{DESIGN}}_${{PERIOD}}_cap_lef.power.rpt
report area   > ${{OUT_DIR}}/rpt/${{DESIGN}}_${{PERIOD}}_cap_lef.area.rpt
report timing > ${{OUT_DIR}}/rpt/${{DESIGN}}_${{PERIOD}}_cap_lef.timing.rpt
report gate   > ${{OUT_DIR}}/rpt/${{DESIGN}}_${{PERIOD}}_cap_lef.gate.rpt
'''.format(out_dir)

_rc_extract_act_cmd = '''

set OUT_DIR {0}

read_netlist -top ${{DESIGN}} ${{OUT_DIR}}/netlist/${{DESIGN}}_${{PERIOD}}_synth.v

define_clock  -name iClk -period ${{PERIOD}} [find / -port iClk]

external_delay -input 500 -clock [find / -clock iClk] -edge_rise  [all_inputs]
external_delay -output 500 -clock [find / -clock iClk] -edge_rise  [all_outputs]

set_attribute hdl_track_filename_row_col true

read_tcf "sim.tcf"

## report and analyze power and timing
report power  > act.power.rpt
report power  -full_instance_names -flat > act.detail.power.rpt
'''

_def_cds_lib='''--SOFTINCLUDE $SYSTEM_CDS_LIB_DIR/cds.lib
--SOFTINCLUDE {0}
define worklib {1}/INCA_libs/worklib
define work {2}/compiled/work
'''

def get_default_cds_lib(tech_lib_cds, out_dir):
    return _def_cds_lib.format(tech_lib_cds, out_dir, out_dir)

def get_rc_synthesis_script(design, tech_lib, out_dir, clk_period,
                            clk_gating=True, effort='high', exit_done=True):
    return _get_rc_lib_cmd(tech_lib)\
        + _get_rc_design_setting_cmd(design, clk_period, clk_gating, effort)\
        + _get_rc_synthesis_cmd(design, out_dir)+'\nexit\n' if exit_done else ''

def get_rc_activity_script(design, tech_lib, out_dir, clk_period,
                           clk_gating=True, effort='high', exit_done=True):
    return _get_rc_lib_cmd(tech_lib)\
        + _get_rc_design_setting_cmd(design, clk_period, clk_gating, effort)\
        + _rc_extract_act_cmd.format(out_dir) +'\nexit\n' if exit_done else ''

def get_ncsim_post_sim_script(design, tech_lib, clk_period, out_dir):
    ns = '{0} -cdslib {1}/cds.lib -work work -linedebug {2};'.format(
        NCVLOG, out_dir, tech_lib.sim_vlog)
    inc_str = ''
    for i in design.hdl_dirs: inc_str += ' -INCDIR '+ os.path.abspath(i)
    for t in design.testbench:
        ns += '%s -cdslib %s/cds.lib %s'%(NCVLOG, out_dir, inc_str)\
            + ' -work work  -linedebug %s;'%t
    ns += '%s -cdslib %s/cds.lib -work work -linedebug'%(NCVLOG, out_dir)\
        +' netlist/{0}_{1}_synth.v;'.format(design.synth_module, clk_period)
    ns += '%s -cdslib %s/cds.lib -work work -messages'%(NCELAB, out_dir)\
        +' -autosdf -ACCESS +rwc -timescale 1ps/1ps %s'%design.sim_module
    dump_cmd ='run\ndumptcf -overwrite -scope {0} -output sim.tcf\nrun\ndumptcf '\
        '-end\n'.format(design.tcf_path)
    return ns, dump_cmd

def generate_rc_scripts(design, tech_lib, clk_period, clk_gating,
                        effort, run_dir):
    syn_script = get_rc_synthesis_script(
        design=design, tech_lib=tech_lib, out_dir=run_dir,
        clk_period=clk_period, clk_gating=clk_gating,
        effort=effort, exit_done=True)
    rc_act_script = get_rc_activity_script(
        design=design, tech_lib=tech_lib, out_dir=run_dir,
        clk_period=clk_period, clk_gating=clk_gating,
        effort=effort, exit_done=True)
    ncsim_compile, dump_cmd = get_ncsim_post_sim_script(
        design=design, tech_lib=tech_lib, clk_period=clk_period,
        out_dir=run_dir)
    with open(os.path.join(run_dir, 'synthesize.cmd'), 'w') as f:
        f.write(syn_script)
    with open(os.path.join(run_dir,'post-sim-compile.cmd'),'w') as f:
        f.write(ncsim_compile)
    with open(os.path.join(run_dir,'post-sim-dump.cmd'),'w') as f:
        f.write(dump_cmd)
    with open(os.path.join(run_dir, 'power-estimation.cmd'), 'w') as f:
        f.write(rc_act_script)
    with open(os.path.join(run_dir, 'cds.lib'), 'w') as f:
        f.write(get_default_cds_lib(tech_lib.cds_lib, run_dir))

def run_synthesis(tcsh_rc, run_dir, VERBOSE=False):
    synth_cmd = os.path.join(run_dir, 'synthesize.cmd')
    cmd = ['tcsh', '-c', 'source {0};{1} -files {2};stty sane'.format(
            tcsh_rc, RC, synth_cmd)]
    cwd = os.getcwd()
    os.chdir(run_dir)
    try:
        child = subprocess.Popen(cmd, stderr=subprocess.PIPE)
        with open('synthesis.log', 'w') as log:
            while True:
                out = child.stderr.read(1)
                if out == '' and child.poll() != None:
                    break
                if out != '':
                    log.write(out)
                    if VERBOSE:
                        sys.stdout.write(out)
                        sys.stdout.flush()
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
    finally: os.chdir(cwd)

def compile_post_sim(tcsh_rc, run_dir):
    sys_utils.mkdir_p(os.path.join(run_dir, 'INCA_libs'))
    sys_utils.mkdir_p(os.path.join(run_dir, 'INCA_libs', 'worklib'))
    sys_utils.mkdir_p(os.path.join(run_dir, 'compiled'))
    sys_utils.mkdir_p(os.path.join(run_dir, 'compiled', 'work'))
    compile_cmd = os.path.join(run_dir, 'post-sim-compile.cmd')
    with open(compile_cmd) as f: compile_cmd = f.read()
    cmd = ['tcsh', '-c', 'source {0};{1};stty sane'.format(
            tcsh_rc, compile_cmd)]
    cwd = os.getcwd()
    os.chdir(run_dir)
    try:
        if not os.path.exists('hdl.var'): open('hdl.var', 'a')
        comp_log = tempfile.TemporaryFile()
        subprocess.check_call(cmd, stdout=comp_log)
        comp_log.seek(0)
        with open('compile.log', 'w') as f: f.write(comp_log.read())
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
    finally: os.chdir(cwd)

def check_and_synthesis(design, run_dir, tcsh_rc, force, VERBOSE):
    syn_hash = {}
    for f in design.hdls: syn_hash[f] = sys_utils.md5_file(f)
    for d in design.hdl_dirs:
        for f in glob.glob(os.path.join(d, '*.v')):
            syn_hash[f] = sys_utils.md5_file(f)
    syn_hash_file = os.path.join(run_dir, 'synth_src.hash')
    skip_synth = False
    if os.path.exists(syn_hash_file):
        if VERBOSE: print('Checking existing build in '+run_dir)
        with open(syn_hash_file) as f:
            try:
                h_cache = json.load(f)
                skip_synth = True
                ck = h_cache.keys()
                if len(ck) != len(syn_hash): skip_synth = False
                else:
                    for f in ck:
                        if f not in syn_hash or h_cache[f] != syn_hash[f]:
                            skip_synth = False
            except: skip_synth = False
    with open(syn_hash_file, 'w') as f: json.dump(syn_hash, f)
    if not skip_synth or force:
        start = time.time()
        if VERBOSE: print('Running RTL synthesis with RC')
        run_synthesis(tcsh_rc, run_dir, VERBOSE)
        if VERBOSE: print('Compiling post-synthesis simulation libraries')
        compile_post_sim(tcsh_rc, run_dir)
        for f in glob.glob(os.path.join(run_dir, 'rc.log*')):os.remove(f)
        for f in glob.glob(os.path.join(run_dir, 'rc.cmd*')):os.remove(f)
        for f in glob.glob(os.path.join(run_dir, 'nc*.log')):os.remove(f)
        t = time.time() - start
        if VERBOSE: print_green('Synthesis finished, elasped time %.2fs'%t)
    elif VERBOSE: print('RTL hash matches, skip synthesis and compilation.')


def run_post_synth_sim(sim_module, tcsh_rc, run_dir, cmd_dir, cds_lib):
    dump_cmd = os.path.join(cmd_dir, 'post-sim-dump.cmd')
    cwd = os.getcwd()
    os.chdir(run_dir)
    cmd = ['tcsh', '-c', 'source {0};{1} -input {2} -cdslib {3} {4};'\
             'stty sane'.format(tcsh_rc, NCSIM, dump_cmd, cds_lib, sim_module )]
    try:
        if not os.path.exists('hdl.var'): open('hdl.var', 'a')
        sim_log = tempfile.TemporaryFile()
        subprocess.check_call(cmd, stdout=sim_log)
        sim_log.seek(0)
        with open('post-sim.log', 'w') as f: f.write(sim_log.read())
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
    finally: os.chdir(cwd)

def run_rc_power_analysis(tcsh_rc, run_dir, cmd_dir):
    pe_cmd = os.path.join(cmd_dir, 'power-estimation.cmd')
    cmd = ['tcsh', '-c', 'source {0};{1} -files {2};stty sane'.format(
            tcsh_rc, RC, pe_cmd)]
    cwd = os.getcwd()
    os.chdir(run_dir)
    try:
        synth_log = tempfile.TemporaryFile()
        subprocess.check_call(cmd, stdout=synth_log)
        synth_log.seek(0)
        with open('power.log', 'w') as f: f.write(synth_log.read())
    except:
        print >>sys.stderr, "Unexpected error:", sys.exc_info()[0], sys.exc_info()[1]
    finally: os.chdir(cwd)

def get_rc_total_power(module, rpt_file):
    p = (0.0, 0.0, 0.0)
    with open(rpt_file) as f:
        for l in f.readlines():
            s = l.split()
            if len(s) != 5: continue
            if s[0] == module:
                p = (float(s[2]), float(s[3]), float(s[4]))
                break
    return p

def get_rc_detailed_power(module, rpt_file):
    p = (0.0, 0.0, 0.0)
    p = []
    active = False
    with open(rpt_file) as f:
        for l in f.readlines():
            if not active:
                if [x for x in l.strip() if x != '-']: continue
                active = True
                continue
            s = l.split()
            if len(s) != 4: continue
            p.append((s[0], float(s[1]), float(s[2]), float(s[3])))
    return p
