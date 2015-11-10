#include "DataTypes/SIROpcode.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

tr1::unordered_map<int,SIROpcodeProperty> SIROpcodeProperty::SIROpcodePropTable;
bool SIROpcodeProperty::Init = SIROpcodeProperty::Initialize();

SIROpcode_t ES_SIMD::
GetSIROpcode(const string& str) {
  string upOps(str);
  ToUpperCase(upOps);
  return GetValueSIROpcode(upOps.c_str());
}// GetTargetOpcode()


bool SIROpcodeProperty::
Initialize() {
#define SIROPPROP(opc, type, in, out, comm, assoc, pre)   \
  SIROpcodePropTable[static_cast<int>(opc)] =             \
    SIROpcodeProperty(type, in, out, comm, assoc, pre)
  //                                             IN OUT  Comm   Assoc
  SIROPPROP(SIROpcode::ADD   , SIROpType::Arith  , 2, 1, true , true , 4);
  SIROPPROP(SIROpcode::SUB   , SIROpType::Arith  , 2, 1, false, false, 4);
  SIROPPROP(SIROpcode::AND   , SIROpType::Logic  , 2, 1, true , true , 1);
  SIROPPROP(SIROpcode::OR    , SIROpType::Logic  , 2, 1, true , true , 1);
  SIROPPROP(SIROpcode::XOR   , SIROpType::Logic  , 2, 1, true , true , 1);
  SIROPPROP(SIROpcode::SRL   , SIROpType::Shift  , 2, 1, false, false, 3);
  SIROPPROP(SIROpcode::SRA   , SIROpType::Shift  , 2, 1, false, false, 3);
  SIROPPROP(SIROpcode::SLL   , SIROpType::Shift  , 2, 1, false, false, 3);
  SIROPPROP(SIROpcode::ROR   , SIROpType::Shift  , 2, 1, false, false, 3);
  SIROPPROP(SIROpcode::MUL   , SIROpType::Arith  , 2, 1, true , true , 3);
  SIROPPROP(SIROpcode::MULU  , SIROpType::Arith  , 2, 1, true , true , 3);
  SIROPPROP(SIROpcode::DIV   , SIROpType::Arith  , 2, 1, false, false, 3);
  SIROPPROP(SIROpcode::MOD   , SIROpType::Arith  , 2, 1, false, false, 3);
  SIROPPROP(SIROpcode::SEL_EQ, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_NE, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_GT, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_GE, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_LT, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_LE, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::MAX   , SIROpType::Select , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::MIN   , SIROpType::Select , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_GTU, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_GEU, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_LTU, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::SEL_LEU, SIROpType::Select , 4, 1, false, false, 1);
  SIROPPROP(SIROpcode::MAXU   , SIROpType::Select , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::MINU   , SIROpType::Select , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SFEQ  , SIROpType::Compare, 2, 1, true , false, 1);
  SIROPPROP(SIROpcode::SFNE  , SIROpType::Compare, 2, 1, true , false, 1);
  SIROPPROP(SIROpcode::SFGTS , SIROpType::Compare, 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SFGES , SIROpType::Compare, 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SFLTS , SIROpType::Compare, 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SFLES , SIROpType::Compare, 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SFGTU , SIROpType::Compare, 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SFGEU , SIROpType::Compare, 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SFLTU , SIROpType::Compare, 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SFLEU , SIROpType::Compare, 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::LW    , SIROpType::Load   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::LH    , SIROpType::Load   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::LB    , SIROpType::Load   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::LHS   , SIROpType::Load   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::LBS   , SIROpType::Load   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::SW    , SIROpType::Store  , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::SH    , SIROpType::Store  , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::SB    , SIROpType::Store  , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BREQ  , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRNE  , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRGE  , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRGT  , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRLE  , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRLT  , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRGEU , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRGTU , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRLEU , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::BRLTU , SIROpType::Branch , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::CALL  , SIROpType::Branch , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::J     , SIROpType::Branch , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::RET   , SIROpType::Branch , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::MOV   , SIROpType::Misc   , 1, 1, false, false, 1);
  SIROPPROP(SIROpcode::READ_L, SIROpType::Misc   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::READ_R, SIROpType::Misc   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::READ_H, SIROpType::Misc   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::READ_T, SIROpType::Misc   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::PUSH_H, SIROpType::Misc   , 2, 1, false, false, 1);
  SIROPPROP(SIROpcode::PUSH_T, SIROpType::Misc   , 2, 1, false, false, 1);

  SIROPPROP(SIROpcode::BB    , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::PRED  , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::SUCC  , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::DOM   , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::PDOM  , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::LOOP  , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::LHDR  , SIROpType::Meta   , 2, 0, false, false, 1);
  SIROPPROP(SIROpcode::LEXT  , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::RLI   , SIROpType::Meta   , 0, 1, false, false, 1);
  SIROPPROP(SIROpcode::RLO   , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::MNUM  , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::MLOC  , SIROpType::Meta   , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::MALIAS, SIROpType::Meta   , 2, 0, false, false, 1);

  SIROPPROP(SIROpcode::NUMGR , SIROpType::Meta   , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::GRSIZE, SIROpType::Meta   , 3, 0, false, false, 1);
  SIROPPROP(SIROpcode::ARGSPC,   SIROpType::Meta  , 2, 0, false, false, 1);
  SIROPPROP(SIROpcode::ARGS,     SIROpType::Meta  , 1, 0, false, false, 1);
  SIROPPROP(SIROpcode::RVALS,    SIROpType::Meta  , 1, 0, false, false, 1);

  SIROPPROP(SIROpcode::NOP   , SIROpType::Misc   , 0, 0, false, false, 1000);

#undef SIROPPROP
#define SIROPPROP(o)  SIROpcodePropTable[static_cast<int>(o)]
  // Arith operation property
  SIROPPROP(SIROpcode::MUL).leftDistributive_   = true;
  SIROPPROP(SIROpcode::MUL).rightDistributive_  = true;
  SIROPPROP(SIROpcode::MULU).leftDistributive_  = true;
  SIROPPROP(SIROpcode::MULU).rightDistributive_ = true;
  SIROPPROP(SIROpcode::DIV).rightDistributive_  = true;
  SIROPPROP(SIROpcode::SLL).rightDistributive_  = true;
  SIROPPROP(SIROpcode::SRA).rightDistributive_  = true;
  SIROPPROP(SIROpcode::SRL).rightDistributive_  = true;
#undef SIROPPROP
  return true;
}// Initialize()

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD, SIROpcode, SIROPCODE_ENUM)
DEFINE_ENUM(ES_SIMD, SIROpType, SIROPTYPE_ENUM)
