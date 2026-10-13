# RV32I Processor | RTL Design and FPGA Implementation

A computer architecture and digital hardware engineering project focused on designing, implementing, verifying, and evaluating a 32-bit RISC-V processor using **SystemVerilog**.

This project builds upon my completed [FPGA-Synthesizable 8-Bit CPU](https://github.com/theboylexis/FPGA-Synthesizable-8Bit-CPU), progressing from a custom multi-cycle processor to the standardized RISC-V instruction set architecture and more advanced processor microarchitectures.

Development follows an incremental hardware engineering methodology involving architectural planning, modular RTL development, functional verification, processor integration, and eventual FPGA implementation and performance characterization.

**Current milestone:** The single-cycle RV32I processor has completed its initial implementation and directed verification. All seven processor-level integration testbenches pass. Development is transitioning toward a five-stage pipelined implementation.

## Project Objectives

- Design and verify a 32-bit single-cycle processor implementing the core RV32I computational, memory, and control-flow instructions.
- Develop a five-stage pipelined RV32I processor.
- Implement data forwarding, hazard detection, pipeline stalls, and control-flow flushing.
- Develop systematic module-level and processor-level verification environments.
- Validate architectural behavior against a trusted RISC-V reference implementation.
- Implement and physically validate the processor on FPGA hardware.
- Evaluate timing, resource utilization, instruction throughput, and execution performance.
- Investigate potential research-oriented architectural optimizations based on measured results.

## Development Roadmap

- [x] Establish repository structure and development environment.
- [x] Study foundational RV32I concepts and instruction formats.
- [x] Define the initial single-cycle datapath and control architecture.
- [x] Implement and test foundational SystemVerilog modules.
- [x] Integrate the single-cycle processor.
- [x] Implement register-register arithmetic, logical, shift, and comparison instructions.
- [x] Implement immediate arithmetic, logical, shift, and comparison instructions.
- [x] Implement all six RV32I conditional branch instructions.
- [x] Implement JAL and JALR.
- [x] Implement LUI and AUIPC.
- [x] Implement byte, halfword, and word memory accesses.
- [x] Develop directed processor-level integration tests.
- [x] Establish an automated single-cycle regression suite.
- [ ] Extend verification to architectural edge cases and instruction legality.
- [ ] Address remaining RV32I architectural requirements and exception behavior.
- [ ] Implement and verify a five-stage pipelined processor.
- [ ] Implement forwarding, hazard detection, stalls, and pipeline flushing.
- [ ] Develop reference-model comparison and broader ISA verification.
- [ ] Implement and validate the processor on FPGA hardware.
- [ ] Collect synthesis, timing, and resource utilization measurements.
- [ ] Conduct architectural benchmarking and performance comparisons.
- [ ] Evaluate a research-motivated architectural extension.

## Processor Architecture

| Feature | Specification |
|---|---|
| Target ISA | RISC-V RV32I |
| Register width (XLEN) | 32 bits |
| General-purpose registers | 32 × 32-bit |
| Zero register | x0 hardwired to zero |
| Instruction width | 32 bits |
| RTL language | SystemVerilog |
| Implemented microarchitecture | Single-cycle |
| Planned microarchitecture | Five-stage pipeline |
| Planned pipeline stages | IF, ID, EX, MEM, WB |
| Instruction memory | 256 × 32-bit words |
| Data memory | 256 × 32-bit words |
| Memory organization | Separate instruction and data memories |
| Data endianness | Little-endian |
| Memory operations | Byte, halfword, and word loads/stores |
| Simulation | Icarus Verilog |
| FPGA target | To be finalized |
| Verification status | Directed unit and integration tests passed |

The current implementation uses separate instruction and data memories to simplify the datapath and allow instruction fetch and data access without contention between those two memory structures.

The single-cycle processor serves as the functional reference for subsequent pipeline development.

**ISA scope:** The processor implements 37 core RV32I computational, memory, branch, and jump instructions. Full RV32I compliance has not yet been established. FENCE, ECALL, EBREAK, architectural exceptions, and additional instruction-legality requirements remain outside the verified implementation.

## RTL Implementation

The processor is organized into reusable hardware modules and microarchitecture-specific components.

### Foundational Hardware Modules

| Module | Function |
|---|---|
| Program Counter | Maintains the current instruction address with synchronous reset |
| Register File | 32 × 32-bit registers, two asynchronous read ports, one synchronous write port, x0 protection |
| Arithmetic Logic Unit | Arithmetic, logical, shift, and comparison operations |
| Immediate Generator | Extraction and extension of I, S, B, U, and J immediates |
| Control Unit | Instruction decoding and generation of datapath control signals |
| Instruction Memory | Combinational instruction reads using the program counter |
| Data Memory | Byte-addressed loads and stores with partial-word writes and load extension |
| Single-Cycle CPU | Integration of processor datapath, instruction control, memory access, and register write-back |

All foundational components have undergone initial functional simulation and testing.

### Instruction Support

**Register-register operations**

ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU

**Immediate operations**

ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU

**Load instructions**

LB, LH, LW, LBU, LHU

**Store instructions**

SB, SH, SW

**Conditional branches**

BEQ, BNE, BLT, BGE, BLTU, BGEU

**Unconditional jumps**

JAL, JALR

**Upper-immediate instructions**

LUI, AUIPC

These instructions have been implemented in RTL and exercised through directed testing. Verification coverage varies between instruction types and does not yet establish correctness for every possible operand or encoding.

### Single-Cycle Execution

The single-cycle microarchitecture performs instruction processing through the following logical activities:

1. **Instruction Fetch:** Retrieve the instruction addressed by the program counter.
2. **Instruction Decode:** Interpret the instruction fields and generate control signals.
3. **Operand Retrieval:** Read source registers and generate immediate operands.
4. **Execution:** Perform arithmetic, logical, comparison, address-generation, or control-flow operations.
5. **Memory Access:** Read or write data memory when required.
6. **Register Write-Back:** Select and write the result to the destination register.
7. **PC Update:** Select the sequential address, branch target, or jump target.

These activities are not separate clock stages in the single-cycle architecture. The required combinational logic operates within a single clock interval, and sequential state is updated at the active clock edge.

The clock period must accommodate the longest relevant combinational path.

## Control Flow

The processor supports sequential execution, conditional branches, and unconditional jumps.

**Sequential execution**

```text
Next PC = PC + 4
```

**Conditional branches**

The control unit determines the branch instruction type, while comparison logic evaluates the required signed or unsigned relationship between the two source operands.

```text
Branch taken:     Next PC = PC + immediate
Branch not taken: Next PC = PC + 4
```

**JAL**

JAL calculates a PC-relative jump target and writes the return address to the destination register.

```text
Next PC = PC + J-type immediate
rd = PC + 4
```

**JALR**

JALR calculates a register-relative target and clears the least significant target bit.

```text
Next PC = (rs1 + I-type immediate) & 0xFFFFFFFE
rd = PC + 4
```

Architectural traps for misaligned instruction targets have not yet been implemented.

## Data Memory Architecture

The data memory is organized as 256 words of 32 bits each, providing 1 KiB of byte-addressable storage in the current simulation model.

The memory supports little-endian addressing, where the lowest-addressed byte occupies the least significant eight bits of its containing word.

**Load operations**

- LB: Load an 8-bit value and sign-extend to 32 bits.
- LBU: Load an 8-bit value and zero-extend to 32 bits.
- LH: Load a 16-bit value and sign-extend to 32 bits.
- LHU: Load a 16-bit value and zero-extend to 32 bits.
- LW: Load a 32-bit word.

**Store operations**

- SB: Update the addressed byte.
- SH: Update the addressed halfword.
- SW: Update the addressed word.

Effective addresses are calculated by adding the base-register value to the sign-extended instruction immediate.

The memory implementation includes alignment checks. Invalid or misaligned reads may produce unknown simulation values, while invalid or misaligned writes are suppressed in the tested implementation. These behaviors are implementation safeguards and do not replace RISC-V architectural exception handling.

## Verification

Verification has been performed incrementally alongside RTL development.

The verification strategy includes isolated hardware-module tests, instruction decoding tests, and integrated processor-level programs.

### Module-Level Verification

Directed tests have been developed for the following modules and subsystems:

- Program Counter
- Register File
- Arithmetic Logic Unit
- Immediate Generator
- Control Unit
- Instruction and Data Memories

Additional verification covers immediate instruction decoding, signed and unsigned arithmetic behavior, shift encodings, byte selection, sign extension, and partial memory writes.

### Processor-Level Integration Verification

Seven integration testbenches are included in the automated regression:

| Testbench | Verification focus |
|---|---|
| `tb_single_cycle_cpu.sv` | Basic arithmetic, register write-back, LW, and SW |
| `tb_branches.sv` | BEQ/BNE behavior and branch-target selection |
| `tb_branch_comparisons.sv` | Signed and unsigned relational branches |
| `tb_jumps.sv` | JAL/JALR targets and return-address write-back |
| `tb_immediate_instructions.sv` | Immediate arithmetic, logic, comparison, and shifts |
| `tb_upper_immediate.sv` | LUI and AUIPC |
| `tb_load_store.sv` | Byte, halfword, and word memory operations |

**Current result: All seven processor-level integration testbenches pass.**

These are directed functional tests. Broader instruction combinations, random testing, formal properties, reference-model comparison, and comprehensive ISA compliance testing remain future work.

### Example Integration Program

The first integrated processor test executes:

```asm
ADDI x1, x0, 16
ADDI x2, x0, 7
ADD  x3, x1, x2
SW   x3, 0(x0)
LW   x4, 0(x0)
ADD  x5, x4, x2
```

Expected and observed architectural state:

| Register / Memory | Value |
|---|---:|
| x1 | 16 |
| x2 | 7 |
| x3 | 23 |
| x4 | 23 |
| x5 | 30 |
| Data Memory[0] | 23 |

The processor correctly executed the sequence in the integration test and produced the expected register and memory contents.

## Repository Structure

```text
RV32I-Processor/
├── docs/
│   ├── architecture.md
│   ├── isa-notes.md
│   ├── design-decisions.md
│   ├── verification-plan.md
│   └── performance-analysis.md
├── rtl/
│   ├── common/
│   │   ├── alu.sv
│   │   ├── data_memory.sv
│   │   ├── immediate_generator.sv
│   │   ├── instruction_memory.sv
│   │   ├── program_counter.sv
│   │   └── register_file.sv
│   ├── single_cycle/
│   │   ├── control_unit.sv
│   │   └── single_cycle_cpu.sv
│   └── pipeline/
├── tb/
│   ├── unit/
│   └── integration/
│       ├── tb_single_cycle_cpu.sv
│       ├── tb_branches.sv
│       ├── tb_branch_comparisons.sv
│       ├── tb_jumps.sv
│       ├── tb_immediate_instructions.sv
│       ├── tb_upper_immediate.sv
│       └── tb_load_store.sv
├── programs/
│   ├── tests/
│   └── benchmarks/
├── fpga/
│   ├── constraints/
│   ├── top/
│   └── reports/
├── scripts/
│   └── run_single_cycle_tests.ps1
├── README.md
└── .gitignore
```

## Running the Simulations

The project uses Icarus Verilog with SystemVerilog support.

### Automated Single-Cycle Regression

From the repository root on Windows, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_single_cycle_tests.ps1
```

This executes the regression script with a process-scoped execution-policy bypass. Review scripts before running them.

The regression script compiles and executes seven processor-level integration testbenches.

Expected successful completion:

```text
ALL SINGLE-CYCLE INTEGRATION TESTS PASSED
```

### Individual Processor Integration Test

Compile:

```powershell
iverilog -g2012 -s tb_single_cycle_cpu -o tb_cpu.vvp rtl/common/program_counter.sv rtl/common/register_file.sv rtl/common/alu.sv rtl/common/immediate_generator.sv rtl/common/instruction_memory.sv rtl/common/data_memory.sv rtl/single_cycle/control_unit.sv rtl/single_cycle/single_cycle_cpu.sv tb/integration/tb_single_cycle_cpu.sv
```

Run:

```powershell
vvp tb_cpu.vvp
```

Expected successful completion:

```text
FIRST INTEGRATED CPU PROGRAM PASSED
```

## Development Milestones

### M1: Architecture and ISA Planning

Initial architecture, instruction formats, datapath organization, and verification requirements have been established.

Remaining architectural documentation and specification details will be refined as development progresses.

### M2: Single-Cycle RV32I Processor

**Status: Initial implementation and directed verification completed**

- Foundational RTL modules implemented.
- Core arithmetic and logical operations supported.
- Immediate instruction execution supported.
- Conditional branches and jumps implemented.
- LUI and AUIPC implemented.
- Byte, halfword, and word memory operations implemented.
- Seven integration testbenches passing.
- Automated regression script established.

Remaining work includes broader architectural verification, exception behavior, and additional specification coverage.

### M3: Five-Stage Pipelined Processor

**Status: Not started**

Planned pipeline stages:

1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

Development will introduce pipeline registers and progressively address data hazards, control hazards, forwarding, stalls, and instruction flushing.

### M4: Comprehensive Verification

**Status: Initial verification completed; expanded phase pending**

Future work includes reference-model comparison, broader instruction coverage, edge cases, and verification of pipeline hazards.

### M5: FPGA Implementation and Performance Analysis

**Status: Not started**

The completed processor implementations will be synthesized and evaluated on FPGA hardware.

### M6: Research-Oriented Architectural Extension

**Status: Future consideration**

Potential architectural experiments will be selected based on measurable engineering questions and results from the baseline implementations.

## Performance Evaluation

Future analysis will investigate:

- Maximum achievable clock frequency.
- Critical-path delay.
- FPGA logic and register utilization.
- On-chip memory resource consumption.
- Cycles per instruction (CPI).
- Instruction throughput.
- Program execution time.
- Pipeline stall frequency and control-flow penalties.
- Comparative performance of single-cycle and pipelined designs.

Performance claims will be supported by measured results and documented experimental conditions.

No FPGA timing, resource utilization, or benchmark performance measurements have been reported at this stage.

## References

- [RISC-V RV32I Base Integer Instruction Set](https://docs.riscv.org/reference/isa/unpriv/rv32.html)
- [RISC-V Unprivileged ISA Specification](https://docs.riscv.org/reference/isa/unpriv/unpriv-index.html)

## Author

**Alex Marfo Appiah**  
BSc Computer Engineering  
Kwame Nkrumah University of Science and Technology (KNUST), Ghana