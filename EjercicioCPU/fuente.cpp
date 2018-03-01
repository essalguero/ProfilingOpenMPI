#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void pruebamalloc(int y)
{

	int* x=(int*)malloc(10*sizeof(int));
	x[1000]=5;

}

int fun3(int x)
{
 int i;
 for(i=0;i<100;i++)
	{
	
	x++;
	}

	pruebamalloc(x);
	return x;
}

int fun2(int x)
{
 int i;
 for(i=0;i<1000;i++)
	{
	  x+=  fun3(x);
	}

	return x;
}

int fun1(int x)
{
 int i;
 for(i=0;i<1000;i++)
	{
		x+=fun2(x);
		x+=fun3(x);
	}

	return x;
}





int main()
{
	fun1(0);
	return 1;
}
