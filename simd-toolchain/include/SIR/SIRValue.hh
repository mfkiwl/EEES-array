#ifndef ES_SIMD_SIRVALUE_HH
#define ES_SIMD_SIRVALUE_HH

#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/SIRDataType.hh"
#include <json/json.h>

namespace ES_SIMD {
  /// \brief Abstract base class of most IR program object classes.
  ///
  /// This class supports LLVM style RTTI. A few things should be noted:
  /// - Each SIRValue object has a unique identifier (UID).
  /// - Each object is responsible for managing resources of its "children".
  /// - If a non-constant SIRValue can be used (e.g., an  instruction with
  ///   output), it has a value ID that is >= 0.
  class SIRValue : NonCopyable {
    friend std::ostream& operator<<(std::ostream& o, const SIRValue& v);
  public:
    typedef std::tr1::unordered_set<SIRValue*> UseSet;
    typedef UseSet::iterator       use_iterator;
    typedef UseSet::const_iterator use_const_iterator;
    /// Discriminator for LLVM-style RTTI (dyn_cast<> et al.)
    enum ValueKind {
      VK_BasicBlock,
      VK_Constant,
      VK_Register,
      VK_DataObject,
      VK_Function,
      VK_Loop,
      VK_Instruction,
      VK_Kernel
    };
  private:
    const ValueKind kind_;
  public:
    ValueKind getKind() const { return kind_; }
    const std::string getKindName() const {
      switch (kind_) {
      default: return "Value";
      case VK_BasicBlock: return "BasicBlock";
      case VK_Constant:   return "Constant";
      case VK_Register:   return "Register";
      case VK_Function:   return "Function";
      case VK_Loop:       return "Loop";
      case VK_Instruction:return "Instruction";
      case VK_DataObject: return "DataObject";
      case VK_Kernel:     return "Kernel";
      }
    }
  private:
    static int ValueCounter;
    int uid_;
    std::set<SIRValue*> children_;
  protected:
    std::string name_;
    std::string info_;
    int valueID_;
    SIRDataType_t dataType_;
    std::tr1::unordered_set<SIRValue*> useSet_;
  public:
    virtual ~SIRValue();

    void SetDataType(SIRDataType_t t) { dataType_ = t;    }
    SIRDataType_t GetDataType() const { return dataType_; }
    /// \brief Get the unique identifier.
    int GetUID()     const { return uid_; }
    /// \brief Set the value ID.
    void SetValueID(int v) { valueID_ = v; }
    /// \brief Get the value ID.
    int  GetValueID() const { return valueID_; }
    /// \brief Check if the value is a vector value.
    bool IsVectorValue() const;
    /// \brief Set the value name.
    ///
    /// The value name may affect the output of the value. Otherthan that
    /// it has no real impact on the behavior.
    void SetName(const std::string& name) { name_ = name; }
    /// \brief Check if the value has name.
    bool               HasName() const { return !name_.empty(); }
    /// \brief Get the value name.
    const std::string& GetName() const { return name_;         }
    /// \brief Set the value information string.
    ///
    /// The information string is any string attached to the value. It should
    /// have no impact on the behavior of the value.
    /// The typical usage is for attaching comment for the value.
    void SetInfo(const std::string& info) { info_ = info; }
    /// \brief Check if the value has name.
    bool               HasInfo() const { return !info_.empty(); }
    /// \brief Get the value name.
    const std::string& GetInfo() const { return info_;         }
    /// \brief Check if v has the same *valid* value ID
    ///
    /// This function only checks the value of v if this value has a valid
    /// value ID(>=0).
    /// \param v The value to compare to.
    /// \return Whether v and this value have the same *valid* value ID.
    bool ValueEqual(const SIRValue* v) const {
      return v && (valueID_ >= 0) && v->GetValueID() == valueID_;
    }

    /// \brief Add a value to the children list.
    void AddManagedValue(SIRValue* v)    { AddChild(v);    }
    /// \brief Remove a value from the children list.
    void RemoveManagedValue(SIRValue* v) { RemoveChild(v); }
    /// \brief Add a value to the use list.
    void AddUse(SIRValue* u) { useSet_.insert(u); }
    /// \brief Remove a value from the use list.
    void RemoveUse(SIRValue* u) { useSet_.erase(u); }
    /// \brief Check how many user are there.
    /// \note  A user may use the value for multiple times.
    unsigned UserCount() const { return useSet_.size(); }
    bool UsedByValue(const SIRValue* u) const {
      return IsElementOf(const_cast<SIRValue*>(u), useSet_);
    }

    /// \brief Check if two values are equal.
    ///
    /// It is basically the same as ValueEqual(). The only exception is that
    /// if v is a move instruction, it checks whether the source of the move
    /// equals to this value.
    /// Drived class can override the behavior.
    /// \param v The value to compare to.
    /// \return Whether v and this value is equal.
    virtual bool EqualsTo(const SIRValue* v) const;
    /// \brief Compare value. The same as EqualsTo().
    bool operator==(const SIRValue& v) const { return EqualsTo(&v); }

    virtual std::ostream& Print(std::ostream& out) const;
    virtual std::ostream& SIRPrettyPrint(std::ostream& out) const;
    virtual std::ostream& TargetPrettyPrint(std::ostream& out) const;
    virtual std::ostream& ValuePrint(std::ostream& o) const;
    virtual std::ostream& PrintValueTree(
      std::ostream& o, const std::string& p) const;

    /// \brief Serialize an SIRValue to a JSON value
    virtual void Dump(Json::Value& val) const;

    bool   use_empty() const { return useSet_.empty(); }
    size_t use_size()  const { return useSet_.size();  }
    use_iterator       use_begin()       { return useSet_.begin(); }
    use_const_iterator use_begin() const { return useSet_.begin(); }
    use_iterator       use_end()         { return useSet_.end();   }
    use_const_iterator use_end()   const { return useSet_.end();   }
  protected:
    SIRValue(ValueKind k)
      : kind_(k), uid_(SIRValue::ValueCounter++), valueID_(-1),
        dataType_(SIRDataType::Unknown) {}
    SIRValue(const char* name, ValueKind k)
      : kind_(k), uid_(SIRValue::ValueCounter++), name_(name), valueID_(-1),
        dataType_(SIRDataType::Unknown) {}
    SIRValue(const std::string& name, ValueKind k)
      : kind_(k), uid_(SIRValue::ValueCounter++), name_(name), valueID_(-1),
        dataType_(SIRDataType::Unknown) {}
    void AddChild(SIRValue* v);
    void RemoveChild(SIRValue* v) { children_.erase(v); }
  };// class SIRValue

  /// \brief push_back with check to avoid duplicate UID.
  void push_back_uid(std::vector<SIRValue*>& cont, SIRValue* val);
  /// \brief push_back with check to avoid duplicate ValueID.
  void push_back_uval(std::vector<SIRValue*>& cont, SIRValue* val);
}// namespace ES_SIMD

#endif//ES_SIMD_SIRVALUE_HH
