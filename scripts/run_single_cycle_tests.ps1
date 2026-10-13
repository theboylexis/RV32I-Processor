
$ErrorActionPreference = "Stop"

$rtl = @(
    "rtl/common/program_counter.sv"
    "rtl/common/register_file.sv"
    "rtl/common/alu.sv"
    "rtl/common/immediate_generator.sv"
    "rtl/common/instruction_memory.sv"
    "rtl/common/data_memory.sv"
    "rtl/single_cycle/control_unit.sv"
    "rtl/single_cycle/single_cycle_cpu.sv"
)

$tests = @(
    "tb_single_cycle_cpu"
    "tb_branches"
    "tb_branch_comparisons"
    "tb_jumps"
    "tb_immediate_instructions"
    "tb_upper_immediate"
    "tb_load_store"
)

New-Item -ItemType Directory -Force -Path "simulations/build" | Out-Null

foreach ($test in $tests) {
    Write-Host "`n=== Running $test ===" -ForegroundColor Cyan

    $output = "simulations/build/$test.vvp"
    $testbench = "tb/integration/$test.sv"

    & iverilog -g2012 -s $test -o $output @rtl $testbench

    if ($LASTEXITCODE -ne 0) {
        throw "Compilation failed: $test"
    }

    & vvp $output

    if ($LASTEXITCODE -ne 0) {
        throw "Simulation failed: $test"
    }

    Write-Host "PASS: $test" -ForegroundColor Green
}

Write-Host "`nALL SINGLE-CYCLE INTEGRATION TESTS PASSED" -ForegroundColor Green
