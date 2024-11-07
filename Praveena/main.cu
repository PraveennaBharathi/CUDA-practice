// #include <torch/torch.h>
// #include <iostream>
// #include <cmath>
// #include <cuda_runtime.h>

// // Function to compare two arrays with a tolerance
// bool compareArrays(const float* arr1, const float* arr2, size_t size, float tolerance) {
//     for (size_t i = 0; i < size; ++i) {
//         if (std::fabs(arr1[i] - arr2[i]) > tolerance) {
//             return false; // Arrays are not equal
//         }
//     }
//     return true; // Arrays are equal within the specified tolerance
// }

// // Combined kernel for RMS Normalization
// __global__ void rmsNormKernel(const float* input, float* output, size_t size, float* rms) {
//     int index = blockIdx.x * blockDim.x + threadIdx.x;

//     // Step 1: Compute the square of each input element and accumulate in shared memory
//     extern __shared__ float sdata[];

//     if (index < size) {
//         sdata[threadIdx.x] = input[index] * input[index];
//     } else {
//         sdata[threadIdx.x] = 0.0f;
//     }
//     __syncthreads();

//     // Step 2: Reduce to get the sum of squared values
//     for (int stride = blockDim.x / 2; stride > 0; stride /= 2) {
//         if (threadIdx.x < stride) {
//             sdata[threadIdx.x] += sdata[threadIdx.x + stride];
//         }
//         __syncthreads();
//     }

//     // Step 3: Write the sum of squared values to global memory (rms)
//     if (threadIdx.x == 0) {
//         atomicAdd(rms, sdata[0]);
//     }

//     // Step 4: Normalize the input values
//     if (index < size) {
//         output[index] = input[index] / (*rms); // Normalize each element
//     }
// }

// int main() {
//     // Initialize the tensor with random values for demonstration
//     torch::manual_seed(42);  // Set seed for reproducibility
//     torch::Tensor input = torch::randn({1024, 1024, 32});  // Random tensor with shape (1024, 1024, 32)

//     std::cout << "Original Tensor Shape: " << input.sizes() << std::endl;

//     // Host input - tensor is converted to flattened array
//     float* h_ptr = input.data_ptr<float>();

//     size_t num_elements = input.numel();  // Number of elements in the tensor

//     // Allocate memory on GPU
//     float* d_input;
//     float* d_output;
//     float* d_rms;
//     cudaMalloc(&d_input, num_elements * sizeof(float));
//     cudaMalloc(&d_output, num_elements * sizeof(float));
//     cudaMalloc(&d_rms, sizeof(float));

//     // Copy input tensor to GPU
//     cudaMemcpy(d_input, h_ptr, num_elements * sizeof(float), cudaMemcpyHostToDevice);

//     // Initialize the RMS value to 0
//     cudaMemset(d_rms, 0, sizeof(float));

//     // Step 1: Compute the squared values, reduction for RMS, and normalize in parallel using kernel
//     int threadsPerBlock = 256;
//     int blocksPerGrid = (num_elements + threadsPerBlock - 1) / threadsPerBlock;
//     rmsNormKernel<<<blocksPerGrid, threadsPerBlock, threadsPerBlock * sizeof(float)>>>(d_input, d_output, num_elements, d_rms);

//     // Step 2: Copy the RMS value back to host
//     float h_rms;
//     cudaMemcpy(&h_rms, d_rms, sizeof(float), cudaMemcpyDeviceToHost);

//     // Compute RMS (square root of the sum of squared values divided by the number of elements)
//     h_rms = std::sqrt(h_rms / num_elements);

//     // Step 3: Normalize the input tensor on the host
//     float* h_output = new float[num_elements];
//     for (size_t i = 0; i < num_elements; ++i) {
//         h_output[i] = h_ptr[i] / h_rms;  // Normalize each element
//     }

//     // Check if the output matches the expected result (for demonstration)
//     if (compareArrays(h_ptr, h_output, num_elements, 1e-3)) {
//         std::cout << "Test passed " << std::endl;
//     } else {
//         std::cout << "Test failed " << std::endl;
//     }

//     // Free GPU memory
//     cudaFree(d_input);
//     cudaFree(d_output);
//     cudaFree(d_rms);

//     delete[] h_output;

//     return 0;
// }



//2

// #include <torch/torch.h>
// #include <iostream>
// #include <cmath>
// #include <cuda_runtime.h>

// // Function to compare two arrays with a tolerance
// bool compareArrays(const float* arr1, const float* arr2, size_t size, float tolerance) {
//     for (size_t i = 0; i < size; ++i) {
//         if (std::fabs(arr1[i] - arr2[i]) > tolerance) {
//             return false; // Arrays are not equal
//         }
//     }
//     return true; // Arrays are equal within the specified tolerance
// }

