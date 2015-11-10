#ifndef ES_SIMD_TARGETINSTRUCTIONPACKET_HH
#define ES_SIMD_TARGETINSTRUCTIONPACKET_HH

#include <vector>
#include <string>
#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"

namespace ES_SIMD {
  class TargetInstruction;

  class TargetInstructionPacket : NonCopyable {
  public:
    typedef std::vector<TargetInstruction*>::iterator iterator;
    typedef std::vector<TargetInstruction*>::const_iterator const_iterator;
    typedef std::vector<TargetInstruction*>::reverse_iterator \
    reverse_iterator;
    typedef std::vector<TargetInstruction*>::const_reverse_iterator \
    const_reverse_iterator;

    TargetInstructionPacket() : id_(-1), address_(-1) {}
    virtual ~TargetInstructionPacket();

    virtual bool Valid() const;
    TargetInstructionPacket& SetAddress(int adr) {
      address_ = adr; return *this;
    }
    int  GetAddress()  const { return address_; }

    TargetInstructionPacket& SetIndex(int idx) {
      id_ = idx;
      return *this;
    }
    int  GetIndex()  const { return id_; }

    int  GetNumOfNonNOPInstr() const {
      int n = 0;
      for (unsigned i = 0; i < instrs_.size(); ++i) {
        if (instrs_[i] != NULL)
          ++n;
      }
      return n;
    }
    virtual std::ostream& Print(std::ostream& out) const;
    virtual std::ostream& PrintASM(std::ostream& out,
                                   const Int2StrMap& syms) const;

    TargetInstructionPacket& AppendInstruction(TargetInstruction* ti) {
      push_back(ti);
      return *this;
    }
    TargetInstruction* operator[](unsigned i) {
      return (i < instrs_.size()) ? instrs_[i] : NULL;
    }
    const TargetInstruction* operator[](unsigned i) const {
      return (i < instrs_.size()) ? instrs_[i] : NULL;
    }

    void push_back(TargetInstruction* ti) { instrs_.push_back(ti); }

    iterator begin() { return instrs_.begin(); }
    iterator end()   { return instrs_.end();   }
    const_iterator begin() const { return instrs_.begin(); }
    const_iterator end()   const { return instrs_.end();   }

    reverse_iterator rbegin() { return instrs_.rbegin(); }
    reverse_iterator rend()   { return instrs_.rend();   }
    const_reverse_iterator rbegin()const{return instrs_.rbegin();}
    const_reverse_iterator rend()  const{return instrs_.rend();  }
  protected:
    std::vector<TargetInstruction*> instrs_;
    int id_;
    int address_;
  };// class TargetInstructionPacket
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETINSTRUCTIONPACKET_HH
