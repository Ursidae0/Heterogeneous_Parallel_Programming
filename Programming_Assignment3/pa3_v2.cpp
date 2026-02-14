/*
 * SPDX-FileCopyrightText: Copyright (c) 2022 University of Geneva. All rights reserved.
 * SPDX-License-Identifier: MIT
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#include <algorithm>
#include <chrono>
#include <numeric>
#include <vector>
#include <iterator>
#include <iostream>
#include <random>
#include <execution>

// Define execution policy based on compiler
#ifdef __NVCOMPILER
#define EXEC_POLICY std::execution::par
#else
#define EXEC_POLICY std::execution::seq
#endif

// Fused select and reduce using transform_reduce
template<class UnaryPredicate>
long fused_select_reduce(const std::vector<int>& v, UnaryPredicate pred)
{
    // Use std::transform_reduce to fuse selection and reduction
    // transform: if predicate is true, return the value; otherwise return 0
    // reduce: sum all the values using std::plus
    long sum = std::transform_reduce(
        EXEC_POLICY,
        v.begin(), v.end(),
        0L,                          // Initial value for reduction
        std::plus<long>{},           // Reduction operation (sum)
        [pred](int x) -> long {      // Transform operation (selection)
            return pred(x) ? static_cast<long>(x) : 0L;
        }
    );
    return sum;
}

// Initialize vector
void initialize(std::vector<int>& v);

// Benchmarks the implementation
template <typename Predicate>
void bench(std::vector<int>& v, Predicate&& predicate);

int main(int argc, char* argv[])
{
    // Read CLI arguments, the first argument is the name of the binary:
    if (argc != 2) {
        std::cerr << "ERROR: Missing length argument!" << std::endl;
        return 1;
    }

    // Read length of vector elements
    long long n = std::stoll(argv[1]);

    // Allocate the data vector
    auto v = std::vector<int>(n);

    initialize(v);

    auto predicate = [](int x) { return x % 3 == 0; };
    long sum = fused_select_reduce(v, predicate);
    
    if (sum <= 0) {
        std::cerr << "ERROR!" << std::endl;
        return 1;
    }
    std::cerr << "OK! Sum = " << sum << std::endl;

    if (n < 40) {
        std::cout << "Sum of selected elements: " << sum << std::endl;
    }
    
    bench(v, predicate);

    return 0;
}

void initialize(std::vector<int>& v)
{
    auto distribution = std::uniform_int_distribution<int> {0, 100};
    auto engine = std::mt19937 {1};
    std::generate(v.begin(), v.end(), [&distribution, &engine]{ return distribution(engine); });
}

template <typename Predicate>
void bench(std::vector<int>& v, Predicate&& predicate) {
  // Measure bandwidth in [GB/s]
  using clk_t = std::chrono::steady_clock;
  fused_select_reduce(v, predicate);  // Warmup
  auto start = clk_t::now();
  int nit = 100;
  for (int it = 0; it < nit; ++it) {
    fused_select_reduce(v, predicate);
  }
  auto seconds = std::chrono::duration<double>(clk_t::now() - start).count(); // Duration in [s]
  // Amount of bytes transferred from/to chip.
  // v is read once (int) for transform_reduce:
  auto gigabytes = sizeof(int) * (double)v.size() * (double)nit * 1.e-9; // GB
  std::cerr << "Bandwidth [GB/s]: " << (gigabytes / seconds) << std::endl;
}
