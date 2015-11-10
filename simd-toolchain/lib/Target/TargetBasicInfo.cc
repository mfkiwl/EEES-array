#include "Target/TargetBasicInfo.hh"
#include "Target/TargetBinaryProgram.hh"
#include <json/json.h>

using namespace std;
using namespace ES_SIMD;

auto_ptr<TargetBasicInfoFactory::TargetCreatorMap> TargetBasicInfoFactory::map_;

TargetBasicInfo* TargetBasicInfoFactory::
GetTargetBasicInfo(const Json::Value& cfg){
  if (!cfg.isMember("arch")) { return NULL; }
  const string& name = cfg["arch"].asString();
  TargetCreatorMap* m = GetMap();
  TargetCreatorMap::iterator it = m->find(name);
  return (it == m->end()) ?  NULL : it->second.first(cfg);
}

TargetBasicInfo::~TargetBasicInfo() {}

unsigned TargetBasicInfo::
GetOperationLatency(const SIRInstruction* instr) const {
  return 1U;
}

TargetBinaryProgram* TargetBasicInfo::
CreateBinaryProgram(int id, const std::string& name) const {
  return new TargetBinaryProgram(id, name);
}// CreateBinaryProgram()

std::ostream& TargetBasicInfo::
PrintOperand(std::ostream& out, const TargetOperand& o,
             TargetInstrType_t t) const {
  return out;
}// PrintOperand

bool TargetBasicInfo::
StripOpcodeStr(std::string& ops) const {
  if (ops.find("v.") == 0)
    ops = ops.substr(2);
  if(!ops.empty() && ((*ops.rbegin() == 'i') || (*ops.rbegin() == 'I')))
     ops = ops.substr(0, ops.length()-1);;
  return true;
}// StripOpcodeStr()

void TargetBasicInfo::InitCodeGenInfo()          {}
void TargetBasicInfo::InitDefaultOperationInfo() {}
void TargetBasicInfo::InitSimulationInfo()       {}
bool TargetBasicInfo::ValidateTarget()     const { return true; }
void TargetBasicInfo::InitTimingInfo()           {}

bool TargetBasicInfo::
SetTargetParam(const std::string& key, const std::string& val) {
  return true;
}// SetTargetParam()

void TargetBasicInfo::
InitDefaultOpTranslation() {
  opTranslation_.clear();
  opTranslation_[SIROpcode::ADD  ]  = TargetOpcode::ADD  ;
  opTranslation_[SIROpcode::SUB  ]  = TargetOpcode::SUB  ;
  opTranslation_[SIROpcode::AND  ]  = TargetOpcode::AND  ;
  opTranslation_[SIROpcode::OR   ]  = TargetOpcode::OR   ;
  opTranslation_[SIROpcode::XOR  ]  = TargetOpcode::XOR  ;
  opTranslation_[SIROpcode::SRL  ]  = TargetOpcode::SRL  ;
  opTranslation_[SIROpcode::SRA  ]  = TargetOpcode::SRA  ;
  opTranslation_[SIROpcode::SLL  ]  = TargetOpcode::SLL  ;
  opTranslation_[SIROpcode::MUL  ]  = TargetOpcode::MUL  ;
  opTranslation_[SIROpcode::MULU ]  = TargetOpcode::MULU ;
  opTranslation_[SIROpcode::LW   ]  = TargetOpcode::LW   ;
  opTranslation_[SIROpcode::LH   ]  = TargetOpcode::LH   ;
  opTranslation_[SIROpcode::LB   ]  = TargetOpcode::LB   ;
  opTranslation_[SIROpcode::SW   ]  = TargetOpcode::SW   ;
  opTranslation_[SIROpcode::SH   ]  = TargetOpcode::SH   ;
  opTranslation_[SIROpcode::SB   ]  = TargetOpcode::SB   ;
  opTranslation_[SIROpcode::CALL ]  = TargetOpcode::JAL  ;
  opTranslation_[SIROpcode::RET  ]  = TargetOpcode::JR   ;
  opTranslation_[SIROpcode::J    ]  = TargetOpcode::J    ;
  opTranslation_[SIROpcode::MOV  ]  = TargetOpcode::MOV  ;
  opTranslation_[SIROpcode::SFEQ ]  = TargetOpcode::SFEQ ;
  opTranslation_[SIROpcode::SFNE ]  = TargetOpcode::SFNE ;
  opTranslation_[SIROpcode::SFGES]  = TargetOpcode::SFGES;
  opTranslation_[SIROpcode::SFGEU]  = TargetOpcode::SFGEU;
  opTranslation_[SIROpcode::SFGTS]  = TargetOpcode::SFGTS;
  opTranslation_[SIROpcode::SFGTU]  = TargetOpcode::SFGTU;
  opTranslation_[SIROpcode::SFLES]  = TargetOpcode::SFLES;
  opTranslation_[SIROpcode::SFLEU]  = TargetOpcode::SFLEU;
  opTranslation_[SIROpcode::SFLTS]  = TargetOpcode::SFLTS;
  opTranslation_[SIROpcode::SFLTU]  = TargetOpcode::SFLTU;
  opTranslation_[SIROpcode::NOP  ]  = TargetOpcode::NOP  ;
  opTranslation_[SIROpcode::READ_L] = TargetOpcode::MOV_L;
  opTranslation_[SIROpcode::READ_R] = TargetOpcode::MOV_R;
  opTranslation_[SIROpcode::READ_H] = TargetOpcode::MOV_H;
  opTranslation_[SIROpcode::READ_T] = TargetOpcode::MOV_T;
  opTranslation_[SIROpcode::PUSH_H] = TargetOpcode::PUSH_H;
  opTranslation_[SIROpcode::PUSH_T] = TargetOpcode::PUSH_T;
}// InitDefaultOperationInfo()
