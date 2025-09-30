// fpga_connect.h
#ifndef FPGA_CONNECT_H
#define FPGA_CONNECT_H

#include "fpga_config.h"


cl_uint load_file_to_memory(const char *filename, char **result);

cl_uint connect_to_fpga(cl_platform_id& platform_id, cl_device_id& device_id, cl_context& context, 
    cl_command_queue& commands, cl_program& program, cl_kernel& kernel, char** argv);


#endif