#include "BaselineBasicInfo.hh"
#include "BaselineBinaryProgram.hh"
#include "BaselineInstruction.hh"

#include "Utils/DbgUtils.hh"
#include "Utils/StringUtils.hh"
#include "Utils/BitUtils.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRFunction.hh"

#include <algorithm>

using namespace std;
using namespace ES_SIMD;

RegisterTargetBasicInfo<BaselineBasicInfo> BaselineBasicInfo::reg_("baseline");

void BaselineBasicInfo::
InitParam() {
  /// Most parameters should have two copies, one for CP and one for PE
  //// Register parameters
  registerFiles_.resize(2);
  predicates_.resize(2);
  predicates_[0].SetRegPrefix("P");
  predicates_[1].SetRegPrefix("P");
  //// Datapath parameters
  dataWidth_.resize(2);
  stages_.resize(2);
  explicitBypass_.resize(2);
  interlock_.resize(2);
  //// Memory parameters
  instMemDepth_.resize(2);
  dataMemDepth_.resize(2); ///< Size of data memories
  //// Control related parameters
  operations_.resize(2); ///< Operation info
  fuOutputMap_.resize(2);
  instrWidth_.resize(2);
  numFUs_.resize(2, 3);
}// InitParam()

BaselineBasicInfo::
BaselineBasicInfo()
  : TargetBasicInfo("baseline", 2) {
  InitParam();
  SetDefaultParam();
}

BaselineBasicInfo::
BaselineBasicInfo(const Json::Value& cfg)
  : TargetBasicInfo(cfg["arch"].asString(), 2) {
  InitParam();
  SetParam(cfg);
}

BaselineBasicInfo::
~BaselineBasicInfo() {}

unsigned BaselineBasicInfo::
GetOperationLatency(const SIRInstruction* instr) const {
  return instr->IsVectorInstr() ? GetPEOperationLatency(instr->GetTargetOpcode())
    : GetCPOperationLatency(instr->GetTargetOpcode());
}// GetOperationLatency()

int BaselineBasicInfo::
GetOperationBinding(const SIRInstruction* instr) const {
  return instr->IsVectorInstr() ? GetPEOperationBinding(instr->GetTargetOpcode())
    : GetCPOperationBinding(instr->GetTargetOpcode());
}

int BaselineBasicInfo::
GetTargetConstant (const SIRValue* v) const {
  if (SIRConstant::classof(v)) {
    return static_cast<const SIRConstant*>(v)->GetImmediate();
  } else if (SIRRegister::classof(v)) {
    const SIRRegister* r = static_cast<const SIRRegister*>(v);
    if (const SIRFunction* f=dynamic_cast<const SIRFunction*>(r->GetParent())) {
      if (r == f->GetNumPERegister()) { return GetNumPE(); }
    }
  }
  return 0;
}// GetTargetConstant()

unsigned BaselineBasicInfo::
GetOperationWritebackDelay(const SIRInstruction* instr) const {
  if (instr->HasTargetOpcode()
      && GetTargetOpNumOutput(instr->GetTargetOpcode())) {
    int pipe = instr->IsVectorInstr();
    if (explicitBypass_[pipe]) {return stages_[pipe] - 2; }
    // The result will be automatically bypassed
    return GetOperationLatency(instr);
  }// if (instr->HasTargetOpcode())
  return 0;
}// GetOperationWritebackDelay()

void BaselineBasicInfo::
SetDefaultParam() {
  SetBranchDelaySlot(1);
  // CP parameters
  registerFiles_[0].SetSize(DEFAULT_CP_NUM_REG);
  predicates_[0].SetSize(3);
  dataWidth_[0]      = 32;
  dataMemDepth_[0]   = 8192;
  stages_[0]         = 4;
  explicitBypass_[0] = true;
  interlock_[0]      = false;

  // PE parameters
  numOfPE_    = DEFAULT_NUM_PE;
  registerFiles_[1].SetSize(DEFAULT_PE_NUM_REG);
  predicates_[1].SetSize(3);
  dataWidth_[1]      = 32;
  dataMemDepth_[1]   = 4096;
  stages_[1]         = 4;
  explicitBypass_[1] = true;
  interlock_[1]      = false;
}// SetDefaultParam()

void BaselineBasicInfo::
SetParam(const Json::Value& cfg) {
  if (!cfg.isMember("cp")) { configValid_ = false; return; }
  // CP
  const Json::Value& cp = cfg["cp"];
  if (!cp.isMember("control_path")) { configValid_ = false; return; }
  //// CP control path
  const Json::Value& ctrl = cp["control_path"];
  SetBranchDelaySlot(ctrl.get("delay_slot", Json::Value(1)).asInt());
  int pp = ctrl.get("predicate", Json::Value(0)).asInt();
  predicates_[0].SetSize((pp > 0) ? (pp+1) : 0);
  //// CP datapath
  if (!cp.isMember("datapath")) { configValid_ = false; return; }
  const Json::Value& cDatapath = cp["datapath"];
  dataWidth_[0] = cDatapath.get("data_width", Json::Value(32)).asInt();
  stages_[0]     = cDatapath.get("pipe_stage",      Json::Value(4)).asInt();
  explicitBypass_[0] = cDatapath.get("explicit_bypass", Json::Value(true)).asBool();
  interlock_[0] = cDatapath.get("interlock", Json::Value(false)).asBool();
  //// CP register
  if (cp.isMember ("rf")) {
    const Json::Value& rf = cp["rf"];
    registerFiles_[0].SetSize(
      rf.get("size", Json::Value(DEFAULT_CP_NUM_REG)).asInt());
    registerFiles_[0].SetWritePorts(rf.get("write_port", Json::Value(1)).asInt());
    registerFiles_[0].SetReadPorts(rf.get("read_port", Json::Value(2)).asInt());
  }

  if (cp.isMember("memory")) {
    const Json::Value& memory = cp["memory"];
    if (!memory.isMember("imem_size") || !memory.isMember("dmem_size")) {
      configValid_ = false;
      return;
    }
    dataMemDepth_[0] = memory["dmem_size"].asInt();
    instMemDepth_[0] = memory["imem_size"].asInt();
  } else { configValid_ = false; return; }

  if (!cfg.isMember("pe")) { numOfPE_ = 0; return; }
  // PE
  const Json::Value& pe = cfg["pe"];
  if (!pe.isMember("datapath"))     { configValid_ = false; return; }
  if (!pe.isMember("control_path")) { configValid_ = false; return; }
  const Json::Value& pCtrl = pe["control_path"];
  pp = pCtrl.get("predicate", Json::Value(0)).asInt();
  predicates_[1].SetSize((pp > 0) ? (pp+1) : 0);
  //// PE Datapath
  const Json::Value& pDatapath = pe["datapath"];
  numOfPE_ = pDatapath.get("num_pe", Json::Value(DEFAULT_NUM_PE)).asInt();
  dataWidth_[1] = pDatapath.get("data_width", Json::Value(32)).asInt();
  stages_[1]     = pDatapath.get("pipe_stage",      Json::Value(4)).asInt();
  explicitBypass_[1]    = pDatapath.get("explicit_bypass", Json::Value(true)).asBool();
  interlock_[1] = pDatapath.get("interlock", Json::Value(false)).asBool();
  //// PE register
  if (pe.isMember ("rf")) {
    const Json::Value& rf = pe["rf"];
    registerFiles_[1].SetSize(
      rf.get("size", Json::Value(DEFAULT_PE_NUM_REG)).asInt());
    registerFiles_[1].SetWritePorts(rf.get("write_port", Json::Value(1)).asInt());
    registerFiles_[1].SetReadPorts(rf.get("read_port", Json::Value(2)).asInt());
  }
  if (pe.isMember("memory")) {
    const Json::Value& memory = pe["memory"];
    if (!memory.isMember("dmem_size")) {
      configValid_ = false;
      return;
    }
    dataMemDepth_[1] = memory["dmem_size"].asInt();
  } else { configValid_ = false; return; }
}// SetParam

