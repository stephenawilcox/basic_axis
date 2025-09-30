#ifndef FPGA_CONFIG_H
#define FPGA_CONFIG_H

#define NUM_WORKGROUPS   1
#define WORKGROUP_SIZE   256
#define MAX_LENGTH       8192
#define MEM_ALIGNMENT    4096

#if defined(VITIS_PLATFORM) && !defined(TARGET_DEVICE)
#define STR_VALUE(arg)   #arg
#define GET_STRING(name) STR_VALUE(name)
#define TARGET_DEVICE    GET_STRING(VITIS_PLATFORM)
#endif

#endif // FPGA_CONFIG_H

#include "/tools/Xilinx/2025.1/XRT/src/runtime_src/core/include/xclhal2.h"
#include <CL/opencl.h>