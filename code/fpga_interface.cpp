// fpga_interface.cpp
#include "fpga_interface.h"

#include <stdio.h>

cl_mem create_buffer(cl_context& context, cl_kernel& kernel, cl_uint num_words, cl_uint bank, cl_int err) {
    // Create structs to define memory bank mapping
    cl_mem_ext_ptr_t mem_ext;
    mem_ext.obj = NULL;
    mem_ext.param = kernel;
    mem_ext.flags = 1;

    cl_mem buffer = clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(cl_uint) * num_words, &mem_ext, &err);
    if (err != CL_SUCCESS) {
      printf("Return code for clCreateBuffer flags=%lu: %d\n", mem_ext.flags, err);
    }
    return buffer;
}

// cl_int write_buffer(cl_command_queue& commands, cl_mem& buffer, cl_uint& num_words, void* in_data_ptr) {
//     return clEnqueueWriteBuffer(commands, buffer, CL_TRUE, 0, sizeof(cl_uint) * num_words, in_data_ptr, 0, NULL, NULL);
// }

cl_int run_kernel(cl_command_queue& commands, cl_kernel& kernel, cl_mem& buffer, cl_uint mode, cl_int err) {
    // Set the arguments to our compute kernel
    // cl_uint vector_length = MAX_LENGTH;
    err |= clSetKernelArg(kernel, 0, sizeof(cl_uint), &mode); // Not used in example RTL logic.
    err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &buffer); 
    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to set kernel arguments! %d\n", err);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }
    size_t global[1];
    size_t local[1];
    // Execute the kernel over the entire range of our 1d input data set
    // using the maximum number of work group items for this device
    global[0] = 1;
    local[0] = 1;
    err = clEnqueueNDRangeKernel(commands, kernel, 1, NULL, (size_t*)&global, (size_t*)&local, 0, NULL, NULL);
    clFinish(commands);
    return err;
}

cl_int read_buffer(cl_command_queue& commands, cl_mem& buffer, cl_uint num_words, void* out_data_ptr, cl_int err) {
    // Read back the results from the device to verify the output
    cl_event readevent;
    err = clEnqueueReadBuffer( commands, buffer, CL_TRUE, 0, sizeof(cl_uint) * num_words, out_data_ptr, 0, NULL, &readevent );
    clWaitForEvents(1, &readevent);
    return err;
}