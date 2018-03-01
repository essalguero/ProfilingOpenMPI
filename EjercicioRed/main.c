#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "operaciones.h"

#define TAG_DATO 0
#define TAG_OPERACION 1

#define OP_ADD 0
#define OP_MUL 1



void master(int argc, char** argv, int rank, int nproc)
{

	int numFilas=1000;
	int numColumnas=1000;

	int* mat1=(int*)malloc(sizeof(int)*numFilas*numColumnas);
	int* mat2=(int*)malloc(sizeof(int)*numFilas*numColumnas);
	int* matRes=(int*)malloc(sizeof(int)*numFilas*numColumnas);

	int operacion=OP_MUL;
	MPI_Status status;

	int subMatrizFilas=numFilas/(nproc-1);
       	int resto=numFilas%(nproc-1);
	subMatrizFilas++;
	for(int i=0;i<numFilas;i++)
		for(int j=0;j<numColumnas;j++)
		{
			mat1[i*numFilas + j]=1;
			mat2[i*numFilas + j]=1;
		}
	int ack=0;
	for(int slave=1;slave<nproc;slave++)
	{

		if((slave-1)==resto) subMatrizFilas --;
		MPI_Send(&subMatrizFilas,1,MPI_INT,slave,
			TAG_DATO,MPI_COMM_WORLD);
		MPI_Send(&numColumnas,1,MPI_INT,slave,TAG_DATO,MPI_COMM_WORLD);
		MPI_Send(&numFilas,1,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD);
		MPI_Send(&numColumnas,1,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD);
		MPI_Send(mat1,subMatrizFilas*numColumnas,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD);
		MPI_Send(mat2,numFilas*numColumnas,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD);
		MPI_Send(&operacion,1,MPI_INT,slave,
				TAG_OPERACION,MPI_COMM_WORLD);
		MPI_Recv(&(ack),1,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD,&status);
	}

	subMatrizFilas++;
	int indexCount=0;
	for(int slave=1;slave<nproc;slave++)
	{

		if((slave-1)==resto) subMatrizFilas --;

		MPI_Recv(&(matRes[indexCount]),subMatrizFilas*numColumnas,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD,&status);
		MPI_Send(&ack,1,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD);		
		indexCount+=subMatrizFilas*numColumnas;
	}

}


void esclavo(int argc, char** argv, int rank, int nproc)
{

		int operacion=0;
		int numFilasM1=0;
		int numColumnasM1=0;
		int numFilasM2=0;
		int numColumnasM2=0;
		int* mat1;
		int* mat2;
		int* matRes;
		int cpu=1;
		int ack=0;
		
		if(argc>=2) cpu=atoi(argv[1]);

		MPI_Status status;
		MPI_Recv(&numFilasM1,1,MPI_INT,0,
			TAG_DATO,MPI_COMM_WORLD,&status);
		MPI_Recv(&numColumnasM1,1,MPI_INT,0,
			TAG_DATO,MPI_COMM_WORLD,&status);
		MPI_Recv(&numFilasM2,1,MPI_INT,0,
			TAG_DATO,MPI_COMM_WORLD,&status);
		MPI_Recv(&numColumnasM2,1,MPI_INT,0,
			TAG_DATO,MPI_COMM_WORLD,&status);

		mat1=(int*)malloc(numFilasM1*numColumnasM1*sizeof(int));
		mat2=(int*)malloc(numFilasM2*numColumnasM2*sizeof(int));
		MPI_Recv(mat1,numFilasM1*numColumnasM1,MPI_INT,0,
				TAG_DATO,MPI_COMM_WORLD,&status);
		MPI_Recv(mat2,numFilasM2*numColumnasM2,MPI_INT,0,
				TAG_DATO,MPI_COMM_WORLD,&status);
		MPI_Recv(&operacion,1,MPI_INT,0,
				TAG_OPERACION,MPI_COMM_WORLD,&status);
		MPI_Send(&ack,1,MPI_INT,0,
				TAG_DATO,MPI_COMM_WORLD);

		matRes=(int*)malloc(numFilasM1*numColumnasM2*sizeof(int));
		switch(operacion)
		{
			case OP_ADD:
				printf("no implementada suma\n");	fflush(stdout);
			break;
			case OP_MUL: 
				multiplicaMatrices 
					(cpu,mat1,mat2,matRes,numFilasM1,numColumnasM1,
					numFilasM2,numColumnasM2);
			break;
			default:
				printf("no implementada suma\n");	fflush(stdout);
			break;
		};

		
		MPI_Send(matRes,numFilasM1*numColumnasM2,MPI_INT,0,
				TAG_DATO,MPI_COMM_WORLD);
		MPI_Recv(&ack,1,MPI_INT,0,
				TAG_DATO,MPI_COMM_WORLD,&status);

		
}

int main (int argc,char** argv)
{


	int rank;
	int nproc;
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&nproc);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	switch(rank)
	{
		case 0:
			master(argc,argv,rank, nproc);
			break;
		default:
			esclavo(argc,argv,rank, nproc);
			break;
	};
	MPI_Finalize();
	return 0;

}
