#ifndef ES_SIMD_SIRMODULE_HH
#define ES_SIMD_SIRMODULE_HH

#include "DataTypes/Object.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/SIRDataType.hh"
#include <json/json.h>

namespace ES_SIMD {
  class SIRValue;
  class SIRFunction;
  class SIRConstant;
  class SIRDataObject;
  class SIRBinExprNode;
  class TargetModuleData;

  /// \brief Class for a basic compilation unit.
  ///
  /// Each invocation of the compiler should operate on one SIRModule. It holds
  /// all the information needed to generate a complete program for a specific
  /// target processor.
  class SIRModule : NonCopyable {
  private:
    std::string name_;
    TargetModuleData* targetData_;
    SIRFunction* entryFunction_;
    bool bare_;
    std::list<SIRFunction*> functionList_;
    std::list<SIRConstant*> constList_;
    std::map<std::string, SIRDataObject*> dataObjects_;

    std::map<int, SIRDataObject*> constantPool_;
    Int2IntMap constReloadCost_;

    std::tr1::unordered_map<int, SIRConstant*>      immediates_;
    std::tr1::unordered_set<std::string>            globalSymbols_;
    std::tr1::unordered_map<std::string, SIRValue*> symbols_;
    std::tr1::unordered_set<SIRFunction*> inactiveFuncs_;
    std::set<SIRBinExprNode*> binExprNodes_;
  public:
    typedef std::list<SIRFunction*> SIRFunctionList_t;
    typedef SIRFunctionList_t::iterator       iterator;
    typedef SIRFunctionList_t::const_iterator const_iterator;
    typedef std::list<SIRConstant*>::iterator       constant_iterator;
    typedef std::list<SIRConstant*>::const_iterator constant_const_iterator;
    typedef std::map<std::string, SIRDataObject*>::iterator dobj_iterator;
    typedef std::map<std::string, SIRDataObject*>::const_iterator
    dobj_const_iterator;

    static SIRModule* GetSIRModule(SIRValue* v);

    SIRModule();
    ~SIRModule();

    void AddBinExprNode(SIRBinExprNode* n) { binExprNodes_.insert(n); }
    void SetTargetData(TargetModuleData* td) { targetData_ = td; }
    TargetModuleData* GetTargetData() { return targetData_; }

    const std::string& GetName() const { return name_; }
    void SetName(const std::string& name) { name_ = name; }

    void SetBareModule(bool b) { bare_ = b;    }
    bool IsBareModule() const  { return bare_; }
    bool IsActiveFunction(const SIRFunction* f) const;
    bool HasVectorKernel() const;
    void AddFunction(SIRFunction* func);
    void SetEntryFunction(SIRModule::iterator i) {
      entryFunction_ = *i;
      functionList_.splice(functionList_.begin(), functionList_, i);
    }
    SIRFunction* GetEntryFunction() { return entryFunction_; }

    void AddGlobalSymbol(const std::string& s) { globalSymbols_.insert(s); }
    void AddSymbol(const std::string& sym, SIRValue* v) { symbols_[sym] = v; }
    /// Basically remove all non-global symbols
    void CleanupSymbols(std::tr1::unordered_set<std::string>& localSyms);

    void AddDataObject(SIRDataObject* dobj);
    SIRDataObject* GetDataObject(const std::string& s) {
      return IsElementOf(s, dataObjects_) ? GetValue(s, dataObjects_) : NULL;
    }

    bool HasSymbol(const std::string& sym) const {
      return symbols_.find(sym) != symbols_.end();
    }
    SIRValue* GetSymbolValue(const std::string& sym) {
      std::tr1::unordered_map<std::string, SIRValue*>::iterator it
        = symbols_.find(sym);
      return (it == symbols_.end()) ? NULL : it->second;
    }
    /// \breif Get or create the SIRConstant object for an immediate value.
    SIRConstant* AddOrGetImmediate(int imm);
    /// \breif Get or create the value object for a symbol.
    SIRValue*    AddOrGetSymbol(const std::string& s);
    /// \breif Get or create the memory data object for an immediate value.
    SIRDataObject* AddOrGetConstPoolValue(
      int imm, SIRDataType_t vType, int reloadCost);
    SIRDataObject* GetConstPoolObject(int imm) const;
    // SIRDataObject* GetConstObject(const SIRValue* v) const;
    int  GetConstReloadCost(int v) const {
      return IsElementOf(v,constReloadCost_) ? GetValue(v,constReloadCost_) : 0;
    }

    bool VerifyModule() const;

    void ValuePrint(std::ostream& o) const;
    void SIRPrettyPrint(std::ostream& o) const;
    void TargetPrettyPrint(std::ostream& o) const;
    void PrintCFG(std::ostream& o) const;
    void PrintSymbolTable(std::ostream& o) const;
    void Dump(Json::Value& mInfo) const;
    // Container interface and iterators
    bool   empty() const { return functionList_.empty(); }
    size_t size() const  { return functionList_.size();  }
    iterator       begin()       { return functionList_.begin(); }
    const_iterator begin() const { return functionList_.begin(); }
    iterator       end()         { return functionList_.end();   }
    const_iterator end() const   { return functionList_.end();   }
    void           remove(SIRFunction* func);

    bool   const_empty() const { return functionList_.empty(); }
    size_t const_size()  const { return functionList_.size();  }
    constant_iterator       const_begin()       { return constList_.begin(); }
    constant_const_iterator const_begin() const { return constList_.begin(); }
    constant_iterator       const_end()         { return constList_.end();   }
    constant_const_iterator const_end() const   { return constList_.end();   }

    bool dobj_empty() const { return dataObjects_.empty(); }
    bool dobj_size()  const { return dataObjects_.size(); }
    dobj_iterator       dobj_begin()       { return dataObjects_.begin(); }
    dobj_const_iterator dobj_begin() const { return dataObjects_.begin(); }
    dobj_iterator       dobj_end()         { return dataObjects_.end();   }
    dobj_const_iterator dobj_end()   const { return dataObjects_.end();   }
  };// class SIRModule
}// namespace ES_SIMD

#endif//ES_SIMD_SIRMODULE_HH
