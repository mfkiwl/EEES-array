#include "Target/TargetRegisterFile.hh"
#include "Utils/StringUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

const std::string TargetRegisterFile::DEFAULT_REG_NAME = "RX";

void TargetRegisterFile::
SetSize(unsigned size) {
  numReg_ = rfSize_ = size;
  reservedReg_.resize(size);
  reservedReg_.reset();
  for (unsigned i = 0; i < numReg_; ++i) {
    string reg = regPrefix_ + Int2DecString(i);
    reg_[reg]   = i;
    regName_[i] = reg;
  }
  availPhyReg_.clear();
  availPhyReg_.reserve(rfSize_);
}// TargetRegisterFile::SetSize()

void TargetRegisterFile::
AddRegisterAlias(unsigned id, const std::string& name) {
  ES_ASSERT_MSG(id < rfSize_, "Cannot add alias for R"<< id <<"\n");
  reg_[name] = id;
}// TargetRegisterFile::AddRegisterAlias()

void TargetRegisterFile::
AddSpecialRegister(int id, unsigned r, const string& name, bool keepReg) {
  ES_ASSERT_MSG(r < numReg_,"Invalid reg addr "<< r <<" for "<< name <<"\n");
  ES_ASSERT_MSG(!reservedReg_[r],
                regPrefix_<< r <<" cannot be used by "<< name <<"\n");
  if (!keepReg) {
    reservedReg_.set(r);
    string reg = regPrefix_ + Int2DecString(r);
    reg_.erase(reg);
    regName_.erase(r);
    --rfSize_;
  }// if (!keepReg)
  reg_[name] = r;
  availPhyReg_.clear();
  specReg_[name]     = r;
  specRegID_[name]   = id;
  specRegName_[r]    = name;
  specRegID2Reg_[id] = r;
}// TargetRegisterFile::AddSpecialRegister()

void TargetRegisterFile::
ReserveRegister(unsigned id) {
  ES_ASSERT_MSG(id < numReg_, "Invalid register ID "<< id);
  reservedReg_.set(id);
}// TargetRegisterFile::ReserveRegister()

IntVector& TargetRegisterFile::
GetAvailPhyRegs() const {
  if (availPhyReg_.empty()) {
    for (unsigned i = 0; i < numReg_; ++i) {
      if (!reservedReg_[i]) {availPhyReg_.push_back(i);}
    }
  }
  return availPhyReg_;
}// GetAvailPhyRegs()