unsigned BaselineBasicInfo::
GetImmSize(const SIRInstruction* instr) const {
  unsigned ibits = 0;
  if (instr->IsVectorInstr()) {
    ibits = peInstrFormat_.iImm_.second - peInstrFormat_.iImm_.first + 1;
  } else {
    if (IsTargetBranch(instr->GetTargetOpcode())) {
      ibits = cpInstrFormat_.jImm_.second - cpInstrFormat_.jImm_.first + 1;
    } else {
      ibits = cpInstrFormat_.iImm_.second - cpInstrFormat_.iImm_.first + 1;
    }
  }
  return ibits;
}// GetImmSize()

bool BaselineBasicInfo::
ImmCanFit(TargetOpcode_t opc, bool isVector, int val) const {
  unsigned ibits = 0;
  bool zimm = ZeroExtensionTargetOp(opc);
  if (isVector) {
    ibits = peInstrFormat_.iImm_.second - peInstrFormat_.iImm_.first + 1;
  } else {
    if (IsTargetBranch(opc)) {
      ibits = cpInstrFormat_.jImm_.second - cpInstrFormat_.jImm_.first + 1;
    } else {
      ibits = cpInstrFormat_.iImm_.second - cpInstrFormat_.iImm_.first + 1;
    }
  }
  return zimm ? UnsignedImmCanFitNBits(val, ibits)
    : SignedImmCanFitNBits(val, ibits);
}// ImmCanFit()

TargetOperand BaselineBasicInfo::
ParseTargetOperand(const std::string& str, const TargetInstruction* instr)const{
  static ImmediateReader immRd;
  TargetOperand o;
  int r = -1;
  if (instr == NULL)
    return o;
  if (instr->GetType() == TargetInstrType::Scalar) {
    // CP operand
    if ((r = registerFiles_[0].GetRegAddr(str)) >= 0) {
      o.type_  = TargetOperandType::Register;
      o.value_ = r;
    } else if ((r = registerFiles_[0].GetSpecRegAddr(str)) >= 0 ) {
      o.type_  = TargetOperandType::Bypass;
      o.value_ = r;
    } else if ((r = predicates_[0].GetRegAddr(str)) >=0 ) {
      o.type_  = TargetOperandType::Predicate;
      o.value_ = r;
    } else if (str.find("h.") == 0) {
      if ((r = registerFiles_[0].GetAddr(str.substr(2))) >= 0) {
        o.type_  = TargetOperandType::Communication;
        o.value_ = COMM_HEAD_BASE +  r;
      }
    } else if (str.find("t.") == 0) {
      if ((r = registerFiles_[0].GetAddr(str.substr(2))) >= 0) {
        o.type_  = TargetOperandType::Communication;
        o.value_ = COMM_TAIL_BASE +  r;
      }
    }
  } else {
    // PE operand
    if ((r = registerFiles_[1].GetRegAddr(str)) >= 0) {
      o.type_  = TargetOperandType::Register;
      o.value_ = r;
    } else if ((r = registerFiles_[1].GetSpecRegAddr(str)) >= 0 ) {
      o.type_  = TargetOperandType::Bypass;
      o.value_ = r;
    } else if ((r = predicates_[1].GetRegAddr(str)) >=0 ) {
      o.type_  = TargetOperandType::Predicate;
      o.value_ = r;
    } else if (str.find("l.") == 0) {
      if ((r = registerFiles_[1].GetAddr(str.substr(2))) >= 0) {
        o.type_  = TargetOperandType::Communication;
        o.value_ = COMM_LEFT_BASE + r;
      }
    } else if (str.find("r.") == 0) {
      if ((r = registerFiles_[1].GetAddr(str.substr(2))) >= 0) {
        o.type_  = TargetOperandType::Communication;
        o.value_ = COMM_RIGHT_BASE + r;
      }
    } else if (str == "CP") {
      o.type_  = TargetOperandType::Communication;
      o.value_ = COMM_BROADCAST;
    }
  }// if (instr->GetType() == TargetInstrType::Vector)
  if (o.type_ == TargetOperandType::TargetOperandTypeEnd) {
    int immVal = immRd.GetIntImmediate(str);
    if (!immRd.error_) {
      o.type_ = TargetOperandType::IntImmediate;
      o.value_ = immVal;
    }// if (!immRd.error_)
  }// if (o.type_ == TargetOperandType::TargetOperandTypeEnd)
  return o;
}// ParseTargetOperand()

std::ostream& BaselineBasicInfo::
PrintOperand(std::ostream& out, const TargetOperand& o,
             TargetInstrType_t t) const {
  switch (o.type_) {
  case TargetOperandType::IntImmediate: out << o.value_;   break;
  case TargetOperandType::Predicate: out <<"P"<< o.value_; break;
  case TargetOperandType::Register:
    if (t == TargetInstrType::Vector) {
      if (registerFiles_[1].IsNormalReg(o.value_)) {
        out << registerFiles_[1].GetRegName(o.value_);
      } else { out <<"r"<< dec << o.value_; }
    } else {
      if (registerFiles_[0].IsNormalReg(o.value_)) {
        out << registerFiles_[0].GetRegName(o.value_);
      } else { out <<"r"<< dec << o.value_; }
    }
    break;
  case TargetOperandType::Bypass:
    if (t == TargetInstrType::Vector) {
      out << registerFiles_[1].GetSpecialRegName(o.value_);
    } else {
      out << registerFiles_[0].GetSpecialRegName(o.value_);
    }// if (t == TargetInstrType::Vector) else
    break;
  case TargetOperandType::Communication:
    if (t == TargetInstrType::Vector) {
      if ((o.value_ >= COMM_LEFT_BASE) && (o.value_ < COMM_RIGHT_BASE)) {
        out <<"l."<< registerFiles_[1].GetSpecialRegName(o.value_-COMM_LEFT_BASE);
      } else if ((o.value_ >= COMM_RIGHT_BASE)  && (o.value_ < COMM_BROADCAST)){
        out <<"l."<<registerFiles_[1].GetSpecialRegName(o.value_-COMM_RIGHT_BASE);
      } else if (o.value_ == COMM_BROADCAST) {
        out <<"CP";
      }
    } else {
      // Use registerFiles_[1] since the value is from PE
      if ((o.value_ >= COMM_HEAD_BASE) && (o.value_ < COMM_TAIL_BASE)) {
        out <<"h."<< registerFiles_[1].GetSpecialRegName(o.value_-COMM_HEAD_BASE);
      } else if (o.value_ >= COMM_TAIL_BASE) {
        out <<"t."<< registerFiles_[1].GetSpecialRegName(o.value_-COMM_TAIL_BASE);
      }
    }// if (t == TargetInstrType::Vector) else
  default: break;
  }// switch (o.type_)
  return out;
}// PrintOperand

