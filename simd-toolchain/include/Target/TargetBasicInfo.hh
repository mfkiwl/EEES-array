#ifndef ES_SIMD_TARGETBASICINFO_HH
#define ES_SIMD_TARGETBASICINFO_HH

#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/SIRDataType.hh"
#include "Target/TargetOperand.hh"
#include "Target/TargetInstruction.hh"
#include "Target/TargetRegisterFile.hh"
#include "Target/TargetOperationInfo.hh"

#include <iostream>
#include <string>
#include <memory>

namespace Json { class Value; }

namespace ES_SIMD {
  class SimProcessorBase;
  class TargetASMParser;
  class TargetBinaryProgram;
  class TargetInstruction;
  class SIRInstruction;
  class SIRValue;

  class TargetBasicInfo : NonCopyable {
    std::string targetName_; // Name of the target architecture
    unsigned instrPacketSize_;   // Maximum #instructions in a packet
    unsigned branchDelaySlots_;
    StrSet illegalASMLabels_;
  protected:
    bool configValid_;
    std::tr1::unordered_map<
      SIROpcode_t, TargetOpcode_t> opTranslation_;

    // Architecture parameters
    std::vector<TargetRegisterFile>  registerFiles_;///< RF parameters
    std::vector<TargetRegisterFile>  predicates_;///< Predicate register files
    std::vector<int> dataWidth_;///< Data-width of different datapaths
    std::vector<int> stages_;   ///< Number of stages of different datapaths
    std::vector<int> numFUs_;   ///< Number of FUs of different datapaths
    BitVector explicitBypass_;  ///< Whether each datapath uses explicit bypassing
    BitVector interlock_;       ///< Whether each datapath has interlock
    std::vector<UIntVector2D> fuOutputMap_;///<< Mapping of FU output to index
    //// Memory parameters
    std::vector<size_t> instMemDepth_; ///< Size of instruction memories
    std::vector<size_t> dataMemDepth_; ///< Size of data memories
    //// Control related parameters
    std::vector<int> instrWidth_;///< Instruction width
    std::vector<TargetOperationInfo> operations_; ///< Operation info
  public:
    TargetBasicInfo() : targetName_("unknown"), instrPacketSize_(0),
                        configValid_(false) {}
    TargetBasicInfo(const std::string& name, int packetSize)
      : targetName_(name), instrPacketSize_(packetSize), branchDelaySlots_(0),
      configValid_(true) {}
    virtual ~TargetBasicInfo();
    const std::string& GetName()   const { return targetName_; }
    unsigned GetInstructionPacketSize() const { return instrPacketSize_;  }
    unsigned GetNumOfBranchDelaySlots() const   { return branchDelaySlots_; }
    int      GetInstructionWidth(unsigned i) const {
      return (i < instrWidth_.size()) ? instrWidth_[i] : 0;
    }
    int GetDataWidth(unsigned i) const {
      return (i < dataWidth_.size()) ? dataWidth_[i] : 0;
    }
    int GetNumFU(unsigned i) const {
      return (i < numFUs_.size()) ? numFUs_[i] : 0;
    }
    /// \brief Get the corresponding constant value of a SIRValue.
    ///
    /// \return If v is a constant immediate, it just return its value.
    /// If v corresponds to a target-specific constant (e.g., NUMPE), it will
    /// return the value. Otherwise it returns 0.
    virtual int GetTargetConstant (const SIRValue* v) const = 0;
    virtual unsigned GetOperationLatency(const SIRInstruction* instr) const;
    virtual int GetOperationBinding(const SIRInstruction* instr) const=0;
    virtual TargetOperand ParseTargetOperand(
      const std::string& str, const TargetInstruction* instr) const=0;
    /// \brief Get the latency between the issue of an instruction and the
    ///        time it can be accessed in the RF.
    virtual unsigned GetOperationWritebackDelay(
      const SIRInstruction* instr) const = 0;

