#define CL_USE_DEPRECATED_OPENCL_1_2_APIS

#include "fpga_config.h"
#include "fpga_connect.h"
#include "fpga_interface.h"
//#include <fcntl.h>
#include <stdio.h>
//#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#ifdef _WINDOWS
#include <io.h>
#else
#include <unistd.h>
#include <sys/time.h>
#endif
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
//#include <CL/opencl.h>
#include <CL/cl_ext.h>
//#include "/tools/Xilinx/2025.1/XRT/src/runtime_src/core/include/xclhal2.h"
#include <chrono>

int main(int argc, char** argv)
{

    cl_int err;                            // error code returned from api calls
    cl_uint check_status = 0;
    const cl_uint number_of_words = 4096; // 16KB of data


    cl_platform_id platform_id;         // platform id
    cl_device_id device_id;             // compute device id
    cl_context context;                 // compute context
    cl_command_queue commands;          // compute command queue
    cl_program program;                 // compute programs
    cl_kernel kernel;                   // compute kernel


    cl_uint* h_data;                                // host memory for input vector

    cl_uint* h_axi00_ptr0_output = (cl_uint*)aligned_alloc(MEM_ALIGNMENT,MAX_LENGTH * sizeof(cl_uint*)); // host memory for output vector
    cl_mem d_axi00_ptr0;                         // device memory used for a vector

    if (argc != 2) {
        printf("Usage: %s xclbin\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Fill our data sets with pattern
    h_data = (cl_uint*)aligned_alloc(MEM_ALIGNMENT,MAX_LENGTH * sizeof(cl_uint*));
    for(cl_uint i = 0; i < MAX_LENGTH; i++) {
        h_data[i]  = i;
        h_axi00_ptr0_output[i] = 0; 

    }

    // CONNECTING TO FPGA
    err = connect_to_fpga(platform_id, device_id, context, commands, program, kernel, argv);
    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to connect to FPGA\n");
        return EXIT_FAILURE;
    }
    printf("CONNECTED TO FPGA\n");

    // CREATING BUFFER
    d_axi00_ptr0 = create_buffer(context, kernel, number_of_words, 1, err);
    if (!(d_axi00_ptr0)) {
        printf("ERROR: Failed to allocate device memory!\n");
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }

    // WRITING DATA TO BUFFER
    err = clEnqueueWriteBuffer(commands, d_axi00_ptr0, CL_TRUE, 0, sizeof(cl_uint) * number_of_words, h_data, 0, NULL, NULL);
    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to write to source array h_data: d_axi00_ptr0: %d!\n", err);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }


    auto start_time = std::chrono::high_resolution_clock::now();
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);
    int num_iterations = 0;

    cl_uint d_mode = 0;

    while(duration.count() < 1000000) {
        // EXECUTE KERNEL
        err = run_kernel(commands, kernel, d_axi00_ptr0, d_mode, err);
        if (err != CL_SUCCESS) {
            printf("ERROR: Failed to execute kernel! %d\n", err);
            printf("ERROR: Test failed\n");
            return EXIT_FAILURE;
        }

        // READ DATA FROM KERNEL
        err = read_buffer(commands, d_axi00_ptr0, number_of_words, h_axi00_ptr0_output, err);
        if (err != CL_SUCCESS) {
            printf("ERROR: Failed to read output array! %d\n", err);
            printf("ERROR: Test failed\n");
            return EXIT_FAILURE;
        }

        // Check Results
        for (cl_uint i = 0; i < number_of_words; i++) {
            if ((h_data[i]) != h_axi00_ptr0_output[i]) {
                printf("ERROR in basic_axis::m00_axi - array index %d (host addr 0x%03x) - input=%d (0x%x), output=%d (0x%x)\n", i, i*4, h_data[i], h_data[i], h_axi00_ptr0_output[i], h_axi00_ptr0_output[i]);
                check_status = 1;
            }
        //  printf("i=%d, input=%d, output=%d\n", i,  h_axi00_ptr0_input[i], h_axi00_ptr0_output[i]);
        }

        end_time = std::chrono::high_resolution_clock::now();
        duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);

        num_iterations++;
    }

    int num_KB_transferred = (16 * num_iterations);
    int num_MB_transferred = num_KB_transferred / 1000;

    printf("The number of iterations ran is %d and it took %ld micro seconds\n", num_iterations, duration.count());

    printf("Each transfer is 4096 integers which is 16KB of data so the amount of data tranferred between the PS and PL is 16KB * num_iterations = %d KB\n", num_KB_transferred);

    printf("The AXI4 Stream can handle about %d MB per second of data\n", num_MB_transferred);


    //--------------------------------------------------------------------------
    // Shutdown and cleanup
    //-------------------------------------------------------------------------- 
    clReleaseMemObject(d_axi00_ptr0);
    free(h_axi00_ptr0_output);



    free(h_data);
    clReleaseProgram(program);

     clReleaseKernel(kernel); 

    clReleaseCommandQueue(commands);
    clReleaseContext(context);

    if (check_status) {
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    } else {
        printf("INFO: Test completed successfully.\n");
        return EXIT_SUCCESS;
    }


} // end of main
