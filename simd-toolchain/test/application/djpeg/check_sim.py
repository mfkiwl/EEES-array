import os, sys
d = os.path.join(os.path.dirname(__file__), '..', 'py-binding')
sys.path.append(os.path.abspath(d))
d = os.path.join(os.path.dirname(__file__), '..', 'lib', 'solver', 'python')
sys.path.append(os.path.abspath(d))

import solver_sim
from utils import solver_bin
from utils.print_color import *

def get_i32_value(val, sim, prog):
    v_p = prog.get_data_object(val)['start']
    return sim.cp_mem(v_p/4)

def run_to_func(func, sim, prog, to_end=False):
    f = prog.get_function(func)
    pc = f['start']+f['size']-1 if to_end else f['start']
    sim.run_pc_trap([pc])
    if sim.program_counter() != pc: raise RuntimeError('Cannot reach %s'%func)

def run_to_block(func, bid, sim, prog, to_end=False):
    b = prog.get_function(func)['blocks'][bid]
    pc = b['start']+b['size']-1 if to_end else b['start']
    sim.run_pc_trap([pc])
    if sim.program_counter() != pc:
        raise RuntimeError('Cannot reach %s.B%d'%(func, bid))

def check_fgetc(sim, prog, ref='fgetc.log'):
    with open(ref) as f:
        fl = f.read()
        f_ref = [int(x) for x in fl.strip().split()]
    sim.reset()
    err = 0
    for i, x in enumerate(f_ref):
        try:
            run_to_func('FGETC', sim, prog, to_end=True)
        except RuntimeError:
            print_red('Cannot reach %d-th FGETC'%i)
            return -1
        sim.run(4) # make sure result is in RF
        cc = sim.cp_ctx(11)
        if x != cc:
            print_red('FGETC %d failed, r11=%d, ref=%d'%(i, cc, x))
            err += 1
    return err

def check_comp(sim, prog, ref='comp.log'):
    sim.reset()
    run_to_func('main', sim, prog, to_end=True)
    n_comp = get_i32_value('n_comp', sim, prog)
    comp_p  = prog.get_data_object('comp')['start']/4
    comp_sz = prog.get_data_object('comp')['size']/10
    comp    = [comp_p+i*comp_sz for i in range(3)]
    with open(ref) as f:
        cl = f.read().splitlines()
        cb_ref = [[int(x) for x in l.strip().split()] for l in cl]
    err = 0
    for i in range (3):
        cb = sum([[(y>>24)&0xFF, (y>>16)&0xFF, (y>>8)&0xFF, y&0xFF]
                 for y in [int(sim.cp_mem(x))
                   for x in range(comp[i], comp[i]+comp_sz)]], [])
        if cb[:9] != cb_ref[i][:9]:
            print_red('Component %d info failed'%i)
            err += 1
    return err

def check_qtable(sim, prog, ref='qtable.log'):
    sim.reset()
    run_to_func('main', sim, prog, to_end=True)
    with open(ref) as f:
        ql = f.read().splitlines()
        qt_ref = [[int(x) for x in l.strip().split()] for l in ql]
    qbuff_p = prog.get_data_object('QTable')['start'] / 4
    qbuff   =[int(sim.cp_mem(qbuff_p+i))/4 for i in range(3)]
    err = 0
    for i, ref in enumerate(qt_ref):
        qt = sum([[(y>>24)&0xFF, (y>>16)&0xFF, (y>>8)&0xFF, y&0xFF]
                  for y in [int(sim.cp_mem(x))
                            for x in range(qbuff[i], qbuff[i]+16)]], [])
        if qt != ref:
            print_red('QTable[%d] failed'%i)
            err += 1
    return err

