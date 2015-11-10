#ifndef ES_SIMD_SIRFUNCTION_HH
#define ES_SIMD_SIRFUNCTION_HH

#include "SIR/SIRValue.hh"
#include "DataTypes/SIROpcode.hh"
#include "DataTypes/ContainerTypes.hh"
#include "DataTypes/FileLocation.hh"

namespace ES_SIMD {
  class SIRBasicBlock;
  class SIRLoop;
  class SIRModule;
  class SIRRegister;
  class SIRKernel;
  class TargetFuncData;
  class SIRFunction;
  class SIRInstruction;
  class SIRDataObject;

  class SIRCallSite {
    std::vector<SIRValue*> arguments_;
    SIRRegister* returnValue_;
    SIRInstruction* caller_;
    SIRFunction* callee_;
  public:
    typedef std::vector<SIRValue*>::iterator       arg_iterator;
    typedef std::vector<SIRValue*>::const_iterator arg_const_iterator;
    SIRCallSite(SIRInstruction* caller)
      : returnValue_(NULL), caller_(caller), callee_(NULL) {}
    SIRInstruction*       GetCallerInstr()       { return caller_; }
    const SIRInstruction* GetCallerInstr() const { return caller_; }

    void SetCallee(SIRFunction* callee) { callee_ = callee; }
    SIRFunction* GetCallee() const { return callee_; }

    bool HasReturnValue() const { return returnValue_ != NULL; }
    void SetReturnValue(SIRRegister* rv) { returnValue_ = rv; }
    SIRRegister* GetReturnValue() const { return returnValue_; }

    void SetArgument(unsigned i, SIRValue* arg) { arguments_[i] = arg; }
    /// \brief Replace argument value.
    /// \param The old argument value to be replaced.
    /// \param The new argument value.
    void ReplaceArgument(SIRValue* oldArg, SIRValue* newArg) {
      for (int i = 0, e=arguments_.size(); i < e; ++i) {
        if (arguments_[i] == oldArg) { arguments_[i] = newArg; }
      }
    }
    SIRValue* GetArgument(unsigned i) const { return arguments_[i]; }
    bool IsArgument(int v) const;
    bool IsArgument(const SIRValue* v) const;
    int  GetArgumentID(const SIRValue* v) const;

    void   arg_resize(size_t n) { arguments_.resize(n, NULL); }
    size_t arg_size()     const { return arguments_.size();  }
    bool   arg_empty()    const { return arguments_.empty(); }
    arg_iterator       arg_begin()       { return arguments_.begin(); }
    arg_iterator       arg_end()         { return arguments_.end();   }
    arg_const_iterator arg_begin() const { return arguments_.begin(); }
    arg_const_iterator arg_end()   const { return arguments_.end();   }
  };// struct SIRCallSite

