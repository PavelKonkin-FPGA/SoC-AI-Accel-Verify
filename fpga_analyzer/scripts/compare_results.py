import matplotlib.pyplot as plt
import numpy as np
import os

MODES = [4, 8, 16, 32, 64, 128]
SAMPLES_PER_MODE = 100
# LATENCY: Number of clock cycles the FPGA lags behind the Python model
# Adjust this value (usually 1, 2, or 3) until Error Delta reaches 0
LATENCY = 1

def load_hex(filename):
    if not os.path.exists(filename):
        print(f"File {filename} not found!")
        return []
    data = []
    with open(filename, 'r') as f:
        for line in f:
            clean_line = line.strip()
            if not clean_line:
                continue
            try:
                # Convert HEX to int. Python handles 128-bit integers natively
                data.append(int(clean_line, 16))
            except ValueError:
                data.append(0)
    return data

def plot_verification():
    golden = load_hex('golden_ref.hex')
    fpga_raw = load_hex('fpga_out.hex')

    if not golden or not fpga_raw:
        return

    # --- LATENCY COMPENSATION (SYNCHRONIZATION) ---
    # We trim the first 'LATENCY' elements from FPGA and the last from Golden
    # to align the data streams in time.
    fpga = fpga_raw[LATENCY:]

    # Synchronize lengths after shift
    limit = min(len(golden), len(fpga))
    golden = golden[:limit]
    fpga = fpga[:limit]

    fig, axes = plt.subplots(3, 2, figsize=(15, 12))
    fig.suptitle(f'SoC AI Accelerator: Verification (Phase Shift: {LATENCY} cycle)', fontsize=16)
    axes = axes.flatten()

    for i, mode in enumerate(MODES):
        start = i * SAMPLES_PER_MODE
        end = start + SAMPLES_PER_MODE

        # Data slices for the current mode
        g_part = golden[start:end]
        f_part = fpga[start:end]

        if not g_part or not f_part: continue

        ax = axes[i]
        curr_len = min(len(g_part), len(f_part))
        x = np.arange(curr_len)

        # Convert to float for plotting (Matplotlib scale handling)
        g_plot = [float(val) for val in g_part[:curr_len]]
        f_plot = [float(val) for val in f_part[:curr_len]]

        # Calculate Error Delta
        error = [float(g - f) for g, f in zip(g_part[:curr_len], f_part[:curr_len])]

        ax.plot(x, g_plot, 'g-', label='Golden (Python)', alpha=0.6, linewidth=2)
        ax.plot(x, f_plot, 'r--', label='FPGA Out', alpha=0.8)
        ax.fill_between(x, 0, error, color='blue', alpha=0.3, label='Error Delta')

        ax.set_title(f'Mode: {mode}-bit')
        ax.grid(True, linestyle=':', alpha=0.7)

        if i >= 4: ax.set_xlabel('Samples')
        if i % 2 == 0: ax.set_ylabel('Amplitude')
        ax.legend(loc='upper right', fontsize='x-small')

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.savefig('verification_report_fixed.png', dpi=300)
    print(f"--- [OK] Sync complete (Latency={LATENCY}). Report saved. ---")
    plt.show()

if __name__ == "__main__":
    plot_verification()