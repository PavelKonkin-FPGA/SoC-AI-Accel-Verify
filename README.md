Project Overview
This repository presents a comprehensive development and verification environment for a scalable System-on-Chip (SoC) AI Accelerator. The hardware architecture is designed to handle high-throughput computational workloads typical of neural network inference and digital signal processing. By leveraging a parameterizable multi-core design, the system demonstrates how specialized hardware can be optimized for parallel execution of complex mathematical functions across variable data widths.

Architectural Design and Parallelism
The core of the accelerator consists of 24 independent processing elements (cores) implemented in Verilog. This architecture mimics the "Tensor Core" approach used in modern AI hardware, where data is processed in parallel to bypass the bottlenecks of traditional serial CPUs. Each core is assigned a unique CORE_ID, allowing for identity-specific transformations. The system concludes with a high-speed aggregation stage that performs a bitwise XOR reduction of results from selected cores (0, 12, and 23), ensuring efficient data fusion before output.

Adaptive Precision and Computational Modes
A key feature of this accelerator is its Mixed-Precision capability, supporting six distinct operational modes: 4, 8, 16, 32, 64, and 128 bits. This reflects the modern AI trend of Quantization, where lower precision (e.g., 4-bit or 8-bit) is used for power-efficient inference, while higher precision (128-bit) is reserved for complex accumulation. The computational logic includes fused multiply-add operations, cyclic bit-shifts, and hardware-optimized scaling, providing a robust primitive set for neural network layers.

Automated Verification Methodology
The project employs a Golden Model Verification strategy to ensure bit-perfect hardware accuracy. A Python-based mathematical model generates stochastic stimulus and "Golden" reference values. These are compared against the RTL simulation results produced by Icarus Verilog. The framework includes a specialized analysis script that accounts for Pipeline Latency, synchronizing the data streams to calculate an "Error Delta." This ensures that the physical hardware logic matches the theoretical mathematical intent with zero deviation.

Execution and Reproducibility
To facilitate ease of use and reproducibility, the entire verification cycle is automated via a master control script. By executing run_verification.bat, the user triggers a four-stage pipeline: data generation, RTL compilation, VVP simulation, and automated report generation. This "one-click" verification flow is essential for Continuous Integration (CI) in hardware design, allowing developers to immediately identify how RTL changes affect the computational accuracy of the AI accelerator.

Technical Requirements
Simulator: Icarus Verilog (iverilog)

Analysis: Python 3.x (with Matplotlib and NumPy)

Hardware Target: Optimized for Altera/Intel Cyclone V series FPGAs

Toolchain: Quartus Prime (for synthesis)# SoC-AI-Accel-Verify
A Framework for Cycle-Accurate Verification of Adaptive Multi-Core AI Accelerators on FPGA
