#!/bin/env python2
import os,sys,re
from sim_trace_error import SimTraceError

_cycle_hdr_re = re.compile('^=\[(.+)\] >>([0-9]+)<< CP-PC=([0-9]+)')
_stage_hdr_re = re.compile('^ \|=\[(.+)\](.+)')
_reg_rstr = '\$F?\(\d+\)'
_cbranch_re = re.compile(
    '^>>OP @(\d+)<([A-Z]+)>\s+\{(%s),\s+(-?\d+)\}\s+\[l=(\d+)\]'%_reg_rstr)
_rinstr_re = re.compile(
    '^>>OP @(\d+)<([A-Z]+)>\s+\{(%s)\}\s+<=\s+\{(%s),\s+(%s)\}\s+'
    'FU(\d+)\[l=(\d+)\]'%(_reg_rstr, _reg_rstr, _reg_rstr))
_cmov_re = re.compile(
    '^>>OP @(\d+)<([A-Z]+)>\s+\{(%s)\}\s+<=\s+\{(%s),\s+(%s),\s+(-?\d+)\}\s+'
    'FU(\d+)\[l=(\d+)\]'%(_reg_rstr, _reg_rstr, _reg_rstr))
_cmovr_re = re.compile(
    '^>>OP @(\d+)<([A-Z]+)>\s+\{(%s)\}\s+<=\s+\{(%s),\s+(%s),\s+(%s)\}\s+'
    'FU(\d+)\[l=(\d+)\]'%(_reg_rstr, _reg_rstr, _reg_rstr, _reg_rstr))
_iinstr_re = re.compile(
    '^>>OP @(\d+)<([A-Z]+)>\s+\{(%s)\}\s+<=\s+\{(%s),\s+(-?\d+)\}\s+'
    'FU(\d+)\[l=(\d+)\]'%(_reg_rstr, _reg_rstr))
_store_re = re.compile(
    '^>>OP @(\d+)<([A-Z]+)>\s+\{(%s),\s+(%s),\s+(-?\d+)\}\s+'
    'FU(\d+)\[l=(\d+)\]'%(_reg_rstr, _reg_rstr))
_imminstr_re = re.compile('^>>OP @(\d+)<([SZ]IMM)>\s+\{(-?\d+)\}\s+\[l=(\d+)\]')
_ji_re = re.compile('^>>OP @(\d+)<([A-Z]+)>\s+\{(-?\d+)}\s+\[l=(\d+)\]')
_jr_re = re.compile('^>>OP @(\d+)<([A-Z]+)>\s+\{(\$\(\d+\))\}\s+\[l=(\d+)\]')

_commit_re = re.compile('^>>\$\((\d+)\)=(-?\d+)')
_flag_wr_re = re.compile('^>>\$F\((\d+)\)=(-?\d+)')

_reg_op_re  = re.compile('\$\((\d+)\)')
_flag_op_re = re.compile('\$F\((\d+)\)')

_mem_rd_re=re.compile(
    '>>([RA]):Read(\d+),\s+A=(\d+),\s*dat=(\d+),\s*lat=(\d+),\s*dst=(\d+)')
_mem_wr_re=re.compile('>>([RA]):Write(.+),\s+A=(\d+),\s*dat=(\d+),\s*lat=(\d+)')

_valid_comps  = ('CP', 'PE')
_valid_stages = ('commit', 'execute', 'decode', 'fetch')
_reg_alias = {'CP':{0:'ZERO', 1:'SP'}, 'PE':{0:'ZERO'}}
_br_opcode = set(('BF', 'BNF', 'J', 'JR', 'JAL', 'JALR'))
_cbr_opcode = set(('BF', 'BNF'))

def get_reg_op(r):
    rm = _reg_op_re.match(r)
    return -1 if not rm else int(rm.group(1))

def get_flag_op(f):
    fm = _flag_op_re.match(f)
    return -1 if not fm else int(fm.group(1))

