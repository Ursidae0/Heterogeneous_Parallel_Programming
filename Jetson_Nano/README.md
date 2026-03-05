# Neural Network Inference on NVIDIA Jetson Nano

Deployment and profiling of three TensorRT-optimized object detection models on the NVIDIA Jetson Nano (Tegra X1 SoC). Focus is on comparing model inference latency and diagnosing SM utilization bottlenecks using `nvprof`.

---

## Models Evaluated

| Model | Inference Time (avg, CPU wall-clock) | Notes |
|---|---|---|
| **PeopleNet** | ~650 ms/image | Fastest overall; optimized for pedestrian detection |
| SSD-Inception-v2 | ~730–800 ms/image | NVIDIA-pretrained, larger backbone |
| SSD-MobileNet-v2 | ~800–890 ms/image | Lightest backbone; highest per-layer fuse efficiency |

Times measured via `detectnet` logs, native (non-Docker) build, averaged across the test sequence.

---

## SM Efficiency Profiling (nvprof)

| Kernel | SSD-MobileNet-v2 | SSD-Inception-v2 | PeopleNet |
|---|---|---|---|
| `fusedConvolutionReluKernel` | **99.6%** | **99.4%** | — |
| `cuInt8::nchwToNchhw2` | — | — | **99.9%** |
| `gatherTopDetections_kernel` (NMS) | ~12.6% | ~12.7% | ~12.6% |

**Key finding**: Fused convolution+activation kernels are near-perfect in SM utilization. The post-processing NMS step (`gatherTopDetections_kernel`) is the universal bottleneck at ~12.6% across all models — a structural limitation of sequential NMS on GPU.

---

## Implementation Decisions

**Native build over Docker:**
Storage on Jetson Nano is constrained (~16 GB eMMC). The team evaluated Docker-based deployment but chose a native/source build to eliminate container filesystem overhead and avoid runtime overhead from the container layer. The profiling results here reflect the native build.

**TensorRT optimization:**
All models were deployed through NVIDIA's `jetson-inference` framework with TensorRT FP16 precision. TensorRT fuses BN, activation, and convolution layers into single kernels — this is what drives the 99%+ SM efficiency on the convolution kernels.

---

## Architecture of the SoC

- **Tegra X1**: ARM Cortex-A57 quad-core CPU + 128-core Maxwell GPU on a single SoC
- **Shared memory bus**: CPU and GPU share the same LPDDR4 memory, making data transfers between host and device essentially free (zero-copy)
- **Power envelope**: ~4 W GPU TDP — inference throughput is fundamentally bandwidth- and memory-constrained, not compute-constrained for these model sizes

---

## Skills Demonstrated

- Embedded GPU deployment with TensorRT
- Low-level profiling with `nvprof` (`sm_efficiency` metric)
- Bottleneck analysis: distinguishing compute-bound vs. memory-bound kernels
- Build environment decisions under storage/resource constraints (native vs. container)
- Quantitative comparison of model architectures on constrained hardware

---

## Files

| File | Description |
|---|---|
| `output_peoplenet.csv` | Per-image inference times, PeopleNet |
| `output_inception.csv` | Per-image inference times, SSD-Inception-v2 |
| `output_mobilenet.csv` | Per-image inference times, SSD-MobileNet-v2 |
| `humans_output_*.jpeg` | Sample detection outputs |
| `report.pdf` | Full report with nvprof tables and methodology |
