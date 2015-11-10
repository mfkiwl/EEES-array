#ifndef ES_SIMD_SIRBASICBLOCK_HH
#define ES_SIMD_SIRBASICBLOCK_HH

#include "SIR/SIRValue.hh"
#include "DataTypes/SIROpcode.hh"

namespace ES_SIMD {
  class SIRInstruction;
  class SIRFunction;
  class SIRRegister;
  class SIRLoop;
  class SIRBinExprNode;
  class TargetBlockData;

  /// \brief Class for basic blocks in SIR.
  ///
  /// An SIR basic block should belong to exactly one SIR function.
  /// It should end with at most one branch instruction. If there are
  /// more than one branch, the block should be splited.
  class SIRBasicBlock : public SIRValue {
    friend class SIRParser;
  private:
    int bbID_;            ///< Block ID inside the function.
    SIRFunction* parent_; ///< The function this block belongs to.
    std::list<SIRInstruction*> instrList_;
    /// CFG
    std::vector<SIRBasicBlock*> predecessors_;
    std::vector<SIRBasicBlock*> successors_;
    std::vector<SIRBasicBlock*> domChildren_; ///< Children in dominator tree
    std::vector<SIRBasicBlock*> pdomChildren_;///< Children in post-dominator tree
    SIRBasicBlock* domParent_; /// Parent in dominator tree
    SIRBasicBlock* pdomParent_;/// Parent in post-dominator tree

    /// Liveness
    std::list<SIRRegister*>     liveIns_;
    std::list<SIRRegister*>     liveOuts_;

    std::tr1::unordered_map<int, SIRRegister*> blockRegs_;
    std::vector<SIRValue*> blockPredicates_;
    bool isEntryBlock_;
    bool isExitBlock_;
    bool hasBranch_;
    SIRLoop* lastLoop_;///<< the inner most loop this block belongs to
    TargetBlockData* targetData_;
  public:
    static std::string GetNormalizedBlockName(const SIRBasicBlock* bb);
    typedef std::list<SIRInstruction*> SIRInstructionList_t;
    typedef SIRInstructionList_t::iterator       iterator;
    typedef SIRInstructionList_t::const_iterator const_iterator;
    typedef SIRInstructionList_t::reverse_iterator       reverse_iterator;
    typedef SIRInstructionList_t::const_reverse_iterator const_reverse_iterator;

    typedef std::vector<SIRBasicBlock*>::iterator       pred_iterator;
    typedef std::vector<SIRBasicBlock*>::const_iterator pred_const_iterator;
    typedef std::vector<SIRBasicBlock*>::iterator       succ_iterator;
    typedef std::vector<SIRBasicBlock*>::const_iterator succ_const_iterator;
    typedef std::list<SIRRegister*>::iterator         li_iterator;
    typedef std::list<SIRRegister*>::const_iterator   li_const_iterator;
    typedef std::list<SIRRegister*>::iterator         lo_iterator;
    typedef std::list<SIRRegister*>::const_iterator   lo_const_iterator;

    typedef std::vector<SIRBasicBlock*>::iterator dom_iterator;
    typedef std::vector<SIRBasicBlock*>::iterator pdom_iterator;
    typedef std::vector<SIRBasicBlock*>::const_iterator dom_const_iterator;
    typedef std::vector<SIRBasicBlock*>::const_iterator pdom_const_iterator;


    SIRBasicBlock(int bid, SIRFunction* parent);
    virtual ~SIRBasicBlock();

    int GetBasicBlockID() const { return bbID_; }

    virtual bool EqualsTo(const SIRValue* v) const;

    SIRInstruction& BuildSIRInstr(SIRBasicBlock::iterator it, bool vect,
                                  SIROpcode_t opc, int value = -1,
                                  const std::string& name = "");

    SIRInstruction& BuildSIRInstr(SIRBasicBlock::iterator it, bool vect,
                                  SIRBinExprNode* expr);

    /// \brief Transfer an instruction of this block to another block.
    /// \param fIt The iterator of this block pointing to the instruction to
    ///            be transferred.
    /// \param tbb Target block.
    /// \param tIt Iterator of the target blokc pointing to the insert point.
    /// \return Iterator pointing to the next node in this block.
    iterator TransferTo(SIRBasicBlock::iterator fIt, SIRBasicBlock* tbb,
                        SIRBasicBlock::iterator tIt);
    /// \brief Replace the value use of an instruction with a given one.
    ///
    /// \param it Iterator pointing to the instruction to be replaced.
    /// \param repl The replacement instruction.
    /// \note If the replacement is in this block, the caller has to guarantee
    ///       that it is before the target instruction.
    void ReplaceInstrValue(SIRBasicBlock::iterator it, SIRInstruction* repl);

