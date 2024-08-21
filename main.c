/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include "stdio.h"
#include "platform.h"
#include "xbasic_types.h"
#include "xparameters.h"
#include "xtime_l.h"
#include "stdint.h"
#include "string.h"
#include "stdlib.h"
#include "math.h"
#include "arm_neon.h"

#define AVG_RUNS 500000

struct mulmatreg {
	volatile float A[9];

	volatile float B[9];

	volatile float C[9];
};

#define MULTMATRIX ((struct mulmatreg *) XPAR_MYIPMATRIXMULTIPLIER_0_S00_AXI_BASEADDR)


void multiplicationMatriceC(float *A, float *B, float *result) {


	//multiplication de AxB

    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            result[j * 3 + i] = 0.0;
            for (int k = 0; k < 3; ++k) {
                result[j * 3 + i] += A[j * 3 + k] * B[k * 3 + i];
            }
        }
    }
}

void multiplicationMatriceNeon(const float32_t *A, const float32_t *B, float32_t *result) {

    float32x4x4_t matA, matB,matC;  //preparation des registres pour stocker les 2 matrices arguments


    //Comme transposée(A)*transposée(B) =  transposée(B*A) on réalise l'opération transposée(B)*transposée(A) = transposée(B*A)
    matB = vld4q_f32(B); //transposition de B
    matA = vld4q_f32(A);  //transposition de A


    // multiplication des matrices
    for (int i = 0; i < 4; ++i) {

		float32x4_t result_ligne = vdupq_n_f32(0.0); //clear de result_row (page 407)

		result_ligne = vmlaq_lane_f32(result_ligne, matA.val[0], vget_low_f32(matB.val[i]),0);
		result_ligne = vmlaq_lane_f32(result_ligne, matA.val[1], vget_low_f32(matB.val[i]),1);
		result_ligne = vmlaq_lane_f32(result_ligne, matA.val[2], vget_high_f32(matB.val[i]),0);
		result_ligne = vmlaq_lane_f32(result_ligne, matA.val[3], vget_high_f32(matB.val[i]),1);

		 //vget_high_f32 car vdupq_n la ligne d'avant donne un float32x4
		// et vmlaq_lane_f32 prend cet argument uniquement en float32x2

		matC.val[i] = result_ligne;

    }

	vst4q_f32(result, matC);
	// on stocke la colonne de resultat dans la colonne de la matrice finale (result) MAIS CELA TRANSPOSE LE RESULTAT.

}

//void convert_3x3_into_4x4(float *A3, float32_t *A4){
//	for(int i = 0; i < 4; i++){
//		for(int j = 0; j < 4; i++){
//			if(i == 3 || j == 3) A4[i * 4 + j] = 0.0;
//			else A4[i * 4 + j] = A3[i * 3 + j];
//		}
//	}
//}

