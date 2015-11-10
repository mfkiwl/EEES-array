#ifndef ES_SIMD_TARGETOPERATION_INFO
#define ES_SIMD_TARGETOPERATION_INFO

#include "DataTypes/TargetOpcode.hh"
#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"

namespace ES_SIMD {
  class TargetOperationInfo {
    std::tr1::unordered_set<TargetOpcode_t> validOps_;
    std::tr1::unordered_map<TargetOpcode_t, uint32_t> opEncode_;
    std::tr1::unordered_map<TargetOpcode_t, unsigned> opLatency_;
    std::tr1::unordered_map<TargetOpcode_t, unsigned> opBinding_;
    std::tr1::unordered_map<uint32_t, TargetOpcode_t> opDecode_;
    std::tr1::unordered_map<uint32_t, TargetOpcode_t> ctrlDecode_;
  public:
    enum {INVALID_BINDING=0xFFFF};
    // Initialization interface
    void AddOperation(TargetOpcode_t opc, unsigned binOpc,
                      int binding, unsigned lat, bool encodeOnly = false);
    void AddControlOperation(TargetOpcode_t opc, unsigned binOpc, unsigned lat);
    void AddOperationBinding(TargetOpcode_t opc, unsigned b, unsigned lat) {
      opBinding_[opc] = b;
      opLatency_[opc] = lat;
    }
    void AddCodeGenOpcode(TargetOpcode_t opc) {
      validOps_.insert(opc);
    }
    
    bool AllOperationsValid() const;

    // Query interface
    bool HasValidOp() const { return !validOps_.empty(); }
    bool IsValidOp(TargetOpcode_t opc) const {
      return IsElementOf(opc, validOps_);
    }
    bool IsValidOp(const std::string& ops) const {
      return IsElementOf(GetTargetOpcode(ops), validOps_);
    }

    uint32_t GetBinaryCode(TargetOpcode_t opc) const {
      return IsElementOf(opc, opEncode_) ? GetValue(opc, opEncode_) : 0;
    }
    TargetOpcode_t DecodeControlOp(uint32_t opc) const {
      return IsElementOf(opc, ctrlDecode_) ?
        GetValue(opc, ctrlDecode_) : TargetOpcode::TargetOpcodeEnd;
    }
    TargetOpcode_t DecodeOperation(uint32_t opc) const {
      return IsElementOf(opc, opDecode_) ?
        GetValue(opc, opDecode_) : TargetOpcode::TargetOpcodeEnd;
    }
    unsigned GetOpLatency(TargetOpcode_t opc) const {
      return IsElementOf(opc, opLatency_) ? GetValue(opc, opLatency_) : 0;
    }
    unsigned GetOpBinding(TargetOpcode_t opc) const {
      return IsElementOf(opc, opBinding_) ?
        GetValue(opc, opBinding_) : INVALID_BINDING;
    }
  };// class TargetOperationInfo
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETOPERATION_INFO