// // Combined kernel for RMS Normalization
// __global__ void rmsNormKernel(const float* input, float* output, size_t size, float* rms) {
//     int index = blockIdx.x * blockDim.x + threadIdx.x;

//     // Step 1: Compute the square of each input element and accumulate in shared memory
//     extern __shared__ float sdata[];

//     if (index < size) {
//         sdata[threadIdx.x] = input[index] * input[index];
//     } else {
//         sdata[threadIdx.x] = 0.0f;
//     }
//     __syncthreads();

//     // Step 2: Reduce to get the sum of squared values
//     for (int stride = blockDim.x / 2; stride > 0; stride /= 2) {
//         if (threadIdx.x < stride) {
//             sdata[threadIdx.x] += sdata[threadIdx.x + stride];
//         }
//         __syncthreads();
//     }

//     // Step 3: Write the sum of squared values to global memory (rms)
//     if (threadIdx.x == 0) {
//         atomicAdd(rms, sdata[0]);
//     }

//     // Step 4: Normalize the input values
//     if (index < size) {
//         output[index] = input[index] / (*rms); // Normalize each element
//     }
// }

// int main() {
//     // Initialize the tensor with random values for demonstration
//     torch::manual_seed(42);  // Set seed for reproducibility
//     torch::Tensor input = torch::randn({1024, 1024, 32});  // Random tensor with shape (1024, 1024, 32)

//     std::cout << "Original Tensor Shape: " << input.sizes() << std::endl;

//     // Host input - tensor is converted to flattened array
//     float* h_ptr = input.data_ptr<float>();

//     size_t num_elements = input.numel();  // Number of elements in the tensor

//     // Step 1: Compute the squared values on CPU
//     auto tensor_squared = input.pow(2);  // Square of the tensor

//     // Step 2: Compute the mean along all dimensions (axis 0, 1, and 2)
//     auto mean_squared = tensor_squared.mean();  // Scalar value, mean of all elements

//     // Step 3: Compute the RMS (root mean square)
//     auto rms = mean_squared.sqrt();  // Square root of the mean squared value

//     // Step 4: Normalize the tensor on CPU
//     torch::Tensor output = input / rms;  // Normalize each element of the tensor

   

//     // Host memory allocation for GPU result
//     float* d_input;
//     float* d_output;
//     float* d_rms;
//     cudaMalloc(&d_input, num_elements * sizeof(float));
//     cudaMalloc(&d_output, num_elements * sizeof(float));
//     cudaMalloc(&d_rms, sizeof(float));

//     // Copy input tensor to GPU
//     cudaMemcpy(d_input, h_ptr, num_elements * sizeof(float), cudaMemcpyHostToDevice);

//     // Initialize the RMS value to 0 on the GPU
//     cudaMemset(d_rms, 0, sizeof(float));

//     // Step 1: Compute the squared values, reduction for RMS, and normalize in parallel using kernel
//     int threadsPerBlock = 256;
//     int blocksPerGrid = (num_elements + threadsPerBlock - 1) / threadsPerBlock;
//     rmsNormKernel<<<blocksPerGrid, threadsPerBlock, threadsPerBlock * sizeof(float)>>>(d_input, d_output, num_elements, d_rms);

//     // Step 2: Copy the RMS value back to host
//     float h_rms;
//     cudaMemcpy(&h_rms, d_rms, sizeof(float), cudaMemcpyDeviceToHost);

//     // Compute RMS (square root of the sum of squared values divided by the number of elements)
//     h_rms = std::sqrt(h_rms / num_elements);

//     // Step 3: Normalize the input tensor on the host using RMS computed from the GPU
//     float* h_output = new float[num_elements];
//     for (size_t i = 0; i < num_elements; ++i) {
//         h_output[i] = h_ptr[i] / h_rms;  // Normalize each element on the host
//     }

//     // Check if the output matches the expected result (for demonstration)
//     if (compareArrays(h_ptr, h_output, num_elements, 1e-3)) {
//         std::cout << "Test passed " << std::endl;
//     } else {
//         std::cout << "Test failed " << std::endl;
//     }

//     // Free GPU memory
//     cudaFree(d_input);
//     cudaFree(d_output);
//     cudaFree(d_rms);

//     delete[] h_output;

//     return 0;
// }


//3
// #include <torch/torch.h>
// #include <iostream>
// #include <cmath>
// #include <cuda_runtime.h>

// // Function to compare two arrays with a tolerance
// bool compareArrays(const float* arr1, const float* arr2, size_t size, float tolerance) {
//     for (size_t i = 0; i < size; ++i) {
//         if (std::fabs(arr1[i] - arr2[i]) > tolerance) {
//             return false; // Arrays are not equal
//         }
//     }
//     return true; // Arrays are equal within the specified tolerance
// }