int BaselineBasicInfo::
InstrImmediateCost(const SIRInstruction* instr) const {
  // TargetOpcode_t opc;
  bool zext = false;
  if (instr->HasTargetOpcode()){
    zext = ZeroExtensionTargetOp(instr->GetTargetOpcode());
  } else if (instr->HasSIROpcode()) {
    if (IsElementOf(instr->GetSIROpcode(), opTranslation_)) {
      zext = ZeroExtensionTargetOp(
        GetValue(instr->GetSIROpcode(), opTranslation_));
    }
    // opc = GetValue(instr->GetSIROpcode(), opTranslation_);
  } else { return 0; }
  for (int i=0, e=instr->operand_size(); i < e; ++i) {
    if (const SIRConstant* c
        = dynamic_cast<const SIRConstant*>(instr->GetOperand(i))) {
      if (c->IsSymbol()) { continue; }
      int imm = c->GetImmediate();
      if (instr->GetBranchTarget()) {
        int n = cpInstrFormat_.jImm_.second - cpInstrFormat_.jImm_.first + 1;
        return SignedImmCanFitNBits(imm, n) ? 0 : 1;
      }
      // bool zext = ZeroExtensionTargetOp(opc);
      int n, ni;
      if (instr->IsVectorInstr()) {
        n = peInstrFormat_.iImm_.second - peInstrFormat_.iImm_.first + 1;
        ni = n + peInstrFormat_.immInstrImm_.second
          - peInstrFormat_.immInstrImm_.first + 1;
      } else {
        n = cpInstrFormat_.iImm_.second - cpInstrFormat_.iImm_.first + 1;
        ni = n + cpInstrFormat_.immInstrImm_.second
          - cpInstrFormat_.immInstrImm_.first + 1;
      }
      if (zext) { if (UnsignedImmCanFitNBits(imm, n)) { return 0; } }
      else { if (SignedImmCanFitNBits(imm, n)) { return 0; } }
      // The sign of the immediate of imm instruction can be control directly,
      // so the signess of the opcode is ignored.
      if (UnsignedImmCanFitNBits(imm, ni) || SignedImmCanFitNBits(imm, ni)) {
        return 1;
      }
      // All fail, return a high cost
      return 5;
    }// if (c=dynamic_cast<const SIRConstant*>(instr->GetOperand(i)))
  }// for i = 0 to operand_size()-1
  return 0;
}// InstrImmediateCost()

bool BaselineBasicInfo::
EncodeInstruction(const TargetInstruction* instr, UInt32Vector& code) const {
  if (instr == NULL) {
    // Treat NULL instruction pointer as NOP
    fill(code.begin(), code.end(), 0);
    return true;
  }
  const BaselineInstruction* tInstr
    = dynamic_cast<const BaselineInstruction*>(instr);
  if (tInstr == NULL) { return false; }
  if (tInstr->GetType() == TargetInstrType::Vector) {
    return EncodePEInstruction(*tInstr, code);
  } else if (tInstr->GetType() == TargetInstrType::Scalar) {
    return EncodeCPInstruction(*tInstr, code);
  } else { return false; }
  ES_UNREACHABLE("Oops, this should no be happening:(");
  return false;
}// EncodeInstruction()

bool BaselineBasicInfo::
EncodeCPInstruction(const BaselineInstruction& instr, UInt32Vector& code) const {
  TargetOpcode_t opc = instr.GetOpcode();
  if (!operations_[0].IsValidOp(opc)) { return false; }
  uint32_t opBin = operations_[0].GetBinaryCode(opc);
  uint32_t commBits = 0, iBit = 0;

  for (unsigned i = 0; i < instr.pred_size(); ++i) {
    int p = instr.GetPredicate(i).GetValue();
    if (p > 0) {
      ES_ASSERT_MSG(p<=2,"Only P1 and P2 can be used as predicate: used P"<< p);
      int pos = cpInstrFormat_.pred_.first + p - 1;
      InsertBitsToIntVector(1, pos, pos, code);
    }// if (p > 0)
  }// for i = 0 to instr.pred_size()-1
  if (IsTargetBranch(opc)) {
    InsertBitsToIntVector(opBin, cpInstrFormat_.jOpcode_.first,
                          cpInstrFormat_.jOpcode_.second, code);
    for (unsigned i = 0; i < instr.GetNumSrcOperands(); ++i) {
      const TargetOperand& sop = instr.GetSrcOperand(i);
      if (sop.type_ == TargetOperandType::Register) {
        InsertBitsToIntVector(sop.value_, cpInstrFormat_.jReg_.first,
                              cpInstrFormat_.jReg_.second, code);
      } else if (sop.type_ == TargetOperandType::IntImmediate) {
        InsertBitsToIntVector(sop.value_, cpInstrFormat_.jImm_.first,
                              cpInstrFormat_.jImm_.second, code);
      } else { return false; }
    }// for i = 0 to instr.GetSrcOperand()-1
  } else if (IsTargetImmediateOp(opc)) {// if (IsTargetBranch(opc))
    InsertBitsToIntVector(opBin, cpInstrFormat_.opcode_.first,
                          cpInstrFormat_.opcode_.second, code);
    InsertBitsToIntVector(
      instr.GetSrcOperand(0).value_, cpInstrFormat_.immInstrImm_.first,
      cpInstrFormat_.immInstrImm_.second, code);
    iBit = 1;
  } else {// if (IsTargetImmediateOp(opc))
    InsertBitsToIntVector(opBin, cpInstrFormat_.opcode_.first,
                          cpInstrFormat_.opcode_.second, code);
    if (instr.GetNumDstOperands() > 0) {
      ES_ASSERT_MSG(instr.GetNumDstOperands()==1, "More than one output");
      const TargetOperand& top = instr.GetDstOperand(0);
      if ((top.type_ == TargetOperandType::Register)
          || (top.type_ == TargetOperandType::Predicate)){
        InsertBitsToIntVector(top.value_, cpInstrFormat_.dst_.first,
                              cpInstrFormat_.dst_.second, code);
      } else if (top.type_ == TargetOperandType::Bypass) {
        if (registerFiles_[0].GetSpecialRegName(top.value_) == "WB") {
          InsertBitsToIntVector(
            top.value_, cpInstrFormat_.dst_.first,
            cpInstrFormat_.dst_.second,code);
        }
      } else { return false; }
    }// if (instr.GetNumDstOperands() > 0)
    for (unsigned i = 0; i < instr.GetNumSrcOperands(); ++i) {
      const TargetOperand& sop = instr.GetSrcOperand(i);
      int rMSB=cpInstrFormat_.srcOperandStart_- i*cpInstrFormat_.regAddrBits_;
      if (sop.type_ == TargetOperandType::Register) {
        InsertBitsToIntVector(sop.value_, rMSB-cpInstrFormat_.regAddrBits_+1,
                              rMSB, code);
      } else if (sop.type_ == TargetOperandType::IntImmediate) {
        if (IsTargetStore(opc)) {
          unsigned lbits
            = cpInstrFormat_.stImmL_.second - cpInstrFormat_.stImmL_.first + 1;
          int immH = sop.value_ >> lbits;
          InsertBitsToIntVector(sop.value_, cpInstrFormat_.stImmL_.first,
                                cpInstrFormat_.stImmL_.second, code);
          InsertBitsToIntVector(immH, cpInstrFormat_.stImmH_.first,
                                cpInstrFormat_.stImmH_.second, code);
        } else {
          InsertBitsToIntVector(sop.value_, cpInstrFormat_.iImm_.first,
                                cpInstrFormat_.iImm_.second, code);
        }
        iBit = 1;
      } else if (sop.type_ == TargetOperandType::Bypass) {
        InsertBitsToIntVector(
          sop.value_, rMSB-cpInstrFormat_.regAddrBits_+1, rMSB, code);
      } else if (sop.type_ == TargetOperandType::Communication) {
        int bid = 0;
        if ((sop.value_ >= COMM_HEAD_BASE) && (sop.value_ < COMM_TAIL_BASE)) {
          commBits = 0x2;
          bid = sop.value_ - COMM_HEAD_BASE;
        } else if (sop.value_ >= COMM_TAIL_BASE) {
          commBits = 0x1;
          bid = sop.value_ - COMM_TAIL_BASE;
        }
        InsertBitsToIntVector(
          bid, rMSB-cpInstrFormat_.regAddrBits_+1, rMSB, code);
      } else {
        return false;
      }
    }// for i = 0 to instr.GetSrcOperand()-1
  }// if (TargetOpcProperty::GetOperationType(opc) == TargetOpType::Branch)
  if (commBits != 0) {
    InsertBitsToIntVector(commBits, cpInstrFormat_.comm_.first,
                          cpInstrFormat_.comm_.second, code);
  }
  if (iBit != 0) {
    InsertBitsToIntVector(iBit, cpInstrFormat_.iTypeBit_,
                          cpInstrFormat_.iTypeBit_, code);
  }
  return true;
}// EncodeCPInstruction()

