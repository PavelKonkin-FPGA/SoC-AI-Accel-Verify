@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: CONFIGURATION: SET YOUR PROJECT PATHS HERE
set PY_DIR=C:\your_python_project_path
set VERILOG_DIR=%~dp0

cd /d "%VERILOG_DIR%"

echo ===================================================
echo    SoC AI Accelerator: Full Verification Cycle
echo ===================================================

:: 1. Data Generation
echo [1/4] Python: Running %PY_DIR%\verify.py
python "%PY_DIR%\verify.py"
if %errorlevel% neq 0 (
    echo [ERROR] Data generation failed.
    pause
    exit /b 1
)

:: 2. Compilation
echo [2/4] Iverilog: Compiling RTL...
iverilog -o sim.vvp -g2012 ^
    accelerator.v ^
    adaptive.v ^
    tb_adaptive.v

if %errorlevel% neq 0 (
    echo [ERROR] Verilog compilation failed.
    pause
    exit /b 1
)

:: 3. Simulation
echo [3/4] VVP: Running Simulation...
if exist fpga_out.hex del fpga_out.hex
vvp sim.vvp

:: 4. Plotting Results
echo [4/4] Python: Generating report via %PY_DIR%\compare_results.py
python "%PY_DIR%\compare_results.py"

echo ===================================================
echo    Done! Please check: verification_report_fixed.png
echo ===================================================
pause