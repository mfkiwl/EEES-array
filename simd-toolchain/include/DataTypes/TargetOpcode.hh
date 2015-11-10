#ifndef ES_SIMD_TARGETOPCODE_HH
#define ES_SIMD_TARGETOPCODE_HH

#include <utility>
#include <tr1/unordered_map>
#include <tr1/unordered_set>
#include "DataTypes/EnumFactory.hh"
#include "DataTypes/SIROpcode.hh"

#define TARGETOPTYPE_ENUM(DEF, DEFV)                              \
  DEF(IntArith)  DEF(IntCompare)  DEF(Load)  DEF(Store)           \
  DEF(Branch)  DEF(Special)  DEF(Immediate) DEF(System) DEF(Misc)

/// Define the superset of possible operations
#define TARGETOPCODE_ENUM(DEF, DEFV)                          \
  DEFV(ADD, SIROpcode::SIROpcodeEnd+1) DEF(SUB)  DEF(RSUB)    \
  DEF(AND)  DEF(OR)  DEF(XOR)                                 \
  DEF(SRL)  DEF(SRA) DEF(SLL)  DEF(ROR)                       \
  DEF(CMOV) DEF(MOVH)  DEF(MOV)                               \
  DEF(MOV_L)  DEF(MOV_R) DEF(PUSH_H)  DEF(PUSH_T)             \
  DEF(MOV_H)  DEF(MOV_T)                                      \
  DEF(MUL)  DEF(MULU)  DEF(DIV)                               \
  DEF(SFEQ)  DEF(SFNE)  DEF(SFGES)  DEF(SFGEU)  DEF(SFGTS)    \
  DEF(SFGTU)  DEF(SFLES)  DEF(SFLEU)  DEF(SFLTS)  DEF(SFLTU)  \
  DEF(LW)  DEF(LHS) DEF(LH)  DEF(LBS )DEF(LB)                 \
  DEF(SW)  DEF(SH)  DEF(SB)                                   \
  DEF(BF)  DEF(BNF) DEF(BEQ)  DEF(BNE)  DEF(BGE)  DEF(BGT)    \
  DEF(BLE)  DEF(BLT)  DEF(JAL)  DEF(JALR)  DEF(J)  DEF(JR)    \
  DEF(SIMM)  DEF(ZIMM)                                        \
  DEF(NOP)

namespace ES_SIMD {
  DECLARE_ENUM(TargetOpcode,TARGETOPCODE_ENUM)
  DECLARE_ENUM(TargetOpType,TARGETOPTYPE_ENUM)
}// namespace ES_SIMD

// Define hash function for TargetOpcode inorder to use unordered_*
namespace std {
  namespace tr1 {
    template<>
    struct hash<ES_SIMD::TargetOpcode_t>
      : public unary_function<ES_SIMD::TargetOpcode_t, size_t> {
    public:
      size_t operator() (const ES_SIMD::TargetOpcode_t& f) const {
        hash<int> h;
        return h(static_cast<const int>(f));
      }
    };// class hash<TargetOpcType>
  }// namespace tr1
}// namespace std

namespace ES_SIMD {
  TargetOpcode_t GetTargetOpcode(const std::string& str);
  static inline bool IsTargetBranch(TargetOpcode_t o) {
    return (o>= TargetOpcode::BF) && (o <=TargetOpcode::JR);
  }
  static inline bool IsTargetCall(TargetOpcode_t o) {
    return (o>= TargetOpcode::JAL) && (o <=TargetOpcode::JALR);
  }
  static inline bool IsTargetCondBranch(TargetOpcode_t o) {
    return (o>= TargetOpcode::BF) && (o <=TargetOpcode::BLT);
  }
  static inline bool IsTargetBranchReg(TargetOpcode_t o) {
    return (o == TargetOpcode::JR) || (o ==TargetOpcode::JALR);
  }
  static inline bool IsTargetCompare(TargetOpcode_t o) {
    return (o>= TargetOpcode::SFEQ) && (o <=TargetOpcode::SFLTU);
  }
  static inline bool IsTargetImmediateOp(TargetOpcode_t o) {
    return (o>= TargetOpcode::SIMM) && (o <=TargetOpcode::ZIMM);
  }
  static inline bool IsTargetMemoryOp(TargetOpcode_t o) {
    return (o>= TargetOpcode::LW) && (o <=TargetOpcode::SB);
  }
  static inline bool IsTargetLoad(TargetOpcode_t o) {
    return (o>= TargetOpcode::LW) && (o <=TargetOpcode::LB);
  }
  static inline bool IsTargetStore(TargetOpcode_t o) {
    return (o>= TargetOpcode::SW) && (o <=TargetOpcode::SB);
  }
  static inline bool IsTargetIntArithmetic (TargetOpcode_t o) {
    return (o>= TargetOpcode::ADD) && (o <=TargetOpcode::SFLTU);
  }
  static inline bool IsTargetCommunication(TargetOpcode_t o) {
    return (o>= TargetOpcode::MOV_L) && (o <=TargetOpcode::MOV_T);
  }