  /// \brief Class for functions in SIR.
  class SIRFunction : public SIRValue {
    friend class SIRParser;
    /// \brief Re-construct the dominator tree.
    void UpdateDomTree();
    /// \brief Re-construct the post-dominator tree.
    void UpdatePostDomTree();
    /// \brief Detect all natural loops.
    void UpdateLoopInfo();
  private:
    FileLocation   fLoc_; ///< Location of the function label
    std::list<SIRBasicBlock*> basicBlockList_;
    std::list<SIRLoop*>       loopList_;
    SIRKernel*     solverKernel_;
    SIRModule*     parent_;
    SIRBasicBlock* entryBlock_;
    std::vector<SIRRegister*> arguments_;
    std::vector<SIRRegister*> returnValues_;
    SIRRegister* stackPointer_;
    SIRRegister* framePointer_;
    SIRRegister* globalPointer_;
    SIRRegister* linkRegister_;
    SIRRegister* zeroRegister_;
    SIRRegister* numPERegister_;
    SIRRegister* peIDRegister_;
    unsigned     valueCounter_;
    unsigned     flagCounter_;
    unsigned     basicBlockCounter_;
    int          numFormalArgs_;
    std::tr1::unordered_map<int, SIRBasicBlock*> blockMap_;
    std::vector<SIRValue*>    callees_;
    std::vector<SIRFunction*> callers_;
    std::vector<BitVector> memoryAliasTable_;
    unsigned sirStackOffset_;
    unsigned targetStackOffset_;
    Int2IntMap argAddrSpace_;
    TargetFuncData* targetData_;
    std::vector<SIRCallSite*> callSites_;
    std::vector<SIRDataObject*> dataObjects_;
    Int2IntMap constUserValue_;///< Map val ID to imm
  public:
    enum {
      ZERO_REG_VALUE  = 10000,
      PEID_REG_VALUE  = 10001,
      NUMPE_REG_VALUE = 10002,
      FLAG_VALUE_BASE = 100000
    };
    static bool IsValidValueID(int i) { return (i >=0)&&(i < FLAG_VALUE_BASE); }
    static bool IsValidFlagID(int i) { return (i >= FLAG_VALUE_BASE); }
    static bool IsGlobalStaticValue(int v) {
      return (v >= ZERO_REG_VALUE) && (v <= NUMPE_REG_VALUE);
    }
    typedef std::list<SIRBasicBlock*> SIRBasicBlockList_t;
    typedef SIRBasicBlockList_t::iterator               iterator;
    typedef SIRBasicBlockList_t::const_iterator         const_iterator;
    typedef SIRBasicBlockList_t::reverse_iterator       reverse_iterator;
    typedef SIRBasicBlockList_t::const_reverse_iterator const_reverse_iterator;
    typedef std::vector<SIRRegister*>::iterator       arg_iterator;
    typedef std::vector<SIRRegister*>::const_iterator arg_const_iterator;
    typedef std::vector<SIRRegister*>::iterator       ret_iterator;
    typedef std::vector<SIRRegister*>::const_iterator ret_const_iterator;
    typedef std::list<SIRLoop*>::iterator       loop_iterator;
    typedef std::list<SIRLoop*>::const_iterator loop_const_iterator;
    typedef std::vector<SIRCallSite*>::iterator       cs_iterator;
    typedef std::vector<SIRCallSite*>::const_iterator cs_const_iterator;
    typedef std::vector<SIRValue*>::iterator       callee_iterator;
    typedef std::vector<SIRValue*>::const_iterator callee_const_iterator;
    typedef std::vector<SIRDataObject*>::iterator  dobj_iterator;

    SIRFunction(const std::string& name, SIRModule* parent);
    virtual ~SIRFunction();

    bool IsSolverKernel() const { return solverKernel_; }
    void SetSolverKernel(SIRKernel* k);
    SIRKernel* GetSolverKernel() const { return solverKernel_; }

    /// \brief Eliminate dead instructions.
    void RemoveDeadValues();
    /// \brief Re-run liveness analysis.
    void UpdateLiveness();
    void UpdateRegValueType();
    void UpdateControlFlowInfo() {
      UpdateDomTree();
      UpdatePostDomTree();
      UpdateLoopInfo();
    }

    void SetTargetData(TargetFuncData* td) { targetData_ = td;   }
    TargetFuncData* GetTargetData()  const { return targetData_; }

    unsigned AllocateValue()      { return valueCounter_++;      }
    unsigned GetNumValues() const { return valueCounter_;        }
    unsigned AllocateFlag()       { return flagCounter_++;       }
    unsigned GetNumFlags()  const { return flagCounter_;         }
    unsigned GetNewBasicBlockID() { return basicBlockCounter_++; }

    void SetSIRStackOffset(unsigned o)    { sirStackOffset_ = o;       }
    unsigned GetSIRStackOffset()    const { return sirStackOffset_;    }
    unsigned GetTargetStackOffset() const { return targetStackOffset_; }
    void  SetTargetStackOffset(unsigned o) { targetStackOffset_ = o; }
    SIRBasicBlock* GetBasicBlock(int bid) const {
      std::tr1::unordered_map<int, SIRBasicBlock*>::const_iterator it
        = blockMap_.find(bid);
      return (it == blockMap_.end()) ? NULL : it->second;
    }
    int GetMaxBasicBlockID() const;