bool BaselineBasicInfo::
EncodePEInstruction(const BaselineInstruction& instr, UInt32Vector& code) const {
  TargetOpcode_t opc = instr.GetOpcode();
  if (!operations_[1].IsValidOp(opc))
    return false;
  uint32_t opBin = operations_[1].GetBinaryCode(opc);
  uint32_t commBits = 0, iBit = 0;
  for (unsigned i = 0; i < instr.pred_size(); ++i) {
    int p = instr.GetPredicate(i).GetValue();
    if (p > 0) {
      ES_ASSERT_MSG(p<=2,"Only P1 and P2 can be used as predicate: used P"<< p);
      int pos = peInstrFormat_.pred_.first + p - 1;
      InsertBitsToIntVector(1, pos, pos, code);
    }// if (p > 0)
  }// for i = 0 to instr.pred_size()-1
  InsertBitsToIntVector(opBin, peInstrFormat_.opcode_.first,
                        peInstrFormat_.opcode_.second, code);
  if (IsTargetImmediateOp(opc)) {
    InsertBitsToIntVector(
      instr.GetSrcOperand(0).value_, peInstrFormat_.immInstrImm_.first,
      peInstrFormat_.immInstrImm_.second, code);
    InsertBitsToIntVector(1, peInstrFormat_.iTypeBit_,
                          peInstrFormat_.iTypeBit_, code);
    return true;
  }
  if (instr.GetNumDstOperands() > 0) {
    ES_ASSERT_MSG(instr.GetNumDstOperands()==1, "More than one output");
    const TargetOperand& top = instr.GetDstOperand(0);
    if ((top.type_ == TargetOperandType::Register)
        || (top.type_ == TargetOperandType::Predicate)) {
      InsertBitsToIntVector(top.value_, peInstrFormat_.dst_.first,
                            peInstrFormat_.dst_.second, code);
    } else if (top.type_ == TargetOperandType::Bypass) {
      if (registerFiles_[1].GetSpecialRegName(top.value_) == "WB") {
        InsertBitsToIntVector(
          top.value_,peInstrFormat_.dst_.first,peInstrFormat_.dst_.second,code);
      }
    } else { return false; }
  }// if (instr.GetNumDstOperands() > 0)
  for (unsigned i = 0; i < instr.GetNumSrcOperands(); ++i) {
    const TargetOperand& sop = instr.GetSrcOperand(i);
    int rMSB=peInstrFormat_.srcOperandStart_- i*peInstrFormat_.regAddrBits_;
    if (sop.type_ == TargetOperandType::Register) {
      InsertBitsToIntVector(sop.value_, rMSB-peInstrFormat_.regAddrBits_+1,
                            rMSB, code);
    } else if (sop.type_ == TargetOperandType::IntImmediate) {
      if (IsTargetStore(opc)) {
        unsigned lbits
          = peInstrFormat_.stImmL_.second - peInstrFormat_.stImmL_.first + 1;
        unsigned immH = sop.value_ >> lbits;
        InsertBitsToIntVector(sop.value_, peInstrFormat_.stImmL_.first,
                              peInstrFormat_.stImmL_.second, code);
        InsertBitsToIntVector(immH, peInstrFormat_.stImmH_.first,
                              peInstrFormat_.stImmH_.second, code);
      } else {
        InsertBitsToIntVector(sop.value_, peInstrFormat_.iImm_.first,
                              peInstrFormat_.iImm_.second, code);
      }// if (IsTargetStore(opc))
      iBit = 1;
    } else if (sop.type_ == TargetOperandType::Bypass) {
      InsertBitsToIntVector(
        sop.value_, rMSB-peInstrFormat_.regAddrBits_+1, rMSB, code);
    } else if (sop.type_ == TargetOperandType::Communication) {
      int bid = 0;
      if ((sop.value_ >= COMM_LEFT_BASE) && (sop.value_ < COMM_RIGHT_BASE)) {
        commBits = 0x2;
        bid = sop.value_ - COMM_LEFT_BASE;
      } else if ((sop.value_>= COMM_RIGHT_BASE)&&(sop.value_< COMM_BROADCAST)){
        commBits = 0x1;
        bid = sop.value_ - COMM_RIGHT_BASE;
      } else if (sop.value_ == COMM_BROADCAST) {
        commBits = 0x3;
      }
      InsertBitsToIntVector(
        bid, rMSB-peInstrFormat_.regAddrBits_+1, rMSB, code);
    } else { return false; }
  }// for i = 0 to instr.GetSrcOperand()-1
  if (commBits != 0) {
    InsertBitsToIntVector(commBits, peInstrFormat_.comm_.first,
                          peInstrFormat_.comm_.second, code);
  }
  if (iBit != 0) {
    InsertBitsToIntVector(iBit, peInstrFormat_.iTypeBit_,
                          peInstrFormat_.iTypeBit_, code);
  }
  return true;
}// EncodePEInstruction()

