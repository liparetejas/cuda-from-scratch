#include <iostream>
#include <chrono>
#include <vector>
#include <cmath>

// Serial Vector Addition on CPU
void vecAddSerial(const float *a, const float *b, float *c, int N) {
    for (int i = 0; i < N; i++) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    int N = 1 << 26; // 2^26 Elements
    size_t bytes = N * sizeof(float);
    std::cout << "CPU Serial Vector addition of size: " << N << " elements" << std::endl;

    // Allocate memory
    std::vector<float> h_a(N, 1.0f); // Filled with 1.0f
    std::vector<float> h_b(N, 2.0f); // Filled with 2.0f
    std::vector<float> h_c(N, 0.0f); // Filled with 0.0f

    // Start timing
    auto start = std::chrono::high_resolution_clock::now();

    // Run the serial addition
    vecAddSerial(h_a.data(), h_b.data(), h_c.data(), N);

    // End timing
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<float, std::milli> duration = end - start;

    std::cout << "CPU Execution Time: " << duration.count() << " ms" << std::endl;

    std::cout << "Serial vector addition completed successfully" << std::endl;

    return 0;
}
