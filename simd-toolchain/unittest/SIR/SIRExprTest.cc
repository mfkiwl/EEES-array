#include "SIR/SIRExpr.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "gtest/gtest.h"

using namespace ES_SIMD;

class SIRExprTest : public testing::Test {
protected:
  virtual void SetUp() {
    testModule = new SIRModule;
    testFunc   = new SIRFunction("test", testModule);
    testBB     = new SIRBasicBlock(0, testFunc);
    zero       = testModule->AddOrGetImmediate(0);
    one        = testModule->AddOrGetImmediate(1);
    testRegs.reserve(8);
    for (int i = 0; i < 8; ++i) {
      testRegs.push_back(new SIRRegister(false, "R", i, testFunc));
    }
    testInstrs.reserve(16);
    testInstrs.push_back(new SIRInstruction(SIROpcode::ADD, testBB, false));
    testInstrs[0]->AddOperand(testRegs[0])  .AddOperand(testRegs[1]);
    testInstrs.push_back(new SIRInstruction(SIROpcode::ADD, testBB, false));
    testInstrs[1]->AddOperand(testRegs[2])  .AddOperand(testInstrs[0]);
    testInstrs.push_back(new SIRInstruction(SIROpcode::MUL, testBB, false));
    testInstrs[2]->AddOperand(testInstrs[0]).AddOperand(testInstrs[1]);
    testInstrs.push_back(new SIRInstruction(SIROpcode::MUL, testBB, false));
    testInstrs[3]->AddOperand(testInstrs[2]).AddOperand(testInstrs[0]);
    testInstrs.push_back(new SIRInstruction(SIROpcode::SUB, testBB, false));
    testInstrs[4]->AddOperand(testRegs[0])  .AddOperand(testRegs[1]);
  }// SetUp()

  virtual void TearDown() {
    for (unsigned i = 0; i < testRegs.size()  ; ++i) { delete testRegs[i];   }
    for (unsigned i = 0; i < testInstrs.size(); ++i) { delete testInstrs[i]; }
    delete testModule;
  }// TearDown()

  void TestSimplify(SIROpcode_t opc, SIRValue* a, SIRValue* b, SIRValue* out) {
    SIRInstruction* TI = new SIRInstruction(opc, testBB, false);
    TI->AddOperand(a).AddOperand(b);
    SIRBinExprNode* t = SIRBinExprNode::CreateBinExprNode(TI);
    t->Simplify();
    TestNode(t, 0, SIROpcode::NOP, out);
    delete TI;
  }

  void TestNode(SIRBinExprNode* n, int h, SIROpcode_t opc,
                SIRValue* val) {
    ASSERT_EQ(n->GetModule(), testModule);
    ASSERT_TRUE(n != NULL);
    EXPECT_TRUE(n->Valid());
    EXPECT_EQ  (h  , n->Height());
    EXPECT_EQ  (opc, n->GetOpcode());
    EXPECT_EQ  (val, n->GetValue());
  }// TestNode()

  std::vector<SIRRegister*>    testRegs;
  std::vector<SIRInstruction*> testInstrs;
  SIRModule* testModule;
  SIRFunction* testFunc;
  SIRBasicBlock* testBB;
  SIRConstant* zero;
  SIRConstant* one;
};// class SIRExprTest

TEST_F(SIRExprTest, Basic) { 
  // A valid leaf
  SIRBinExprNode* e1 = SIRBinExprNode::CreateBinExprNode(testRegs[0]);
  TestNode(e1, 0, SIROpcode::NOP, testRegs[0]);
  EXPECT_EQ  (NULL, e1->GetLHS());
  EXPECT_EQ  (NULL, e1->GetRHS());
  EXPECT_TRUE(e1->IsLeaf());
  EXPECT_TRUE(e1->IsRoot());
}// TEST_F(SIRExprTest, Basic)

