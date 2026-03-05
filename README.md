# Heterogeneous Parallel Programming

Coursework and paper reproduction projects from a graduate-level heterogeneous computing course. Covers GPU kernel development in CUDA C/C++, embedded inference on constrained hardware, and parallel algorithms using C++ STL.

---

## Projects

| Directory | Topic | Primary Skill |
|---|---|---|
| `Sparse_GPU_Kernels_for_Deep_Learning_Paper_Reproduction/` | SpMM/SpConv benchmarking on RTX 4070 Super | CUDA, cuSPARSE, Sputnik |
| `Jetson_Nano/` | TensorRT model inference on Tegra X1 | Embedded GPU, nvprof |
| `Programming_Assignment1/` | N-body gravitational simulation (CUDA) | Kernel optimization, unified memory |
| `Programming_Assignment3/` | Parallel select-reduce (C++ STL + NVC++) | `std::execution`, `transform_reduce` |

---

## Hardware Used

- **Development/benchmarking**: NVIDIA GeForce RTX 4070 Super (12 GB VRAM), CUDA 13.1, Ubuntu 22.04
- **Embedded deployment**: NVIDIA Jetson Nano (Tegra X1 SoC, 128 CUDA cores, ~4 W GPU TDP)

---

## Key Results

### Sparse GPU Kernels
- Sputnik SpMM exceeded **4.3 TFLOPs** peak throughput on RTX 4070 Super
- **7.8x speedup** over dense cuBLAS at 99% sparsity (8192x2048x128, 172 µs vs 1,344 µs)
- Reproduced paper's sparsity break-even at **70.5%** (paper reports ~71% on V100)
- cuSPARSE plateaued at 1.2–1.4 TFLOPs; Sputnik reached up to **3.5x faster** on large matrices

### Jetson Nano Inference
- PeopleNet achieved the fastest inference at **~650 ms/image** across three TensorRT models
- Fused convolution kernels hit **99.9% SM utilization** (nvprof `sm_efficiency`)
- NMS post-processing (`gatherTopDetections_kernel`) identified as primary bottleneck at **~12.6% SM efficiency**

---

## Skills Demonstrated

- CUDA C/C++ kernel writing: global memory access patterns, grid-stride loops, unified memory
- GPU profiling: `nsys`, `nvprof`, SM efficiency analysis
- Sparse linear algebra: SpMM, sparse convolution, CSR/CSC formats
- TensorRT model deployment on embedded hardware (Jetson Nano, native build)
- C++ parallel algorithms: `std::execution::par`, `std::transform_reduce`
- Quantitative benchmarking and honest comparison against published paper results