def get_op_str(op, comp):
    if type(op) != tuple or len(op) != 2:
        raise TypeError('argument should be a tuple (type, value)')
    if op[0] == 'Reg':
        return _reg_alias[comp][op[1]] if op[1] in _reg_alias[comp]\
            else '$(%d)'%op[1]
    elif op[0] == 'Flag':
        return '$F(%d)'%op[1]
    elif op[0] == 'Imm':
        return '%d'%op[1]
    else:
        raise SimTraceError('Invalid operand type "%s"'%op[0])

def get_mem_op_str(mo):
    s = 'M-%s %s: addr=%d, width=%d'%(
        'Req' if mo['type'] == 'R' else 'Ack',
        'Read' if 'dst' in mo else 'Write', mo['addr'], mo['width'])
    if mo['type'] == 'A' or 'dst' not in mo: s+= ', data=%d'%mo['data']
    if 'dst' in mo: s += ', to $(%d)'%mo['dst']
    s += ', latency = %d'%mo['lat']
    return s

class TraceInstr:
    def __init__(self, opcode, addr, comp, dest = None, latency=-1, fu=-1):
        self.opcode   = opcode
        self.comp     = comp
        self.addr     = int(addr)
        self.latency  = latency
        self.fu       = fu
        self.dest     = dest
        self.operands = []
        self.use      = 0

    def inc_use(self): self.use += 1

    def add_operand(self, *args):
        for op in args:
            r = get_reg_op(op)
            f = -1 if r >= 0 else get_flag_op(op)
            if r >= 0: self.operands.append(('Reg', r))
            elif f >= 0:
                if r < 0: r = 0
                self.operands.append(('Flag', r))
            else: self.operands.append(('Imm', int(op)))

    def has_condbr(self, tgt):
        if self.opcode not in _cbr_opcode: return False
        if tgt != None: 
            if self.operands[-1][0] == 'Imm':
                return tgt == (self.operands[-1][1] + self.addr)
            return False
        return True

    def has_uncondbr(self, tgt):
        if self.opcode in _cbr_opcode:    return False
        if self.opcode not in _br_opcode: return False
        if tgt != None: 
            if self.operands[-1][0] == 'Imm':
                return tgt == (self.operands[-1][1] + self.addr)
            return False
        return True

    def has_br(self, tgt):
        if self.opcode not in _br_opcode: return False
        if tgt != None: 
            if self.operands[-1][0] == 'Imm':
                return tgt == (self.operands[-1][1] + self.addr)
            return False
        return True

    def uses_val(self, v):
        for o in self.operands:
            if o[0] == 'Reg' and o[1] == v: return True
        return False

    def uses_flag(self, f):
        for o in self.operands:
            if o[0] == 'Flag' and o[1] == f: return True
        return False

    def uses_imm(self, v):
        for o in self.operands:
            if o[0] == 'Imm' and o[1] == v: return True
        return False

    def uses_fu(self, f):  return self.fu == f
    def uses_opcode(self, opc): return self.opcode == opc
    def def_val(self, v):  return self.dest and get_reg_op(self.dest) == v
    def def_flag(self, f): return self.dest and get_flag_op(self.dest) == f

    def __str__(self):
        s = '[%d] %s'%(self.addr, self.opcode)
        if self.dest: s += ' {%s}'%self.dest
        if self.operands:
            s += ' <= ' if self.dest else '  '
            s+='{'
            for i, op in enumerate(self.operands):
                ops = get_op_str(op, self.comp)
                s += ', %s'%ops if i > 0 else '%s'%ops
            s+='}'
        if self.fu >= 0:      s += ' FU%d'%self.fu
        if self.latency >= 0: s += '[l=%d]'%self.latency
        return s