TEST_F(SIRExprTest, InstrCreate) {
  SIRBinExprNode* e0 = SIRBinExprNode::CreateBinExprNode(testInstrs[0]);
  SIRBinExprNode* e1 = SIRBinExprNode::CreateBinExprNode(testInstrs[1]);
  SIRBinExprNode* e2 = SIRBinExprNode::CreateBinExprNode(testInstrs[2]);
  SIRBinExprNode* e3 = SIRBinExprNode::CreateBinExprNode(testInstrs[3]);
  TestNode(e0, 1, SIROpcode::ADD, NULL);
  TestNode(e0->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(e0->GetRHS(), 0, SIROpcode::NOP, testRegs[1]);

  TestNode(e1, 2, SIROpcode::ADD, NULL);
  TestNode(e1->GetLHS(), 0, SIROpcode::NOP, testRegs[2]);
  TestNode(e1->GetRHS(), 1, SIROpcode::ADD, NULL);
  TestNode(e1->GetRHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(e1->GetRHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[1]);
  // Test operator==
  EXPECT_TRUE((e1->GetRHS() != e0) && (*e1->GetRHS() == *e0));

  TestNode(e2, 3, SIROpcode::MUL, NULL);
  TestNode(e2->GetLHS(), 1, SIROpcode::ADD, NULL);
  TestNode(e2->GetRHS(), 2, SIROpcode::ADD, NULL);
  EXPECT_TRUE(*e2->GetLHS() == *e0);
  EXPECT_TRUE(*e2->GetRHS() == *e1);

  TestNode(e3, 4, SIROpcode::MUL, NULL);
  TestNode(e3->GetLHS(), 3, SIROpcode::MUL, NULL);
  TestNode(e3->GetRHS(), 1, SIROpcode::ADD, NULL);
  EXPECT_TRUE(*e3->GetLHS() == *e2);
  EXPECT_TRUE(*e3->GetRHS() == *e0);
}// TEST_F(SIRExprTest, InstrCreate)

TEST_F(SIRExprTest, Simplify) {
  // A - A = 0
  SIRInstruction* TI = new SIRInstruction(SIROpcode::SUB, testBB, false);
  TI->AddOperand(testRegs[0]).AddOperand(testRegs[0]);
  SIRBinExprNode* t = SIRBinExprNode::CreateBinExprNode(TI);
  t->Simplify();
  TestNode(t, 0, SIROpcode::NOP, zero);
  delete TI;
  TestSimplify(SIROpcode::SUB, testRegs[0], testRegs[0], zero);       // A-A = 0
  TestSimplify(SIROpcode::SUB, testRegs[0], zero       , testRegs[0]);// A-0 = A
  TestSimplify(SIROpcode::ADD, testRegs[0], zero       , testRegs[0]);// A+0 = A
  TestSimplify(SIROpcode::ADD, zero       , testRegs[0], testRegs[0]);// 0+A = A
  TestSimplify(SIROpcode::MUL, testRegs[0], zero       , zero);       // A*0 = 0
  TestSimplify(SIROpcode::MUL, zero       , testRegs[0], zero);       // 0*A = 0
  TestSimplify(SIROpcode::MUL, testRegs[0], one        , testRegs[0]);// A*1 = A
  TestSimplify(SIROpcode::MUL, one        , testRegs[0], testRegs[0]);// 1*A = A

  TestSimplify(SIROpcode::ADD, zero, zero, zero);// 0+0 = 0
  TestSimplify(SIROpcode::ADD, zero, one,  one); // 0+1 = 1
  TestSimplify(SIROpcode::ADD, one,  one,
               testModule->AddOrGetImmediate(2));// 1+1 = 2
  TestSimplify(SIROpcode::MUL, testModule->AddOrGetImmediate(2),
               testModule->AddOrGetImmediate(3),
               testModule->AddOrGetImmediate(6));// 2*3 = 6
  TestSimplify(SIROpcode::DIV, testModule->AddOrGetImmediate(15),
               testModule->AddOrGetImmediate(5),
               testModule->AddOrGetImmediate(3));// 15/5 = 3
  // 15 / 5 = 3
  TI = new SIRInstruction(SIROpcode::DIV, testBB, false);
  TI->AddOperand(testModule->AddOrGetImmediate(15))
    .AddOperand(testModule->AddOrGetImmediate(5));
  t = SIRBinExprNode::CreateBinExprNode(TI);
  t->Simplify();
  TestNode(t, 0, SIROpcode::NOP, testModule->AddOrGetImmediate(3));
  delete TI;
}// TEST_F(SIRExprTest, Simplify)

TEST_F(SIRExprTest, Commute) {
  SIRBinExprNode* e0 = SIRBinExprNode::CreateBinExprNode(testInstrs[0]);
  SIRBinExprNode* ce0 = SIRBinExprNode::Commute(e0);
  EXPECT_EQ(ce0, e0);
  TestNode(ce0->GetLHS(), 0, SIROpcode::NOP, testRegs[1]);
  TestNode(ce0->GetRHS(), 0, SIROpcode::NOP, testRegs[0]);
  SIRBinExprNode* eq = SIRBinExprNode::CreateBinExprNode(testInstrs[0]);
  // operator== should handle commutativity
  EXPECT_TRUE(*eq == *ce0);

  SIRBinExprNode* e1 = SIRBinExprNode::CreateBinExprNode(testInstrs[4]);
  // SUB is not commutative, so the node should remain unchanged
  SIRBinExprNode* ce1 = SIRBinExprNode::Commute(e1);
  EXPECT_EQ(ce1, e1);
  TestNode(ce1->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(ce1->GetRHS(), 0, SIROpcode::NOP, testRegs[1]);
}// TEST_F(SIRExprTest, Commute)

TEST_F(SIRExprTest, Rotate) {
  // RotateLeft
  SIRInstruction* I0 = new SIRInstruction(SIROpcode::ADD, testBB, false);
  SIRInstruction* I1 = new SIRInstruction(SIROpcode::ADD, testBB, false);
  /*     +              +     */
  /*    / \            / \    */
  /*   R0  +    =>    +   R2  */
  /*      / \        / \      */
  /*     R1  R2     R0  R1    */
  I0->AddOperand(testRegs[0]).AddOperand(I1);
  I1->AddOperand(testRegs[1]).AddOperand(testRegs[2]);
  SIRBinExprNode* t = SIRBinExprNode::CreateBinExprNode(I0);
  SIRBinExprNode* rl = SIRBinExprNode::RotateLeft(t);
  TestNode(rl, 2, SIROpcode::ADD, NULL);
  TestNode(rl->GetLHS(), 1, SIROpcode::ADD, NULL);
  TestNode(rl->GetLHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(rl->GetLHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[1]);
  TestNode(rl->GetRHS(), 0, SIROpcode::NOP, testRegs[2]);
  delete I0;
  delete I1;

  // RotateRight
  I0 = new SIRInstruction(SIROpcode::ADD, testBB, false);
  I1 = new SIRInstruction(SIROpcode::ADD, testBB, false);
  /*       +          +       */ 
  /*      / \        / \      */ 
  /*     +   R2  => R0  +     */ 
  /*    / \            / \    */ 
  /*   R0  R1         R1  R2  */ 
  I0->AddOperand(I1).AddOperand(testRegs[2]);
  I1->AddOperand(testRegs[0]).AddOperand(testRegs[1]);
  t = SIRBinExprNode::CreateBinExprNode(I0);
  SIRBinExprNode* rr = SIRBinExprNode::RotateRight(t);
  TestNode(rr, 2, SIROpcode::ADD, NULL);
  TestNode(rr->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(rr->GetRHS(), 1, SIROpcode::ADD, NULL);
  TestNode(rr->GetRHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[1]);
  TestNode(rr->GetRHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[2]);
  delete I0;
  delete I1;
}// TEST_F(SIRExprTest, Rotate)

TEST_F(SIRExprTest, Distribute) {
  // DistributeLeft
  SIRInstruction* I0 = new SIRInstruction(SIROpcode::MUL, testBB, false);
  SIRInstruction* I1 = new SIRInstruction(SIROpcode::ADD, testBB, false);
  /*     *               +        */ 
  /*    / \           /     \     */ 
  /*   R0  +    =>   *       *    */ 
  /*      / \       / \     / \   */ 
  /*     R1  R2    R0  R1  R0  R2 */ 
  I0->AddOperand(testRegs[0]).AddOperand(I1);
  I1->AddOperand(testRegs[1]).AddOperand(testRegs[2]);
  SIRBinExprNode* t = SIRBinExprNode::CreateBinExprNode(I0);
  SIRBinExprNode* dl = SIRBinExprNode::DistributeLeft(t);
  TestNode(dl, 2, SIROpcode::ADD, NULL);
  TestNode(dl->GetLHS(), 1, SIROpcode::MUL, NULL);
  TestNode(dl->GetRHS(), 1, SIROpcode::MUL, NULL);
  TestNode(dl->GetLHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(dl->GetLHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[1]);
  TestNode(dl->GetRHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(dl->GetRHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[2]);
  delete I0;
  delete I1;

  // DistributeRight
  I0 = new SIRInstruction(SIROpcode::MUL, testBB, false);
  I1 = new SIRInstruction(SIROpcode::ADD, testBB, false);
  /*       *              +        */ 
  /*      / \          /     \     */ 
  /*     +   R2  =>   *       *    */ 
  /*    / \          / \     / \   */ 
  /*   R0  R1       R0  R2  R1  R2 */ 
  I0->AddOperand(I1).AddOperand(testRegs[2]);
  I1->AddOperand(testRegs[0]).AddOperand(testRegs[1]);
  t = SIRBinExprNode::CreateBinExprNode(I0);
  SIRBinExprNode* dr = SIRBinExprNode::DistributeRight(t);
  TestNode(dr, 2, SIROpcode::ADD, NULL);
  TestNode(dr->GetLHS(), 1, SIROpcode::MUL, NULL);
  TestNode(dr->GetRHS(), 1, SIROpcode::MUL, NULL);
  TestNode(dr->GetLHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(dr->GetLHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[2]);
  TestNode(dr->GetRHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[1]);
  TestNode(dr->GetRHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[2]);
  delete I0;
  delete I1;
}// TEST_F(SIRExprTest, Distribute)

TEST_F(SIRExprTest, Extract) {
  // DistributeLeft
  SIRInstruction* TI = new SIRInstruction(SIROpcode::ADD, testBB, false);
  SIRInstruction* LI = new SIRInstruction(SIROpcode::MUL, testBB, false);
  SIRInstruction* RI = new SIRInstruction(SIROpcode::MUL, testBB, false);
  /*         +               *       */ 
  /*      /     \           / \      */ 
  /*     *       *     =>  R0  +     */ 
  /*    / \     / \           / \    */ 
  /*   R0  R1  R0  R2        R1  R2  */ 
  TI->AddOperand(LI).AddOperand(RI);
  LI->AddOperand(testRegs[0]).AddOperand(testRegs[1]);
  RI->AddOperand(testRegs[0]).AddOperand(testRegs[2]);
  SIRBinExprNode* t = SIRBinExprNode::CreateBinExprNode(TI);
  SIRBinExprNode* el = SIRBinExprNode::ExtractLeft(t);
  TestNode(el, 2, SIROpcode::MUL, NULL);
  TestNode(el->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(el->GetRHS(), 1, SIROpcode::ADD, NULL);
  TestNode(el->GetRHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[1]);
  TestNode(el->GetRHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[2]);
  delete TI;
  delete LI;
  delete RI;

  // DistributeRight
  TI = new SIRInstruction(SIROpcode::ADD, testBB, false);
  LI = new SIRInstruction(SIROpcode::MUL, testBB, false);
  RI = new SIRInstruction(SIROpcode::MUL, testBB, false);
  /*         +               *     */ 
  /*      /     \           / \    */ 
  /*     *       *     =>  +   R1  */ 
  /*    / \     / \       / \      */ 
  /*   R0  R1  R2  R1    R0  R2    */ 
  TI->AddOperand(LI).AddOperand(RI);
  LI->AddOperand(testRegs[0]).AddOperand(testRegs[1]);
  RI->AddOperand(testRegs[2]).AddOperand(testRegs[1]);
  t = SIRBinExprNode::CreateBinExprNode(TI);
  SIRBinExprNode* er = SIRBinExprNode::ExtractRight(t);
  TestNode(er, 2, SIROpcode::MUL, NULL);
  TestNode(er->GetLHS(), 1, SIROpcode::ADD, NULL);
  TestNode(er->GetLHS()->GetLHS(), 0, SIROpcode::NOP, testRegs[0]);
  TestNode(er->GetLHS()->GetRHS(), 0, SIROpcode::NOP, testRegs[2]);
  TestNode(er->GetRHS(), 0, SIROpcode::NOP, testRegs[1]);
  delete TI;
  delete LI;
  delete RI;
}// TEST_F(SIRExprTest, Distribute)

struct LeafCounter {
  int c_;
  LeafCounter() : c_(0) {}
  void operator()(SIRBinExprNode* n) { if (n && n->IsLeaf()) { ++c_; } }
};

TEST_F(SIRExprTest, Visit) {
  SIRBinExprNode* e = SIRBinExprNode::CreateBinExprNode(testInstrs[3]);
  LeafCounter lc;
  e->VisitNodesPreOrder(lc);
  EXPECT_EQ(7, lc.c_);

  e = SIRBinExprNode::CreateBinExprNode(testRegs[0]);
  lc.c_ = 0;
  e->VisitNodesPreOrder(lc);
  EXPECT_EQ(1, lc.c_);
}// TEST_F(SIRExprTest, Distribute)
