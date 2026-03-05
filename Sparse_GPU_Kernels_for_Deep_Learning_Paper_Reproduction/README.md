# Sparse GPU Kernels for Deep Learning — Paper Reproduction

Reproduction of **"Sparse GPU Kernels for Deep Learning"** (Gale et al., 2020) on an NVIDIA RTX 4070 Super. The original paper benchmarks SpMM (Sparse Matrix–Matrix Multiplication) and sparse depthwise convolution on a V100; this work reproduces the key findings on a consumer Ampere-generation GPU using the Sputnik library.

**Paper**: T. Gale, M. Zaharia, C. Young, E. Elsen — *Sparse GPU Kernels for Deep Learning*, NeurIPS 2020

---

## What Was Reproduced

- SpMM throughput curves vs. sparsity level for Sputnik, cuSPARSE, and dense cuBLAS
- Sparsity break-even point: the crossover where sparse beats dense
- Sparse depthwise convolution at varying input resolutions

---

## Key Results (RTX 4070 Super, CUDA 13.1)

| Metric | This Reproduction | Paper (V100) |
|---|---|---|
| Sparsity break-even (SpMM vs cuBLAS) | **70.5%** | ~71% |
| Peak SpMM throughput (Sputnik) | **>4.3 TFLOPs** | — |
| cuSPARSE throughput plateau | 1.2–1.4 TFLOPs | — |
| Speedup vs. cuBLAS at 99% sparsity (8192×2048×128) | **7.8x** (172 µs vs 1,344 µs) | — |
| Max speedup vs. cuSPARSE (large matrices) | **3.5x** | — |
| Depthwise conv peak throughput | 1.42 T/s at 112×112 | — |

The 70.5% break-even on RTX 4070 Super closely matches the paper's ~71% on V100, confirming that kernel efficiency scales across GPU generations despite architectural differences.

---

## Architecture Notes

**Why Sputnik outperforms cuSPARSE here:**
- Sputnik exploits row-level load balancing optimized for deep learning weight matrices (structured sparsity patterns)
- cuSPARSE is a general-purpose library; its kernels are not co-optimized for the column distributions common in pruned DNN weights
- At low-to-moderate sparsity (<70%), the overhead of sparse indexing dominates — hence the break-even point

**Matrix dimensions tested** follow the paper's benchmark set (e.g., 8192×2048×128), which represents realistic transformer/MLP weight shapes.

---

## How to Run

The benchmarks require the Sputnik library, CUDA toolkit, and cuSPARSE (included with CUDA).

```bash
# Build and run (see Reproduction_Report.pdf for full setup)
nvcc -O3 -lcusparse benchmark.cu -o benchmark
./benchmark
```

Full setup instructions, environment details, and raw output plots are in `Reproduction_Report.pdf`.

---

## Hardware

- GPU: NVIDIA GeForce RTX 4070 Super (12 GB GDDR6X, Ada Lovelace, 2560 CUDA cores)
- CUDA: 13.1
- OS: Ubuntu 22.04

---

## Limitations and Honest Assessment

- Depthwise convolution results are hardware-dependent; absolute TFLOPs differ from V100 results in the paper
- The paper's full benchmark suite includes additional matrix shapes not reproduced here
- Sputnik's structured sparsity assumption holds well for pruned DNNs but degrades for truly random sparsity patterns
