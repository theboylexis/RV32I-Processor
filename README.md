# RV32I Processor — RTL Design & FPGA Implementation

An ongoing computer architecture project focused on the design, implementation, verification, and performance evaluation of a 32-bit RISC-V processor using **SystemVerilog**.

This project builds on my completed [FPGA-Synthesizable 8-Bit CPU](https://github.com/theboylexis/FPGA-Synthesizable-8Bit-CPU), progressing from a custom multi-cycle processor toward the standardized RISC-V instruction set architecture and more advanced processor microarchitectures.

Development follows an incremental hardware engineering approach, combining architectural design, RTL implementation, module-level verification, processor integration, and eventual FPGA-based performance evaluation.

## Project Objectives

- Design and verify an RV32I single-cycle processor.
- Develop a five-stage pipelined RV32I implementation.
- Implement data forwarding, hazard detection, stalls, and pipeline flushing.
- Support arithmetic, logical, memory-access, branch, and jump instructions.
- Develop comprehensive SystemVerilog verification environments.
- Implement and physically validate the processor on an FPGA.
- Analyze timing, resource utilization, and architectural performance.
- Investigate a research-oriented architectural extension where justified by a meaningful research question.

## Development Roadmap

- [x] Establish repository structure and development environment.
- [x] Study introductory RV32I concepts and instruction formats.
- [x] Establish the initial single-cycle datapath architecture.
- [x] Implement foundational processor modules in SystemVerilog.
- [x] Develop and execute initial module-level tests.
- [x] Integrate the initial single-cycle processor datapath.
- [x] Execute and verify the first processor-level test program.
- [ ] Complete the single-cycle RV32I instruction implementation.
- [ ] Extend verification to instruction edge cases and comprehensive processor tests.
- [ ] Develop and verify a five-stage pipelined processor.
- [ ] Implement forwarding, hazard detection, stalls, and pipeline flushing.
- [ ] Implement and validate the processor on FPGA hardware.
- [ ] Collect synthesis, timing, and resource utilization results.
- [ ] Conduct architectural benchmarking and comparative analysis.
- [ ] Evaluate a research-motivated architectural extension.

## Planned Architecture

| Feature | Specification / Target |
|---|---|
| ISA | RISC-V RV32I |
| Integer register width (XLEN) | 32 bits |
| General-purpose registers | 32 × 32-bit |
| Zero register | x0 hardwired to zero |
| Instruction width | 32 bits |
| RTL language | SystemVerilog |
| Initial microarchitecture | Single-cycle |
| Advanced microarchitecture | Five-stage pipeline |
| Pipeline stages | IF, ID, EX, MEM, WB |
| Initial instruction memory | 256 × 32-bit words |
| Initial data memory | 256 × 32-bit words |
| Initial memory access support | Aligned 32-bit loads and stores |
| Verification tools | Icarus Verilog; additional tools to be evaluated |
| FPGA target | To be finalized |
| Performance evaluation | Clock frequency, critical path, resource utilization, CPI, and benchmarking |

The single-cycle processor serves as the architectural and verification baseline for subsequent pipelining and performance analysis.

The current integrated implementation supports a limited subset of RV32I instructions. Full RV32I compliance has not been established.

## RTL Implementation

Development uses modular SystemVerilog components organized into reusable hardware blocks and microarchitecture-specific modules.

### Completed Foundational Modules

| Module | Description | Initial Verification |
|---|---|---|
| Program Counter | 32-bit sequential PC register with synchronous reset | Passed |
| Register File | 32 × 32-bit registers, two asynchronous read ports, one synchronous write port, x0 protection | Passed |
| Arithmetic Logic Unit | 32-bit arithmetic, logical, shift, and comparison operations | Passed |
| Immediate Generator | I, S, B, U, and J immediate extraction and extension | Passed |
| Control Unit | Initial instruction decoding and datapath control generation | Passed |
| Instruction Memory | Byte-addressed instruction fetch with combinational reads | Passed |
| Data Memory | Aligned 32-bit word reads and synchronous writes | Passed |

### Single-Cycle Processor Integration

The initial processor implementation connects the foundational modules into an executable single-cycle datapath.

Implemented functionality includes:

- Instruction fetch using the program counter.
- Sequential PC advancement.
- Instruction decoding and control-signal generation.
- Register operand retrieval.
- Register-register ALU operations.
- ADDI execution.
- Aligned LW and SW execution.
- ALU operand selection and register write-back.
- Synchronous updates to architectural state.

The current processor prototype has successfully executed a six-instruction integration test.

Conditional branches, jumps, additional immediate operations, byte/halfword memory accesses, and remaining ISA functionality are not yet implemented in the integrated processor.

## Verification

Verification is developed alongside RTL implementation.

### Module-Level Verification

The following initial directed tests have passed:

| Module / Subsystem | Tests Passed |
|---|---:|
| Program Counter | 5 |
| Register File | 5 |
| ALU | 20 |
| Immediate Generator | 12 |
| Control Unit | 10 |
| Memory Subsystem | 8 |
| **Total** | **60** |

These tests evaluate selected functional behavior and edge cases. They do not constitute exhaustive verification.

### Processor-Level Integration Test

The first integrated processor test executes the following program:

```asm
ADDI x1, x0, 16
ADDI x2, x0, 7
ADD  x3, x1, x2
SW   x3, 0(x0)
LW   x4, 0(x0)
ADD  x5, x4, x2
```

**Expected and observed final state:**

| Register / Memory | Value |
|---|---:|
| x1 | 16 |
| x2 | 7 |
| x3 | 23 |
| x4 | 23 |
| x5 | 30 |
| Data Memory[0] | 23 |

All register and memory checks passed. Sequential PC progression was also verified.

**Integration result: FIRST INTEGRATED CPU PROGRAM PASSED**

### Planned Verification Extensions

- Expanded instruction-level directed testing.
- Boundary-condition and signed/unsigned arithmetic testing.
- Branch and jump verification.
- Additional memory-access and alignment tests.
- Randomized instruction sequences where appropriate.
- Comparison against a trusted RISC-V reference implementation.
- Broader instruction-set compliance testing.
- FPGA hardware validation against simulation results.

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
│   │   ├── tb_alu.sv
│   │   ├── tb_control_unit.sv
│   │   ├── tb_immediate_generator.sv
│   │   ├── tb_memory.sv
│   │   ├── tb_program_counter.sv
│   │   └── tb_register_file.sv
│   └── integration/
│       └── tb_single_cycle_cpu.sv
├── programs/
│   ├── tests/
│   └── benchmarks/
├── fpga/
│   ├── constraints/
│   ├── top/
│   └── reports/
├── scripts/
├── README.md
└── .gitignore
```

## Simulation

The initial processor integration test can be compiled using Icarus Verilog with SystemVerilog support enabled.

From the repository root:

```powershell
iverilog -g2012 -s tb_single_cycle_cpu -o tb_cpu.vvp rtl/common/program_counter.sv rtl/common/register_file.sv rtl/common/alu.sv rtl/common/immediate_generator.sv rtl/common/instruction_memory.sv rtl/common/data_memory.sv rtl/single_cycle/control_unit.sv rtl/single_cycle/single_cycle_cpu.sv tb/integration/tb_single_cycle_cpu.sv
```

Run the simulation:

```powershell
vvp tb_cpu.vvp
```

Successful execution produces:

```text
FIRST INTEGRATED CPU PROGRAM PASSED
```

The current integration test uses a simulation-loaded program and directly inspects the final architectural state.

## Performance Analysis

Future work will evaluate:

- Maximum achievable clock frequency.
- Critical-path delay and timing closure.
- FPGA logic, register, and memory utilization.
- Instruction throughput and cycles per instruction.
- Program execution time under documented workloads.
- Pipeline stalls and control-flow penalties.
- Comparative performance of single-cycle and pipelined implementations.

Experimental comparisons will use documented workloads, measurement conditions, and implementation assumptions.

No FPGA performance measurements have been reported at this stage.

## Current Development Status

**M1 — Architecture & ISA Planning: Partially completed / ongoing refinement**

- [x] Repository structure established.
- [x] GitHub milestones and initial issues created.
- [x] Introductory RV32I instruction formats and register model studied.
- [x] Initial datapath and control requirements established.
- [ ] Finalize implementation assumptions and remaining ISA requirements.
- [ ] Refine architecture and verification documentation.

**M2 — RV32I Single-Cycle Processor: In progress**

- [x] Implement and initially verify foundational RTL modules.
- [x] Implement initial instruction decoder.
- [x] Integrate the initial single-cycle datapath.
- [x] Execute the first six-instruction processor-level program.
- [ ] Strengthen instruction decoder validation.
- [ ] Implement branches and jumps.
- [ ] Complete remaining RV32I instruction functionality.
- [ ] Expand integration and instruction-level verification.

**M3 — Five-Stage Pipelined Processor: Not started**

**M4 — Comprehensive Verification: Initial tests underway; dedicated phase pending**

**M5 — FPGA Implementation & Performance Analysis: Not started**

**M6 — Research-Oriented Architectural Extension: Not started / scope to be evaluated**

## References

- [RISC-V RV32I Base Integer Instruction Set](https://docs.riscv.org/reference/isa/unpriv/rv32.html)
- [RISC-V Unprivileged ISA Specification](https://docs.riscv.org/reference/isa/unpriv/unpriv-index.html)

## Author

**Alex Marfo Appiah**  
BSc Computer Engineering  
Kwame Nkrumah University of Science and Technology (KNUST), Ghana

[LinkedIn](https://linkedin.com/in/alexmarfoappiah)
