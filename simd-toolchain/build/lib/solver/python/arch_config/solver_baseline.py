
DEFAULT_NUM_PE = 4
DEFAULT_DWIDTH = 32

class ControlProcessor(object):
    def __init__(self, cfg):
        self.rf       = cfg['rf'] if 'rf' in cfg else {}
        self.ctrl     = cfg['control_path'] if 'control_path' in cfg else {}
        self.datapath = cfg['datapath'] if 'datapath' in cfg else {}
        self.mem      = cfg['memory'] if 'memory' in cfg else {}

        self.dwidth = self.datapath['data_width']\
            if 'data_width' in self.datapath else DEFAULT_DWIDTH

    def rf_id_width(self): return len(bin(self.rf['size']-1))-2
    def rf_num_entries(self):
        s = self.rf['size']
        if 'explicit_bypass' in self.datapath\
                and self.datapath['explicit_bypass']:
            s -= self.datapath['pipe_stage']
        return s

class PEArray(object):
    def __init__(self, cfg):
        if cfg:
            self.rf       = cfg['rf'] if 'rf' in cfg else {}
            self.ctrl     = cfg['control_path'] if 'control_path' in cfg else {}
            self.datapath = cfg['datapath'] if 'datapath' in cfg else {}
            self.mem      = cfg['memory'] if 'memory' in cfg else {}

            self.size = self.datapath['num_pe'] if 'num_pe' in self.datapath\
                else DEFAULT_NUM_PE
            self.dwidth = self.datapath['data_width']\
                if 'data_width' in self.datapath else DEFAULT_DWIDTH
        else:
            self.size   = 0
            self.dwidth = 0
            self.rf  = {'size':0, 'read_port':0, 'write_port':0}
            self.mem = {'imem_size':0, 'dmem_size':0}

    def pe_id_width(self): return max(len(bin(self.size-1))-2,       0)
    def rf_id_width(self): return max(len(bin(self.rf['size']-1))-2, 0)
    def rf_num_entries(self):
        if self.size <= 0: return 0
        s = self.rf['size']
        if 'explicit_bypass' in self.datapath\
                and self.datapath['explicit_bypass']:
            s -= self.datapath['pipe_stage']
        return s

class Baseline(object):
    def __init__(self, cfg):
        self.name = cfg['arch']
        self.prop = cfg['misc'] if 'misc' in cfg else {}
        self.cp   = ControlProcessor(cfg['cp'])
        self.pe   = PEArray(cfg['pe']) if 'pe' in cfg else PEArray(None)

    def __str__(self):
        s = 'Solver: %s\n'%self.name
        s += '- CP: %db\n'%self.cp.dwidth
        if self.pe: s += '- PE: %d x %db'%(self.pe.size, self.pe.dwidth)
        return s

    def get_tgt_sig(self):
        sig = tgt_attr = self.name
        if self.pe.size > 0: tgt_attr += '-%dpe'%self.pe.size
        sig += '-' + self.get_tgt_attr()
        return sig

    def get_tgt_attr(self):
        tgt_attr = '%db-%dstage'%(self.cp.datapath['data_width'],
                                  self.cp.datapath['pipe_stage'])
        if self.cp.datapath['explicit_bypass']: tgt_attr += '-bypass'
        return tgt_attr
