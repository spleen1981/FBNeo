#ifndef M68KOPS__HEADER
#define M68KOPS__HEADER
#ifdef __cplusplus
 extern "C" {
#endif
/* ======================================================================== */
/* ============================ OPCODE HANDLERS =========================== */
/* ======================================================================== */


/* Build the opcode handler table */
void m68ki_build_opcode_table(void);

extern void (*m68ki_instruction_jump_table[0x10000])(void); /* opcode handler jump table */
extern unsigned char m68ki_cycles[][0x10000];


/* ======================================================================== */
/* ============================== END OF FILE ============================= */
/* ======================================================================== */
#ifdef __cplusplus
 }
#endif
#endif /* M68KOPS__HEADER */


