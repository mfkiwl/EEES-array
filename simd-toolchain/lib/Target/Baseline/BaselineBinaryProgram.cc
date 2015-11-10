#include <sstream>
#include "BaselineBinaryProgram.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineInstructionPacket.hh"
#include "BaselineInstruction.hh"
#include "Utils/VerilogMemInit.hh"
#include "Utils/InlineUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

BaselineBinaryProgram::
~BaselineBinaryProgram() {}

bool BaselineBinaryProgram::
ResolveSymbols() {
  for (TargetBinaryProgram::iterator pIt = begin(); pIt != end(); ++pIt) {
    TargetInstructionPacket* ip = *pIt;
    if (ip == NULL)
      continue;
    for (TargetInstructionPacket::iterator iIt = ip->begin();
         iIt != ip->end(); ++iIt) {
      BaselineInstruction* instr = dynamic_cast<BaselineInstruction*>(*iIt);
      if (instr == NULL)
        continue;
      for (unsigned i = 0; i < instr->GetNumSrcOperands(); ++i) {
        TargetOperand& o = instr->GetSrcOperand(i);
        if (o.type_ == TargetOperandType::Label) {
          const TargetSymbol& sym = GetSymbol(o.value_);
          int offset = sym.address_ - ip->GetAddress();
          o.type_ = TargetOperandType::IntImmediate;
          o.value_ = offset;
        }// if (o.type_ == TargetOperandType::Label)
      }// for i = 0 to instr->GetNumSrcOperands()-1
    }// for ip iterator iIt
  }// for prog_ iterator pIt
  return true;
}// ResolveSymbols()

int BaselineBinaryProgram::
AddDataInit(int dSec, SIRDataType_t dt, int addr, int val) {
  std::vector<MemDataSection>& data = (dSec == 1) ? data_[1] : data_[0];
  int dwidth = (dSec==1) ? target_.GetPEDataWidth() : target_.GetCPDataWidth();
  MemDataSection* sec = NULL;
  unsigned waddr = addr * 8 / dwidth;// Word address
  for (unsigned i = 0; i < data.size(); ++i) {
    if ((data[i].size() + data[i].start_) >= waddr) {
      sec = &data[i];
      break;
    }
  }
  if (!sec) {
    data.push_back(MemDataSection(waddr, dwidth));
    sec = &data.back();
  }// if (!sec)
  unsigned woffset = waddr - sec->start_;
  switch (dt) {
  case SIRDataType::Int32:
    if (woffset >= sec->size()) { sec->data_.push_back(UIntVector(1, val)); }
    else { sec->data_[woffset][0] = val; }
    return 4;
  case SIRDataType::Int16:
    switch (dwidth / 8) {
    case 1: break;
    case 2: {
      if (woffset >= sec->size()) { sec->data_.push_back(UIntVector(1, val)); }
      else { sec->data_[woffset][0] = val; }
      break;
    }
    case 4: {
      int hwIdx = ((addr>>1) & 1);
      if (woffset >= sec->size()) {
        sec->data_.push_back(UIntVector(1, val << (hwIdx*16)));
      } else {
        int w = sec->data_[woffset][0];
        reinterpret_cast<int16_t*>(&w)[hwIdx] = static_cast<int16_t>(val);
        sec->data_[woffset][0] = w;
      }
      break;
    }
    default: ES_UNREACHABLE("Invalid data width");
    }
    return 2;
  case SIRDataType::Int8: {
    switch (dwidth / 8) {
    case 1:
      if (woffset >= sec->size()) { sec->data_.push_back(UIntVector(1, val)); }
      else { sec->data_[woffset][0] = val; }
      break;
    case 2: {
      int bIdx = (addr & 1);
      if (woffset >= sec->size()) {
        sec->data_.push_back(UIntVector(1, val<< (bIdx*8)));
      } else {
        int w = sec->data_[woffset][0];
        reinterpret_cast<int8_t*>(&w)[bIdx] = static_cast<int8_t>(val);
        sec->data_[woffset][0] = w;
      }
      break;
    }
    case 4: {
      int bIdx = (addr & 3);
      if (woffset >= sec->size()) {
        sec->data_.push_back(UIntVector(1, val << (bIdx*8)));
      } else {
        int w = sec->data_[woffset][0];
        reinterpret_cast<int8_t*>(&w)[bIdx] = static_cast<int8_t>(val);
        sec->data_[woffset][0] = w;
      }
      break;
    }
    default: ES_UNREACHABLE("Invalid data width");
    }
    return 1;
  }
  default: return 0;
  }
}// AddDataInit()

FileStatus_t BaselineBinaryProgram::
SaveVerilogMemHex(const std::string& prefix) const {
  int len = binaryInstrs_.size();
  int cpW = CeilDiv(target_.GetCPInstrWidth(), 32);
  int peW = CeilDiv(target_.GetPEInstrWidth(), 32);
  UInt32Vector2D cpCode(len, UInt32Vector(cpW, 0)),
    peCode(len, UInt32Vector(peW, 0));
  int idx = 0;
  for (TargetBinaryProgram::const_iterator pIt = begin(); pIt != end(); ++pIt) {
    const TargetInstructionPacket* ip = *pIt;
    if (ip == NULL)
      continue;
    for (TargetInstructionPacket::const_iterator iIt = ip->begin();
         iIt != ip->end(); ++iIt) {
      const BaselineInstruction* instr
        = dynamic_cast<const BaselineInstruction*>(*iIt);
      if (instr == NULL)
        continue;
      if (instr->GetType() == TargetInstrType::Vector) {
        target_.EncodePEInstruction(*instr, peCode[idx]);
      } else {
        target_.EncodeCPInstruction(*instr, cpCode[idx]);
      }
    }// for ip iterator iIt
    ++idx;
  }// for prog_ iterator pIt

  stringstream css, pss;
  FileStatus_t fs;
  WriteVerilogMemHex(css, cpCode, target_.GetCPInstrWidth(), codeStartAddr_);
  fs = WriteStringToFile(css.str(), prefix+".cp.imem_init");
  if (fs != FileStatus::OK) { return fs; }
  WriteVerilogMemHex(pss, peCode, target_.GetPEInstrWidth(), codeStartAddr_);
  fs = WriteStringToFile(pss.str(), prefix+".pe.imem_init");
  if (fs != FileStatus::OK) { return fs; }
  if (!data_[0].empty()) {
    stringstream cds;
    for (unsigned i = 0; i < data_[0].size(); ++i) {
      WriteVerilogMemHex(
        cds, data_[0][i].data_, data_[0][i].width_, data_[0][i].start_);
    }
    fs = WriteStringToFile(cds.str(), prefix+".cp.dmem_init");
    if (fs != FileStatus::OK) { return fs; }
  }// if (!data_[0].empty())
  if (!data_[1].empty()) {
    stringstream pds;
    for (unsigned i = 0; i < data_[1].size(); ++i) {
      WriteVerilogMemHex(
        pds, data_[1][i].data_, data_[1][i].width_, data_[1][i].start_);
    }
    fs = WriteStringToFile(pds.str(), prefix+".pe.dmem_init");
    if (fs != FileStatus::OK) { return fs; }
  }// if (!data_[1].empty())
  return fs;
}// SaveVerilogMemHex()