bool BaselineBasicInfo::
DecodeInstruction(TargetInstruction* instr, const UInt32Vector& code) const {
  BaselineInstruction* tInstr = dynamic_cast<BaselineInstruction*>(instr);
  if (tInstr == NULL)
    return false;
  bool nop = true;
  for (unsigned i = 0; i < code.size(); ++i) {
    if (code[i] != 0) { nop = false; break; }
  }
  if (nop) { instr->SetOpcode(TargetOpcode::NOP); return true; }
  if (tInstr->IsVectorInstr()) { return DecodePEInstruction(*tInstr, code); }
  else if (tInstr->IsScalarInstr()) {return DecodeCPInstruction(*tInstr, code);}

  ES_UNREACHABLE("Oops, this should no be happening:(");
  return false;
}// DecodeInstruction()

bool BaselineBasicInfo::
DecodeCPInstruction(BaselineInstruction& instr, const UInt32Vector& code) const{
  uint32_t iBit = ExtractBitsFromIntVector(
    cpInstrFormat_.iTypeBit_, cpInstrFormat_.iTypeBit_, code);
  uint32_t commBits = ExtractBitsFromIntVector(
    cpInstrFormat_.comm_.first, cpInstrFormat_.comm_.second, code);
  uint32_t opc = ExtractBitsFromIntVector(
    cpInstrFormat_.opcode_.first, cpInstrFormat_.opcode_.second,code);
  uint32_t jtype = ExtractBitsFromIntVector(
    cpInstrFormat_.jType_.first, cpInstrFormat_.jType_.second,code);
  uint32_t pred  = CPHasPredicates() ? ExtractBitsFromIntVector(
    cpInstrFormat_.pred_.first, cpInstrFormat_.pred_.second,code) : 0;
  if (pred) {
    for (unsigned p = 1; pred; ++p, pred >>= 1) {
      if (pred & 0x1) { instr.AppendPredicate(p); }
    }
  }// if (pred)
  if (jtype == 0) {// Branch
    uint32_t jopc = ExtractBitsFromIntVector(
      cpInstrFormat_.jOpcode_.first, cpInstrFormat_.jOpcode_.second, code);
    TargetOpcode_t jOp = GetCPBranchOpcode(jopc);
    if (jOp == TargetOpcode::TargetOpcodeEnd) { return false; }
    instr.SetOpcode(jOp);
    if (IsTargetBranchReg(jOp)) {
      int jReg = ExtractBitsFromIntVector(
        cpInstrFormat_.jReg_.first, cpInstrFormat_.jReg_.second, code);
      instr.AppendOperand(TargetOperandType::Register, jReg);
    } else {
      uint32_t jImmBits = ExtractBitsFromIntVector(
        cpInstrFormat_.jImm_.first, cpInstrFormat_.jImm_.second, code);
      int jImm = SignExtendNBitImm(
        jImmBits,
        (cpInstrFormat_.jImm_.second - cpInstrFormat_.jImm_.first + 1));
      instr.AppendOperand(TargetOperandType::IntImmediate, jImm);
    }// if (IsTargetBranchReg(jOp))
    return true;
  }// if (jtype == 0)
  // Normal instructions
  TargetOpcode_t op = GetCPOpcode(opc);
  if (op == TargetOpcode::TargetOpcodeEnd) { return false; }
  instr.SetOpcode(op);
  if (NumTargetOpResult(op) == 1) {
    uint32_t dst = ExtractBitsFromIntVector(
      cpInstrFormat_.dst_.first, cpInstrFormat_.dst_.second, code);
    TargetOperandType_t opType = registerFiles_[0].IsNormalReg(dst)
      ? TargetOperandType::Register : TargetOperandType::Bypass;
    if ((opType == TargetOperandType::Register) && explicitBypass_[0] && (dst == 0)) {
      opType = TargetOperandType::Bypass;
    }
    instr.AppendOperand(opType, dst);
  } else if (IsTargetCompare(op)) {
    uint32_t dst = ExtractBitsFromIntVector(
      cpInstrFormat_.dst_.first, cpInstrFormat_.dst_.second, code);
    if (dst) { instr.AppendOperand(TargetOperandType::Predicate, dst); }
  }// if (IsTargetCompare(op))
  unsigned nIn = NumOfOpInput(op);
  // Handle reg operands
  unsigned nRegOperand = (iBit > 0) ? (nIn-1) : nIn;
  for (unsigned i = 0; i < nRegOperand; ++i) {
    int srcMSB = cpInstrFormat_.srcOperandStart_-i*cpInstrFormat_.regAddrBits_;
    uint32_t src = ExtractBitsFromIntVector(
      srcMSB - cpInstrFormat_.regAddrBits_ + 1, srcMSB, code);
    TargetOperandType_t opType = registerFiles_[0].IsNormalReg(src) ?
      TargetOperandType::Register:TargetOperandType::Bypass;
    if ((i == 0) && (commBits != 0)) {
      opType = TargetOperandType::Communication;
      switch (commBits) {
      case 1: src += COMM_TAIL_BASE; break;
      case 2: src += COMM_HEAD_BASE; break;
      default: return false;
      }// switch (commBits)
    }// if ((i == 0) && (commBits != 0))
    instr.AppendOperand(opType, src);
  }// for i = 0 to (nIn-1)-1
  if (iBit > 0) { // Handle immediate operand
    int immVal = 0;
    int immBits = cpInstrFormat_.iImm_.second - cpInstrFormat_.iImm_.first + 1;
    if (IsTargetStore(op)) {
      uint32_t iL = ExtractBitsFromIntVector(
        cpInstrFormat_.stImmL_.first, cpInstrFormat_.stImmL_.second, code);
      uint32_t iH = ExtractBitsFromIntVector(
        cpInstrFormat_.stImmH_.first, cpInstrFormat_.stImmH_.second, code);
      unsigned lBits = cpInstrFormat_.stImmL_.second
        - cpInstrFormat_.stImmL_.first + 1;
      immBits = cpInstrFormat_.stImmH_.second - cpInstrFormat_.stImmH_.first
        + 1 + lBits;
      immVal = (iH<<lBits) | iL;
    } else if (IsTargetImmediateOp(op)) {
      immVal = ExtractBitsFromIntVector(
        cpInstrFormat_.immInstrImm_.first,
        cpInstrFormat_.immInstrImm_.second, code);
      immBits = cpInstrFormat_.immInstrImm_.second
        - cpInstrFormat_.immInstrImm_.first + 1;
    } else {
      immVal = ExtractBitsFromIntVector(
        cpInstrFormat_.iImm_.first, cpInstrFormat_.iImm_.second, code);
    }// if (IsTargetStore(op))
    if (!ZeroExtensionTargetOp(op)) {
      immVal = SignExtendNBitImm(immVal, immBits);
    }
    instr.AppendOperand(TargetOperandType::IntImmediate, immVal);
    // We assume that there is NO subi, only rsubi
    if (instr.GetOpcode() == TargetOpcode::SUB) {
      instr.SetOpcode(TargetOpcode::RSUB);
    }
  } else {}// if (iBit == 0)
  return true;
}// DecodeCPInstruction()