    virtual bool StripOpcodeStr(std::string& ops) const;
    virtual std::ostream& PrintOperand(
      std::ostream& out, const TargetOperand& o, TargetInstrType_t t) const;
    virtual void InitCodeGenInfo();
    virtual void InitDefaultOperationInfo();
    virtual void InitSimulationInfo();
    virtual bool ValidateTarget() const;
    virtual bool SetTargetParam(const std::string& key,
                                const std::string& val);
    /// \brief The binary code of the target instruction is stored
    ///        in an array of 32-bit integer, word order is LITTLE-ENDIAN
    /// \param instr pointer to instruction to be encoded
    /// \param code reference to the code store
    /// \return false if there is any error, otherwise true
    virtual bool EncodeInstruction(const TargetInstruction* instr,
                                   UInt32Vector& code) const = 0;
    virtual bool DecodeInstruction(TargetInstruction* instr,
                                   const UInt32Vector& code) const = 0;
    /// \brief The interface to query on the cost of the immediate in the
    ///        IR instruction on this target.
    ///
    /// The default implementation assumes that any immediate will fit. If this
    /// is no the case, the target should implement it.
    /// \param The instruction.
    /// \param If there is no immediate operand or the immediate can be encoded
    ///        without any extra cost, it returns 0. Otherwise, it returns the
    ///        estimated number of extra target instructions required without
    ///        storing the immediate to memory.
    virtual int InstrImmediateCost(const SIRInstruction* i) const { return 0; }
    /// \brief The threshold when an immediate should be promote to memory.
    /// \return The return value should be normalized to the value returned by
    ///         InstrImmediateCost. The default implementation return 1.0.
    virtual float ImmediatePromoteThreshold() const { return 1.0f; }
    virtual SIRDataType_t GetConstantPoolDataType() const {
      return SIRDataType::Int32;
    }

    virtual TargetBinaryProgram* CreateBinaryProgram(
      int id, const std::string& name) const;
  protected:
    virtual void InitTimingInfo();
    void InitDefaultOpTranslation();
    void SetBranchDelaySlot(int bd) { branchDelaySlots_ = bd; }
  };// class TargetBasicInfo

  template <typename T>
  TargetBasicInfo* CreateTargetFromCfg(const Json::Value& cfg) {
    return new T(cfg);
  }
  template <typename T> TargetBasicInfo* CreateTarget() { return new T; }

  /// \brief Factory class for TargetBasicInfo
  class TargetBasicInfoFactory {
  public:
    typedef std::pair<TargetBasicInfo*(*)(const Json::Value&),  \
                      TargetBasicInfo*(*)()> TargetCreator;
    typedef std::map<std::string, TargetCreator> TargetCreatorMap;
    /// \brief Get TargetBasicInfo from architecture name
    /// \param name a valid built-in target architecture name
    /// \return a pointer to the generated TargetBasicInfo for the target.
    ///         NULL if there is any error
    static TargetBasicInfo* GetTargetBasicInfo(const std::string& name) {
      TargetCreatorMap* m = GetMap();
      TargetCreatorMap::iterator it = m->find(name);
      return (it == m->end()) ? NULL : it->second.second();
    }
    /// \brief Get TargetBasicInfo from a configuration
    /// \param cfg JSON value of a valid target configuration
    /// \return a pointer to the generated TargetBasicInfo for the target.
    ///         NULL if there is any error
    static TargetBasicInfo* GetTargetBasicInfo(const Json::Value& cfg);

    static TargetCreatorMap* GetMap() {
      if (!map_.get()) { map_.reset(new TargetCreatorMap); }
      return map_.get();
    }
  private:
    static std::auto_ptr<TargetCreatorMap> map_;
  };// class TargetBasicInfoFactory

  template <typename T>
  class RegisterTargetBasicInfo : public TargetBasicInfoFactory {
  public:
    RegisterTargetBasicInfo(const std::string name) {
      (*GetMap())[name]=std::make_pair(CreateTargetFromCfg<T>, CreateTarget<T>);
    }
  };
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETBASICINFO_HH
