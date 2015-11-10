#ifndef ES_SIMD_SIROPCODE_HH
#define ES_SIMD_SIROPCODE_HH


#include "DataTypes/EnumFactory.hh"
#include <string>
#include <tr1/unordered_map>

/// Define the superset of possible operations
#define SIROPCODE_ENUM(DEF, DEFV)                                       \
  DEFV(ADD, 0)  DEF(ADDC) DEF(ADDCC) DEF(SUB) DEF(SUBC) DEF(SUBCC)      \
  DEF(AND)  DEF(OR)    DEF(XOR)                                         \
  DEF(SRL)  DEF(SRA)   DEF(SLL)  DEF(ROR)                               \
  DEF(MUL)  DEF(MULU)  DEF(DIV)  DEF(MOD)                               \
  DEF(SEL_EQ)  DEF(SEL_NE)  DEF(SEL_GT)  DEF(SEL_GE)  DEF(SEL_LT)       \
  DEF(SEL_LE)  DEF(SEL_GTU)  DEF(SEL_GEU)  DEF(SEL_LTU)  DEF(SEL_LEU)   \
  DEF(MAX)  DEF(MIN)  DEF(MAXU)  DEF(MINU)                              \
  DEF(LW)  DEF(LH)  DEF(LB) DEF(LHS)  DEF(LBS)                          \
  DEF(SW)  DEF(SH)  DEF(SB)                                             \
  DEF(SFEQ)  DEF(SFNE)  DEF(SFGES)  DEF(SFGEU)  DEF(SFGTS) DEF(SFGTU)   \
  DEF(SFLES) DEF(SFLEU) DEF(SFLTS)  DEF(SFLTU)                          \
  DEF(BREQ)  DEF(BRNE)  DEF(BRGE)   DEF(BRGT)  DEF(BRLE)  DEF(BRLT)     \
  DEF(BRGEU) DEF(BRGTU) DEF(BRLEU)  DEF(BRLTU)                          \
  DEF(CALL)  DEF(J)     DEF(RET)    DEF(NOP)                            \
  DEF(MOV)                                                              \
  DEF(READ_L)  DEF(READ_R) DEF(PUSH_H) DEF(PUSH_T)                      \
  DEF(READ_H) DEF(READ_T)                                               \
  DEF(BB)  DEF(PRED)  DEF(SUCC)                                         \
  DEF(DOM) DEF(PDOM)                                                    \
  DEF(LOOP)  DEF(LHDR)  DEF(LEXT)                                       \
  DEF(RLI)   DEF(RLO)                                                   \
  DEF(MNUM)  DEF(MLOC)  DEF(MALIAS)                                     \
  DEF(NUMGR) DEF(GRSIZE)                                                \
  DEF(ARGSPC) DEF(ARGS) DEF(RVALS)

#define SIROPTYPE_ENUM(DEF, DEFV) \
  DEF(Arith)  DEF(Shift)  DEF(Logic)  DEF(Store)  DEF(Select)           \
  DEF(Branch) DEF(Load)  DEF(Compare)  DEF(Comm)  DEF(Misc)  DEF(Meta)

namespace ES_SIMD {
  DECLARE_ENUM(SIROpcode, SIROPCODE_ENUM)
  DECLARE_ENUM(SIROpType, SIROPTYPE_ENUM)
}

// Define hash function for TargetOpcode inorder to use unordered_*
namespace std {
  namespace tr1 {
    template<>
    struct hash<ES_SIMD::SIROpcode_t>
      : public unary_function<ES_SIMD::SIROpcode_t, size_t> {
    public:
      size_t operator() (const ES_SIMD::SIROpcode_t& f) const {
        hash<int> h;
        return h(static_cast<const int>(f));
      }
    };// class hash<TargetOpcType>
  }// namespace tr1
}// namespace std

namespace ES_SIMD {
  SIROpcode_t GetSIROpcode(const std::string& str);