bool BaselineBasicInfo::
DecodePEInstruction(BaselineInstruction& instr, const UInt32Vector& code) const{
  uint32_t iBit = ExtractBitsFromIntVector(
    peInstrFormat_.iTypeBit_, peInstrFormat_.iTypeBit_, code);
  uint32_t commBits = ExtractBitsFromIntVector(
    peInstrFormat_.comm_.first, peInstrFormat_.comm_.second, code);
  uint32_t opc = ExtractBitsFromIntVector(
    peInstrFormat_.opcode_.first, peInstrFormat_.opcode_.second,code);
  TargetOpcode_t op = GetCPOpcode(opc);
  if (op == TargetOpcode::TargetOpcodeEnd) { return false; }
  uint32_t pred  = PEHasPredicates() ? ExtractBitsFromIntVector(
    peInstrFormat_.pred_.first, peInstrFormat_.pred_.second,code) : 0;
  if (pred) {
    for (unsigned p = 1; pred; ++p, pred >>= 1) {
      if (pred & 0x1) { instr.AppendPredicate(p); }
    }
  }// if (pred)
  instr.SetOpcode(op);
  // I-Type instruction
  if (NumTargetOpResult(op) == 1) {
    uint32_t dst = ExtractBitsFromIntVector(
      peInstrFormat_.dst_.first, peInstrFormat_.dst_.second, code);
    TargetOperandType_t opType = registerFiles_[1].IsNormalReg(dst)
      ? TargetOperandType::Register : TargetOperandType::Bypass;
    if ((opType == TargetOperandType::Register) && explicitBypass_[1] && (dst == 0)) {
      opType = TargetOperandType::Bypass;
    }
    instr.AppendOperand(opType, dst);
  } else if (IsTargetCompare(op)) {
    uint32_t dst = ExtractBitsFromIntVector(
      peInstrFormat_.dst_.first, peInstrFormat_.dst_.second, code);
    if (dst) { instr.AppendOperand(TargetOperandType::Predicate, dst); }
  }// if (IsTargetCompare(op))
  unsigned nIn = NumOfOpInput(op);
  // Handle reg operands
  unsigned nRegOperand = (iBit > 0) ? (nIn-1) : nIn;
  for (unsigned i = 0; i < nRegOperand; ++i) {
    int srcMSB = peInstrFormat_.srcOperandStart_-i*peInstrFormat_.regAddrBits_;
    uint32_t src = ExtractBitsFromIntVector(
      srcMSB - peInstrFormat_.regAddrBits_ + 1, srcMSB, code);
    TargetOperandType_t opType = registerFiles_[1].IsNormalReg(src) ?
      TargetOperandType::Register:TargetOperandType::Bypass;
    // if (opType == TargetOperandType::Bypass)
    if ((i == 0) && (commBits != 0)) {
      opType = TargetOperandType::Communication;
      switch (commBits) {
      case 1: src += COMM_RIGHT_BASE; break;
      case 2: src += COMM_LEFT_BASE;  break;
      case 3: src += COMM_BROADCAST;  break;
      default: return false;
      }// switch (commBits)
    }// if ((i == 0) && (commBits != 0))
    instr.AppendOperand(opType, src);
  }// for i = 0 to (nIn-1)-1
  if (iBit > 0) { // Handle immediate operand
    int immVal = 0;
    int immBits = peInstrFormat_.iImm_.second - peInstrFormat_.iImm_.first + 1;
    if (IsTargetStore(op)) {
      uint32_t iL = ExtractBitsFromIntVector(
        peInstrFormat_.stImmL_.first, peInstrFormat_.stImmL_.second, code);
      uint32_t iH = ExtractBitsFromIntVector(
        peInstrFormat_.stImmH_.first, peInstrFormat_.stImmH_.second, code);
      unsigned lBits = peInstrFormat_.stImmL_.second
        - peInstrFormat_.stImmL_.first + 1;
      immBits = peInstrFormat_.stImmH_.second - peInstrFormat_.stImmH_.first
        + 1 + lBits;
      immVal = (iH<<lBits) | iL;
    } else if (IsTargetImmediateOp(op)) {
      immVal = ExtractBitsFromIntVector(
        peInstrFormat_.immInstrImm_.first,
        peInstrFormat_.immInstrImm_.second, code);
      immBits = peInstrFormat_.immInstrImm_.second
        - peInstrFormat_.immInstrImm_.first + 1;
    } else {
      immVal = ExtractBitsFromIntVector(
        peInstrFormat_.iImm_.first, peInstrFormat_.iImm_.second, code);
    }// if (IsTargetStore(op))
    if (!ZeroExtensionTargetOp(op)) {
      immVal = SignExtendNBitImm(immVal, immBits);
    }
    instr.AppendOperand(TargetOperandType::IntImmediate, immVal);
    // We assume that there is NO subi, only rsubi
    if (instr.GetOpcode() == TargetOpcode::SUB) {
      instr.SetOpcode(TargetOpcode::RSUB);
    }
  }// if (iBit == 0)
  return true;
}// DecodePEInstruction()

TargetBinaryProgram* BaselineBasicInfo::
CreateBinaryProgram(int id, const std::string& name) const {
  return new BaselineBinaryProgram(id, name, *this);
}// CreateBinaryProgram()

bool BaselineBasicInfo::
ValidateTarget() const {
  if (!configValid_ || !operations_[1].AllOperationsValid()
      || !operations_[1].AllOperationsValid()){
    return false;
  }
  return true;
}// ValidateTarget()

void BaselineBasicInfo::
InitCodeGenInfo() {
  InitDefaultOpTranslation();
  InitCPOperandInfo();
  InitPEOperandInfo();
  InitTimingInfo();
  InitDefaultOperationInfo();
  cpInstrFormat_.Initialize(true, predicates_[0].GetNumRegs());
  peInstrFormat_.Initialize(true, predicates_[1].GetNumRegs());
  instrWidth_[0] = cpInstrFormat_.GetTotalBits();
  instrWidth_[1] = peInstrFormat_.GetTotalBits();
}// InitCodeGenInfo()

void BaselineBasicInfo::
InitSimulationInfo() {
  InitCPOperandInfo();
  InitPEOperandInfo();
  InitTimingInfo();
  InitDefaultOperationInfo();
  cpInstrFormat_.Initialize(true, predicates_[0].GetNumRegs());
  peInstrFormat_.Initialize(true, predicates_[1].GetNumRegs());
  instrWidth_[0] = cpInstrFormat_.GetTotalBits();
  instrWidth_[1] = peInstrFormat_.GetTotalBits();
}// InitSimulationInfo()

