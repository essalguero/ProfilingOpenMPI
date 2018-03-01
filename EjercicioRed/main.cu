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

	double init;
	double end;

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
		
		init = MPI_Wtime();
		
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

		end = MPI_Wtime();

		printf("Ejecucion Master - Tiempo envio datos a esclavo %d: %f\n", slave, end - init);
	}

	subMatrizFilas++;
	int indexCount=0;
	for(int slave=1;slave<nproc;slave++)
	{

		if((slave-1)==resto) subMatrizFilas --;

		init = MPI_Wtime();

		MPI_Recv(&(matRes[indexCount]),subMatrizFilas*numColumnas,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD,&status);
		MPI_Send(&ack,1,MPI_INT,slave,
				TAG_DATO,MPI_COMM_WORLD);		

		end = MPI_Wtime();

		printf("Ejecucion Master - Tiempo recepcion datos desde esclavo %d: %f\n", slave, end - init);

		indexCount+=subMatrizFilas*numColumnas;
	}

}


void esclavo(int argc, char** argv, int rank, int nproc)
{

	double init;
	double end;

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

		init = MPI_Wtime();

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
		
		end = MPI_Wtime();
		printf("Ejecucion Esclavo %d - Tiempo recepcion datos desde Master: %f\n", rank, end - init);

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

		init = MPI_Wtime();

		MPI_Send(matRes,numFilasM1*numColumnasM2,MPI_INT,0,
				TAG_DATO,MPI_COMM_WORLD);
		MPI_Recv(&ack,1,MPI_INT,0,
				TAG_DATO,MPI_COMM_WORLD,&status);
		end = MPI_Wtime();

		printf("Ejecucion Esclavo %d - Envio resultado a Master: %f\n", rank, end - init);
}

int main (int argc,char** argv)
{

	int rank;
	int nproc;

	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&nproc);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);

	double init[nproc];
	double end[nproc];

	switch(rank)
	{
		case 0:
			printf("\n\nInicio programa\n\n");

			init[rank] = MPI_Wtime();
			master(argc,argv,rank, nproc);			
			end[rank] = MPI_Wtime();
			printf("Ejecucion Master: %f\n", end[rank] - init[rank]);

			
			printf("\n\nFin programa\n\n");

			break;
		default:
			init[rank] = MPI_Wtime();
			esclavo(argc,argv,rank, nproc);
			end[rank] = MPI_Wtime();
			printf("Ejecucion Esclavo %d: %f\n", rank, end[rank] - init[rank]);
			break;
	};


	MPI_Finalize();

	return 0;

}
