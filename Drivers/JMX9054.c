#include <cvirte.h>		
#include <userint.h>
#include "JMX9054.h"

static int panelHandle;


int cardHandle[18]={0};
int running=0;
int portNum=0;
int CVICALLBACK rcvThread (void *functionData); 
FILE *saveFile=NULL;


int main (int argc, char *argv[])
{
	int threadId=0; 
	if (InitCVIRTE (0, argv, 0) == 0)
		return -1;	/* out of memory */
	if ((panelHandle = LoadPanel (0, "JMX9054.uir", PANEL)) < 0)
		return -1;
	DisplayPanel (panelHandle);


	if(jmx_open(cardHandle)<0){
		MessagePopup ("错误", "板卡初始化失败！");
	}
	CmtScheduleThreadPoolFunction (DEFAULT_THREAD_POOL_HANDLE, rcvThread, 0, &threadId); 
	

	RunUserInterface ();
	DiscardPanel (panelHandle);
	return 0;
}

int CVICALLBACK mainPanelCB (int panel, int event, void *callbackData,
							 int eventData1, int eventData2)
{		
	switch (event)
	{
		case EVENT_GOT_FOCUS:

			break;
		case EVENT_LOST_FOCUS:

			break;
		case EVENT_CLOSE:
			jmx_close(cardHandle[0]);
			QuitUserInterface (0);
			break;
	}
	return 0;
}

int CVICALLBACK resetBtn (int panel, int control, int event,
						  void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			jmx_reset(cardHandle[0]);
			break;
	}  
	return 0;
}

int CVICALLBACK sendDataBtn (int panel, int control, int event,
							 void *callbackData, int eventData1, int eventData2)
{	
	
	char str[4096]="";
	unsigned char *data=NULL;
	unsigned int dataLen=0;

	switch (event)
	{
		case EVENT_COMMIT:
			GetCtrlVal (panelHandle, MAIN_TEXTBOX, str);
			str2hex(str, strlen(str), &data, &dataLen);
			jmx_send(cardHandle[0], portNum, data, dataLen); 


				int i=0;
			for(i=0;i<dataLen;i++){
			viOut32 (handle, VI_PXI_BAR2_SPACE, 4*(0x70+portNum*16+0x0f), data[i]); 	
			}
			viOut32 (handle, VI_PXI_BAR2_SPACE, 4*(0x70+portNum*16+0x0a),0x00);
			viOut32 (handle, VI_PXI_BAR2_SPACE, 4*(0x70+portNum*16+0x0a),0x01);
			viOut32 (handle, VI_PXI_BAR2_SPACE, 4*(0x70+portNum*16+0x0a),0x00);
			return 0;

			while(count<100000000)
				{
					if(rdcount<txcount)
					{
						readData(rdcount, rddata);
					}
					else if(rdcount==txcount+1000000)
					{
						do
						{
							sleep(50);/* code */
						} while (rdcount<txcount);
											
					}
					else
					{
						break;
					}
				}

			free(data);
			break;
	}
	return 0;
}

int CVICALLBACK clearSendBtn (int panel, int control, int event,
							  void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			ResetTextBox (mainPanel, MAIN_TEXTBOX, "");
			break;
	}
	return 0;
}

int CVICALLBACK clearRcvBtn (int panel, int control, int event,
							 void *callbackData, int eventData1, int eventData2)
{
	switch (event)
	{
		case EVENT_COMMIT:
			ResetTextBox (mainPanel, MAIN_TEXTBOX_2, "");
			break;
	}
	return 0;
}

int CVICALLBACK configBtn (int panel, int control, int event,
						   void *callbackData, int eventData1, int eventData2)
{
	int width=0,height=0,frame=0;

	switch (event)
	{
		case EVENT_COMMIT:
			GetCtrlVal (mainPanel, RING, &portNum);
			//GetCtrlVal (mainPanel, MAIN_NUMERIC_3, &sendtime); 
			GetCtrlVal (mainPanel, NUMERIC, &width); 
			GetCtrlVal (mainPanel, NUMERIC_2, &height); 
			//GetCtrlVal (mainPanel, MAIN_RING_33, &data_number); 
			//GetCtrlVal (mainPanel, MAIN_RING_37, &cntl_number); 
			GetCtrlVal (mainPanel, NUMERIC_3, &frame); 
			running=1;
			break;
	}
	return 0;
}



int CVICALLBACK rcvThread (void *functionData){
	int i=0;
	int dataLen=0;
	unsigned int *data = NULL;
	char *str = NULL;
	int strLen=0;
	while(1){
		if(running){
			jmx_getDataLen(cardHandle[0], portNum, &dataLen);
			if(dataLen>0){
				data = malloc(4*dataLen);
				str = calloc (4, dataLen*10);
				SetCtrlVal(mainPanel, MAIN_NUMERIC_2, dataLen);
				for(i=0;i<dataLen;i++){
					jmx_getData(cardHandle[0], portNum, &data[i]); 
				}
				
				for(i=0;i<dataLen;i++){
					sprintf(str, "%s%02X ", str, data[i]);
				}
				sprintf(str, "%s\n", str); 
			//	hex2str(data, dataLen, &str, &strLen);   
				SetCtrlVal (mainPanel, MAIN_TEXTBOX, str); 
				if(saveFile){
					fwrite (data, 4, dataLen, saveFile);
				}
				free(str);
				free(data);
			}
		}
		Sleep(10);
	}
	return 0;
}