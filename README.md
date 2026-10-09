
# RV32I Processor — RTL Design & FPGA Implementation

An ongoing computer architecture project exploring the design, implementation, verification, and performance analysis of a 32-bit RISC-V processor using Verilog HDL.

The project builds on my completed [FPGA-Synthesizable 8-Bit CPU](https://github.com/theboylexis/FPGA-Synthesizable-8Bit-CPU), progressing from a custom multi-cycle architecture toward a standardized RISC-V instruction set and more advanced processor microarchitectures.

## Project Objectives

- Implement an RV32I single-cycle processor.
- Develop a five-stage pipelined RV32I implementation.
- Implement data forwarding, hazard detection, pipeline stalls, and flushing.
- Handle branches and other control-flow instructions.
- Develop unit-level and processor-level verification tests.
- Implement and validate the processor on an FPGA.
- Analyze timing, FPGA resource utilization, and architectural performance.
- Explore a research-motivated architectural extension.

## Development Roadmap

- [ ] Study RV32I specifications and define implementation requirements.
- [ ] Document the single-cycle datapath and control architecture.
- [ ] Implement and verify the single-cycle processor.
- [ ] Design and implement a five-stage pipeline.
- [ ] Implement forwarding and hazard handling.
- [ ] Implement control hazard handling and pipeline flushing.
- [ ] Complete instruction-level and processor-level verification.
- [ ] Implement and validate the design on an FPGA.
- [ ] Collect synthesis, timing, and resource utilization results.
- [ ] Conduct architectural benchmarking and comparative analysis.
- [ ] Investigate a research-oriented architectural extension.

## Planned Architecture

| Feature | Target |
|---|---|
| ISA | RISC-V RV32I |
| Data width | 32 bits |
| Initial microarchitecture | Single-cycle |
| Advanced microarchitecture | Five-stage pipeline |
| Pipeline stages | IF, ID, EX, MEM, WB |
| RTL language | Verilog |
| Verification | Unit and processor-level simulation |
| FPGA target | To be finalized |
| Performance evaluation | Timing, resource utilization, and benchmarking |

The initial implementation will establish a functional baseline before introducing pipelining and subsequent architectural improvements.

## Repository Structure

```text
docs/               Architecture, ISA, verification, and analysis
rtl/
  common/            Shared RTL components
  single_cycle/      Single-cycle implementation
  pipeline/          Pipelined implementation
tb/
  unit/              Module-level testbenches
  integration/       Processor-level testbenches
programs/
  tests/             Assembly and machine-code test programs
  benchmarks/        Performance evaluation workloads
fpga/
  constraints/       FPGA constraints
  top/               Board-level integration
  reports/           Synthesis and timing reports
scripts/             Build, simulation, and analysis scripts
```

## Verification Strategy

Verification will be developed alongside RTL implementation rather than deferred until integration.

Planned activities include:

- Unit testing of individual modules.
- Instruction-level functional testing.
- Processor integration testing.
- Directed edge-case testing.
- Comparison against a trusted RISC-V reference model.
- FPGA hardware validation.

## Performance Analysis

The project will investigate measurable architectural and implementation characteristics, including:

- Clock frequency and critical-path delay.
- FPGA logic and register utilization.
- Cycles per instruction (CPI).
- Instruction execution performance.
- Pipeline stalls and branch penalties.
- Architectural trade-offs between implementations.

Comparisons will distinguish between architectural performance and FPGA implementation characteristics.

## Current Status

**Phase 1 — Repository setup and architectural planning**

RTL implementation has not yet begun.

## Author

**Alex Marfo Appiah**  
BSc Computer Engineering — KNUST

[GitHub](https://github.com/theboylexis) · [LinkedIn](https://linkedin.com/in/alexmarfoappiah)