def check_htable(sim, prog, ref='htable.log'):
    sim.reset()
    run_to_func('main', sim, prog, to_end=True)
    with open(ref) as f:
        hl = f.read().splitlines()
        ht_ref = [[int(x)&0xFFFFFFFF for x in l.strip().split()] for l in hl]
    err = 0
    dt0_p = prog.get_data_object('DC_Table0')['start'] / 4
    dt0_ref = ht_ref[0]
    dt0_sz  = (len(dt0_ref)+3)/4
    dt0 = sum([[(y>>24)&0xFF, (y>>16)&0xFF, (y>>8)&0xFF, y&0xFF]
               for y in [int(sim.cp_mem(x))
                         for x in range(dt0_p, dt0_p+dt0_sz)]], [])
    if dt0[:len(dt0_ref)] != dt0_ref:
        print_red('DC_Table0 failed')
        err += 1
    dt1_p = prog.get_data_object('DC_Table1')['start'] / 4
    dt1_ref = ht_ref[1]
    dt1_sz  = (len(dt1_ref)+3)/4
    dt1 = sum([[(y>>24)&0xFF, (y>>16)&0xFF, (y>>8)&0xFF, y&0xFF]
               for y in [int(sim.cp_mem(x))
                         for x in range(dt1_p, dt1_p+dt1_sz)]], [])
    if dt1[:len(dt1_ref)] != dt1_ref:
        print_red('DC_Table1 failed')
        err += 1
    at0_p = prog.get_data_object('AC_Table0')['start'] / 4
    at0_ref = ht_ref[2]
    at0_sz  = (len(at0_ref)+3)/4
    at0 = sum([[(y>>24)&0xFF, (y>>16)&0xFF, (y>>8)&0xFF, y&0xFF]
               for y in [int(sim.cp_mem(x))
                         for x in range(at0_p, at0_p+at0_sz)]], [])
    if at0[:len(at0_ref)] != at0_ref:
        print_red('AC_Table0 failed')
        err += 1
    at1_p = prog.get_data_object('AC_Table1')['start'] / 4
    at1_ref = ht_ref[3]
    at1_sz  = (len(at1_ref)+3)/4
    at1 = sum([[(y>>24)&0xFF, (y>>16)&0xFF, (y>>8)&0xFF, y&0xFF]
               for y in [int(sim.cp_mem(x))
                         for x in range(at1_p, at1_p+at1_sz)]], [])
    if at1[:len(at1_ref)] != at1_ref:
        print_red('AC_Table1 failed')
        err += 1
    minc_p = prog.get_data_object('MinCode')['start'] / 4
    minc_ref, minc_sz = ht_ref[4], len(ht_ref[4])
    minc = [int(sim.cp_mem(x)) for x in range(minc_p, minc_p+minc_sz)]
    if minc[:len(minc_ref)] != minc_ref:
        print_red('MinCode failed')
        err += 1
    maxc_p = prog.get_data_object('MaxCode')['start'] / 4
    maxc_ref, maxc_sz = ht_ref[5], len(ht_ref[5])
    maxc = [int(sim.cp_mem(x)) for x in range(maxc_p, maxc_p+maxc_sz)]
    if maxc[:len(maxc_ref)] != maxc_ref:
        print_red('MaxCode failed')
        err += 1
    vp_p = prog.get_data_object('ValPtr')['start'] / 4
    vp_ref, vp_sz = ht_ref[6], len(ht_ref[6])
    vp = [int(sim.cp_mem(x)) for x in range(vp_p, vp_p+vp_sz)]
    if vp[:len(vp_ref)] != vp_ref:
        print_red('ValPtr failed')
        err += 1
    return err

def check_fblock(sim, prog, ref='fblock.log'):
    sim.reset()
    run_to_func('process_MCU', sim, prog)
    fbuff = int(get_i32_value('FBuff', sim, prog))/4
    with open(ref) as f:
        fl = f.read().splitlines()
        fb_ref = [[int(x)&0xFFFFFFFF for x in l.strip().split()] for l in fl]
    err = 0
    for i, ref in enumerate(fb_ref):
        run_to_func('IDCT', sim, prog)
        fb = [sim.cp_mem(x) for x in range(fbuff, fbuff+64)]
        if fb != ref:
            print_red('FBlock %d failed'%i)
            err += 1
    return err

