#ifndef ES_SIMD_SIREXPR_HH
#define ES_SIMD_SIREXPR_HH

#include "DataTypes/SIROpcode.hh"

namespace ES_SIMD {
  class SIRValue;
  class SIRModule;

  /// \brief Binary expression class in SIR.
  ///
  /// A SIR binary expression is basically a binary tree. Each node belongs to
  /// an SIRModule, which takes care of the memory management. So there is no
  /// need to delete a node explicitly.
  class SIRBinExprNode {
    SIRValue* value_;
    // Tree structure
    SIRBinExprNode* lhs_;
    SIRBinExprNode* rhs_;
    SIRBinExprNode* parent_;
    SIROpcode_t opcode_;
    SIRModule*  module_;
    SIRBinExprNode(SIRModule* m, SIROpcode_t opc = SIROpcode::NOP)
      : value_(NULL), lhs_(NULL), rhs_(NULL), parent_(NULL),
        opcode_(opc), module_(m) {}
    SIRBinExprNode(SIRModule* m, SIROpcode_t opc, SIRBinExprNode* lhs,
                     SIRBinExprNode* rhs, SIRValue* val = NULL)
      : value_(val), lhs_(lhs), rhs_(rhs), parent_(NULL),
        opcode_(opc), module_(m) {
      if (lhs) { lhs->parent_ = this; }
      if (rhs) { rhs->parent_ = this; }
    }
    SIRBinExprNode(SIRValue* val, SIROpcode_t opc = SIROpcode::NOP);

    SIRBinExprNode(const SIRBinExprNode& t);
  public:
    /// \defgroup SIRBinExprFactory SIR binary expression factory methods
    /// @{
    /// \brief Create the binary expression of an SIR value.
    static SIRBinExprNode* CreateBinExprNode(SIRValue* val);
    /// \brief Create a binary expression with given details.
    static SIRBinExprNode* CreateBinExprNode(
      SIRModule* m, SIROpcode_t opc, SIRBinExprNode* lhs, SIRBinExprNode* rhs,
      SIRValue* val = NULL);
    /// \brief Copy a binary expression.
    static SIRBinExprNode* CreateBinExprNode(SIRBinExprNode* e);
    /// @}
    static void SetSIRBinExprNode(
      SIRBinExprNode* root, SIRBinExprNode* lhs, SIRBinExprNode* rhs);

    friend std::ostream& operator<<(std::ostream& o, const SIRBinExprNode& t);

    SIRBinExprNode& operator=(const SIRBinExprNode& t);
    ~SIRBinExprNode();
    bool Valid() const;
    SIRModule* GetModule() const { return module_; }

    std::ostream& Print(std::ostream& o) const;
    std::string GetString() const;

    template<typename F> void VisitNodesPreOrder(F& f) {
      f(this);
      if (lhs_) { lhs_->VisitNodesPreOrder(f); }
      if (rhs_) { rhs_->VisitNodesPreOrder(f); }
    }
    template<typename F> void VisitNodesPostOrder(F& f) {
      if (lhs_) { lhs_->VisitNodesPostOrder(f); }
      if (rhs_) { rhs_->VisitNodesPostOrder(f); }
      f(this);
    }
    template<typename F> void VisitNodesInOrder(F& f) {
      if (lhs_) { lhs_->VisitNodesInOrder(f); }
      f(this);
      if (rhs_) { rhs_->VisitNodesInOrder(f); }
    }
    template<typename F> void VisitNodesPreOrder(F& f) const {
      f(this);
      if (lhs_) { lhs_->VisitNodesPreOrder(f); }
      if (rhs_) { rhs_->VisitNodesPreOrder(f); }
    }
    template<typename F> void VisitNodesPostOrder(F& f) const {
      if (lhs_) { lhs_->VisitNodesPostOrder(f); }
      if (rhs_) { rhs_->VisitNodesPostOrder(f); }
      f(this);
    }
    template<typename F> void VisitNodesInOrder(F& f) const {
      if (lhs_) { lhs_->VisitNodesInOrder(f); }
      f(this);
      if (rhs_) { rhs_->VisitNodesInOrder(f); }
    }
    void SetNode(SIROpcode_t opc, SIRBinExprNode* lhs,
                 SIRBinExprNode* rhs, SIRValue* v = NULL);
    void SetValue(SIRValue* v) { SetNode(SIROpcode::NOP, NULL, NULL, v); }