void BaselineBasicInfo::
InitCPOperandInfo() {
  registerFiles_[0].AddRegisterAlias(0,  "ZERO");
  registerFiles_[0].AddRegisterAlias(1,  "SP");
  registerFiles_[0].AddRegisterAlias(2,  "FP");
  registerFiles_[0].AddRegisterAlias(9,  "RA");
  registerFiles_[0].AddRegisterAlias(25, "GP");
  if (explicitBypass_[0]) {
    if (stages_[0] == 4) {
      registerFiles_[0].AddSpecialRegister(-1, 0,  "--" , true);
      registerFiles_[0].AddSpecialRegister( 2, 28, "LSU");
      registerFiles_[0].AddSpecialRegister( 1, 29, "MUL");
      registerFiles_[0].AddSpecialRegister( 0, 30, "ALU");
      registerFiles_[0].AddSpecialRegister( 3, 31, "WB" );
    } else if (stages_[0] == 5) {
      registerFiles_[0].AddSpecialRegister(-1, 0,  "--"  , true);
      registerFiles_[0].AddSpecialRegister( 0, 27, "ALU1");
      registerFiles_[0].AddSpecialRegister( 2, 28, "LSU" );
      registerFiles_[0].AddSpecialRegister( 1, 29, "MUL" );
      registerFiles_[0].AddSpecialRegister( 3, 30, "ALU2");
      registerFiles_[0].AddSpecialRegister( 4, 31, "WB"  );
    } else {
      ES_NOTSUPPORTED("CP only support 4- or 5-stage");
    }
  }// if (explicitBypass_[0])
}// InitCPOperandInfo()

void BaselineBasicInfo::
InitPEOperandInfo() {
  registerFiles_[1].AddRegisterAlias(0,  "ZERO");
  registerFiles_[1].AddRegisterAlias(1,  "PEID");
  if (explicitBypass_[1]) {
    if (stages_[1] == 4) {
      registerFiles_[1].AddSpecialRegister(-1, 0,  "--" , true);
      registerFiles_[1].AddSpecialRegister( 2, 28, "LSU");
      registerFiles_[1].AddSpecialRegister( 1, 29, "MUL");
      registerFiles_[1].AddSpecialRegister( 0, 30, "ALU");
      registerFiles_[1].AddSpecialRegister( 3, 31, "WB" );
    } else if (stages_[1] == 5) {
      registerFiles_[1].AddSpecialRegister(-1, 0,  "--"  , true);
      registerFiles_[1].AddSpecialRegister( 0, 27, "ALU1");
      registerFiles_[1].AddSpecialRegister( 2, 28, "LSU" );
      registerFiles_[1].AddSpecialRegister( 1, 29, "MUL" );
      registerFiles_[1].AddSpecialRegister( 3, 30, "ALU2");
      registerFiles_[1].AddSpecialRegister( 4, 31, "WB"  );
    } else {
      ES_NOTSUPPORTED("PE only support 4- or 5-stage");
    }
  }// if (explicitBypass_[1])
}// InitDefaultPEOperandInfo()

void BaselineBasicInfo::
InitTimingInfo(){
  if (explicitBypass_[0]) {
    fuOutputMap_[0].resize(3);
    if (stages_[0] == 5) {
      // ALU extra output buffer
      fuOutputMap_[0][0].push_back(27);
      fuOutputMap_[0][1].push_back(0);
      fuOutputMap_[0][2].push_back(0);
    }
    fuOutputMap_[0][0].push_back(30);// ALU
    fuOutputMap_[0][1].push_back(29);// MUL
    fuOutputMap_[0][2].push_back(28);// LSU
  }// if (explicitBypass_[0])
  if (explicitBypass_[1]) {
    fuOutputMap_[1].resize(3);
    if (stages_[1] == 5) {
      // ALU extra output buffer
      fuOutputMap_[1][0].push_back(27);
      fuOutputMap_[1][1].push_back(0);
      fuOutputMap_[1][2].push_back(0);
    }
    fuOutputMap_[1][0].push_back(30);// ALU
    fuOutputMap_[1][1].push_back(29);// MUL
    fuOutputMap_[1][2].push_back(28);// LSU
  }// if (explicitBypass_[1])
}// InitTimingInfo()

