# Sparse GPU Kernels for Deep Learning — Course Reproduction

This course-team study adapted and benchmarked the **original [Sputnik](https://github.com/google-research/sputnik) implementation** on an NVIDIA GeForce RTX 4070 Super. Our contribution was environment porting, compatibility fixes, benchmark execution, and analysis—not authorship of Sputnik's GPU kernels. The accompanying [report](Reproduction_Report.pdf) describes the experiments and results.

**Original paper:** T. Gale, M. Zaharia, C. Young, and E. Elsen, [“Sparse GPU Kernels for Deep Learning”](https://people.eecs.berkeley.edu/~matei/papers/2020/sc_sparse_gpu.pdf), **SC '20** (not NeurIPS 2020).

## Scope and environment

- GPU: GeForce RTX 4070 Super (12 GB, **Ada Lovelace** architecture).
- Workstation OS: Ubuntu 22.04. The report describes porting to CUDA 13.1, targeting compute capability 8.9 in CMake, and fixing an Abseil `std::max` type mismatch by casting to `size_t`.
- The report also describes a custom container based on `nvidia/cuda:12.2.2-devel-ubuntu22.04`. Because neither that Dockerfile nor the patched source is published here, the exact build environment for the reported runs cannot be reconstructed from this folder alone.
- We ran Sputnik's benchmark suite for sparse matrix–dense matrix multiplication (SpMM), sampled dense–dense matrix multiplication (SDDMM), and depthwise convolution. The SpMM comparisons include cuSPARSE and dense cuBLAS. This is a **limited reproduction on different hardware**, not a reimplementation or validation of every result in the original paper.

## Results reported in the course report

| Experiment | Reported observation | Scope |
|---|---|---|
| SpMM sparse/dense crossover | About **70.5% sparsity** | Sputnik versus dense cuBLAS for the reported 8192 × 2048 × 128 case; not a universal threshold. |
| SpMM at 99% sparsity | About **39 µs** for Sputnik versus **299 µs** for dense cuBLAS | Same reported matrix case; about 7.7× using these rounded times. The report describes this as 7.8×. |
| SpMM throughput | Peak above **4.3 TFLOP/s** for Sputnik; cuSPARSE around **1.2–1.4 TFLOP/s** | Reported benchmark plots and tested problem sizes. |
| SpMM versus cuSPARSE | Up to **3.5×** faster | Large tested matrices in the report; not a claim for all inputs. |
| Depthwise convolution | Peak **1.42 T/s** at 112 × 112 | As labeled in the report; the benchmark's throughput unit is not further defined here. |

The previous README paired **172 µs / 1,344 µs** with the 99%-sparsity result. Those numbers are not the 99% case shown in the report: it reports **172 µs / 299 µs at 90%** and **39 µs / 299 µs at 99%** for the matrix above. The table now follows the report. These are **report-derived results**; raw benchmark logs and plotting inputs are not included in this repository.

## Reproduction status

This folder currently contains the report and this summary, **not a runnable benchmark checkout**. In particular, it does not contain the modified Sputnik source, Dockerfile, `benchmark.cu`, build scripts, or raw outputs. The old `nvcc ... benchmark.cu` instruction was removed because it could not run from this folder. For the starting code, see [upstream Sputnik](https://github.com/google-research/sputnik). Reproducing these exact reported runs would additionally require the team's compatibility changes, complete build commands, benchmark configuration, and raw outputs.

The techniques discussed in the report—such as subwarp tiling, reverse-offset memory alignment, and row swizzling—come from the **original Sputnik work**. The observed crossover on this one GPU/setup is similar to that cited for the V100 in the report, but does not establish that performance scales generally across GPU generations.