// // Combined kernel for RMS Normalization on GPU
// __global__ void rmsNormKernel(const float* input, float* output, size_t size, float* d_rms, float* d_mean) {
//     int index = blockIdx.x * blockDim.x + threadIdx.x;
//     extern __shared__ float sdata[];

//     // Step 1: Compute the square of each input element and accumulate in shared memory
//     if (index < size) {
//         sdata[threadIdx.x] = input[index] * input[index];
//     } else {
//         sdata[threadIdx.x] = 0.0f;
//     }
//     __syncthreads();

//     // Step 2: Perform block-wise reduction to get the sum of squared values
//     for (int stride = blockDim.x / 2; stride > 0; stride /= 2) {
//         if (threadIdx.x < stride) {
//             sdata[threadIdx.x] += sdata[threadIdx.x + stride];
//         }
//         __syncthreads();
//     }

//     // Step 3: Write the sum of squared values to global memory (rms)
//     if (threadIdx.x == 0) {
//         atomicAdd(d_rms, sdata[0]);
//     }

//     // Step 4: Write the sum to calculate mean in the global memory
//     if (threadIdx.x == 0) {
//         atomicAdd(d_mean, sdata[0]);
//     }

//     // Step 5: Normalize the input values (after reduction)
//     if (index < size) {
//         output[index] = input[index] / (*d_rms); // Normalize each element by RMS
//     }
// }

// int main() {
//     // Initialize the tensor with random values for demonstration
//     torch::manual_seed(42);  // Set seed for reproducibility
//     torch::Tensor input = torch::randn({1024, 1024, 32});  // Random tensor with shape (1024, 1024, 32)

//     std::cout << "Original Tensor Shape: " << input.sizes() << std::endl;

//     // Host input - tensor is converted to flattened array
//     float* h_ptr = input.data_ptr<float>();

//     size_t num_elements = input.numel();  // Number of elements in the tensor

//     // --- CPU Computation (Using predefined functions) ---
//     // Step 1: Compute the squared values on CPU
//     auto tensor_squared = input.pow(2);  // Square of the tensor

//     // Step 2: Compute the mean squared value
//     auto mean_squared = tensor_squared.mean();  // Scalar value, mean of all elements

//     // Step 3: Compute the RMS (root mean square)
//     auto rms = mean_squared.sqrt();  // Square root of the mean squared value

//     // Step 4: Normalize the tensor on CPU
//     torch::Tensor output_cpu = input / rms;  // Normalize each element of the tensor

//     // --- GPU Computation (Step-by-step kernel execution) ---
//     float* d_input;
//     float* d_output;
//     float* d_rms;
//     float* d_mean;
//     cudaMalloc(&d_input, num_elements * sizeof(float));
//     cudaMalloc(&d_output, num_elements * sizeof(float));
//     cudaMalloc(&d_rms, sizeof(float));
//     cudaMalloc(&d_mean, sizeof(float));

//     // Copy input tensor to GPU
//     cudaMemcpy(d_input, h_ptr, num_elements * sizeof(float), cudaMemcpyHostToDevice);

//     // Initialize the RMS and mean values to 0 on the GPU
//     cudaMemset(d_rms, 0, sizeof(float));
//     cudaMemset(d_mean, 0, sizeof(float));

//     // Step 1: Compute squared values and RMS, normalize in parallel using kernel
//     int threadsPerBlock = 256;
//     int blocksPerGrid = (num_elements + threadsPerBlock - 1) / threadsPerBlock;
//     rmsNormKernel<<<blocksPerGrid, threadsPerBlock, threadsPerBlock * sizeof(float)>>>(d_input, d_output, num_elements, d_rms, d_mean);

//     // Synchronize GPU
//     cudaDeviceSynchronize();

//     // Step 2: Copy the RMS and mean values back to host
//     float h_rms, h_mean;
//     cudaMemcpy(&h_rms, d_rms, sizeof(float), cudaMemcpyDeviceToHost);
//     cudaMemcpy(&h_mean, d_mean, sizeof(float), cudaMemcpyDeviceToHost);

//     // Compute RMS (square root of the sum of squared values divided by the number of elements)
//     h_rms = std::sqrt(h_rms / num_elements);

//     // Step 3: Copy the GPU output back to host
//     float* h_output_gpu = new float[num_elements];
//     cudaMemcpy(h_output_gpu, d_output, num_elements * sizeof(float), cudaMemcpyDeviceToHost);

