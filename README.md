
# RV32I Processor — RTL Design & FPGA Implementation

An ongoing computer architecture project focused on the design, implementation, verification, and performance analysis of a 32-bit RISC-V processor using Verilog HDL.

This project builds on my completed [FPGA-Synthesizable 8-Bit CPU](https://github.com/theboylexis/FPGA-Synthesizable-8Bit-CPU), progressing from a custom multi-cycle processor toward the standardized RISC-V ISA and more advanced processor microarchitectures.

## Project Objectives

- Design and implement an RV32I single-cycle processor.
- Develop a five-stage pipelined RV32I implementation.
- Implement data forwarding, hazard detection, stalls, and pipeline flushing.
- Support conditional branches, jumps, and other control-flow instructions.
- Develop comprehensive RTL verification and processor-level tests.
- Implement and physically validate the processor on an FPGA.
- Analyze timing, resource utilization, and architectural performance.
- Explore a research-oriented architectural extension.

## Development Roadmap

- [ ] Study the RV32I specification and define implementation requirements.
- [ ] Document the single-cycle datapath and control architecture.
- [ ] Implement and verify the single-cycle processor.
- [ ] Design and implement a five-stage pipeline.
- [ ] Implement forwarding and data hazard handling.
- [ ] Implement control hazard handling and pipeline flushing.
- [ ] Complete comprehensive instruction-level and processor-level verification.
- [ ] Implement and validate the processor on FPGA hardware.
- [ ] Collect synthesis, timing, and resource utilization results.
- [ ] Conduct architectural benchmarking and comparative analysis.
- [ ] Investigate a research-motivated architectural extension.

## Planned Architecture

| Feature | Target |
|---|---|
| ISA | RISC-V RV32I |
| Integer register width (XLEN) | 32 bits |
| General-purpose registers | 32 × 32-bit (x0 hardwired to zero) |
| Instruction width | 32 bits (base RV32I) |
| Initial microarchitecture | Single-cycle |
| Advanced microarchitecture | Five-stage pipeline |
| Pipeline stages | IF, ID, EX, MEM, WB |
| RTL language | Verilog HDL |
| Verification | Unit-level, instruction-level, and processor-level testing |
| FPGA target | To be finalized |
| Performance evaluation | Timing, resource utilization, CPI, and benchmarking |

The initial single-cycle implementation will establish a functional baseline before introducing pipelining and architectural optimizations.

Instruction support, memory behavior, exception handling, and other implementation requirements will be documented during the architecture planning phase. Full RV32I compliance will not be claimed until the implemented behavior has been appropriately verified.

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
│   ├── single_cycle/
│   └── pipeline/
├── tb/
│   ├── unit/
│   └── integration/
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

## Verification Strategy

Verification will be developed alongside RTL implementation rather than deferred until processor integration.

Planned activities include:

- Module-level testbenches for individual hardware components.
- Directed instruction-level functional tests.
- Processor-level integration and program execution tests.
- Edge-case testing for arithmetic, memory access, and control flow.
- Comparison against a trusted RISC-V reference model.
- FPGA hardware validation against simulation results.

## Performance Analysis

The project will evaluate architectural and FPGA implementation characteristics, including:

- Maximum clock frequency and critical-path delay.
- FPGA logic, register, and memory resource utilization.
- Cycles per instruction (CPI).
- Instruction execution time and benchmark performance.
- Pipeline stalls and branch penalties.
- Performance and implementation trade-offs between architectures.

Comparisons will use documented workloads and measurement conditions to distinguish microarchitectural improvements from FPGA implementation effects.

## Current Status

**M1 — Architecture & ISA Planning (In Progress)**

- [x] Repository structure established.
- [x] GitHub milestones and initial issues created.
- [x] Studied the RV32I register model and six instruction formats.
- [ ] Document complete RV32I instruction semantics.
- [ ] Define single-cycle datapath and control architecture.
- [ ] Document architectural design decisions.
- [ ] Develop processor verification plan.
- [ ] Define performance evaluation methodology.

**Implementation status:** RTL development has not yet begun.

## References

- [RISC-V RV32I Base Integer Instruction Set](https://docs.riscv.org/reference/isa/unpriv/rv32.html)
- [RISC-V Unprivileged ISA Specification](https://docs.riscv.org/reference/isa/unpriv/unpriv-index.html)

## Author

**Alex Marfo Appiah**  
BSc Computer Engineering — KNUST

[LinkedIn](https://linkedin.com/in/alexmarfoappiah)
