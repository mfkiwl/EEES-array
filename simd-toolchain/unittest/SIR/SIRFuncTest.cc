#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRLoop.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "gtest/gtest.h"

using namespace ES_SIMD;

class SIRFuncTest : public testing::Test {
protected:
  virtual void SetUp() { testModule = new SIRModule; }

  virtual void TearDown() { delete testModule; }

  SIRModule* testModule;
};// class SIRInstrTest

static void AddCFGEdge(SIRBasicBlock* from, SIRBasicBlock* to) {
  from->succ_push_back(to);
  to->pred_push_back(from);
}

::testing::AssertionResult IsIDomChild(const SIRBasicBlock* a,
                                  const SIRBasicBlock* b) {
  if (a->IsIDomChild(b) && !b->IsIDomChild(a) && a->Dominates(b) && !b->Dominates(a)) {
    return ::testing::AssertionSuccess();
  } else { return ::testing::AssertionFailure(); }
}

::testing::AssertionResult IsIPDomChild(const SIRBasicBlock* a,
                                   const SIRBasicBlock* b) {
  if (a->IsIPDomChild(b) && !b->IsIPDomChild(a)
      && a->PostDominates(b) && !b->PostDominates(a)) {
    return ::testing::AssertionSuccess();
  }
  else { return ::testing::AssertionFailure(); }
}

::testing::AssertionResult Dominates(const SIRBasicBlock* a,
                                     const SIRBasicBlock* b) {
  if (a->Dominates(b) && (!b->Dominates(a) || (a == b))) {
    return ::testing::AssertionSuccess();
  } else { return ::testing::AssertionFailure(); }
}

::testing::AssertionResult PostDominates(const SIRBasicBlock* a,
                                         const SIRBasicBlock* b) {
  if (a->PostDominates(b) && (!b->PostDominates(a) || (a == b))) {
    return ::testing::AssertionSuccess();
  } else { return ::testing::AssertionFailure(); }
}

TEST_F(SIRFuncTest, CFGUpdate) {
  SIRFunction* f = new SIRFunction("test_cfg", testModule);
  SIRBasicBlock* entry = new SIRBasicBlock(0, f);
  SIRBasicBlock* exit  = new SIRBasicBlock(1, f);
  f->push_back(entry);
  f->push_back(exit);
  f->SetEntryBlock(entry);
  exit->SetExitBlock(true);

  // Straight two block CFG
  AddCFGEdge(entry, exit);
  f->UpdateControlFlowInfo();
  EXPECT_TRUE(IsIDomChild(entry, exit));
  EXPECT_TRUE(IsIPDomChild(exit, entry));

  for (SIRFunction::iterator bIt = f->begin(); bIt != f->end(); ++bIt) {
    (*bIt)->succ_clear();
    (*bIt)->pred_clear();
  }
  SIRBasicBlock* leftBlock  = new SIRBasicBlock(2, f);
  SIRBasicBlock* rightBlock = new SIRBasicBlock(3, f);
  f->push_back(leftBlock);
  f->push_back(rightBlock);
  // A diamond-shape CFG
  AddCFGEdge(entry, leftBlock);
  AddCFGEdge(entry, rightBlock);
  AddCFGEdge(leftBlock, exit);
  AddCFGEdge(rightBlock, exit);

  f->UpdateControlFlowInfo();

  EXPECT_TRUE(IsIDomChild(entry, leftBlock));
  EXPECT_TRUE(IsIDomChild(entry, rightBlock));
  EXPECT_TRUE(IsIDomChild(entry, exit));
  EXPECT_TRUE(IsIPDomChild(exit, leftBlock));
  EXPECT_TRUE(IsIPDomChild(exit, rightBlock));
  EXPECT_TRUE(IsIPDomChild(exit, entry));

  EXPECT_FALSE(IsIDomChild(leftBlock,  rightBlock));
  EXPECT_FALSE(IsIDomChild(rightBlock, leftBlock));
  EXPECT_FALSE(IsIPDomChild(leftBlock,  rightBlock));
  EXPECT_FALSE(IsIPDomChild(rightBlock, leftBlock));

  for (SIRFunction::iterator bIt = f->begin(); bIt != f->end(); ++bIt) {
    (*bIt)->succ_clear();
    (*bIt)->pred_clear();
  }
  SIRBasicBlock* loopHdr = new SIRBasicBlock(4, f);
  SIRBasicBlock* loopExt = new SIRBasicBlock(5, f);
  f->push_back(loopHdr);
  f->push_back(loopExt);
  // A loop with a diamon-shape loop body
  AddCFGEdge(entry, loopHdr);
  AddCFGEdge(loopHdr, leftBlock);
  AddCFGEdge(loopHdr, rightBlock);
  AddCFGEdge(leftBlock, loopExt);
  AddCFGEdge(rightBlock, loopExt);
  AddCFGEdge(loopExt, loopHdr); // Back edge
  AddCFGEdge(loopExt, exit);
  f->UpdateControlFlowInfo();

  EXPECT_TRUE(IsIDomChild(entry  ,  loopHdr));
  EXPECT_TRUE(IsIDomChild(loopHdr,  leftBlock));
  EXPECT_TRUE(IsIDomChild(loopHdr,  rightBlock));
  EXPECT_TRUE(IsIDomChild(loopHdr,  loopExt));
  EXPECT_TRUE(IsIDomChild(loopExt,  exit));
  EXPECT_TRUE(IsIPDomChild(loopHdr, entry));
  EXPECT_TRUE(IsIPDomChild(exit   , loopExt));
  EXPECT_TRUE(IsIPDomChild(loopExt, leftBlock));
  EXPECT_TRUE(IsIPDomChild(loopExt, rightBlock));
  EXPECT_TRUE(IsIPDomChild(loopExt, loopHdr));

  EXPECT_TRUE(Dominates(entry,   leftBlock));
  EXPECT_TRUE(Dominates(entry,   rightBlock));
  EXPECT_TRUE(Dominates(entry,   loopExt));
  EXPECT_TRUE(Dominates(entry,   exit));
  EXPECT_TRUE(Dominates(loopHdr, loopExt));

  EXPECT_FALSE(IsIDomChild (leftBlock,  rightBlock));
  EXPECT_FALSE(IsIPDomChild(leftBlock,  rightBlock));
  EXPECT_FALSE(IsIDomChild (rightBlock, leftBlock));
  EXPECT_FALSE(IsIPDomChild(rightBlock, leftBlock));
}// TEST_F(SIRInstrTest, CFGUpdate)