    void SetTargetData(TargetBlockData* td) { targetData_ = td;   }
    TargetBlockData* GetTargetData()  const { return targetData_; }

    SIRRegister* AddOrGetBlockRegister(int val, bool vect,
                                       const std::string& n = "");
    void AddBlockRegister(SIRRegister* r);
    void AddBlockPredicate(SIRValue* p);

    void AddLiveIn(SIRRegister* r);
    void AddLiveOut(SIRRegister* r);
    void AddLiveInValue (bool vector, const std::string& name, int v);
    void AddLiveOutValue(bool vector, const std::string& name, int v);
    SIRRegister* AddOrGetLiveIn (bool vector, int v);
    SIRRegister* AddOrGetLiveOut(bool vector, int v);
    bool IsValueLiveIn (int v) const;
    bool IsValueLiveOut(int v) const;
    bool InstrLiveOut(const SIRInstruction* instr) const;
    bool InstrLiveOut(const_iterator it) const;
    bool UsesValue(int v) const;

    SIRFunction* GetParent() const { return parent_; }

    void SetEntryBlock(bool e) { isEntryBlock_ = e;    }
    bool IsEntryBlock() const  { return isEntryBlock_; }
    void SetExitBlock(bool e)  { isExitBlock_ = e;     }
    bool IsExitBlock() const   { return isExitBlock_;  }
    bool InLoop() const { return lastLoop_ != NULL; }
    int  GetLoopDepth() const;
    SIRLoop* GetLoop() const { return lastLoop_; }
    void SetLoop(SIRLoop* lp);
    /// \brief Add a child of the dominator tree
    void AddIDomChild(SIRBasicBlock* b);
    /// \brief Add a child of the post-dominator tree
    void AddIPDomChild(SIRBasicBlock* b);
    /// \brief Check if b is immediately dominated by the current block.
    bool IsIDomChild (const SIRBasicBlock* b) const;
    /// \brief Check if b is immediately post-dominated by the current block.
    bool IsIPDomChild (const SIRBasicBlock* b) const;
    /// \breif Get the parent node in dominator tree of this block.
    SIRBasicBlock* GetDomTreeParent() const { return  domParent_; }
    int GetDomTreeDistance(const SIRBasicBlock* b) const;
    /// \breif Get the parent node int post-dominator tree of this block.
    SIRBasicBlock* GetPDomTreeParent() const { return pdomParent_; }
    /// \brief Check if b is dominated by the current block
    ///
    /// This method recursively checks if b is dominated by this block.
    /// \param b The block to be checked.
    /// \return Return true if b is dominated by this block, otherwise false.
    bool Dominates(const SIRBasicBlock* b) const;
    /// \brief Check if b is post-dominated by the current block
    ///
    /// This method recursively checks if b is post-dominated by this block.
    /// \param b The block to be checked.
    /// \return Return true if b is post-dominated by this block,
    ///         otherwise false.
    bool PostDominates(const SIRBasicBlock* b) const;
    bool HasBranch() const { return hasBranch_; }
    /// \brief Check if b is a successor of this block.
    bool IsSuccessor(const SIRBasicBlock* b) const;
    /// \brief Check if b is a predecessor of this block;
    bool IsPredecessor(const SIRBasicBlock* b) const;
    void ChangePredecessor(SIRBasicBlock* oldPred, SIRBasicBlock* newPred);
    void ChangeSuccessor(SIRBasicBlock* oldSucc, SIRBasicBlock* newSucc);
    /// \brief Split the block into two.
    ///
    /// This function creates a new block that directly follows the curent
    /// block. The instruction from (including) the split point till the end
    /// are transfrred to the new block.
    /// \param it The iterator pointing to the split point.
    /// \return The newly created block.
    SIRBasicBlock* SplitBlock(SIRBasicBlock::iterator it);

    // Printing functions
    virtual std::ostream& Print(std::ostream& o) const;
    virtual std::ostream& SIRPrettyPrint(std::ostream& o) const;
    virtual std::ostream& TargetPrettyPrint(std::ostream& o) const;
    virtual std::ostream& ValuePrint(std::ostream& o) const;
    virtual void Dump(Json::Value& info) const;
    void PrintTargetStat(std::ostream& o) const;

