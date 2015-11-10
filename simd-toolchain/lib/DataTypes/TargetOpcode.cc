#include "Utils/StringUtils.hh"
#include "DataTypes/TargetOpcode.hh"

using namespace std;
using namespace ES_SIMD;

TargetOpcode_t ES_SIMD::
GetTargetOpcode(const string& str) {
  string upOps(str);
  ToUpperCase(upOps);
  return GetValueTargetOpcode(upOps.c_str());
}// GetTargetOpcode()

////////////////////////////////////////////////////////////////////////////////
//                      Enum related definition
////////////////////////////////////////////////////////////////////////////////
DEFINE_ENUM(ES_SIMD,TargetOpcode,TARGETOPCODE_ENUM)
DEFINE_ENUM(ES_SIMD,TargetOpType,TARGETOPTYPE_ENUM)

tr1::unordered_map<TargetOpcode_t, TargetOpcProperty>
TargetOpcProperty::targetOpProp;

tr1::unordered_set<TargetOpcode_t> TargetOpcProperty::zExtOps;

bool TargetOpcProperty::init = TargetOpcProperty::Init();

bool TargetOpcProperty::
Init() {
  targetOpProp[TargetOpcode::ADD]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, true, true);
  targetOpProp[TargetOpcode::SUB]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, false, false);
  targetOpProp[TargetOpcode::RSUB]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, false, false);
  targetOpProp[TargetOpcode::AND]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, true, true);
  targetOpProp[TargetOpcode::OR]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, true, true);
  targetOpProp[TargetOpcode::XOR]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, true, true);
  targetOpProp[TargetOpcode::SRL]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, false, false);
  targetOpProp[TargetOpcode::SRA]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, false, false);
  targetOpProp[TargetOpcode::SLL]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, false, false);
  targetOpProp[TargetOpcode::ROR]
    = TargetOpcProperty(TargetOpType::IntArith,2,1, false, false);
  targetOpProp[TargetOpcode::MUL]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1,true,true);
  targetOpProp[TargetOpcode::MULU]
    =TargetOpcProperty(TargetOpType::IntArith, 2, 1, true, true);
  targetOpProp[TargetOpcode::DIV]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1,true,true);
  targetOpProp[TargetOpcode::CMOV]
    = TargetOpcProperty(TargetOpType::IntArith, 2, 1, false, false, true, true);

  targetOpProp[TargetOpcode::LW]
    = TargetOpcProperty(TargetOpType::Load, 2, 1, false, false);
  targetOpProp[TargetOpcode::LH]
    = TargetOpcProperty(TargetOpType::Load, 2, 1, false, false);
  targetOpProp[TargetOpcode::LB]
    = TargetOpcProperty(TargetOpType::Load, 2, 1, false, false);
  targetOpProp[TargetOpcode::LHS]
    = TargetOpcProperty(TargetOpType::Load, 2, 1, false, false);
  targetOpProp[TargetOpcode::LBS]
    = TargetOpcProperty(TargetOpType::Load, 2, 1, false, false);
  targetOpProp[TargetOpcode::SW]
    = TargetOpcProperty(TargetOpType::Store, 3, 0, false, false);
  targetOpProp[TargetOpcode::SH]
    = TargetOpcProperty(TargetOpType::Store, 3, 0, false, false);
  targetOpProp[TargetOpcode::SB]
    = TargetOpcProperty(TargetOpType::Store, 3, 0, false, false);
  targetOpProp[TargetOpcode::BF]
    = TargetOpcProperty(TargetOpType::Branch, 1, 0, false, false, false, true);
  targetOpProp[TargetOpcode::BNF]
    = TargetOpcProperty(TargetOpType::Branch, 1, 0, false, false, false, true);
  targetOpProp[TargetOpcode::BEQ]
    = TargetOpcProperty(TargetOpType::Branch, 3, 0, false, false, false);
  targetOpProp[TargetOpcode::BNE]
    = TargetOpcProperty(TargetOpType::Branch, 3, 0, false, false, false);
  targetOpProp[TargetOpcode::BGE]
    = TargetOpcProperty(TargetOpType::Branch, 3, 0, false, false, false);
  targetOpProp[TargetOpcode::BGT]
    = TargetOpcProperty(TargetOpType::Branch, 3, 0, false, false, false);
  targetOpProp[TargetOpcode::BLE]
    = TargetOpcProperty(TargetOpType::Branch, 3, 0, false, false, false);
  targetOpProp[TargetOpcode::BLT]
    = TargetOpcProperty(TargetOpType::Branch, 3, 0, false, false, false);
  targetOpProp[TargetOpcode::JAL]
    = TargetOpcProperty(TargetOpType::Branch, 1, 0, false, false, false);
  targetOpProp[TargetOpcode::JR]
    = TargetOpcProperty(TargetOpType::Branch, 1, 0, false, false, false);
  targetOpProp[TargetOpcode::J]
    = TargetOpcProperty(TargetOpType::Branch, 1, 0, false, false, false);
  targetOpProp[TargetOpcode::SIMM]
    = TargetOpcProperty(TargetOpType::Immediate, 1, 0, false, false);
  targetOpProp[TargetOpcode::ZIMM]
    = TargetOpcProperty(TargetOpType::Immediate, 1, 0, false, false);
  targetOpProp[TargetOpcode::SFEQ ]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFNE ]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFGES]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFGEU]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFGTS]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFGTU]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFLES]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFLEU]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFLTS]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);
  targetOpProp[TargetOpcode::SFLTU]
    = TargetOpcProperty(TargetOpType::IntCompare, 2, 0, false, false);

  targetOpProp[TargetOpcode::MOVH]
    = TargetOpcProperty(TargetOpType::Misc, 1, 1, false, false);
  targetOpProp[TargetOpcode::MOV]
    = TargetOpcProperty(TargetOpType::Misc, 1, 1, false, false);
  targetOpProp[TargetOpcode::NOP  ]
    = TargetOpcProperty(TargetOpType::Misc, 0, 0, false, false);
  targetOpProp[TargetOpcode::MOV_L]
    = TargetOpcProperty(TargetOpType::Misc, 2, 1, false, false);
  targetOpProp[TargetOpcode::MOV_R]
    = TargetOpcProperty(TargetOpType::Misc, 2, 1, false, false);
  targetOpProp[TargetOpcode::MOV_H]
    = TargetOpcProperty(TargetOpType::Misc, 2, 1, false, false);
  targetOpProp[TargetOpcode::MOV_T]
    = TargetOpcProperty(TargetOpType::Misc, 2, 1, false, false);

  zExtOps.insert(TargetOpcode::ZIMM);
  zExtOps.insert(TargetOpcode::AND);
  zExtOps.insert(TargetOpcode::OR);
  zExtOps.insert(TargetOpcode::XOR);
  zExtOps.insert(TargetOpcode::MULU);
  zExtOps.insert(TargetOpcode::SFGEU);
  zExtOps.insert(TargetOpcode::SFGTU);
  zExtOps.insert(TargetOpcode::SFLEU);
  zExtOps.insert(TargetOpcode::SFLTU);
  return true;
}// TargetOpcProperty::Init()