    /// Tree structure interface
    SIRBinExprNode*  GetParent() const { return parent_; }
    SIRBinExprNode*  GetLHS() const { return lhs_; }
    SIRBinExprNode*  GetRHS() const { return rhs_; }
    SIRBinExprNode*& GetLHSRef()    { return lhs_; }
    SIRBinExprNode*& GetRHSRef()    { return rhs_; }

    /// Node properties
    SIRValue* GetValue() const { return value_; }
    SIROpcode_t GetOpcode() const { return opcode_; }
    bool ValueEqual(const SIRValue* v) const;
    bool ConstantEqual(int c) const;
    bool IsScalar() const;
    bool IsLeaf() const { return !lhs_ && !rhs_; }
    bool IsRoot() const { return !parent_; }
    bool IsConstant() const;
    /// \brief Get the constant value of this node.
    ///
    /// \return The constant value, if this is a constant node, otherwise 0.
    int  GetConstant() const;
    int  Height() const {
      if (IsLeaf()) { return 0; }
      int lh = lhs_ ? lhs_->Height() : 0;
      int rh = rhs_ ? rhs_->Height() : 0;
      return std::max(lh, rh) + 1;
    }
    bool HasOpcode(SIROpcode_t o) const {
      return (opcode_ == o) || (lhs_ && lhs_->HasOpcode(o))
        || (rhs_ && rhs_->HasOpcode(o));
    }
    /// \brief If an SIR value with given value ID is used in this expression.
    bool UsesValue(int val) const;
    /// \brief If an SIR value is used in this expression.
    bool UsesValue(SIRValue* val) const;
    /// \brief Check if this expression equals to t.
    ///
    /// At the moment it checks equality using the string representation.
    bool operator==(const SIRBinExprNode& t) const;
    /// \brief If an SIR value is used in the left child of this expression.
    bool UsedInLHS(SIRValue* val) const { return lhs_ && lhs_->UsesValue(val); }
    /// \brief If an SIR value is used in the right child of this expression.
    bool UsedInRHS(SIRValue* val) const { return rhs_ && rhs_->UsesValue(val); }
    bool IsChild(const SIRBinExprNode* t) const {
      if ((lhs_ == t) || (rhs_ == t)) { return true; }
      return (lhs_ && lhs_->IsChild(t)) || (rhs_ && rhs_->IsChild(t));
    }
    bool IsLeftChild(const SIRBinExprNode* t) const {
      return (lhs_ == t) || (lhs_ && lhs_->IsChild(t));
    }
    bool IsRightChild(const SIRBinExprNode* t) const {
      return (rhs_ == t) || (rhs_ && rhs_->IsChild(t));
    }

    /// \brief Try to simplify the expression.
    SIRBinExprNode* Simplify();

    // Static transformation methods
    static SIRBinExprNode* Commute(SIRBinExprNode* t);
    static SIRBinExprNode* RotateLeft (SIRBinExprNode* t);
    static SIRBinExprNode* RotateRight(SIRBinExprNode* t);
    static SIRBinExprNode* DistributeLeft (SIRBinExprNode* t);
    static SIRBinExprNode* DistributeRight(SIRBinExprNode* t);
    static SIRBinExprNode* ExtractLeft (SIRBinExprNode* t);
    static SIRBinExprNode* ExtractRight(SIRBinExprNode* t);
  };// class SIRBinExprNode
}// namespace ES_SIMD

namespace std {
  namespace tr1 {
    /// For now, simply use the expression string for hashing
    template <> struct hash<ES_SIMD::SIRBinExprNode*> {
      size_t operator()(const ES_SIMD::SIRBinExprNode* e) const {
        return hash<std::string>()(e->GetString());
      }
    };
  }// namespace tr1
  template <> struct equal_to<ES_SIMD::SIRBinExprNode*> {
    bool operator()(const ES_SIMD::SIRBinExprNode* x,
                    const ES_SIMD::SIRBinExprNode* y) const {
      return (x && y && (*x == *y)) || (!x && !y);
    }
  };
}// namespace std

#endif//ES_SIMD_SIREXPR_HH