class TraceCycle:
    def __init__(self, cycle, pc):
        self.cycle = cycle
        self.pc    = pc
        self.instrs = {'CP':{'fetch':[],'decode':[],'execute':[],'commit':[]},
                       'PE':{'fetch':[],'decode':[],'execute':[],'commit':[]}}
        self.lines = {'CP':{'fetch':[],'decode':[],'execute':[],'commit':[]},
                      'PE':{'fetch':[],'decode':[],'execute':[],'commit':[]}}
        self.commits      = {'CP':{}, 'PE':{}}
        self.memory_ops   = {'CP':[], 'PE':[]}
        self.flag_updates = {'CP':{}, 'PE':{}}
        self.branch_target = None
        self.terminate     = False

    def add_trace_instr(self, comp, stage, instr):
        comp, stage  = comp.upper(), stage.lower()
        if instr:
            if comp in _valid_comps : self.instrs[comp][stage].append(instr)
            else: raise SimTraceError('Invalid component "%s"'%comp)

    def add_trace_line(self, comp, stage, ln):
        ln = ln.strip()
        if not ln: return
        if ln == '>>Terminate':
            self.terminate = True
            return
        if ln.startswith('>>Branch to'):
            self.branch_target = int(ln[11:])
            return
        comp, stage  = comp.upper(), stage.lower()
        if comp not in _valid_comps:
            raise SimTraceError('Invalid component "%s"'%comp)
        if stage not in _valid_stages:
            raise SimTraceError('Invalid stage "%s"'%stage)
        cmatch  = _commit_re.match(ln)  if stage == 'commit'  else None
        fwmatch = mrmatch = mwmatch = None
        if stage == 'execute':
            fwmatch = _flag_wr_re.match(ln)
            mrmatch = None if fwmatch else _mem_rd_re.match(ln)
            mwmatch = None if mrmatch else _mem_wr_re.match(ln)
        if cmatch: self.commits[comp][int(cmatch.group(1))]=int(cmatch.group(2))
        elif fwmatch:
            self.flag_updates[comp][int(fwmatch.group(1))]=int(fwmatch.group(2))
        elif mrmatch:
            #'>>[RA]:Read(\d+),\s+A=(\d+),\s*dat=(\d+),\s*lat=(\d+),\s*dst=(\d+)'
            self.memory_ops[comp].append(
                {'type':mrmatch.group(1),      'width':int(mrmatch.group(2)),
                 'addr':int(mrmatch.group(3)), 'data':int(mrmatch.group(4)),
                 'lat':int(mrmatch.group(5)),  'dst':int(mrmatch.group(6))})
        elif mwmatch:
            #'>>[RA]:Write(.+),\s+A=(\d+),\s*dat=(\d+),\s*lat=(\d+)'
            self.memory_ops[comp].append(
                {'type':mwmatch.group(1),      'width':int(mwmatch.group(2)),
                 'addr':int(mwmatch.group(3)), 'data':int(mwmatch.group(4)),
                 'lat':int(mwmatch.group(5))})
        else:
            if ln.startswith('>>R:') or ln.startswith('>>A:'):
                raise SimTraceError('Memory op not recognized: "%s"'%ln)
            if ln.startswith('>>OP'):
                raise SimTraceError('Operation not recognized: "%s"'%ln)
            self.lines[comp][stage].append(ln)

    def get_instr(self, comp, stage):
        comp, stage = comp.upper(), stage.lower()
        if comp not in _valid_comps:
            raise SimTraceError('Invalid component "%s"'%comp)
        if stage not in _valid_stages:
            raise SimTraceError('Invalid stage "%s"'%stage)
        return self.instrs[comp][stage]

    def use_instr(self, iaddr, comp, stage='all'):
        comp, stage  = comp.upper(), stage.lower()
        if comp not in _valid_comps:
            raise SimTraceError('Invalid component "%s"'%comp)
        if stage != 'all' and stage not in _valid_stages:
            raise SimTraceError('Invalid stage "%s"'%stage)
        stages = _valid_stages if stage == 'all' else (stage, )
        for st in stages:
            if self.instrs[comp][st].addr == iaddr: return True
        return False

    def __check_instr(self, fn,  comp, stage, *args):
        comp, stage  = comp.upper(), stage.lower()
        comps  = _valid_comps  if comp  == 'ALL' else (comp, )
        stages = _valid_stages if stage == 'all' else (stage,)
        for c in comps:
            for st in stages:
                t = map(lambda ins: getattr(ins, fn)(*args), self.instrs[c][st])
                if True in t: return True
        return False
        
    def has_define(self, v, comp, stage):
        return self.__check_instr('def_val', comp, stage, v)

    def has_use(self, v, comp, stage):
        return self.__check_instr('uses_val', comp, stage, v)

    def has_writeflag(self, f, comp, stage):
        return self.__check_instr('def_flag', comp, stage, f)

    def has_readflag(self, f, comp, stage):
        return self.__check_instr('uses_flag', comp, stage, f)

    def has_opcode(self, o, comp, stage):
        return self.__check_instr('uses_opcode', comp, stage, o)

    def has_fu(self, f, comp, stage):
        return self.__check_instr('uses_fu', comp, stage, f)

    def has_br(self, addr, comp, stage):
        return self.__check_instr('has_br', 'CP', stage, addr)

    def has_condbr(self, addr, comp, stage):
        return self.__check_instr('has_condbr', 'CP', stage, addr)

    def has_uncondbr(self, addr, comp, stage):
        return self.__check_instr('has_uncondbr', 'CP', stage, addr)

    def has_takenbr(self, addr, comp, stage):
        if self.branch_target == None and not self.terminate: return False
        return True if addr == None\
            else self.__check_instr('has_br', 'CP', 'decode', addr)

    def has_commit(self, v, comp, stage):
        comps  = _valid_comps  if comp.upper()  == 'ALL' else (comp.upper(),)
        for c in comps:
            if v in self.commits[c]: return True
        return False

    def has_mem(self, addr, comp, stage):
        comps  = _valid_comps  if comp.upper()  == 'ALL' else (comp.upper(),)
        for c in comps:
            if not self.memory_ops[c]: continue
            if addr != None:
                for m in self.memory_ops[c]:
                    if m['addr'] == addr: return True
            else: return True
        return False

    def has_store(self, addr, comp, stage):
        comps  = _valid_comps  if comp.upper()  == 'ALL' else (comp.upper(),)
        for c in comps:
            if not self.memory_ops[c]: continue
            for m in self.memory_ops[c]:
                if 'dst' in m: continue
                if addr != None:
                    if m['addr'] == addr: return True
                else: return True
        return False

    def has_load(self, addr, comp, stage):
        comps  = _valid_comps  if comp.upper()  == 'ALL' else (comp.upper(),)
        for c in comps:
            if not self.memory_ops[c]: continue
            for m in self.memory_ops[c]:
                if 'dst' not in m: continue
                if addr != None:
                    if m['addr'] == addr: return True
                else: return True
        return False

    def stage_str(self, comp='ALL', stage='all'):
        s = ''
        comp, stage  = comp.upper(), stage.lower()
        comps  = _valid_comps  if comp  == 'ALL' else (comp, )
        stages = _valid_stages if stage == 'all' else (stage,)
        for c in comps:
            c_s = ''
            if c not in _valid_comps:
                raise SimTraceError('Invalid component "%s"'%c)
            for st in stages:
                if st not in _valid_stages:
                    raise SimTraceError('Invalid stage "%s"'%st)
                if self.instrs[c][st]:
                    for instr in self.instrs[c][st]:
                        c_s += '   |==[%7s] OP: %s\n'%(st, str(instr))
                if self.lines[c][st]:
                    for l in self.lines[c][st]:c_s+='   |==[%7s] -- %s\n'%(st,l)
                if st == 'commit':
                    if self.commits[c]:
                        for r, v in self.commits[c].items():
                            c_s += '   |==[ commit] >> $(%d) = %d\n'%(r, v)
                if st == 'execute':
                    if self.flag_updates[c]:
                        for r, v in self.flag_updates[c].items():
                            c_s += '   |==[execute] >> $F(%d) = %d\n'%(r, v)
                    if self.memory_ops[c]:
                        for mo in self.memory_ops[c]:
                            c_s += '   |==[execute] >> %s\n'%get_mem_op_str(mo)
            if c_s: s += '== %s\n%s'%(c, c_s)
        if (self.branch_target != None) and not self.terminate and\
                (stage == 'all' or stage == 'decode'):
            s += '---- Branching to %d ----'%self.branch_target
        return s+'>>>> Terminate <<<<' if self.terminate else s

    def __str__(self): return self.stage_str()