    // For LLVM-style RTTI
    static bool classof(const SIRValue *v) {
      return v->getKind() == VK_BasicBlock;
    }

    /// Container interface and iterators
    bool   empty()  const { return instrList_.empty(); }
    size_t size()   const { return instrList_.size();  }
    void push_back(SIRInstruction* instr);
    iterator insert(iterator it, SIRInstruction* instr);
    iterator erase(iterator pos);
    iterator find(iterator first, iterator last, const SIRInstruction* instr) {
      return std::find(first, last, instr);
    }
    const_iterator find(const_iterator first, const_iterator last,
                        const SIRInstruction* instr) const {
      return std::find(first, last, instr);
    }
    SIRInstruction*& back() { return instrList_.back(); }
    iterator       begin()       { return instrList_.begin(); }
    const_iterator begin() const { return instrList_.begin(); }
    iterator       end()         { return instrList_.end();   }
    const_iterator end()   const { return instrList_.end();   }
    reverse_iterator       rbegin()       { return instrList_.rbegin(); }
    const_reverse_iterator rbegin() const { return instrList_.rbegin(); }
    reverse_iterator       rend()         { return instrList_.rend();   }
    const_reverse_iterator rend()   const { return instrList_.rend();   }

    bool   pred_empty()  const { return predecessors_.empty(); }
    size_t pred_size()   const { return predecessors_.size();  }
    void   pred_push_back(SIRBasicBlock* bb);
    void   pred_clear() { predecessors_.clear(); }
    void   pred_erase(SIRBasicBlock* bb);
    pred_iterator       pred_begin()       { return predecessors_.begin(); }
    pred_const_iterator pred_begin() const { return predecessors_.begin(); }
    pred_iterator       pred_end()         { return predecessors_.end();   }
    pred_const_iterator pred_end()   const { return predecessors_.end();   }

    bool   succ_empty()  const { return successors_.empty(); }
    size_t succ_size()   const { return successors_.size();  }
    void   succ_push_back(SIRBasicBlock* bb);
    void   succ_clear() { successors_.clear(); }
    void   succ_erase(SIRBasicBlock* bb);
    succ_iterator       succ_begin()       { return successors_.begin(); }
    succ_const_iterator succ_begin() const { return successors_.begin(); }
    succ_iterator       succ_end()         { return successors_.end();   }
    succ_const_iterator succ_end()   const { return successors_.end();   }

    void   li_clear()  { liveIns_.clear(); }
    bool   li_empty()  const { return liveIns_.empty(); }
    size_t li_size()   const { return liveIns_.size();  }
    li_iterator       li_begin()       { return liveIns_.begin(); }
    li_const_iterator li_begin() const { return liveIns_.begin(); }
    li_iterator       li_end()         { return liveIns_.end();   }
    li_const_iterator li_end()   const { return liveIns_.end();   }

    void   lo_clear()  { liveOuts_.clear(); }
    bool   lo_empty()  const { return liveOuts_.empty(); }
    size_t lo_size()   const { return liveOuts_.size();  }
    lo_iterator       lo_begin()       { return liveOuts_.begin(); }
    lo_const_iterator lo_begin() const { return liveOuts_.begin(); }
    lo_iterator       lo_end()         { return liveOuts_.end();   }
    lo_const_iterator lo_end()   const { return liveOuts_.end();   }

    void   dom_clear() { domChildren_.clear(); }
    bool   dom_empty() { return domChildren_.empty(); }
    size_t dom_size()  { return domChildren_.size();  }
    dom_iterator       dom_begin()       { return domChildren_.begin(); }
    dom_const_iterator dom_begin() const { return domChildren_.begin(); }
    dom_iterator       dom_end()         { return domChildren_.begin(); }
    dom_const_iterator dom_end()   const { return domChildren_.begin(); }

    void   pdom_clear() { pdomChildren_.clear(); }
    bool   pdom_empty() { return pdomChildren_.empty(); }
    size_t pdom_size()  { return pdomChildren_.size();  }
    pdom_iterator       pdom_begin()       { return pdomChildren_.begin(); }
    pdom_const_iterator pdom_begin() const { return pdomChildren_.begin(); }
    pdom_iterator       pdom_end()         { return pdomChildren_.begin(); }
    pdom_const_iterator pdom_end()   const { return pdomChildren_.begin(); }
  };// class SIRBasicBlock
}// namespace ES_SIMD

#endif//ES_SIMD_SIRBASICBLOCK_HH
