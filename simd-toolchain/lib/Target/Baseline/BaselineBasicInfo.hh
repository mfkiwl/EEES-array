#ifndef ES_SIMD_BASELINETARGETBASICINFO_HH
#define ES_SIMD_BASELINETARGETBASICINFO_HH

#include "DataTypes/ContainerTypes.hh"
#include "Target/TargetBasicInfo.hh"
#include "Target/TargetRegisterFile.hh"
#include "Target/TargetOperationInfo.hh"
#include "BaselineInstrFormat.hh"
#include <json/json.h>

namespace ES_SIMD {
  class TargetASMParser;
  class TargetInstruction;
  class BaselineInstruction;
  class BaselineSimProcessor;

  class BaselineBasicInfo : public TargetBasicInfo {
    /// Processor parameters
    unsigned numOfPE_;      ///< Number of processing elements (PE)
    bool decoupledCP_;      ///< CP runs in decoupled mode
    BaselineInstrFormat cpInstrFormat_;
    BaselineInstrFormat peInstrFormat_;
    void InitParam();
  public:
    enum {
      DEFAULT_CP_NUM_REG = 32, DEFAULT_PE_NUM_REG = 32, DEFAULT_NUM_PE = 4,
      COMM_LEFT_BASE = 1000, COMM_RIGHT_BASE = 2000,
      COMM_HEAD_BASE = 1000, COMM_TAIL_BASE  = 2000,
      COMM_BROADCAST = 3000
    };
    enum { CP = 0, PE = 1 };
    BaselineBasicInfo();
    BaselineBasicInfo(const Json::Value& cfg);
    virtual ~BaselineBasicInfo();

    ////////////////////////////////////////////////////////////////////////////
    ///     Configuration interface
    virtual void InitCodeGenInfo();
    virtual void InitDefaultOperationInfo();
    virtual void InitSimulationInfo();
    virtual void InitTimingInfo();
    virtual bool ValidateTarget() const;
    virtual bool SetTargetParam(const std::string& key,
                                const std::string& val);

    ////////////////////////////////////////////////////////////////////////////
    ///     Instruction interface
    int GetCPInstrWidth() const { return cpInstrFormat_.totalBits_; }
    int GetPEInstrWidth() const { return peInstrFormat_.totalBits_; }
    virtual int InstrImmediateCost(const SIRInstruction* instr) const;
    virtual SIRDataType_t GetConstantPoolDataType() const {
      switch(dataWidth_[0]) {
      case 32: return SIRDataType::Int32;
      case 16: return SIRDataType::Int16;
      default: return SIRDataType::Unknown;
      }
    }
    virtual int GetTargetConstant (const SIRValue* v) const;
    /// \brief Get the maximum CP immediate width with immediate instruction.
    int GetCPMaxImmSize() const {
      return (cpInstrFormat_.iImm_.second - cpInstrFormat_.iImm_.first + 1)
        + (cpInstrFormat_.immInstrImm_.second
           - cpInstrFormat_.immInstrImm_.first + 1);
    }
    /// \brief Get the maximum CP immediate width with immediate instruction.
    int GetPEMaxImmSize() const {
      return (peInstrFormat_.iImm_.second - peInstrFormat_.iImm_.first + 1)
        + (peInstrFormat_.immInstrImm_.second
           - peInstrFormat_.immInstrImm_.first + 1);
    }
    unsigned GetCPImmHighOffset() const {
      return cpInstrFormat_.iImm_.second - cpInstrFormat_.iImm_.first + 1;
    }
    unsigned GetCPImmHighOffsetJType() const {
      return cpInstrFormat_.jImm_.second - cpInstrFormat_.jImm_.first + 1;
    }
    unsigned GetPEImmHighOffset() const {
      return peInstrFormat_.iImm_.second - peInstrFormat_.iImm_.first + 1;
    }
    unsigned GetImmSize(const SIRInstruction* instr) const;
    bool ImmCanFit(
      TargetOpcode_t opc, bool isVector, int val) const;
    virtual unsigned GetOperationWritebackDelay(
      const SIRInstruction* instr) const;
    unsigned GetCPOperationLatency(TargetOpcode_t o) const {
      return operations_[0].GetOpLatency(o);
    }
    unsigned GetPEOperationLatency(TargetOpcode_t o) const {
      return operations_[1].GetOpLatency(o);
    }
    unsigned GetCPOperationBinding(TargetOpcode_t o) const {
      return operations_[0].GetOpBinding(o);
    }
    unsigned GetPEOperationBinding(TargetOpcode_t o) const {
      return operations_[1].GetOpBinding(o);
    }

