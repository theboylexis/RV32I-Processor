
# RV32I Base Integer ISA — Study Notes

## 1. Overview

RISC-V is an open instruction set architecture (ISA).

RV32I is its 32-bit base integer instruction set.

Key properties:
- XLEN = 32 bits
- 32 general-purpose registers (x0–x31)
- x0 is hardwired to zero
- 32-bit base instructions
- Byte-addressable memory
- Load/store architecture
- Four core formats: R, I, S, U
- Two immediate variants: B, J

An ISA defines processor behavior, not its implementation.
Both single-cycle and pipelined processors can implement RV32I.

## 2. Register Model

- x0–x31: 32 integer registers
- Each register is 32 bits wide
- Register identifiers use 5 bits
- x0 always reads zero; writes are ignored
- PC holds the address of the current instruction

Calling convention:
- x1: conventional return address register
- x2: conventional stack pointer
- x5: alternative link register

The ISA does not require dedicated hardware registers
for the stack pointer or return address.

## 3. Instruction Formats

All formats occupy 32 instruction bits.

### R-Type

funct7[7] | rs2[5] | rs1[5] | funct3[3] | rd[5] | opcode[7]

- Two source registers
- One destination register
- funct3 and funct7 distinguish operations

Example:
ADD x5, x6, x7

Operation:
x5 = x6 + x7 (modulo 2^32)

Encoding: 0x007302B3

### I-Type

imm[11:0] | rs1[5] | funct3[3] | rd[5] | opcode[7]

- One source register
- 12-bit immediate field
- Used for immediate arithmetic, loads, and JALR
- Shift-immediate instructions have specialized encodings

Example:
ADDI x5, x6, 10

Operation:
x5 = x6 + 10 (modulo 2^32)

Encoding: 0x00A30293

Signed 12-bit immediate range: -2048 to +2047

### S-Type

imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode

- Used for stores
- rs1 provides base address
- rs2 provides data
- Immediate is split into 7 upper and 5 lower bits
- No destination register

Example:
SW x5, 8(x6)

Operation:
Store 32-bit value from x5 at address x6 + 8.

Encoding: 0x00532423

### B-Type

imm[12] | imm[10:5] | rs2 | rs1 |
funct3 | imm[4:1] | imm[11] | opcode

- Used for conditional branches
- Compares rs1 and rs2
- Branch offset is PC-relative
- Offset bit 0 is zero
- Signed byte-offset range: -4096 to +4094

Example:
BEQ x5, x6, 8

If x5 == x6:
    PC = PC + 8
Otherwise:
    PC = PC + 4

### U-Type

imm[31:12] | rd[5] | opcode[7]

- Contains a 20-bit immediate
- No source register fields
- Lower 12 bits of the constructed value are zero

LUI:
rd = imm20 << 12

AUIPC:
rd = PC + (imm20 << 12)

Example:
LUI x5, 0x12345
x5 = 0x12345000

### J-Type

imm[20] | imm[10:1] | imm[11] |
imm[19:12] | rd | opcode

- Used by JAL
- Unconditional PC-relative jump
- Saves return address in rd
- Jump offset is a signed multiple of 2 bytes
- Signed byte-offset range:
  -1048576 to +1048574

Example:
JAL x1, 12

If PC = 0x1000:
x1 = 0x1004
PC = 0x100C

JALR is I-type, not J-type.

## 4. Instruction Groups

### Arithmetic
ADD, SUB, ADDI

### Logical
AND, OR, XOR, ANDI, ORI, XORI

### Shifts
SLL, SRL, SRA, SLLI, SRLI, SRAI

### Comparisons
SLT, SLTU, SLTI, SLTIU

### Loads
LB, LH, LW, LBU, LHU

### Stores
SB, SH, SW

### Conditional Branches
BEQ, BNE, BLT, BGE, BLTU, BGEU

### Jumps
JAL, JALR

### Upper Immediate
LUI, AUIPC

### Memory Ordering and System
FENCE, ECALL, EBREAK

Note:
The specification also defines instruction
encoding details, hints, and other required
behavior beyond this functional grouping.

## 5. Memory Addressing

- Memory is byte-addressed
- Byte = 8 bits
- Halfword = 16 bits
- Word = 32 bits
- Effective address = rs1 + sign-extended offset

Loads transfer data from memory into registers.
Stores transfer data from registers into memory.

Load extension:
- LB/LH: sign-extend
- LBU/LHU: zero-extend
- LW: loads 32 bits

Endianness is an execution-environment property
and must be defined for the processor's memory model.

## 6. Memory Alignment

Natural alignment:
- Byte: any address
- Halfword: address divisible by 2
- Word: address divisible by 4

Misaligned accesses may succeed or raise exceptions,
depending on the execution environment.

The implementation policy must be documented.

## 7. Instruction Alignment

- Base RV32I uses 4-byte instruction alignment
- IALIGN = 32 bits
- Sequential PC normally advances by 4 bytes
- Taken branches/jumps to misaligned addresses
  cause instruction-address-misaligned exceptions
- Untaken conditional branches do not cause this
  exception

## 8. Instruction Legality and Exceptions

- Instruction decoding must follow ISA encoding rules
- Invalid encodings must not execute unintended operations
- Reserved encodings may have platform-dependent behavior
- ECALL requests execution-environment services
- EBREAK requests a breakpoint exception
- FENCE defines memory/I/O ordering requirements

Exception handling and execution-environment
assumptions must be specified before claiming
complete RV32I compliance.

## 9. Implementation Scope — To Be Decided

Before RTL development, define:

- Supported ISA requirements
- Memory organization and endianness
- Reset and initial PC behavior
- Instruction/data memory interfaces
- Misaligned memory-access handling
- Illegal-instruction handling
- ECALL/EBREAK handling
- FENCE behavior
- Verification and compliance criteria

These are implementation decisions, not
features already completed.

## Reference

RISC-V RV32I Base Integer ISA:
https://docs.riscv.org/reference/isa/unpriv/rv32.html