TEST_F(SIRFuncTest, NaturalLoopDetection) {
  SIRFunction* f = new SIRFunction("test_loop", testModule);
  SIRBasicBlock* entry    = new SIRBasicBlock(0, f);
  SIRBasicBlock* loop1Hdr = new SIRBasicBlock(1, f);
  SIRBasicBlock* loop1Ext = new SIRBasicBlock(2, f);
  SIRBasicBlock* loop2    = new SIRBasicBlock(3, f);
  SIRBasicBlock* loop1Bdy = new SIRBasicBlock(4, f);
  SIRBasicBlock* exit     = new SIRBasicBlock(5, f);
  f->push_back(entry);
  f->push_back(loop1Hdr);
  f->push_back(loop1Ext);
  f->push_back(loop1Bdy);
  f->push_back(loop2);
  f->push_back(exit);

  f->SetEntryBlock(entry);
  exit->SetExitBlock(true);

  AddCFGEdge(entry,    loop1Hdr);
  AddCFGEdge(loop1Hdr, loop2);
  AddCFGEdge(loop2,    loop2);
  AddCFGEdge(loop2,    loop1Bdy);
  AddCFGEdge(loop1Bdy, loop1Ext);
  AddCFGEdge(loop1Ext, loop1Hdr);
  AddCFGEdge(loop1Ext, exit);
  f->UpdateControlFlowInfo();

  EXPECT_TRUE(IsIDomChild(entry  ,  loop1Hdr));
  EXPECT_TRUE(IsIDomChild(loop1Hdr, loop2));
  EXPECT_TRUE(IsIDomChild(loop2,    loop1Bdy));
  EXPECT_TRUE(IsIDomChild(loop1Bdy, loop1Ext));
  EXPECT_TRUE(IsIDomChild(loop1Ext, exit));
  EXPECT_TRUE(Dominates(loop2, loop2));
  SIRLoop* l1 = loop1Hdr->GetLoop();
  ASSERT_TRUE(l1 != NULL);
  EXPECT_TRUE (l1->Contains(loop1Hdr));
  EXPECT_TRUE (l1->Contains(loop2));
  EXPECT_TRUE (l1->Contains(loop1Bdy));
  EXPECT_TRUE (l1->Contains(loop1Ext));
  EXPECT_FALSE(l1->Contains(entry));
  EXPECT_FALSE(l1->Contains(exit));
  EXPECT_EQ(l1->GetLoopDepth(), 1u);
  ASSERT_EQ(l1->sub_size(),  1u);
  ASSERT_EQ(l1->exit_size(), 1u);
  EXPECT_EQ(l1->GetHeader(), loop1Hdr);
  EXPECT_EQ(*l1->exit_begin(), loop1Ext);

  SIRLoop* l2 = loop2->GetLoop();
  ASSERT_TRUE(l2 != NULL);
  EXPECT_FALSE(l2->Contains(l2));
  EXPECT_FALSE(l2->Contains(loop1Hdr));
  EXPECT_TRUE (l2->Contains(loop2));
  EXPECT_FALSE(l2->Contains(loop1Ext));
  EXPECT_FALSE(l2->Contains(entry));
  EXPECT_FALSE(l2->Contains(exit));
  EXPECT_EQ(l2->sub_size(),  0u);
  EXPECT_TRUE (l1->Contains(l2));
  EXPECT_EQ(*l1->sub_begin(), l2);
  EXPECT_EQ(l2->GetLoopDepth(), 2u);
  ASSERT_EQ(l2->exit_size(), 1u);
  EXPECT_EQ(l2->GetHeader(), loop2);
  EXPECT_EQ(*l2->exit_begin(), loop2);
}// TEST_F(SIRFuncTest, NaturalLoopDetection)
