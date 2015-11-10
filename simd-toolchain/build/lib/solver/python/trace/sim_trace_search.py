#!/bin/env python2
from sim_trace_error import SimTraceError

_method_proto = {
    'use':'index', 'define':'index', 'commit':'index',
    'readflag':'index', 'writeflag':'index', 'fu':'index',
    'opcode':'opcode',
    'store':'addr', 'load':'addr', 'mem':'addr',
    'condbr':'addr', 'uncondbr':'addr', 'br':'addr', 'takenbr':'addr',
    }
class SimTraceSearchEngine:
    keywords = ('next', 'last', # range
                # control
                'print',
                # filters
                'stage', 'comp',
                # branches
                'condbr', 'uncondbr', 'br', 'takenbr',
                # opcode
                'opcode', 'store', 'load', 'mem',
                'fu',
                # value update
                'use', 'define', 'readflag', 'writeflag', 'commit')
    states   = ('init', 'setdir', 'getindex', 'setcomp', 'setstage'
                'getopcode', 'getaddr',
                'done', 'err')
    def __init__(self): self.__state = 'init'
    def has_error(self): return self.__state == 'err'
    
    def __set_last_undef_filter(self, method):
        if self.__search_param['filter'] \
                and 'method' not in self.__search_param['filter'][-1]:
            self.__search_param['filter'][-1]['method'] = method
        else:
            self.__search_param['filter'].append(
                {'method':method, 'comp':self.__comp, 'stage':self.__stage})

    def process_keyword(self, k):
        if k not in SimTraceSearchEngine.keywords:
            raise SimTraceError('Unknown search keyword "%s"'%k)
        if k == 'next':
            self.__search_param['forward'] = True
            return 'setdir'
        elif k == 'last':
            self.__search_param['forward'] = False
            return 'setdir'
        elif k in _method_proto:
            self.__set_last_undef_filter(k)
            if _method_proto[k] == 'index':
                return 'getindex'
            elif _method_proto[k] == 'opcode':
                return 'getopcode'
            elif _method_proto[k] == 'addr':
                self.__search_param['filter'][-1]['addr'] = None
                return 'getaddr'
        elif k == 'comp':  return 'setcomp'
        elif k == 'stage': return 'setstage'
        elif k == 'print':
            self.__search_param['print'] = True
            return self.__state
        raise SimTraceError('Keyword "%s" not handled'%k)

    def _getindex_next(self, tk):
        try: self.__search_param['filter'][-1]['index'] = int(tk)
        except ValueError: raise SimTraceError('Invalid index "%s"'%tk)
        return 'init'

    def _getaddr_next(self, tk):
        try: self.__search_param['filter'][-1]['addr'] = int(tk)
        except ValueError: return self.process_keyword(tk)
        return 'init'

    def _getopcode_next(self, tk):
        self.__search_param['filter'][-1]['opcode'] = tk.upper()
        return 'init'

    def _setcomp_next(self, tk):
        tku = tk.upper()
        if tku != 'CP' and tku != 'PE' and tku != 'ALL':
            raise SimTraceError('Invalid component "%s"'%tk)
        self.__comp = tku
        if 'method' not in self.__search_param['filter'][-1]:
            self.__search_param['filter'][-1]['comp'] = tku
        return 'init'

    def _setstage_next(self, tk):
        tkl = tk.lower()
        if tkl != 'fetch' and tkl != 'decode' and tkl != 'execute'\
                and tkl != 'commit' and tkl != 'all':
            raise SimTraceError('Invalid stage "%s"'%tk)
        self.__stage = tkl
        if 'method' not in self.__search_param['filter'][-1]:
            self.__search_param['filter'][-1]['stage'] = tkl
        return 'init'

    def _init_next(self, tk): return self.process_keyword(tk)

    def _setdir_next(self, tk):
        try: self.__search_param['range'] = int(tk)
        except ValueError: return self.process_keyword(tk)
        return 'init'
        
    def parse_arg(self, tokens):
        self.__state   = 'init'
        self.__comp, self.__stage = 'CP', 'fetch'
        self.__search_param = {'forward':True, 'range':0, 'print':False,
                               'filter':[{'comp':'CP', 'stage':'fetch'}]}
        for tk in tokens:
            transition = getattr(self, '_%s_next'%self.__state)
            # s = '%s'%self.__state
            self.__state = transition(tk)
            # s += '->%s'%self.__state
            # print s
            if not self.__state or self.__state=='done' or self.__state=='err':
                break
        return self.__search_param

def check_cycle(trace, c, filters):
    t_cycle = trace.get(c)
    if not t_cycle: return False
    for f in filters:
        if 'method' not in f: raise SimTraceError('Undefined method')
        try:
            fn = getattr(t_cycle, 'has_%s'%f['method'])
        except AttributeError:
            raise SimTraceError('"%s" method not supported'%f['method'])
        mp = _method_proto[f['method']]
        if mp == 'index':
            if not fn(f['index'], f['comp'], f['stage']): return False
        elif mp == 'opcode':
            if 'opcode' not in f:raise SimTraceError('no search opcode')
            if not fn(f['opcode'], f['comp'], f['stage']): return False
        elif mp == 'addr':
            addr = f['addr'] if 'addr' in f else None
            if not fn(addr=addr, comp=f['comp'], stage=f['stage']): return False
    return True

def run_search(trace, cycle, search_param):
    rng = search_param['range']
    if search_param['forward']:
        start, end = cycle+1, trace.max_cycle if rng == 0 else cycle + rng
    else: start, end = 0 if rng == 0 else cycle - rng, cycle-1
    start, end = max(0, start), min(end, trace.max_cycle)
    (s,e,i) = (start,end+1,1) if search_param['forward'] else (end,start-1,-1)
    for c in range(s, e, i):
        if check_cycle(trace, c, search_param['filter']): return c
            

_trace_search = SimTraceSearchEngine()

def search_sim_trace(trace, cycle, arg):
    if len(trace) <= 0: return
    arg_tokens = arg.split()
    sp = _trace_search.parse_arg(arg_tokens)
    if _trace_search.has_error() or not sp or not sp['filter']:
        raise SimTraceError('Invalid search command "%s"'%arg)
    c = run_search(trace, cycle, sp)
    if c != None and sp['print']: print '>>  %d  <<\n%s'%(c,str(trace.get(c)))
    # print 'c=%s'%str(c)
    return c