//     // --- Compare Results between CPU and GPU ---
//     if (compareArrays(h_ptr, h_output_gpu, num_elements, 1e-4)) {
//         std::cout << "Test passed: GPU and CPU outputs are the same." << std::endl;
//     } else {
//         std::cout << "Test failed: GPU and CPU outputs are different." << std::endl;
//     }

//     // Free GPU memory
//     cudaFree(d_input);
//     cudaFree(d_output);
//     cudaFree(d_rms);
//     cudaFree(d_mean);

//     delete[] h_output_gpu;

//     return 0;
// }

//4
#include <torch/torch.h>
#include <iostream>
#include <cmath>
#include <cuda_runtime.h>

// Kernel to square each element in the input array
__global__ void squareElements(const float* input, float* output, size_t size) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size) {
        output[idx] = input[idx] * input[idx];
    }
}

// Kernel to calculate the mean of the squared elements
__global__ void calculateMean(const float* input, float* output, size_t size) {
    extern __shared__ float shared_data[];
    int tid = threadIdx.x;
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    shared_data[tid] = (idx < size) ? input[idx] : 0.0f;
    __syncthreads();

    for (int stride = blockDim.x / 2; stride > 0; stride >>= 1) {
        if (tid < stride) {
            shared_data[tid] += shared_data[tid + stride];
        }
        __syncthreads();
    }

    if (tid == 0) {
        atomicAdd(output, shared_data[0] / size);
    }
}

// Kernel to calculate the square root of the mean
__global__ void calculateSqrt(float* mean) {
    *mean = sqrt(*mean);
}

// Kernel to normalize the input array with the RMS value
__global__ void normalize(const float* input, float* output, float rms, size_t size) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size) {
        output[idx] = input[idx] / rms;
    }
}

// Function to compare arrays within a given tolerance
bool compareArrays(const float* arr1, const float* arr2, size_t size, float tolerance) {
    for (size_t i = 0; i < size; ++i) {
        if (std::fabs(arr1[i] - arr2[i]) > tolerance) {
            return false;
        }
    }
    return true;
}

int main() {
    // Initialize the tensor with random values for demonstration
    torch::manual_seed(42);  // Set seed for reproducibility
    torch::Tensor input = torch::randn({1024, 1024, 32});  // Random tensor with shape (1024, 1024, 32)
    std::cout << "Original Tensor Shape: " << input.sizes() << std::endl;

    // Host input pointer to flattened array
    float* h_ptr = input.data_ptr<float>();

    // Step 1: CPU RMS normalization
    auto tensor_squared = input.pow(2);
    auto mean_squared = tensor_squared.mean();
    auto rms = mean_squared.sqrt();
    torch::Tensor output = input / rms;
    float* h_output_ptr = output.data_ptr<float>();

    // GPU allocation and data copy
    size_t output_size = 1;
    for (int i : output.sizes()) output_size *= i;

    float *d_input, *d_squared, *d_mean, *d_output;

    // Allocate memory on GPU
    cudaMalloc(&d_input, output_size * sizeof(float));
    cudaMalloc(&d_squared, output_size * sizeof(float));
    cudaMalloc(&d_mean, sizeof(float));
    cudaMalloc(&d_output, output_size * sizeof(float));

    cudaMemcpy(d_input, h_ptr, output_size * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemset(d_mean, 0, sizeof(float));

    // Define block and grid sizes
    int blockSize = 256;
    int gridSize = (output_size + blockSize - 1) / blockSize;

    // Step 2: Squaring each element
    squareElements<<<gridSize, blockSize>>>(d_input, d_squared, output_size);

    // Step 3: Calculating the mean of squared elements
    calculateMean<<<gridSize, blockSize, blockSize * sizeof(float)>>>(d_squared, d_mean, output_size);

    // Step 4: Calculating the square root of the mean
    calculateSqrt<<<1, 1>>>(d_mean);

    // Step 5: Normalizing the input by RMS
    float* h_rms = new float[1];
    cudaMemcpy(h_rms, d_mean, sizeof(float), cudaMemcpyDeviceToHost);
    normalize<<<gridSize, blockSize>>>(d_input, d_output, *h_rms, output_size);

    // Copy result back to host
    float* cuda_output = new float[output_size];
    cudaMemcpy(cuda_output, d_output, output_size * sizeof(float), cudaMemcpyDeviceToHost);

    // Compare CPU and GPU outputs
    if (compareArrays(h_output_ptr, cuda_output, output_size, 1e-3)) {
        std::cout << "Test passed" << std::endl;
    } else {
        std::cout << "Test failed" << std::endl;
    }

    // Free GPU memory
    cudaFree(d_input);
    cudaFree(d_squared);
    cudaFree(d_mean);
    cudaFree(d_output);
    delete[] cuda_output;
    delete[] h_rms;

    return 0;
}
