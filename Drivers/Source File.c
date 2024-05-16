//==============================================================================
//
// Title:		Source File.c
// Purpose:		A short description of the implementation.
//
// Created on:	2024/5/16 at 19:28:48 by .
// Copyright:	. All Rights Reserved.
//
//==============================================================================

//==============================================================================
// Include files

//#include "Source File.h"

//==============================================================================
// Constants

//==============================================================================
// Types

//==============================================================================
// Static global variables

//==============================================================================
// Static functions

//==============================================================================
// Global variables

//==============================================================================
// Global functions

/// HIFN  What does your function do?
/// HIPAR x/What inputs does your function expect?
/// HIRET What does your function return?


#include <visa.h>
#define jmx_MANF_ID 0xFEE5 
#define jmx_MODEL_CODE 0x5005 


int jmx_open(unsigned long *handle){
	ViSession rescManager=0; 
	int instrNum;
	char instrDesp[256]; 
	ViSession findHandle;
	ViSession instrHandle; 
	ViUInt16 manfId,modelCode;
	int i=0,cardNum=0;
	
	if(viOpenDefaultRM(&rescManager)<0){return -1;}
	if(viFindRsrc (rescManager, "PXI?*INSTR", &findHandle, &instrNum, instrDesp)<0){ return -1; } 
	for(i=0;i<instrNum;i++)
	{
		if(viOpen (rescManager, instrDesp, VI_NULL, VI_NULL, &instrHandle)<0)
		{ 
			viClose(findHandle); 
			return -1; 
		}
		//-------为了兼容NIVISA 3.x------//
		viIn16 (instrHandle, VI_PXI_CFG_SPACE, 0 ,&manfId); 	
		viIn16 (instrHandle, VI_PXI_CFG_SPACE, 2 ,&modelCode); 
		if( (manfId == jmx_MANF_ID) && (modelCode == jmx_MODEL_CODE) )
		{
		   	handle[cardNum]=instrHandle;	  //模块已找到
			cardNum = cardNum + 1;
			if(i<instrNum-1)
			{
				if(viFindNext (findHandle, instrDesp)<0){ viClose(findHandle); return -1; }
			}
		}
		else
		{
			viClose(instrHandle); 
			if(i<instrNum-1)
			{
				if(viFindNext (findHandle, instrDesp)<0){ viClose(findHandle); return -1; }
			}
		}	
	}
	if(cardNum > 0) 
	{
		viClose(findHandle);
		return 0;
	}
	return -2;
}


int jmx_close(unsigned long handle){
	if(handle){
		viClose(handle);
	} 
	return 0;
}


int jmx_reset(unsigned long handle){
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0, 1);   
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0, 0); 
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*120, 0);   
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*120, 1); 
	
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x21, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x23, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x25, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x27, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x29, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x2b, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x2d, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x2f, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x31, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x33, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x35, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x37, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x39, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x3b, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x3d, 0x40000000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x3f, 0x40000000);
	
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x1c, 0x00020000);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x19, 0x0);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*0x19, 0x1);
	return 0;
}



int jmx_send(unsigned long handle, int portNum, char *data, int dataLen){
	int i=0;
	for(i=0;i<dataLen;i++){
		viOut32 (handle, VI_PXI_BAR2_SPACE, 4*(0x70+portNum*16+0x0f), data[i]); 	
	}
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*(0x70+portNum*16+0x0a),0x00);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*(0x70+portNum*16+0x0a),0x01);
	viOut32 (handle, VI_PXI_BAR2_SPACE, 4*(0x70+portNum*16+0x0a),0x00);
	return 0;
} 


int jmx_getDataLen(unsigned long handle, int portNum, int *dataLen){
	unsigned int base_add, offset_add, ret_data;
	base_add=0x80+(portNum%6-1)*0x10;
	offset_add=0x0e;
	viIn32(handle, VI_PXI_BAR2_SPACE, 4*(base_add+offset_add), &ret_data);
	*dataLen = ret_data&0xffff;
	if( (*dataLen&0x7ff)==0 ){
		*dataLen=0;	
	} 
	return 0;
} 

int jmx_getData(unsigned long handle, int portNum, unsigned int *data){
	unsigned int base_add,offset_add,ret_data;
	int i;
	
	base_add=0x80+(portNum%6-1)*0x10;
	offset_add=0x0f;
//	for(i=0;i<number;i++){
		viIn32(handle, VI_PXI_BAR2_SPACE, 4*(base_add+offset_add), data);
//	}
	return 0;
} 






