
# RV32I ISA Notes

## 1. Overview

- RISC-V is an open instruction set architecture.
- RV32I is the 32-bit base integer ISA.
- 32 general-purpose registers, each 32 bits wide.
- x0 is hardwired to zero.
- Base instructions are 32 bits wide.
- Memory is byte-addressed.
- Six instruction formats: R, I, S, B, U, J.

## 2. Register File

- Registers: x0–x31
- Register width: 32 bits
- Register addresses: 5 bits
- x0 always reads as zero; writes are ignored.
- Most arithmetic instructions operate on registers.

Example:
add x5, x6, x7

Meaning:
x5 = x6 + x7 (modulo 2^32)


## 3. R-Type Instructions

Format (32 bits):
funct7[7] | rs2[5] | rs1[5] | funct3[3] | rd[5] | opcode[7]

- opcode: instruction category
- rd: destination register
- rs1, rs2: source registers
- funct3, funct7: operation selection

Example:
add x5, x6, x7

Encoding:
0000000 00111 00110 000 00101 0110011

Hex: 0x007302B3

Operation:
x5 = x6 + x7 (modulo 2^32)


## 4. I-Type Instructions

Format (32 bits):
imm[11:0] | rs1[5] | funct3[3] | rd[5] | opcode[7]

- Uses one source register and a 12-bit immediate field.
- Arithmetic immediates are generally sign-extended.
- Signed 12-bit range: -2048 to +2047.
- Used for immediate arithmetic, loads, and JALR.
- Shift-immediate instructions have special encoding rules.

Example:
addi x5, x6, 10

Encoding:
000000001010 00110 000 00101 0010011

Hex: 0x00A30293

Operation:
x5 = x6 + 10 (modulo 2^32)



## 5. S-Type Instructions

Format (32 bits):
imm[11:5] | rs2[5] | rs1[5] | funct3[3] | imm[4:0] | opcode[7]

- Used for store instructions: SB, SH, SW.
- rs1 contains the base address.
- rs2 contains the data to store.
- The 12-bit immediate is split across two fields.
- Effective address = rs1 + sign-extended immediate.
- No destination register (rd).

Example:
sw x5, 8(x6)

Encoding:
0000000 00101 00110 010 01000 0100011

Hex: 0x00532423

Operation:
Memory[x6 + 8] = lower 32 bits of x5
(Store word, using four consecutive bytes.)



## 6. B-Type Instructions

Format (32 bits):
imm[12] | imm[10:5] | rs2 | rs1 | funct3 |
imm[4:1] | imm[11] | opcode

- Used for conditional branches.
- Compares rs1 and rs2.
- No destination register.
- Immediate is split across four fields.
- Branch offset is a signed multiple of 2 bytes.
- Taken target = PC + sign-extended branch offset.
- Not taken = PC + 4 (without compressed instructions).

Instructions:
BEQ, BNE, BLT, BGE, BLTU, BGEU

Example:
beq x5, x6, 8

If x5 == x6:
    PC = PC + 8
Else:
    PC = PC + 4



## 7. U-Type Instructions

Format (32 bits):
imm[31:12] | rd[5] | opcode[7]

- Contains a 20-bit immediate.
- No source registers.
- Lower 12 bits of the constructed immediate are zero.
- Used for large constants and address calculations.

LUI:
rd = imm20 << 12

AUIPC:
rd = PC + (imm20 << 12)

Example:
lui x5, 0x12345
Result: x5 = 0x12345000

Example:
auipc x5, 0x1
If PC = 0x1000:
Result: x5 = 0x2000

AUIPC writes to rd; it does not change the PC.



## 8. J-Type Instructions

Format (32 bits):
imm[20] | imm[10:1] | imm[11] | imm[19:12] | rd | opcode

Instruction: JAL

- Performs an unconditional PC-relative jump.
- Saves PC + 4 in the destination register.
- Jump target = PC + sign-extended offset.
- Offset bit 0 is always zero.
- Signed offset range: -1,048,576 to +1,048,574 bytes.
- JALR is I-type, not J-type.

Example:
jal x1, 12

If PC = 0x1000:
x1 = 0x1004
PC = 0x100C

