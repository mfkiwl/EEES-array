#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRModule.hh"
#include "gtest/gtest.h"

using namespace ES_SIMD;

class SIRInstrTest : public testing::Test {
protected:
  virtual void SetUp() {
    testRegs.reserve(8);
    for (int i = 0; i < 8; ++i) {
      testRegs.push_back(new SIRRegister(false, "R", i, NULL));
    }
    testModule = new SIRModule;
  }// SetUp()

  virtual void TearDown() {
    for (unsigned i = 0; i < testRegs.size()  ; ++i) { delete testRegs[i];   }
    delete testModule;
  }// TearDown()

  std::vector<SIRRegister*>    testRegs;
  SIRModule* testModule;
};// class SIRInstrTest

TEST_F(SIRInstrTest, Basic) {
  // Default constructor
  SIRInstruction* ins = new SIRInstruction(SIROpcode::NOP, NULL, false);
  EXPECT_EQ   (SIROpcode::NOP, ins->GetOpcode());
  EXPECT_EQ   (TargetOpcode::TargetOpcodeEnd, ins->GetTargetOpcode());
  EXPECT_FALSE(ins->IsVectorInstr());
  delete ins;
}// TEST_F(SIRInstrTest, Basic)
