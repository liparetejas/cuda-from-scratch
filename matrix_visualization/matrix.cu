#include <iostream>
#include <cuda_runtime.h>
#include <iomanip>

// 2D CUDA kernel
__global__ void fillMatrix2D(int *matrix, int width, int height) {
    // Calculate the global thread coordinates
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    // Boundary check
    if((row < height) && (col < width)) {
        // Flatten the coordinates
        int index = row * width + col;
        // Fill the matrix
       matrix[index] = blockIdx.x * 100 + threadIdx.x;
    }
}

int main() {
    int width = 8;
    int height = 6;
    int n = width * height;
    size_t bytes = n * sizeof(int);

    // Allocate CPU host memory
    int *h_matrix = (int*)malloc(bytes);

    // Allocate GPU device memory
    int *d_matrix;
    cudaMalloc(&d_matrix, bytes);

    // Define 2D Block and Grid Structures
    // Block size: 4 threads wide x 3 threads high
    dim3 threadsPerBlock(4, 3);

    // Grid size: Calculate the blocks needed in both X and Y directions
    dim3 blocksPerGrid((width + threadsPerBlock.x - 1) / threadsPerBlock.x,
        (height + threadsPerBlock.y - 1) / threadsPerBlock.y);

    std::cout << "Block dimensions: " << threadsPerBlock.x << " x " << threadsPerBlock.y << " y " << threadsPerBlock.z << " z " << std::endl;

    std::cout << "Launching 2D Grid Kernel..." << std::endl;

    fillMatrix2D<<<blocksPerGrid, threadsPerBlock>>>(d_matrix, width, height);

    // Wait for completion
    cudaDeviceSynchronize();
    cudaError_t err = cudaGetLastError();
    if(err != cudaSuccess) {
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl;
        return -1;
    }

    // Copy the results back to CPU
    cudaMemcpy(h_matrix, d_matrix, bytes, cudaMemcpyDeviceToHost);

    // Print the result
    std::cout << "\n--- Result Matrix (" << height << " Rows x " << width << " Columns) ---" << std::endl;
    for (int r = 0; r < height; r++) {
        for (int c = 0; c < width; c++) {
            std::cout << std::setw(5) << h_matrix[r * width + c] << " ";
        }
        std::cout << std::endl;
    }

    // Free memory
    free(h_matrix);
    cudaFree(d_matrix);

    return 0;
}