  struct TargetOpcProperty {
    TargetOpType_t type_;
    unsigned  numOfInput_;  /// Number of input operands, excluding flag(s)
    unsigned  numOfOutput_; /// Number of output operands, excluding flag(s)
    bool      commutative_; /// Is the operation commutative
    bool      associative_; /// Is the operation associative
    bool      validVector_; /// Is the operation available in vector form
    bool      usesFlag_;    /// Does the operation uses flag by definition

    static std::tr1::unordered_map<TargetOpcode_t,
                                   TargetOpcProperty> targetOpProp;
    static std::tr1::unordered_set<TargetOpcode_t> zExtOps;
    static bool init;
    static bool Init();

    /// Static helpers
    static bool IsValidVectorOp(TargetOpcode_t opc) {
      return targetOpProp[opc].validVector_;
    }
    static unsigned GetNumOfOutput(TargetOpcode_t opc) {
      return targetOpProp[opc].numOfOutput_;
    }
    static TargetOpType_t GetOperationType(
      TargetOpcode_t opc) {
      return targetOpProp[opc].type_;
    }

    TargetOpcProperty() {}
    TargetOpcProperty(TargetOpType_t t, unsigned nInput, unsigned nOutput,
                      bool comm, bool assoc, bool vec=true, bool uFlag=false)
      : type_(t), numOfInput_(nInput), numOfOutput_(nOutput),
        commutative_(comm), associative_(assoc), validVector_(vec),
        usesFlag_(uFlag){}
  };// struct OpcodeProperty

  static inline bool IsValidTargetOpcode(unsigned opc) {
    return (opc >= static_cast<unsigned>(TargetOpcode::ADD))
      && (opc < static_cast<unsigned>(TargetOpcode::TargetOpcodeEnd));
  }
  static inline unsigned NumTargetOpResult(TargetOpcode_t opc) {
    return TargetOpcProperty::targetOpProp[opc].numOfOutput_;
  }
  static inline unsigned NumOfOpInput(TargetOpcode_t opc) {
    return TargetOpcProperty::targetOpProp[opc].numOfInput_;
  }
  static inline unsigned GetTargetOpNumOutput(TargetOpcode_t opc){
    return TargetOpcProperty::targetOpProp[opc].numOfOutput_;
  }
  static inline unsigned GetTargetOpNumInput(TargetOpcode_t opc) {
    return TargetOpcProperty::targetOpProp[opc].numOfInput_;
  }
  static inline bool OpUsesFlag(TargetOpcode_t opc) {
    return TargetOpcProperty::targetOpProp[opc].usesFlag_;
  }
  static inline bool ZeroExtensionTargetOp(TargetOpcode_t opc) {
    return TargetOpcProperty::zExtOps.find(opc)
      != TargetOpcProperty::zExtOps.end();
  }
  static inline TargetOpcode_t GetTargetCompareOpcode (SIROpcode_t irOpc) {
    switch(irOpc) {
    default:                return TargetOpcode::TargetOpcodeEnd;
    case SIROpcode::SEL_EQ : return TargetOpcode::SFEQ ;
    case SIROpcode::SEL_NE : return TargetOpcode::SFNE ;
    case SIROpcode::SEL_GT : return TargetOpcode::SFGTS;
    case SIROpcode::SEL_GE : return TargetOpcode::SFGES;
    case SIROpcode::SEL_LT : return TargetOpcode::SFLTS;
    case SIROpcode::SEL_LE : return TargetOpcode::SFLES;
    case SIROpcode::SEL_GTU: return TargetOpcode::SFGTU;
    case SIROpcode::SEL_GEU: return TargetOpcode::SFGEU;
    case SIROpcode::SEL_LTU: return TargetOpcode::SFLTU;
    case SIROpcode::SEL_LEU: return TargetOpcode::SFLEU;
    case SIROpcode::MAX    : return TargetOpcode::SFGTS;
    case SIROpcode::MIN    : return TargetOpcode::SFLTS;
    case SIROpcode::MAXU   : return TargetOpcode::SFGTU;
    case SIROpcode::MINU   : return TargetOpcode::SFLTU;
    case SIROpcode::BREQ   : return TargetOpcode::SFEQ;
    case SIROpcode::BRNE   : return TargetOpcode::SFNE;
    case SIROpcode::BRGE   : return TargetOpcode::SFGES;
    case SIROpcode::BRGT   : return TargetOpcode::SFGTS;
    case SIROpcode::BRLE   : return TargetOpcode::SFLES;
    case SIROpcode::BRLT   : return TargetOpcode::SFLTS;
    case SIROpcode::BRGEU  : return TargetOpcode::SFGEU;
    case SIROpcode::BRGTU  : return TargetOpcode::SFGTU;
    case SIROpcode::BRLEU  : return TargetOpcode::SFLEU;
    case SIROpcode::BRLTU  : return TargetOpcode::SFLTU;
    }
  }
}// namespace ES_SIMD

#endif//ES_SIMD_TARGETOPCODE_HH
