// fpga_interface.h
#ifndef FPGA_INTERFACE_H
#define FPGA_INTERFACE_H

#include "fpga_config.h"


cl_mem create_buffer(cl_context& context, cl_kernel& kernel, cl_uint num_words, cl_uint bank, cl_int err);

// cl_int write_buffer(cl_command_queue& commands, cl_mem& buffer, cl_uint& num_words, void* in_data_ptr);

cl_int run_kernel(cl_command_queue& commands, cl_kernel& kernel, cl_mem& buffer, cl_uint mode, cl_int err);

cl_int read_buffer(cl_command_queue& commands, cl_mem& buffer, cl_uint num_words, void* out_data_ptr, cl_int err);

#endif