    const FileLocation& GetFileLocation() const { return fLoc_; }
    const std::vector<BitVector>& GetMemoryAliasTable() const {
      return memoryAliasTable_;
    }
    std::vector<BitVector>& GetMemoryAliasTable() { return memoryAliasTable_; }
    bool AliasTableValue(unsigned i, unsigned j) const {
      return memoryAliasTable_[i][j];
    }
    void AddMemoryAliasPair(SIRInstruction* a, SIRInstruction* b, bool alias);
    
    SIRModule* GetParent() const { return parent_; }

    void                   SetEntryBlock(SIRBasicBlock* bb);
    SIRBasicBlock* GetEntryBlock() const { return entryBlock_; }

    bool UsesFramePointer() const;
    bool UsesGlobalPointer() const;
    bool IsInvariant(const SIRValue* v) const;

    // Special registers
    SIRRegister* GetStackPointer()  const { return stackPointer_;  }
    SIRRegister* GetFramePointer()  const { return framePointer_;  }
    SIRRegister* GetGlobalPointer() const { return globalPointer_; }
    SIRRegister* GetLinkRegister()  const { return linkRegister_;  }
    SIRRegister* GetZeroRegister()  const { return zeroRegister_;  }
    SIRRegister* GetNumPERegister() const { return numPERegister_;  }
    SIRRegister* GetPEIDRegister()  const { return peIDRegister_;  }

    bool         IsSpecialRegister(int v) const;
    SIRRegister* GetSpecialRegister(const std::string& reg) const;

    // Return value
    SIRRegister* AddOrGetReturnValue(const std::string& rv);
    SIRRegister* GetReturnValue(const std::string& i);
    SIRRegister* GetReturnValue(unsigned i) const;

    // Argument
    SIRRegister* AddOrGetArgument(const std::string& name);
    SIRRegister* GetArgument(const std::string& name) const;
    SIRRegister* GetArgument(unsigned i) const {return arguments_[i];}
    SIRRegister* GetArgumentFromValue(int v) const;
    bool IsArgumentValue(int v) const;
    int  GetArgPointerAddrSpace(int v) const;
    int  GetNumFormalArguments() const { return numFormalArgs_; }

    // Call site
    SIRCallSite* AddOrGetCallSite(SIRInstruction* caller);
    SIRCallSite* GetCallSite(const SIRInstruction* caller) const;
    bool IsLeaf() const { return callees_.empty(); }
    void AddCallee(SIRFunction* f);

    // Loop
    SIRLoop* AddOrGetLoop(unsigned l);

    // Data object
    void AddDataObject(SIRDataObject* o);

    virtual std::ostream& SIRPrettyPrint(std::ostream& o) const;
    virtual std::ostream& TargetPrettyPrint(std::ostream& o) const;
    virtual std::ostream& ValuePrint(std::ostream& o) const;
    virtual void Dump(Json::Value& info) const;
    bool IsConstPoolUser(int v) const { return IsElementOf(v, constUserValue_); }
    int  GetConstPoolUserImm(int v) const {
      return IsElementOf(v, constUserValue_) ? GetValue(v, constUserValue_) : 0;
    }
    void AddConstPoolUser(int v, int imm) {
      if (IsValidValueID(v)) { constUserValue_[v] = imm; }
    }
    void PrintIRInfo(std::ostream& o) const;