    TargetOpcode_t GetCPOpcode(uint32_t opc) const {
      return operations_[0].DecodeOperation(opc);
    }
    TargetOpcode_t GetCPBranchOpcode(uint32_t opc) const {
      return operations_[0].DecodeControlOp(opc);
    }
    TargetOpcode_t GetPEOpcode(uint32_t opc) const {
      return operations_[1].DecodeOperation(opc);
    }
    const BaselineInstrFormat& GetPEInstrFormat() const {return peInstrFormat_;}
    const BaselineInstrFormat& GetCPInstrFormat() const {return cpInstrFormat_;}
    const UIntVector& GetCPFUOutQueue(unsigned f) const {
      return fuOutputMap_[0][f];
    }
    const UIntVector& GetPEFUOutQueue(unsigned f) const {
      return fuOutputMap_[1][f];
    }
    virtual unsigned GetOperationLatency(const SIRInstruction* instr) const;
    virtual int GetOperationBinding(const SIRInstruction* instr) const;
    bool IsValidCPOpc(const std::string& ops) const {
      return operations_[0].IsValidOp(ops);
    }
    bool IsValidPEOpc(const std::string& ops) const {
      return operations_[1].IsValidOp(ops);
    }// IsValidPEOpc()

    bool IsValidCPOpc(TargetOpcode_t opc) const {
      return operations_[0].IsValidOp(opc);
    }
    bool IsValidPEOpc(TargetOpcode_t opc) const {
      return operations_[1].IsValidOp(opc);
    }
    TargetOpcode_t TranslateCPOpcode(SIROpcode_t opc) const {
      if (IsElementOf(opc, opTranslation_)) {
        TargetOpcode_t top = GetValue(opc, opTranslation_);
        if (IsValidCPOpc(top)) { return top; }
      }// if (IsElementOf(opc, opTranslation_)
      return TargetOpcode::TargetOpcodeEnd;
    }
    TargetOpcode_t TranslatePEOpcode(SIROpcode_t opc) const {
      if (IsElementOf(opc, opTranslation_)) {
        TargetOpcode_t top = GetValue(opc, opTranslation_);
        if (IsValidPEOpc(top)) { return top; }
      }// if (IsElementOf(opc, opTranslation_)
      return TargetOpcode::TargetOpcodeEnd;
    }

    virtual TargetOperand ParseTargetOperand(
      const std::string& str, const TargetInstruction* instr) const;
    virtual std::ostream& PrintOperand(
      std::ostream& out, const TargetOperand& o, TargetInstrType_t t) const;
    virtual bool EncodeInstruction(
      const TargetInstruction* instr, UInt32Vector& code) const;
    bool EncodeCPInstruction(
      const BaselineInstruction& instr, UInt32Vector& code) const;
    bool EncodePEInstruction(
      const BaselineInstruction& instr, UInt32Vector& code) const;

    virtual bool DecodeInstruction(
      TargetInstruction* instr, const UInt32Vector& code) const;
    bool DecodeCPInstruction(
      BaselineInstruction& instr, const UInt32Vector& code) const;
    bool DecodePEInstruction(
      BaselineInstruction& instr, const UInt32Vector& code) const;

    virtual TargetBinaryProgram* CreateBinaryProgram(
      int id, const std::string& name) const;