def check_pblock(sim, prog, ref='pblock.log'):
    sim.reset()
    run_to_func('process_MCU', sim, prog)
    mbuff_p = prog.get_data_object('MCU_buff')["start"]/4
    mbuff = [int(sim.cp_mem(mbuff_p+i))/4 for i in range(3)]
    with open(ref) as f:
        pl = f.read().splitlines()
        pb_ref = [[int(x)&0xFFFFFFFF for x in l.strip().split()] for l in pl]
    err = 0
    for i in range(len(pb_ref)/3):
        for j in range(3):
            run_to_func('IDCT', sim, prog, to_end=True)
            pb = sum([[(y>>24)&0xFF, (y>>16)&0xFF, (y>>8)&0xFF, y&0xFF]
                      for y in [int(sim.cp_mem(x))
                                for x in range(mbuff[j], mbuff[j]+16)]], [])
            if pb != pb_ref[i*3+j]:
                print_red('PBlock %d, %d failed'%(i, j))
                err += 1
    return err

def check_color(sim, prog, ref='color.log'):
    with open(ref) as f:
        cl = f.read().splitlines()
        cb_ref = [[int(x) for x in l.strip().split()] for l in cl]
    sim.reset()
    run_to_func('process_MCU', sim, prog)
    cbuff_p = prog.get_data_object('ColorBuffer')['start']/4
    cbuff = int(sim.cp_mem(cbuff_p)) / 4
    mcu_sx = get_i32_value('MCU_sx', sim, prog)
    mcu_sy = get_i32_value('MCU_sy', sim, prog)
    n_comp = get_i32_value('n_comp', sim, prog)
    cbuff_sz = mcu_sx*mcu_sy*n_comp / 4
    err = 0
    for i, ref in enumerate(cb_ref):
        run_to_func('color_conversion', sim, prog, to_end=True)
        cb = sum([[(y>>24)&0xFF, (y>>16)&0xFF, (y>>8)&0xFF, y&0xFF]
                  for y in [int(sim.cp_mem(x))
                            for x in range(cbuff, cbuff+cbuff_sz)]], [])
        if cb != ref:
            print_red('ColorBuffer %d failed'%i)
            err += 1
    return err

if __name__ == '__main__':
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        print 'check_sim <prefix> [name]'
        exit(0)
    if os.path.exists(os.path.join(sys.argv[1], 'arch.json')):
        sim = solver_sim.SolverSim(os.path.join(sys.argv[1], 'arch.json'))
    else: sim = solver_sim.SolverSim('baseline')
    n = sys.argv[2] if len(sys.argv) == 3 else 'jpeg_decoder'
    sim.add_program_init(os.path.join(sys.argv[1], 'bin', n))
    prog = solver_bin.read_solver_stab(os.path.join(
            sys.argv[1], '%s.stab'%n))
    adr = prog.get_data_object('input_buffer')["start"]
    sim.add_data_binary('surfer.jpg', 'cp', adr)
    sim.reset()
    sim.run()
    print 'x_size=%d, y_size=%d,'%(get_i32_value('x_size', sim, prog),
                                  get_i32_value('y_size', sim, prog)),
    print 'rx_size=%d, ry_size=%d'%(get_i32_value('rx_size', sim, prog),
                                  get_i32_value('ry_size', sim, prog))
    print 'MCU_sx=%d, MCU_sy=%d,'%(get_i32_value('MCU_sx', sim, prog),
                                  get_i32_value('MCU_sy', sim, prog)),
    print 'n_comp=%d'%get_i32_value('n_comp', sim, prog)
    print 'stuffers=%d, passed=%d, vld_count=%d'%(
        get_i32_value('stuffers', sim, prog),
        get_i32_value('passed', sim, prog),
        get_i32_value('vld_count', sim, prog))
    
    if not check_fgetc(sim, prog):   print_green('FGETC check passed')
    else: exit(1)
    if not check_comp(sim, prog):   print_green('Comp check passed')
    else: exit(1)
    if not check_qtable(sim, prog):   print_green('QTable check passed')
    else: exit(1)
    if not check_htable(sim, prog):   print_green('HTable check passed')
    else: exit(1)
    if not check_fblock(sim, prog): print_green('FBlock check passed')
    else: exit(1)
    if not check_pblock(sim, prog): print_green('PBlock check passed')
    else: exit(1)
    if not check_color(sim, prog):  print_green('Color check passed')
    else: exit(1)
