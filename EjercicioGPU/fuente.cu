#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>


__global__ void sumaDatos(int* in, int* out, int size)
{
	int IDx=blockIdx.x*blockDim.x+threadIdx.x;

	if(IDx>size) return;

	out[IDx]=in[IDx]+in[IDx];

}

int main(int argc, char **argv)
{
	int datosCount=100000000;

	int* h_datos=(int*)malloc(datosCount*sizeof(int));
	int* h_datosout=(int*)malloc(datosCount*sizeof(int));
	int* d_datos;
	int* d_datosout;
	cudaMalloc(&d_datos,datosCount*sizeof(int));
	cudaMalloc(&d_datosout,datosCount*sizeof(int));


	for(int i=0;i<datosCount;i++)
	{
		h_datos[i]=i*2;
	}

	cudaMemcpy(d_datos,h_datos,datosCount*sizeof(int),cudaMemcpyHostToDevice);
	int numthreads=256;
	int numbloques=datosCount/numthreads+1;

	sumaDatos<<<numbloques,numthreads>>>(d_datos,d_datosout,datosCount);

	cudaMemcpy(h_datosout,d_datosout,datosCount*sizeof(int),cudaMemcpyDeviceToHost);

	printf("FIN\n");

	return 0;
}
