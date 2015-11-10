#ifndef ES_SIMD_SIRDATAOBJECT_HH
#define ES_SIMD_SIRDATAOBJECT_HH

#include "SIR/SIRValue.hh"
#include "DataTypes/SIRDataType.hh"

namespace ES_SIMD {
  class SIRFunction;
  class SIRModule;
  class SIRValue;

  /// \brief A class that represents global data objects.
  class SIRDataObject : public SIRValue {
    friend class SIRParser;
  private:
    typedef std::pair<SIRDataType_t, int> InitEntry;
    SIRModule* parent_;               ///< Module that contains this object
    int  size_;                       ///< Size in bytes
    int  address_;                    ///< Address in memory
    int  addressSpace_;               ///< Address space ID
    bool isVector_;                   ///< Is data in vector memory
    bool zeroInit_;                   ///< Is initialized with zero (bss/sbss)
    std::vector<InitEntry> init_;     ///< Initial value
    std::vector<std::pair<std::string, SIRValue*> > initSym_;///< Symbol init
  public:
    typedef std::vector<std::pair<std::string,SIRValue*> >::iterator sym_iterator;
    SIRDataObject(const std::string& name, SIRModule* parent)
      : SIRValue(name, SIRValue::VK_DataObject), parent_(parent), size_(0),
        address_(-1), addressSpace_(0), isVector_(false), zeroInit_(false) {}
    virtual ~SIRDataObject();

    /// \brief Set object size.
    /// \param sz Size in bytes.
    void SetSize(int sz) { size_ = sz;   }
    /// \brief Get object size.
    /// \return Object size in bytes.
    int  GetSize() const { return size_; }

    void SetAddress(int addr) { address_ = addr; }
    int  GetAddress()   const { return address_; }

    void SetAddressSpace(int addrSpace) { addressSpace_ = addrSpace; }
    int  GetAddressSpace()        const { return addressSpace_;      }

    void SetVector(bool v = true) { isVector_ = v;    }
    bool IsVector()         const { return isVector_; }

    bool IsReferenced() const;

    void AddInit(SIRDataType_t t,int v) {init_.push_back(std::make_pair(t, v));}
    void AddInit(const std::string& s, SIRValue* v = NULL);

    SIRModule* GetParent() const { return parent_; }
    virtual std::ostream& Print(std::ostream& o) const;
    virtual std::ostream& ValuePrint(std::ostream& o) const;
    virtual std::ostream& TargetPrettyPrint(std::ostream& o) const;
    virtual void Dump(Json::Value& info) const;

    size_t       sym_size()  const { return initSym_.size();  }
    bool         sym_empty() const { return initSym_.empty(); }
    sym_iterator sym_begin() { return initSym_.begin(); }
    sym_iterator sym_end()   { return initSym_.end();   }

    // For LLVM-style RTTI
    static bool classof(const SIRValue *v) {
      return v->getKind() == VK_DataObject;
    }
  };// class SIRDataObject
}// namespace ES_SIMD

#endif//ES_SIMD_SIRDATAOBJECT_HH