  struct SIROpcodeProperty {
    SIROpType_t type_;
    unsigned numInput_;
    unsigned numOutput_;
    bool     commutative_;
    bool     associative_;
    int      precedence_;
    bool     leftDistributive_;
    bool     rightDistributive_;
    static std::tr1::unordered_map<int, SIROpcodeProperty> SIROpcodePropTable;
    static bool Init;
    static bool Initialize();
    SIROpcodeProperty() {}
    SIROpcodeProperty(SIROpType_t t, unsigned nInput, unsigned nOutput,
                      bool comm, bool assoc, int precedence)
        : type_(t), numInput_(nInput), numOutput_(nOutput),
          commutative_(comm), associative_(assoc), precedence_(precedence),
          leftDistributive_(false), rightDistributive_(false) {}
  };// struct SIROpcodeProperty

  static inline const SIROpcodeProperty& GetSIROpProperty(SIROpcode_t o) {
    return SIROpcodeProperty::SIROpcodePropTable[static_cast<int>(o)];
  }
  static inline int    GetSIRPrecedence(SIROpcode_t o) {
    return GetSIROpProperty(o).precedence_;
  }
  static inline size_t GetSIROpNumInput(SIROpcode_t o) {
    return GetSIROpProperty(o).numInput_;
  }
  static inline size_t GetSIROpNumOutput(SIROpcode_t o) {
    return GetSIROpProperty(o).numOutput_;
  }
  static inline bool IsSIRShift(SIROpcode_t o) {
    return (o >= SIROpcode::SRL)  && (o <= SIROpcode::SLL);
  }
  static inline bool IsSIRMetaOp(SIROpcode_t o) {
    return (o >= SIROpcode::BB) && (o <= SIROpcode::MALIAS);
  }
  static inline bool IsSIRMemoryOp(SIROpcode_t o) {
    return (o >= SIROpcode::LW) && (o <= SIROpcode::SB);
  }
  static inline bool IsSIRLoad(SIROpcode_t o) {
    return (o >= SIROpcode::LW) && (o <= SIROpcode::LB);
  }
  static inline bool IsSIRSExtLoad(SIROpcode_t o) {
    return (o == SIROpcode::LBS) || (o == SIROpcode::LHS);
  }
  static inline bool IsSIRStore(SIROpcode_t o) {
    return (o >= SIROpcode::SW) && (o <= SIROpcode::SB);
  }
  static inline bool IsSIRSelect(SIROpcode_t o) {
    return (o >= SIROpcode::SEL_EQ) && (o <= SIROpcode::MINU);
  }
  static inline bool IsSIRBranch(SIROpcode_t o) {
    return (o >= SIROpcode::BREQ) && (o <= SIROpcode::RET);
  }
  static inline bool IsSIRUnCondBranch(SIROpcode_t o) {
    return (o >= SIROpcode::CALL) && (o <= SIROpcode::RET);
  }
  static inline bool IsSIRCondBranch(SIROpcode_t o) {
    return (o >= SIROpcode::BREQ) && (o <= SIROpcode::BRLTU);
  }
  static inline bool IsSIRCompare(SIROpcode_t o) {
    return (o>= SIROpcode::SFEQ) && (o <=SIROpcode::SFLTU);
  }
  static inline bool IsSIRCommunication(SIROpcode_t o) {
    return (o >= SIROpcode::READ_L) && (o <= SIROpcode::READ_T);
  }
  static inline bool IsSIRCommutativeOp(SIROpcode_t o) {
    return GetSIROpProperty(o).commutative_;
  }
  static inline bool IsSIRAssociativeOp(SIROpcode_t o) {
    return GetSIROpProperty(o).associative_;
  }
  static inline bool IsSIRLeftDistributiveOp(SIROpcode_t o) {
    return GetSIROpProperty(o).leftDistributive_;
  }
  static inline bool IsSIRRightDistributiveOp(SIROpcode_t o) {
    return GetSIROpProperty(o).rightDistributive_;
  }
}// namespace ES_SIMD

#endif//ES_SIMD_SIROPCODE_HH