// source: https://stackoverflow.com/questions/33058848/generate-a-random-double-between-1-and-1
double randfrom(double min, double max)
{
    double range = (max - min);
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

int main()
{
    init_platform();


    printf("Started!\n");
    XTime timeBeginVhdl;
    XTime timeEndVhdl;

    XTime tic_C;
    XTime tac_C;

    XTime tic_NEON;
    XTime tac_NEON;
    float C[9];
    float res_C[9];

    float A[9] = {6.15, 0.3333, 0.691,
    		-12.3,-1.9638, -0.00,
			64.9, 106.00,1.0};

//    float B[9] = {0.5, -0.12, 80.987654,
//    		-0.5,20.6, 94.0001,
//			10.641, 40.45,30.01902};
//

    float B[9];
    for(int i = 0; i < 9; i++) {
    	B[i] = (float)rand()/(float)(RAND_MAX/50.0);
    }

    float32_t res4[16];
    float32_t A4[16] = {
    		6.15, 0.3333, 0.691, 0.0,
    		-12.3,-1.9638, -0.00, 0.0,
			64.9, 106.00,1.0, 0.0,
    		0.0, 0.0, 0.0, 0.0};
    float32_t B4[16] = {
    		B[0], B[1], B[2], 0.0,
    		B[3], B[4], B[5], 0.0,
			B[6], B[7], B[8], 0.0,
    		0.0, 0.0, 0.0, 0.0};

//    convert_3x3_into_4x4(A, A4);
//    convert_3x3_into_4x4(B, B4);


    XTime_GetTime(&timeBeginVhdl);
    memcpy(MULTMATRIX->A, &A, sizeof(A));
    memcpy(MULTMATRIX->B, &B, sizeof(B));
    memcpy(&C, MULTMATRIX->C, sizeof(C));
    XTime_GetTime(&timeEndVhdl);

    XTime_GetTime(&tic_C);
    multiplicationMatriceC(A, B, res_C);
    XTime_GetTime(&tac_C);

    XTime_GetTime(&tic_NEON);
    multiplicationMatriceNeon(A4, B4, res4);
    XTime_GetTime(&tac_NEON);


    printf("A =");
	for (int i = 0; i < 3; ++i) {
		for (int j = 0; j < 3; ++j) {
			printf("%f ", A[i*3 + j]);
		}
		printf("\n");
	}
	printf("\n");

	printf("B =");
	for (int i = 0; i < 3; ++i) {
		for (int j = 0; j < 3; ++j) {
			printf("%f ", B[i*3 + j]);
		}
		printf("\n");
	}
	printf("\n");


    printf("A x B =\n");
	for (int i = 0; i < 3; ++i) {
		for (int j = 0; j < 3; ++j) {
			printf("%f ", C[i*3 + j]);
		}
		printf("\n");
	}
	printf("\n");

	printf("C results\n");
	for (int i = 0; i < 3; ++i) {
		for (int j = 0; j < 3; ++j) {
			printf("%f ", res_C[i*3 + j]);
		}
		printf("\n");
	}
	printf("\n");

	printf("NEON results\n");
	for (int i = 0; i < 3; ++i) {
		for (int j = 0; j < 3; ++j) {
			printf("%f ", res4[i*4 + j]);
		}
		printf("\n");
	}
	printf("\n");

	printf("Écart relative (C - Hardware):\n");
	for (int i = 0; i < 3; ++i) {
		for (int j = 0; j < 3; ++j) {
			printf("%f ", fabs((C[i*3 + j] - res_C[i*3 + j])/C[i*3 + j]));
		}
		printf("\n");
	}
	printf("\n");

	printf("Comparison with C results\n");
	for (int i = 0; i < 3; ++i) {
		for (int j = 0; j < 3; ++j) {
			printf("%d ", (fabs((C[i*3 + j] - res_C[i*3 + j])/C[i*3 + j])) < 0.0001);
		}
		printf("\n");
	}
	printf("\n");

	double timeVHDL = ((double) (timeEndVhdl - timeBeginVhdl))* 1000000 * 2/ XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ;
	double timeC = ((double) (tac_C - tic_C))* 1000000 * 2/ XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ;
	double timeNEON = ((double) (tac_NEON - tic_NEON))* 1000000 * 2/ XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ;

	printf("Custom Multiplication Execution Time: %f us\n", timeVHDL);
	printf("C Multiplication Execution Time: %f us\n", timeC);
	printf("NEON Multiplication Execution Time: %f us\n", timeNEON);

	timeVHDL = 0;
	timeC = 0;
	timeNEON = 0;
	double error = 0;
	for(int i = 0; i < AVG_RUNS; i++){
	    for(int k = 0; k < 9; k++) {
	    	B[k] = randfrom(-1000000, 1000000);
	    }
		double partial_error = 0;

	    XTime_GetTime(&timeBeginVhdl);
	    memcpy(MULTMATRIX->A, &A, sizeof(A));
	    memcpy(MULTMATRIX->B, &B, sizeof(B));
	    memcpy(&C, MULTMATRIX->C, sizeof(C));
	    XTime_GetTime(&timeEndVhdl);

	    XTime_GetTime(&tic_C);
	    multiplicationMatriceC(A, B, res_C);
	    XTime_GetTime(&tac_C);

	    XTime_GetTime(&tic_NEON);
	    multiplicationMatriceNeon(A4, B4, res4);
	    XTime_GetTime(&tac_NEON);

	    printf("A x B =\n");
	    for (int i = 0; i < 3; ++i) {
		    for (int j = 0; j < 3; ++j) {
			    printf("%f ", C[i*3 + j]);
		    }
		    printf("\n");
	    }
	    printf("\n");
	    printf("C results\n");
	    for (int i = 0; i < 3; ++i) {
		    for (int j = 0; j < 3; ++j) {
			    printf("%f ", res_C[i*3 + j]);
		    }
		    printf("\n");
	    }
	    printf("\n");
	    printf("Écart relative (C - Hardware):\n");
	    for (int i = 0; i < 3; ++i) {
		    for (int j = 0; j < 3; ++j) {
			    printf("%f ", fabs(C[i*3 + j] - res_C[i*3 + j])/C[i*3 + j]);
		    }
		    printf("\n");
	    }
	    printf("\n");

	    for (int i = 0; i < 3; ++i) {
			for (int j = 0; j < 3; ++j) {
				partial_error += fabs((C[i*3 + j] - res_C[i*3 + j])/C[i*3 + j]);
			}
		}
	    partial_error /= 9;

	    error += partial_error;

		timeVHDL += ((double) (timeEndVhdl - timeBeginVhdl))* 1000000 * 2/ XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ;
		timeC += ((double) (tac_C - tic_C))* 1000000 * 2/ XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ;
		timeNEON += ((double) (tac_NEON - tic_NEON))* 1000000 * 2/ XPAR_CPU_CORTEXA9_CORE_CLOCK_FREQ_HZ;

	}

	printf("Average (500 000 runs) Relative difference (C - Hardware, C as reference): %f\n", error/AVG_RUNS);
	printf("Average (500 000 runs) Custom Multiplication Execution Time: %f us\n", timeVHDL/AVG_RUNS);
	printf("Average (500 000 runs) C Multiplication Execution Time: %f us\n", timeC/AVG_RUNS);
	printf("Average (500 000 runs) NEON Multiplication Execution Time: %f us\n", timeNEON/AVG_RUNS);

    cleanup_platform();
    return 0;
}
