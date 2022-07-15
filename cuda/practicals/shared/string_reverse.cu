#include <cstdlib>
#include <cstdio>
#include <iostream>

#include "util.hpp"

// implement a kernel that reverses a string of length n in place
__global__
void reverse_string(char* str, int n)
{
	__shared__ char buffer[1024];
	
	int block_start = blockDim.x * blockIdx.x;
	int lid = threadIdx.x;
	int gid = lid + block_start;

	if (gid < n)
	{
		buffer[lid] = str[n-gid-1];
		str[gid] = buffer[lid];
	}
}

int main(int argc, char** argv) {
    // check that the user has passed a string to reverse
    if(argc<2) {
        std::cout << "useage : ./string_reverse \"string to reverse\"\n" << std::endl;
        exit(0);
    }

    // determine the length of the string, and copy in to buffer
    auto n = strlen(argv[1]);
    auto string = malloc_managed<char>(n+1);
    std::copy(argv[1], argv[1]+n, string);
    string[n] = 0; // add null terminator

    std::cout << "string to reverse:\n" << string << "\n";

    // call the string reverse function
	int block_dim = 128;
	int numBlock = (n-1)/block_dim + 1;
	reverse_string<<<numBlock, block_dim>>>(string, n);

    // print reversed string
    cudaDeviceSynchronize();
    std::cout << "reversed string:\n" << string << "\n";

    // free memory
    cudaFree(string);

    return 0;
}

