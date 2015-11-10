#ifndef ES_SIMD_TARGETISSUEPACKET_HH
#define ES_SIMD_TARGETISSUEPACKET_HH

#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/Object.hh"
#include <json/json.h>

namespace ES_SIMD {
  class SIRValue;
  class SIRInstruction;

  class TargetIssuePacket :NonCopyable {
    int issueTime_;
    std::vector<SIRInstruction*> instrs_;
  public:
    typedef std::vector<SIRInstruction*>::iterator       iterator;
    typedef std::vector<SIRInstruction*>::const_iterator const_iterator;
    TargetIssuePacket(int size) : issueTime_(-1), instrs_(size, NULL) {}
    TargetIssuePacket(int t, int size) : issueTime_(t), instrs_(size, NULL) {}

    void SetIssueTime(int t);
    void SetInstr(SIRInstruction* instr, unsigned i) { instrs_[i] = instr; }
    SIRInstruction* GetInstruction(unsigned i) const { return instrs_[i];  }
    int GetIssueID(const SIRInstruction* instr) const;
    void RemoveInstr(SIRInstruction* instr);

    bool IsNOP() const;
    bool HasCall() const;
    bool HasBranch() const;
    int  IssueTime() const { return issueTime_; }
    bool UsesValue(int v) const;
    int  ValueUseCount(int v) const;
    bool DefinesValue(int v) const;
    bool ReplaceOperandValue(SIRValue* val);
    SIRInstruction* GetValueInstr(int v) const;

    SIRInstruction* GetInstr(unsigned idx) const { return instrs_[idx]; }
    void Print(std::ostream& o) const;
    void ValuePrint(std::ostream& o) const;
    void Dump(Json::Value& pInfo) const;

    SIRInstruction*&       operator[](size_t i)       { return instrs_[i]; }
    SIRInstruction* const& operator[](size_t i) const { return instrs_[i]; }
    size_t size()  const { return instrs_.size();  }
    bool   empty() const { return instrs_.empty(); }
    iterator       begin()       { return instrs_.begin(); }
    const_iterator begin() const { return instrs_.begin(); }
    iterator       end()         { return instrs_.end();   }
    const_iterator end()   const { return instrs_.end();   }
  };// struct TargetIssuePacket
}

#endif//ES_SIMD_TARGETISSUEPACKET_HH
