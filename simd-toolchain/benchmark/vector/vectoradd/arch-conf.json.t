{

    "arch": "baseline",
    "cp": {
        "control_path": {
            "ins_width":  26,
            "branch_predict": false,
            "inter_lock": false,
            "delay_slot": 1,
            "issue_slot": 1,
            "predicate":  2
        } , "datapath": {
            "data_width" : 32, "pipe_stage": 4, "explicit_bypass": EXP_BYPASS,
            "fu" :
            [{"name": "ALU", "id": 0, "pipelined": false, "num_stage": 1,
              "operation": {"arith": 1, "cmp": 1},
              "bypass_map": [{"name" : "ALU", "out_stage": 1, "id": 2, "reg": 30}]},
             {"name": "MUL", "id": 1, "pipelined":  true,  "num_stage":  1,
              "operation":  {"mul": 1, "shift": 1, "logic": 1},
              "bypass_map": [{"name": "MUL", "out_stage": 1, "id": 1, "reg": 29}]},

             {"name": "LSU", "id": 2, "pipelined": true, "num_stage": 1,
              "operation":  {"load": 1, "store": 1},
              "bypass_map": [{"name": "LSU", "out_stage": 1, "id": 0, "reg": 28}]}],
            "writeback": {
                "bypass_map": [{"name": "WB", "out_tage": 1, "id": 3, "reg" : 31}]
            }, "operation" : {
                "ADD"     : {"type": "arith" , "opcode": "0x2" },
                "SUB"     : {"type": "arith" , "opcode": "0x3" },
                "MUL"     : {"type": "mul"   , "opcode": "0x4" },
                "MULU"    : {"type": "mul"   , "opcode": "0x5" },
                "OR"      : {"type": "logic" , "opcode": "0x6" },
                "AND"     : {"type": "logic" , "opcode": "0x7" },
                "XOR"     : {"type": "logic" , "opcode": "0x8" },
                "CMOV"    : {"type": "arith" , "opcode": "0x9" },
                "SFEQ"    : {"type": "cmp"   , "opcode": "0xa" },
                "SFNE"    : {"type": "cmp"   , "opcode": "0xb" },
                "SFLES"   : {"type": "cmp"   , "opcode": "0xc" },
                "SFLTS"   : {"type": "cmp"   , "opcode": "0xd" },
                "SFGES"   : {"type": "cmp"   , "opcode": "0xe" },
                "SFGTS"   : {"type": "cmp"   , "opcode": "0xf" },
                "SFLEU"   : {"type": "cmp"   , "opcode": "0x10"},
                "SFLTU"   : {"type": "cmp"   , "opcode": "0x11"},
                "SFGEU"   : {"type": "cmp"   , "opcode": "0x12"},
                "SFGTU"   : {"type": "cmp"   , "opcode": "0x13"},
                "SLL"     : {"type": "shift" , "opcode": "0x14"},
                "SRA"     : {"type": "shift" , "opcode": "0x15"},
                "SRL"     : {"type": "shift" , "opcode": "0x16"},
                "ROR"     : {"type": "shift" , "opcode": "0x17"},
                "SIMM"    : {"type": "imm"   , "opcode": "0x0" },
                "ZIMM"    : {"type": "imm"   , "opcode": "0x1" },
                "LB"      : {"type": "load"  , "opcode": "0x1a"},
                "SB"      : {"type": "store" , "opcode": "0x1b"},
                "LH"      : {"type": "load"  , "opcode": "0x1c"},
                "SH"      : {"type": "store" , "opcode": "0x1d"},
                "LW"      : {"type": "load"  , "opcode": "0x1e"},
                "SW"      : {"type": "store" , "opcode": "0x1f"},
                "BF"      : {"type": "branch", "opcode": "0x0", "jopc": "0x2"},
                "BNF"     : {"type": "branch", "opcode": "0x0", "jopc": "0x3"},
                "J"       : {"type": "branch", "opcode": "0x1", "jopc": "0x0"},
                "JAL"     : {"type": "branch", "opcode": "0x1", "jopc": "0x1"},
                "JR"      : {"type": "branch", "opcode": "0x1", "jopc": "0x2"},
                "JALR"    : {"type": "branch", "opcode": "0x1", "jopc": "0x3"},
                "NOP"     : {"type": "nop"   , "opcode": "0x0", "jopc": "0x0"},
                "SysCall" : {"type": "sys"   , "opcode": "0x0", "jopc": "0x1"}
            }
        }, "memory": {
            "imem_size": 2048,
            "dmem_size": 2048
        }, "rf": {"size": 32, "read_port": 2, "write_port": 1}
    },
    "pe": {
        "control_path": {"issue_slot": 1, "ins_width": 26, "predicate": 2},
        "datapath": {
            "num_pe": NPE, "data_width": 32,
            "pipe_stage": 4, "broadcast_stage": 0, "explicit_bypass": EXP_BYPASS,
            "fu":
            [{"name": "ALU", "id": 0, "pipelined": false, "num_stage": 1,
              "operation": {"arith": 1, "cmp": 1},
              "bypass_map": [{"name": "ALU", "out_stage": 1, "id": 2, "reg": 30}]},
             {"name": "MUL", "id": 1, "pipelined": true, "num_stage": 1,
              "operation": {"mul": 1, "shift": 1, "logic": 1},
              "bypass_map": [{"name": "MUL", "out_stage": 1, "id": 1, "reg": 29}]},
             {"name": "LSU", "id": 2, "pipelined": true, "num_stage": 1,
              "operation": {"load": 1, "store": 1},
              "bypass_map": [{"name": "LSU", "out_stage": 1, "id": 0, "reg": 28}]}],

            "writeback": {"bypass_map": [{"name": "WB", "out_stage": 1, "id": 3, "reg": 31}]},
            "data_shuffle": {
                "type": "neighborhood", "boundary": "zero", "capacity": "first"
            },"operation": {
                "NOP"     : {"type": "nop"   , "opcode": "0x0" },
                "ADD"     : {"type": "arith" , "opcode": "0x2" },
                "SUB"     : {"type": "arith" , "opcode": "0x3" },
                "MUL"     : {"type": "mul"   , "opcode": "0x4" },
                "MULU"    : {"type": "mul"   , "opcode": "0x5" },
                "OR"      : {"type": "logic" , "opcode": "0x6" },
                "AND"     : {"type": "logic" , "opcode": "0x7" },
                "XOR"     : {"type": "logic" , "opcode": "0x8" },
                "CMOV"    : {"type": "arith" , "opcode": "0x9" },
                "SFEQ"    : {"type": "cmp"   , "opcode": "0xa" },
                "SFNE"    : {"type": "cmp"   , "opcode": "0xb" },
                "SFLES"   : {"type": "cmp"   , "opcode": "0xc" },
                "SFLTS"   : {"type": "cmp"   , "opcode": "0xd" },
                "SFGES"   : {"type": "cmp"   , "opcode": "0xe" },
                "SFGTS"   : {"type": "cmp"   , "opcode": "0xf" },
                "SFLEU"   : {"type": "cmp"   , "opcode": "0x10"},
                "SFLTU"   : {"type": "cmp"   , "opcode": "0x11"},
                "SFGEU"   : {"type": "cmp"   , "opcode": "0x12"},
                "SFGTU"   : {"type": "cmp"   , "opcode": "0x13"},
                "SLL"     : {"type": "shift" , "opcode": "0x14"},
                "SRA"     : {"type": "shift" , "opcode": "0x15"},
                "SRL"     : {"type": "shift" , "opcode": "0x16"},
                "ROR"     : {"type": "shift" , "opcode": "0x17"},
                "SIMM"    : {"type": "imm"   , "opcode": "0x0 "},
                "ZIMM"    : {"type": "imm"   , "opcode": "0x1 "},
                "LB"      : {"type": "load"  , "opcode": "0x1a"},
                "SB"      : {"type": "store" , "opcode": "0x1b"},
                "LH"      : {"type": "load"  , "opcode": "0x1c"},
                "SH"      : {"type": "store" , "opcode": "0x1d"},
                "LW"      : {"type": "load"  , "opcode": "0x1e"},
                "SW"      : {"type": "store" , "opcode": "0x1f"}
            }
        }, "memory": {
            "imem_size": 2048, "dmem_size": 2048
        }, "rf": {
            "size": 32, "read_port": 2, "write_port": 1
        }
    },
    "misc": {
        "lock_step": true,
        "adder_tree": false
    }
}
