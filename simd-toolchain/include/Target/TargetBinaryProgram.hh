#ifndef ES_SIMD_TARGETBINARYPROGRAM_HH
#define ES_SIMD_TARGETBINARYPROGRAM_HH

#include <list>
#include <string>
#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/MemDataSection.hh"
#include "DataTypes/SIRDataType.hh"
#include "Target/TargetOperand.hh"
#include "Utils/FileUtils.hh"

namespace ES_SIMD {
  class TargetInstructionPacket;
  class TargetBinaryProgram : NonCopyable {
  protected:
    int  id_;
    std::string name_;
    int  symbolCounter_;
    std::list<TargetInstructionPacket*> binaryInstrs_;
    std::tr1::unordered_map<std::string, TargetSymbol> symbols_;
    Int2StrMap id2symbol_;
    std::tr1::unordered_map<int, IntSet> addr2SymID_;
    StrSet extSymbols_;

    int codeStartAddr_;
    std::vector<std::vector<MemDataSection> > data_;
  public:
    typedef std::list<TargetInstructionPacket*>::iterator iterator;
    typedef std::list<TargetInstructionPacket*>::const_iterator \
    const_iterator;
    typedef std::list<TargetInstructionPacket*>::reverse_iterator \
    reverse_iterator;
    typedef std::list<TargetInstructionPacket*>::const_reverse_iterator \
    const_reverse_iterator;

    TargetBinaryProgram(int id=-1, const std::string& name="unknown",
                        int numDataSec=1)
      : id_(id), name_(name), symbolCounter_(0), codeStartAddr_(0),
        data_(numDataSec) {}
    virtual ~TargetBinaryProgram();


    virtual bool Valid() const;

    TargetBinaryProgram& InsertASMLabel(const std::string& l) {
      if (!IsElementOf(l, symbols_)) {
        symbols_[l].id_      = symbolCounter_;
        symbols_[l].type_    = TargetSymbolType::TargetSymbolTypeEnd;
        symbols_[l].value_   = l;
        symbols_[l].address_ = -1;
        id2symbol_[symbolCounter_++] = l;
      }
      return *this;
    }
    TargetBinaryProgram& SetSymbol(
      const std::string& l, TargetSymbolType_t t, int adr) {
      symbols_[l].type_    = t;
      symbols_[l].value_   = l;
      symbols_[l].address_ = adr;
      if (adr >= 0) {
        addr2SymID_[adr].insert(symbols_[l].id_);
      }
      return *this;
    }

    const TargetSymbol& GetSymbol(int i) const {
      return symbols_.find(id2symbol_.find(i)->second)->second;
    }

    const TargetSymbol& GetSymbol(const std::string& s) const {
      return symbols_.find(s)->second;
    }

    int GetSymbolID(const std::string& s) const {
      return IsElementOf(s, symbols_) ? symbols_.find(s)->second.id_ : -1;
    }

    bool IsValidSymbol(const std::string& s) const {
      return IsElementOf(s, symbols_) || IsElementOf(s, extSymbols_);
    }

    /// \brief add data memory initialization item
    /// \param dSec Data section index.
    /// \param dt   data type
    /// \param addr target address
    /// \param val  actual value
    /// \return next available address
    virtual int AddDataInit(int dSec, SIRDataType_t dt, int addr, int val) {
      return 0;
    }

    virtual std::ostream& Print(std::ostream& out) const;
    virtual std::ostream& PrintASM(std::ostream& out) const;
    /// @brief save the program in Verilog memory initialization format
    /// @param filename output file name. When multiple files are created,
    ///                 this is used as the prefix
    /// @return file status
    virtual FileStatus_t SaveVerilogMemHex(
      const std::string& filename) const;

    virtual bool ResolveSymbols();
    virtual bool PrepBinary();

    void push_back(TargetInstructionPacket* tip) {
      binaryInstrs_.push_back(tip);
    }
    void push_front(TargetInstructionPacket* tip) {
      binaryInstrs_.push_front(tip);
    }

    iterator begin() { return binaryInstrs_.begin(); }
    iterator end()   { return binaryInstrs_.end();   }
    const_iterator begin() const { return binaryInstrs_.begin(); }
    const_iterator end()   const { return binaryInstrs_.end();   }

    reverse_iterator rbegin() { return binaryInstrs_.rbegin(); }
    reverse_iterator rend()   { return binaryInstrs_.rend();   }
    const_reverse_iterator rbegin()const{return binaryInstrs_.rbegin();}
    const_reverse_iterator rend()  const{return binaryInstrs_.rend();  }
  };// class TargetBinaryProgram
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETBINARYPROGRAM_HH
