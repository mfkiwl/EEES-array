#ifndef ES_SIMD_TARGETREGISTERFILE_HH
#define ES_SIMD_TARGETREGISTERFILE_HH

#include "DataTypes/ContainerTypes.hh"

namespace ES_SIMD {
  class TargetRegisterFile {
    unsigned   numReg_;        ///< All registers, including special regs
    unsigned   rfSize_;        ///< Number of actual actual regs in the RF
    unsigned   readPorts_;     ///< Number of read ports of the RF
    unsigned   writePorts_;    ///< Number of write ports of the RF
    Str2IntMap reg_;           ///< Reg name to ID look-up-table
    Int2StrMap regName_;       ///< Reg ID to name look-up-table
    Str2IntMap specReg_;       ///< Special reg name to reg addr look-up-table
    Str2IntMap specRegID_;     ///< Special reg name to ID look-up-table
    Int2StrMap specRegName_;   ///< Special reg ID to name look-up-table
    Int2IntMap specRegID2Reg_; ///< Special reg ID to reg address look-up-table
    BitVector  reservedReg_;
    std::string regPrefix_;
    mutable IntVector availPhyReg_; ///< Available physical regs in the RF
    static const std::string DEFAULT_REG_NAME;
  public:
    TargetRegisterFile(const std::string& p = "r") : regPrefix_(p) {
      SetSize(0);
    }
    void SetSize(unsigned size);
    void AddRegisterAlias(unsigned id, const std::string& name);
    void AddSpecialRegister(int id, unsigned reg, const std::string& name,
                            bool keepReg = false);
    void ReserveRegister(unsigned id);
    void SetRegPrefix(const std::string& p) { regPrefix_ = p;SetSize(numReg_); }

    void SetWritePorts(unsigned n) { writePorts_ = n; }
    void SetReadPorts (unsigned n) { readPorts_ = n;  }
    unsigned GetRFSize()  const { return rfSize_; }
    unsigned GetNumRegs() const { return numReg_; }
    unsigned GetNumReadPorts()  const { return readPorts_;  }
    unsigned GetNumWritePorts() const { return writePorts_; }
    IntVector& GetAvailPhyRegs() const;

    bool Empty() const { return (numReg_ == 0);}
    bool IsValidRegAddr(unsigned r) const { return r < numReg_; }
    bool IsNormalReg(unsigned r) const {
      return (r < numReg_) && !reservedReg_[r];
    }
    const std::string& GetRegName(int r) const {
      return IsElementOf(r,regName_) ? GetValue(r,regName_) : DEFAULT_REG_NAME;
    }
    const std::string& GetSpecialRegName(int id) const {
      int r = GetSpecRegAddr(id);
      return IsElementOf(r,specRegName_) ?
        GetValue(r,specRegName_) : DEFAULT_REG_NAME;
    }
    int GetRegAddr(const std::string& name) const {
      return IsElementOf(name, reg_) ? GetValue(name, reg_) : -1;
    }
    int GetSpecRegAddr(const std::string& name) const {
      return IsElementOf(name, specReg_) ? GetValue(name, specReg_) : -1;
    }
    unsigned GetSpecRegAddr(int id) const {
      return IsElementOf(id, specRegID2Reg_) ? GetValue(id, specRegID2Reg_) : 0;
    }
    int GetAddr(const std::string& name) const {
      int r = GetRegAddr(name);
      return (r >= 0) ? r : GetSpecRegAddr(name);
    }
  };// class TargetRegisterFile
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETREGISTERFILE_HH