void BaselineBasicInfo::
InitDefaultOperationInfo() {
  int      lgShBind = (stages_[0] == 4) ? 1 : 0;
  unsigned mulLat   = (stages_[0] == 4) ? 1 : 2;
  unsigned memLat   = (stages_[0] == 4) ? 1 : 2;
  if (!operations_[0].HasValidOp()) {
    ///                             opcode         bin  binding  latency
    operations_[0].AddOperation(TargetOpcode::SIMM , 0 , -1,        1);
    operations_[0].AddOperation(TargetOpcode::ZIMM , 1 , -1,        1);
    operations_[0].AddOperation(TargetOpcode::ADD  , 2 ,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SUB  , 3 ,  0,        1);
    operations_[0].AddOperation(TargetOpcode::MUL  , 4 ,  1,        mulLat);
    operations_[0].AddOperation(TargetOpcode::MULU , 5 ,  1,        mulLat);
    operations_[0].AddOperation(TargetOpcode::OR   , 6 ,  lgShBind, 1);
    operations_[0].AddOperation(TargetOpcode::AND  , 7 ,  lgShBind, 1);
    operations_[0].AddOperation(TargetOpcode::XOR  , 8 ,  lgShBind, 1);
    operations_[0].AddOperation(TargetOpcode::CMOV , 9 ,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFEQ , 10,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFNE , 11,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFLES, 12,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFLTS, 13,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFGES, 14,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFGTS, 15,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFLEU, 16,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFLTU, 17,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFGEU, 18,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SFGTU, 19,  0,        1);
    operations_[0].AddOperation(TargetOpcode::SLL  , 20,  lgShBind, 1);
    operations_[0].AddOperation(TargetOpcode::SRA  , 21,  lgShBind, 1);
    operations_[0].AddOperation(TargetOpcode::SRL  , 22,  lgShBind, 1);
    operations_[0].AddOperation(TargetOpcode::ROR  , 23,  lgShBind, 1);
    if (dataWidth_[0] > 16) {
      operations_[0].AddOperation(TargetOpcode::LB, 26, 2, memLat);
      operations_[0].AddOperation(TargetOpcode::SB, 27, 2, memLat);
    }
    operations_[0].AddOperation(TargetOpcode::LH, 28, 2, memLat);
    operations_[0].AddOperation(TargetOpcode::SH, 29, 2, memLat);
    operations_[0].AddOperation(TargetOpcode::LW, 30, 2, memLat);
    operations_[0].AddOperation(TargetOpcode::SW, 31, 2, memLat);

    // Only used for code generation
    operations_[0].AddOperation(TargetOpcode::RSUB, 3,  0, 1, true);
    operations_[0].AddOperationBinding(TargetOpcode::MOV , 0, 1);
    operations_[0].AddOperationBinding(TargetOpcode::MOV_H, 0, 1);
    operations_[0].AddOperationBinding(TargetOpcode::MOV_T, 0, 1);
    operations_[0].AddCodeGenOpcode(TargetOpcode::MOV);
    operations_[0].AddCodeGenOpcode(TargetOpcode::MOV_H);
    operations_[0].AddCodeGenOpcode(TargetOpcode::MOV_T);
    //// Branch opcode decoding info
#ifdef ES_SUPPORT_SYSCALL
    operations_[0].AddControlOperation(TargetOpcode::SYS, 1, 2);
#endif
    operations_[0].AddControlOperation(TargetOpcode::BF  , 2, 2); 
    operations_[0].AddControlOperation(TargetOpcode::BNF , 3, 2); 
    operations_[0].AddControlOperation(TargetOpcode::J   , 4, 2); 
    operations_[0].AddControlOperation(TargetOpcode::JAL , 5, 2); 
    operations_[0].AddControlOperation(TargetOpcode::JR  , 6, 2); 
    operations_[0].AddControlOperation(TargetOpcode::JALR, 7, 2); 
    operations_[0].AddControlOperation(TargetOpcode::NOP , 0, 1);
  }
  if ((numOfPE_ == 0) || operations_[1].HasValidOp()) { return; }
  // PE operations
  lgShBind = (stages_[1] == 4) ? 1 : 0;
  mulLat   = (stages_[1] == 4) ? 1 : 2;
  memLat   = (stages_[1] == 4) ? 1 : 2;
  operations_[1].AddOperation(TargetOpcode::SIMM , 0 , -1,        1);
  operations_[1].AddOperation(TargetOpcode::ZIMM , 1 , -1,        1);
  operations_[1].AddOperation(TargetOpcode::ADD  , 2 ,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SUB  , 3 ,  0,        1);
  // RSUB is only used for encoding
  operations_[1].AddOperation(TargetOpcode::RSUB , 3 ,  0,        1, true);
  operations_[1].AddOperation(TargetOpcode::MUL  , 4 ,  1,        mulLat);
  operations_[1].AddOperation(TargetOpcode::MULU , 5 ,  1,        mulLat);
  operations_[1].AddOperation(TargetOpcode::OR   , 6 ,  lgShBind, 1);
  operations_[1].AddOperation(TargetOpcode::AND  , 7 ,  lgShBind, 1);
  operations_[1].AddOperation(TargetOpcode::XOR  , 8 ,  lgShBind, 1);
  operations_[1].AddOperation(TargetOpcode::CMOV , 9 ,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFEQ , 10,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFNE , 11,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFLES, 12,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFLTS, 13,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFGES, 14,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFGTS, 15,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFLEU, 16,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFLTU, 17,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFGEU, 18,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SFGTU, 19,  0,        1);
  operations_[1].AddOperation(TargetOpcode::SLL  , 20,  lgShBind, 1);
  operations_[1].AddOperation(TargetOpcode::SRA  , 21,  lgShBind, 1);
  operations_[1].AddOperation(TargetOpcode::SRL  , 22,  lgShBind, 1);
  operations_[1].AddOperation(TargetOpcode::ROR  , 23,  lgShBind, 1);
  if (dataWidth_[1] > 16) {
    operations_[1].AddOperation(TargetOpcode::LB, 26, 2, memLat);
    operations_[1].AddOperation(TargetOpcode::SB, 27, 2, memLat);
  }
  operations_[1].AddOperation(TargetOpcode::LH, 28, 2, memLat);
  operations_[1].AddOperation(TargetOpcode::SH, 29, 2, memLat);
  operations_[1].AddOperation(TargetOpcode::LW, 30, 2, memLat);
  operations_[1].AddOperation(TargetOpcode::SW, 31, 2, memLat);

  operations_[1].AddControlOperation(TargetOpcode::NOP , 0, 1);

  operations_[1].AddOperation(TargetOpcode::RSUB, 3,  0, 1, true);
  operations_[1].AddOperationBinding(TargetOpcode::MOV , 0, 1);
  operations_[1].AddOperationBinding(TargetOpcode::MOV_L, 0, 1);
  operations_[1].AddOperationBinding(TargetOpcode::MOV_R, 0, 1);
  operations_[1].AddOperationBinding(TargetOpcode::PUSH_H, 0, 1);
  operations_[1].AddOperationBinding(TargetOpcode::PUSH_T, 0, 1);
  operations_[1].AddCodeGenOpcode(TargetOpcode::MOV);
  operations_[1].AddCodeGenOpcode(TargetOpcode::MOV_L);
  operations_[1].AddCodeGenOpcode(TargetOpcode::MOV_R);
  operations_[1].AddCodeGenOpcode(TargetOpcode::PUSH_H);
  operations_[1].AddCodeGenOpcode(TargetOpcode::PUSH_T);
}// InitOperationInfo()

bool BaselineBasicInfo::
SetTargetParam(const std::string& key, const std::string& val) {
  bool succ = false;
  ImmediateReader immRd;
  int s = immRd.GetIntImmediate(val);
  if (key == "pe") {
    succ = !immRd.error_;
    numOfPE_ = s;
  } else if (key == "stage") {
    succ = !immRd.error_;
    stages_[1] = stages_[0] = s;
  } else if (key == "cp-stage") {
    succ = !immRd.error_;
    stages_[0] = s;
  } else if (key == "pe-stage") {
    succ = !immRd.error_;
    stages_[1] = s;
  } else if (key == "dwidth") {
    if (!immRd.error_) {
      succ = true;
      dataWidth_[0] = dataWidth_[1] = s;
    }// if (!immRd.error_)
  } else if (key == "cp-dwidth") {
    if (!immRd.error_) {
      succ = true;
      dataWidth_[0] = s;
    }// if (!immRd.error_)
  } else if (key == "pe-dwidth") {
    if (!immRd.error_) {
      succ = true;
      dataWidth_[1] = s;
    }// if (!immRd.error_)
  }  else if (key == "cp-bypass") {
    if (!immRd.error_) {
      succ = true;
      explicitBypass_[0] = (s>0) ? true : false;
    } else if (val == "true") {
      succ = true;
      explicitBypass_[0] = true;
    } else if (val == "false") {
      succ = true;
      explicitBypass_[0] = false;
    }// if (!immRd.error_)
  } else if (key == "pe-bypass") {
    if (!immRd.error_) {
      succ = true;
      explicitBypass_[1] = (s>0) ? true : false;
    } else if (val == "true") {
      succ = true;
      explicitBypass_[1] = true;
    } else if (val == "false") {
      succ = true;
      explicitBypass_[1] = false;
    }// if (!immRd.error_)
  } else if (key == "bypass") {
    if (!immRd.error_) {
      succ = true;
      explicitBypass_[1] = explicitBypass_[0] = (s>0) ? true : false;
    } else if (val == "true") {
      succ = true;
      explicitBypass_[1] = explicitBypass_[0] = true;
    } else if (val == "false") {
      succ = true;
      explicitBypass_[1] = explicitBypass_[0] = false;
    }// if (!immRd.error_)
  } else if (key == "cp-dmem-depth") {
    succ = !immRd.error_;
    dataMemDepth_[0] = s;
  } else if (key == "pe-dmem-depth") {
    succ = !immRd.error_;
    dataMemDepth_[1] = s;
  } else if (key == "predicate") {
    succ = !immRd.error_;
    predicates_[0].SetSize(s+1);
    predicates_[1].SetSize(s+1);
  } else if (key == "cp-predicate") {
    succ = !immRd.error_;
    predicates_[0].SetSize(s+1);
  } else if (key == "pe-predicate") {
    succ = !immRd.error_;
    predicates_[1].SetSize(s+1);
  }
  return succ;
}// SetTargetParam()
