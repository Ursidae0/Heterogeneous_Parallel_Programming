# Object Detection Profiling on NVIDIA Jetson Nano

This course-team study built [NVIDIA `jetson-inference`](https://github.com/dusty-nv/jetson-inference) **natively from source** on a Jetson Nano and ran three existing object-detection models through its `detectnet` application. We compared the run-specific image times reported in our [course report](report.pdf) and collected per-kernel `nvprof` **SM-activity metrics**. We did not develop the models, TensorRT kernels, or `jetson-inference` framework.

## Setup and timing observations

The report documents the source build and a profiling command of the form `nvprof --csv --metrics sm_efficiency ./detectnet --network=<model> ...`. We selected a native build partly because storage on the device was constrained. The repository contains the resulting metric CSVs and sample output images, but not the `jetson-inference` source, original `detectnet` timing logs, or a Docker-versus-native performance comparison.

| Model | Approximate per-image CPU time reported by `detectnet` | Interpretation |
|---|---:|---|
| PeopleNet | 620–700 ms | Fastest **in this reported run**; first-run engine setup was much slower. |
| SSD-Inception-v2 | 730–800 ms | Run-specific reported range. |
| SSD-MobileNet-v2 | 800–890 ms | Run-specific reported range; not evidence that MobileNet is generally slower. |

These are **application CPU-time observations from the report**, not GPU-kernel durations or independently repeatable benchmark statistics. The raw timing logs are not published here. The C++ build compiled `detectnet`; TensorRT prepared model-specific engines at runtime rather than the team compiling the model architectures themselves.

## What the published `nvprof` CSVs show

The CSVs contain `sm_efficiency` for named GPU kernels, with **Min**, **Max**, and **Avg** columns. The examples below use **Avg**. NVIDIA defines this metric as the percentage of time at least one warp is active on an SM, averaged across SMs; it is **not** the kernel's share of total inference time, compute throughput, or proof of a bottleneck. See the [CUDA Profiler User's Guide](https://docs.nvidia.com/cuda/archive/11.2.0/profiler-users-guide/index.html).

| Model / CSV | Representative kernel | Average `sm_efficiency` |
|---|---|---:|
| [SSD-MobileNet-v2](output_mobilenet.csv) | `fusedConvolutionReluKernel` (one variant) | 99.66% |
| SSD-MobileNet-v2 | `gatherTopDetections_kernel` | 13.00% |
| SSD-MobileNet-v2 | `allClassNMS_kernel` | 99.59% |
| [SSD-Inception-v2](output_inception.csv) | `fusedConvolutionReluKernel` (one variant) | 99.45% |
| SSD-Inception-v2 | `gatherTopDetections_kernel` | 13.60% |
| SSD-Inception-v2 | `allClassNMS_kernel` | 99.96% |
| [PeopleNet](output_peoplenet.csv) | `cuInt8::nchwToNchhw2` (layout conversion) | 99.90% |
| PeopleNet | `generatedNativePointwise` | 79.89% |

The **99.90% PeopleNet value belongs to a layout-conversion kernel**, not a fused-convolution kernel. The published PeopleNet CSV has **no `gatherTopDetections_kernel` or `allClassNMS_kernel` row**, so it cannot support a PeopleNet NMS percentage. Although `gatherTopDetections_kernel` has low SM activity in the two SSD traces, another NMS-named kernel has high activity. The data therefore do **not** establish that NMS as a whole is universally underutilized or the dominant end-to-end latency bottleneck. To make a bottleneck claim, we would need kernel durations and their contribution to total application time, ideally across repeated controlled runs.

## Limits of this study

- Results describe these models, inputs, device setup, and reported run; no cross-device or general model ranking is claimed.
- `nvprof --metrics sm_efficiency` measures activity, not whether a kernel is compute-bound or memory-bound. The original report discusses possible explanations, but its stronger causal bottleneck interpretation is not established by these CSVs.
- A native build was chosen for practical storage reasons. We did not measure a runtime advantage over Docker.
- The Jetson Nano's CPU and GPU share system memory, but this does not make data conversion, synchronization, or memory access free. The report does not provide a measured bandwidth or power bottleneck.

## Published files

| File | Contents |
|---|---|
| `output_peoplenet.csv`, `output_inception.csv`, `output_mobilenet.csv` | Per-kernel `sm_efficiency` summaries from `nvprof`; **not per-image inference-time logs**. |
| `humans_output_*.jpeg` | Sample model output images. |
| `report.pdf` | Build steps, approximate application timing ranges, and the original course analysis. |
