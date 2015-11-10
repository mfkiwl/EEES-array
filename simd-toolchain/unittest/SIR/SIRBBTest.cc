#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "gtest/gtest.h"

using namespace ES_SIMD;

class SIRBBTest : public testing::Test {
protected:
  virtual void SetUp() { testModule = new SIRModule; }

  virtual void TearDown() { delete testModule; }

  SIRModule* testModule;
};// class SIRInstrTest

::testing::AssertionResult IsIDomChild(const SIRBasicBlock* a,
                                       const SIRBasicBlock* b);
::testing::AssertionResult IsIPDomChild(const SIRBasicBlock* a,
                                        const SIRBasicBlock* b);
::testing::AssertionResult Dominates(const SIRBasicBlock* a,
                                     const SIRBasicBlock* b);
::testing::AssertionResult PostDominates(const SIRBasicBlock* a,
                                         const SIRBasicBlock* b);

static void AddCFGEdge(SIRBasicBlock* from, SIRBasicBlock* to) {
  from->succ_push_back(to);
  to->pred_push_back(from);
}

TEST_F(SIRBBTest, BBSplit) {
  SIRFunction* f = new SIRFunction("test_bb_split", testModule);
  SIRBasicBlock* entry = new SIRBasicBlock(0, f);
  SIRBasicBlock* body  = new SIRBasicBlock(1, f);
  SIRBasicBlock* exit  = new SIRBasicBlock(2, f);
  f->push_back(entry);
  f->push_back(body);
  f->push_back(exit);

  AddCFGEdge(entry, body);
  AddCFGEdge(body, exit);

  SIRInstruction* I1 = new SIRInstruction(SIROpcode::ADD, body, false);
  SIRInstruction* I2 = new SIRInstruction(SIROpcode::ADD, body, false);
  entry->push_back(I1);
  entry->push_back(I2);
  SIRBasicBlock:: iterator sIt = body->begin();
  ++sIt;
  SIRBasicBlock* succ = body->SplitBlock(sIt);
  EXPECT_TRUE(body->IsSuccessor(succ));
  EXPECT_TRUE(succ->IsPredecessor(body));
  EXPECT_TRUE(succ->IsSuccessor(exit));
  EXPECT_TRUE(exit->IsPredecessor(succ));
  EXPECT_FALSE(body->IsSuccessor(exit));
  EXPECT_FALSE(exit->IsPredecessor(body));
}// TEST_F(SIRBBTest, BBSplit)