    // For LLVM-style RTTI
    static bool classof(const SIRValue *v) {
      return v->getKind() == VK_Function;
    }
    /// Container interface and iterators
    bool   empty() const { return basicBlockList_.empty(); }
    size_t size()  const { return basicBlockList_.size();  }
    SIRBasicBlock*&       front()       { return basicBlockList_.front(); }
    SIRBasicBlock* const& front() const { return basicBlockList_.front(); }
    SIRBasicBlock*& back()              { return basicBlockList_.back();  }
    SIRBasicBlock* const& back()  const { return basicBlockList_.back();  }
    void   push_back (SIRBasicBlock* bb);
    void   push_front(SIRBasicBlock* bb);
    iterator insert(iterator it, SIRBasicBlock* bb);
    iterator       begin()       { return basicBlockList_.begin(); }
    const_iterator begin() const { return basicBlockList_.begin(); }
    iterator       end()         { return basicBlockList_.end();   }
    const_iterator end()   const { return basicBlockList_.end();   }
    reverse_iterator       rbegin()       { return basicBlockList_.rbegin(); }
    const_reverse_iterator rbegin() const { return basicBlockList_.rbegin(); }
    reverse_iterator       rend()         { return basicBlockList_.rend();   }
    const_reverse_iterator rend()   const { return basicBlockList_.rend();   }

    bool   arg_empty() const { return arguments_.empty(); }
    size_t arg_size()  const { return arguments_.size();  }
    arg_iterator       arg_begin()       { return arguments_.begin(); }
    arg_const_iterator arg_begin() const { return arguments_.begin(); }
    arg_iterator       arg_end()         { return arguments_.end();   }
    arg_const_iterator arg_end()   const { return arguments_.end();   }

    bool   ret_empty() const { return returnValues_.empty(); }
    size_t ret_size()  const { return returnValues_.size();  }
    ret_iterator       ret_begin()       { return returnValues_.begin(); }
    ret_const_iterator ret_begin() const { return returnValues_.begin(); }
    ret_iterator       ret_end()         { return returnValues_.end();   }
    ret_const_iterator ret_end()   const { return returnValues_.end();   }

    bool   loop_empty() const { return loopList_.empty(); }
    size_t loop_size()  const { return loopList_.size();  }
    void   loop_clear();
    loop_iterator       loop_begin()       { return loopList_.begin(); }
    loop_const_iterator loop_begin() const { return loopList_.begin(); }
    loop_iterator       loop_end()         { return loopList_.end();   }
    loop_const_iterator loop_end()   const { return loopList_.end();   }

    bool   cs_empty() const { return callSites_.empty(); }
    size_t cs_size()  const { return callSites_.size();  }
    cs_iterator       cs_begin()       { return callSites_.begin(); }
    cs_const_iterator cs_begin() const { return callSites_.begin(); }
    cs_iterator       cs_end()         { return callSites_.end();   }
    cs_const_iterator cs_end()   const { return callSites_.end();   }

    bool   caller_empty() const { return callers_.empty(); }
    size_t caller_size()  const { return callers_.size();  }

    bool  callee_empty() const { return callees_.empty(); }
    size_t callee_size() const { return callees_.size();  }
    callee_iterator callee_begin() { return callees_.begin(); }
    callee_iterator callee_end()   { return callees_.end();   }
    callee_const_iterator callee_begin() const { return callees_.begin(); }
    callee_const_iterator callee_end()   const { return callees_.end();   }

    dobj_iterator dobj_begin() { return dataObjects_.begin(); }
    dobj_iterator dobj_end()   { return dataObjects_.end(); }
  };// class SIRFunction

  void BuildLoopWithPreHeader(
    SIRBasicBlock*& preHeader, SIRBasicBlock*& hdr, SIRBasicBlock*& ext,
    SIRValue* loopBound, SIRValue* step, SIROpcode_t incOpcode,
    const std::list<SIRBasicBlock*>& loopBlocks, SIRBasicBlock* entryBlock,
    SIRBasicBlock* exitBlock, SIRFunction* func);
  void BuildEmptyLoop(
    SIRFunction::iterator insIt, SIRBasicBlock*& preHeader,
    SIRBasicBlock*& body, const std::vector<SIRBasicBlock*>& loopSuccs,
    SIRValue* bound, SIRValue* step, SIROpcode_t incOpcode, SIRFunction* func);
}// namespace ES_SIMD

#endif//ES_SIMD_SIRFUNCTION_HH