    ////////////////////////////////////////////////////////////////////////////
    ///    Pipeline interface
    unsigned GetNumPE()       const { return numOfPE_; }
    unsigned GetCPDataWidth() const { return dataWidth_[0]; }
    unsigned GetPEDataWidth() const { return dataWidth_[1]; }
    unsigned GetCPNumStages() const { return stages_[0]; }
    unsigned GetPENumStages() const { return stages_[1]; }
    bool CPIsDecoupled()  const { return decoupledCP_; }
    unsigned GetCPBranchDelaySlot() const { return GetNumOfBranchDelaySlots(); }
    bool IsCPExplicitBypass() const { return explicitBypass_[0]; }
    bool IsPEExplicitBypass() const { return explicitBypass_[1]; }

    ////////////////////////////////////////////////////////////////////////////
    ///    Memory interface
    unsigned GetCPDMemDepth() const { return dataMemDepth_[0]; }
    unsigned GetPEDMemDepth() const { return dataMemDepth_[1]; }
    unsigned GetCPIMemDepth() const { return instMemDepth_[0]; }
    unsigned GetPEIMemDepth() const { return instMemDepth_[1]; }

    ////////////////////////////////////////////////////////////////////////////
    ///    Register file and bypass interface
    unsigned GetNumberOfCPReg() const { return registerFiles_[0].GetNumRegs(); }
    unsigned GetCPRFSize() const      { return registerFiles_[0].GetRFSize();  }
    unsigned GetNumberOfPEReg() const { return registerFiles_[1].GetNumRegs(); }
    unsigned GetPERFSize() const      { return registerFiles_[1].GetRFSize();  }
    unsigned GetCPBypassRegID(int bid) const {
      return registerFiles_[0].GetSpecRegAddr(bid);
    }
    unsigned GetPEBypassRegID(int bid) const {
      return registerFiles_[1].GetSpecRegAddr(bid);
    }
    const std::string& GetCPBypassName(int bid) const {
      return registerFiles_[0].GetSpecialRegName(bid);
    }
    const std::string& GetPEBypassName(int bid) const {
      return registerFiles_[1].GetSpecialRegName(bid);
    }
    unsigned GetCPCommitRegID() const {
      return registerFiles_[0].GetSpecRegAddr("WB");
    }
    unsigned GetPECommitRegID() const {
      return registerFiles_[1].GetSpecRegAddr("WB");
    }
    const IntVector& GetCPAvailPhyRegs() const {
      return registerFiles_[0].GetAvailPhyRegs();
    }
    const IntVector& GetPEAvailPhyRegs() const {
      return registerFiles_[1].GetAvailPhyRegs();
    }
    bool     CPHasPredicates()    const { return !predicates_[0].Empty();     }
    bool     PEHasPredicates()    const { return !predicates_[1].Empty();     }
    unsigned GetCPNumPredicates() const { return predicates_[0].GetNumRegs(); }
    unsigned GetPENumPredicates() const { return predicates_[1].GetNumRegs(); }
    bool     IsCPPhyRegister(int r) const {
      return (r > 0) && (r < static_cast<int>(GetCPRFSize()));
    }
    bool     IsPEPhyRegister(int r) const {
      return (r > 0) && (r < static_cast<int>(GetPERFSize()));
    }
  private:
    ////////////////////////////////////////////////////////////////////////////
    ///     Internal helpers
    void SetDefaultParam();
    void SetParam(const Json::Value& cfg);
    void InitCPOperandInfo();
    void InitPEOperandInfo();
    static RegisterTargetBasicInfo<BaselineBasicInfo> reg_;
  };// class BaselineBasicInfo

  bool ConfigureBaseline(const std::string& cfg, BaselineBasicInfo& arch,
                         bool dbg, std::ostream& dbgs, std::ostream& err);
}// namespace ES_SIMD

#endif//ES_SIMD_BASELINETARGETBASICINFO_HH
