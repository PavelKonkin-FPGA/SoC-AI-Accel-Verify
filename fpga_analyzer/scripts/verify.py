import os
import random

# CONFIGURATION
TARGET_DIR = r"C:\your_fpga_project_path"
MODES = [4, 8, 16, 32, 64, 128]
SAMPLES_PER_MODE = 100

# GLOBAL MASKS
MASK32 = 0xFFFFFFFF
MASK128 = (1 << 128) - 1


def acc_core_logic(data_in, core_id, mode):
    # Split 128-bit input into four 32-bit words
    v = [(data_in >> (32 * i)) & MASK32 for i in range(4)]

    if mode == 4:   return ((v[0] + v[1]) * (core_id + 1)) & MASK128
    if mode == 8:   return ((v[0] + v[2]) & MASK32) | (((v[1] + v[3]) & MASK32) << 32)
    if mode == 16:
        res = 0
        for i in range(4): res |= ((v[i] + core_id) & MASK32) << (32 * i)
        return res & MASK128
    if mode == 32:  return ((v[0] * v[1]) + (v[2] * v[3])) & MASK128
    if mode == 64:  return (((data_in << 64) | (data_in >> 64)) ^ core_id) & MASK128
    if mode == 128: return (v[0] * 1 + v[1] * 2 + v[2] * 3 + v[3] * 4 + core_id) & MASK128
    return (data_in ^ core_id) & MASK128


def generate_full_test():
    all_inputs, all_golden = [], []
    for m in MODES:
        for _ in range(SAMPLES_PER_MODE):
            x = random.getrandbits(128)
            # XOR sum of cores 0, 8, and 15
            res = acc_core_logic(x, 0, m) ^ acc_core_logic(x, 8, m) ^ acc_core_logic(x, 15, m)
            all_inputs.append(x)
            all_golden.append(res & MASK128)  # Now 'MASK128' is resolved

    if not os.path.exists(TARGET_DIR): os.makedirs(TARGET_DIR)

    with open(os.path.join(TARGET_DIR, "input_data.hex"), "w") as f:
        for v in all_inputs: f.write(f"{v:032x}\n")

    with open(os.path.join(TARGET_DIR, "golden_ref.hex"), "w") as f:
        for v in all_golden: f.write(f"{v:032x}\n")

    print(f"--- [OK] Generated {len(all_inputs)} vectors across 6 modes ---")


if __name__ == "__main__":
    generate_full_test()