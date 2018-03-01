#include <stdio.h>
#include <stdlib.h>
#include "operaciones.h"



__global__ void multiplicaVectores(int* mres,int* m1,int* m2, int numFilas, int numColumnas)
{

	int idx=blockIdx.x*blockDim.x+threadIdx.x;

	int numFila=idx/numColumnas;
	int numColumna=idx%numColumnas;

	mres[numFila*numColumnas+numColumna]=0;
	for(int i=0;i<numColumnas;i++)
	{
		mres[numFila*numColumnas+numColumna]+=m1[numFila*numColumnas+i]*m2[numFila*numColumnas+i];
	}

}



void imprimeMatriz(int* mat, int numFilas, int numColumnas)
{
	for(int i=0;i<numFilas;i++)
	{
		for(int j=0;j<numColumnas;j++)
		{
			printf("%d,",mat[i*numFilas+j]);
		}
		printf("\n");
	}

}


int multiplicaVectores(int* v1,int* v2, int size)
{
	int resultado=0;
	for(int i=0;i<size;i++)
	{
		resultado+=v1[i]*v2[i];
	}
	return resultado;
}




void multiplicaMatrices(int cpu,int* m1,int* m2, int* mRes,int numFilasM1, int numColumnasM1,int numFilasM2, int numColumnasM2)
{

if(cpu){
printf("CPU!\n");
		for(int i=0;i<numFilasM1;i++)
			for(int j=0;j<numColumnasM2;j++)
			mRes[i*numColumnasM2+j]=multiplicaVectores(&(m1[i*numColumnasM2]),
						&(m2[j*numColumnasM2])
						,numColumnasM2);
}else{
printf("CUDA!\n");

	int numThreadBloque=128;
	int numBloques=(numFilasM1*numColumnasM2/numThreadBloque)+1;
	
	int* d_m1;
	int* d_m2;
	int* d_mres;

	cudaMalloc((void**)&d_m1,sizeof(int)*numFilasM1*numColumnasM1);
	cudaMalloc((void**)&d_m2,sizeof(int)*numFilasM2*numColumnasM2);
	cudaMalloc((void**)&d_mres,sizeof(int)*numFilasM1*numColumnasM2);
	
	cudaMemcpy(d_m1,m1,sizeof(int)*numFilasM1*numColumnasM1,cudaMemcpyHostToDevice);
	cudaMemcpy(d_m2,m2,sizeof(int)*numFilasM2*numColumnasM2,cudaMemcpyHostToDevice);

multiplicaVectores<<<numThreadBloque,numBloques>>>(d_mres,d_m1,d_m2,numFilasM1, numColumnasM2);

	cudaMemcpy(mRes,d_mres,sizeof(int)*numFilasM1*numColumnasM2,cudaMemcpyDeviceToHost);
}
}
