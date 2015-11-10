#include "Target/TargetOperationInfo.hh"

using namespace std;
using namespace ES_SIMD;

void TargetOperationInfo::
AddOperation(TargetOpcode_t opc, unsigned binOpc,
             int binding, unsigned lat, bool encodeOnly) {
  validOps_.insert(opc);
  opEncode_[opc]    = binOpc;
  if (!encodeOnly) { opDecode_[binOpc] = opc; }
  opLatency_[opc]   = lat;
  if (binding >= 0) {opBinding_[opc] = static_cast<unsigned>(binding); }
}// AddOperation()

void TargetOperationInfo::
AddControlOperation(TargetOpcode_t opc, unsigned binOpc,
                    unsigned lat) {
  validOps_.insert(opc);
  opEncode_[opc]    = binOpc;
  ctrlDecode_[binOpc] = opc;
  opLatency_[opc]   = lat;
}// AddOperation()

bool TargetOperationInfo::
AllOperationsValid() const {
  for (tr1::unordered_set<TargetOpcode_t>::const_iterator it
         = validOps_.begin(); it != validOps_.end(); ++it) {
    if (*it >= TargetOpcode::TargetOpcodeEnd)
      return false;
  }
  return true;
}// AllOperationsValid()
