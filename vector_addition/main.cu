#include <iostream>
#include <cuda_runtime.h>
#include <cmath>
#include <chrono>

// CUDA Kernel
__global__ void vecAdd(float *a, float *b, float *c, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < N) {
        c[i] = a[i] + b[i];
    }
}

// Main
int main() {
    int N = 1 << 26; // 2^26 Elements
    size_t bytes = N * sizeof(float);
    std::cout << "Vector addition of size: " << N << " elements" << std::endl;

    // Allocate the Host (CPU) memory
    float* h_a = (float*)malloc(bytes);
    float* h_b = (float*)malloc(bytes);
    float* h_c = (float*)malloc(bytes);

    // Initialize the vectors
    for(int i = 0; i < N; i++) {
        h_a[i] = 1.0f;
        h_b[i] = 2.0f;
        h_c[i] = 0.0f;
    }

    // Allocate the Device (GPU) Memory
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    // Copy data from Host to Device
    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

    // Define Thread block and grid structure
    // 256 threads per block
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    std::cout << "Launching kernel with " << blocksPerGrid << " blocks and " << threadsPerBlock << " threads per block" << std::endl;

    // Start Overall (Wall-Clock) Timing
    auto start_overall = std::chrono::high_resolution_clock::now();

    // Launch the CUDA kernel
    vecAdd<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, N);

    // Check for errors
    cudaError_t err = cudaGetLastError();
    if(err != cudaSuccess) {
        std::cerr << "CUDA error: " << cudaGetErrorString(err) << std::endl;
        return -1;
    }

    // Synchronize CPU and GPU
    cudaDeviceSynchronize();

    // Stop overall host-side wall-clock timing
    auto end_overall = std::chrono::high_resolution_clock::now();
    std::chrono::duration<float, std::milli> overall_time = end_overall - start_overall;

    // Copy result from GPU to CPU
    cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);

    std::cout << "GPU Execution Time: " << overall_time.count() << " ms" << std::endl;

    // Clean up the memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(h_a);
    free(h_b);
    free(h_c);

    std::cout << "Parallel vector addition completed successfully" << std::endl;
    
    return 0;
}