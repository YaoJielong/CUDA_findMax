#include <iostream>
#include <cmath>

using namespace std;

struct S {
    
    double a[100];
    double max;

} s;


__global__ void findMax(S* d_out, S* d_in){
 
    double m = d_in->a[0];

    for (int i = 0; i < 100; i++) {

        if (*(d_in->a + i) > m) {
            m = *(d_in->a + i);
        }

    }

    d_out->max = m;

    
}


int main(){


    for(int i = 0; i < 100; i++){
        s.a[i] = i + 0.6;
    }


    //host memory
    S* h_in = &s;
    S* h_out = new S;

    size_t memory_size = sizeof(s);

    //Declare and allocate device memory
    S* d_in;
    S* d_out;
    cudaMalloc((void**)&d_in, memory_size); 
    cudaMalloc((void**)&d_out, memory_size);

    cudaMemcpy(d_in, h_in, memory_size, cudaMemcpyHostToDevice);//data transfer from host to device

    findMax<<<1, 1>>>(d_out, d_in);//Kernel function, calculate each particle's density. 4 blocks in total; 625 threads per block.
    cudaDeviceSynchronize();

    cudaMemcpy(h_out, d_out, memory_size, cudaMemcpyDeviceToHost); //data transfer from device to host

    cudaFree(d_in); cudaFree(d_out);//free allocated device memory

    s = *h_out; //get the contents of coordinates in host's end

    cout << s.max << endl;

    return 0;

}