class SimulationTrace:
    def __init__(self):
        self.__clean()

    def __clean(self):
        self.trace  = {}
        self.max_cycle = -1
        self.filename = None
        self.program = {'CP':{}, 'PE':{}}
        self.max_pc = -1

    def has(self, t): return t in self.trace
    def get(self, t): return self.trace[t] if t in self.trace else None
    def __len__(self):   return len(self.trace)

    def print_stat(self):
        print 'Arch name: %s\nTrace:   len = %d cycles, max_cycle=%d\n'\
            'Program: cp_ops = %d, pe_ops = %d, max_pc = %d'%(
            self.arch, len(self.trace), self.max_cycle,
            len(self.program['CP']), len(self.program['PE']), self.max_pc)

    def get_instr_str(self, addr, comp, skip_nop = False):
        comp = comp.upper()
        if comp != 'ALL' and comp not in _valid_comps:
            raise SimTraceError('Invald component "%s"'%comp)
        comps = _valid_comps if comp == 'ALL' else (comp,)
        s = ''
        sep = False
        for i, c in enumerate(comps):
            c_s = str(self.program[c][addr])\
                if addr in self.program[c] else (
                '[%d] NOP'%addr if not skip_nop else '')
            if c_s:
                if sep: s += '  ||  '
                s += '%s: %s'%(c, c_s)
                sep = True
        return s

    def search(self, cycle, arg):
        return None
        
    def read_trace(self, filename, keep=False):
        if not keep: self.__clean()
        with file(filename) as f: trace_lns = f.read().split('\n')

        self.filename = os.path.abspath(filename)
        self.arch = None
        cyc  = -1
        proc  = None
        stage = None
        self.program = {'CP':{}, 'PE':{}}
        for l in trace_lns:
            cycm = _cycle_hdr_re.match(l)
            if cycm:
                if not self.arch: self.arch = cycm.group(1)
                cyc = int(cycm.group(2))
                pc  = int(cycm.group(3))
                if cyc not in self.trace:
                    self.trace[cyc] = TraceCycle(cyc, pc)
                    if cyc > self.max_cycle: self.max_cycle = cyc
            else: #if cycm:
                stgm = _stage_hdr_re.match(l)
                if stgm:
                    proc  = stgm.group(1).upper() 
                    stage = stgm.group(2).lower()
                    if proc not in _valid_comps:
                        raise SimTraceError('Invalid component "%s"'%proc)
                    if stage not in _valid_stages:
                        raise SimTraceError('Invalid stage "%s"'%stage)
                elif not self.arch or cyc not in self.trace:
                    pass
                else:
                    if not proc: raise SimTraceError('No valid component')
                    if not stage: raise SimTraceError('No valid stage')

                    l = l.strip()
                    rimatch  = _rinstr_re.match(l)
                    iimatch  = None if rimatch else _iinstr_re.match(l)
                    cmmatch  = None if iimatch else _cmov_re.match(l)
                    cmrmatch = None if cmmatch else _cmovr_re.match(l)
                    stmatch  = None if cmmatch else _store_re.match(l)
                    cbmatch  = None if stmatch else _cbranch_re.match(l)
                    jimatch  = None if cbmatch else _ji_re.match(l)
                    jrmatch  = None if jimatch else _jr_re.match(l)
                    immmatch = None if jrmatch else _imminstr_re.match(l)
                    ln_instr = None
                    ln_addr  = -1
                    if cmrmatch: cmmatch = cmrmatch
                    if rimatch:
                        ln_instr = TraceInstr(
                            opcode=rimatch.group(2), addr=rimatch.group(1),
                            comp=proc, dest=rimatch.group(3),
                            fu=int(rimatch.group(6)),
                            latency=int(rimatch.group(7)))
                        ln_instr.add_operand(rimatch.group(4), rimatch.group(5))
                        ln_addr = int(rimatch.group(1))
                    elif iimatch:
                        ln_instr = TraceInstr(
                            opcode=iimatch.group(2), addr=iimatch.group(1),
                            comp=proc, dest=iimatch.group(3),
                            fu=int(iimatch.group(6)), 
                            latency=int(iimatch.group(7)))
                        ln_instr.add_operand(iimatch.group(4), iimatch.group(5))
                        ln_addr = int(iimatch.group(1))
                    elif cmmatch:
                        ln_instr = TraceInstr(
                            opcode=cmmatch.group(2), addr=cmmatch.group(1),
                            comp=proc, dest=cmmatch.group(3),
                            fu=int(cmmatch.group(7)),
                            latency=int(cmmatch.group(8)))
                        ln_instr.add_operand(cmmatch.group(4), cmmatch.group(5),
                                             cmmatch.group(6))
                        ln_addr = int(cmmatch.group(1))
                    elif stmatch:
                        ln_instr = TraceInstr(
                            opcode=stmatch.group(2), addr=stmatch.group(1),
                            comp=proc, fu=int(stmatch.group(6)),
                            latency=int(stmatch.group(7)))
                        ln_instr.add_operand(stmatch.group(3), stmatch.group(4),
                                             stmatch.group(5))
                        ln_addr = int(stmatch.group(1))
                    elif cbmatch:
                        ln_instr = TraceInstr(
                            opcode=cbmatch.group(2),addr=cbmatch.group(1),
                            comp=proc, latency=int(cbmatch.group(5)))
                        ln_instr.add_operand(cbmatch.group(3), cbmatch.group(4))
                        ln_addr = int(cbmatch.group(1))
                    elif jimatch:
                        ln_instr = TraceInstr(
                            opcode=jimatch.group(2),addr=jimatch.group(1),
                            comp=proc, latency=int(jimatch.group(4)))
                        ln_instr.add_operand(jimatch.group(3))
                        ln_addr = int(jimatch.group(1))
                    elif jrmatch:
                        ln_instr = TraceInstr(
                            opcode=jrmatch.group(2),addr=jrmatch.group(1),
                            comp=proc, latency=int(jrmatch.group(4)))
                        ln_instr.add_operand(jrmatch.group(3))
                        ln_addr = int(jrmatch.group(1))
                    elif immmatch:
                        ln_instr = TraceInstr(
                            opcode=immmatch.group(2),addr=immmatch.group(1),
                            comp=proc, latency=int(immmatch.group(4)))
                        ln_instr.add_operand(immmatch.group(3))
                        ln_addr = int(immmatch.group(1))
                    elif l.startswith('>>OP'):
                        raise SimTraceError('Cannot process operation "%s"'%l)
                
                    if ln_instr:
                        if ln_addr not in self.program[proc]:
                            self.program[proc][ln_addr] = ln_instr
                            self.max_pc = max(self.max_pc, ln_addr)
                        self.trace[cyc].add_trace_instr(
                            proc, stage, self.program[proc][ln_addr])
                    else:
                        self.trace[cyc].add_trace_line(proc, stage, l)
            # if cycm else
        #for l in trace_lns
        pc_set = set()
        for v in self.trace.values():
            for c in _valid_comps:
                pc_set.clear()
                for s in _valid_stages:
                    for ins in v.get_instr(c, s): pc_set.add(ins.addr)
                for p in pc_set:
                    self.program[c][p].inc_use()
            # for c in _valid_comps
        # for v in self.trace.values()
    # read_trace()
