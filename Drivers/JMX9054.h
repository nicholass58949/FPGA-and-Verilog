/**************************************************************************/
/* LabWindows/CVI User Interface Resource (UIR) Include File              */
/*                                                                        */
/* WARNING: Do not add to, delete from, or otherwise modify the contents  */
/*          of this include file.                                         */
/**************************************************************************/

#include <userint.h>

#ifdef __cplusplus
    extern "C" {
#endif

     /* Panels and Controls: */

#define  PANEL                            1       /* callback function: mainPanelCB */
#define  PANEL_LED                        2       /* control type: LED, callback function: (none) */
#define  PANEL_TEXTBOX                    3       /* control type: textBox, callback function: (none) */
#define  PANEL_TEXTBOX_2                  4       /* control type: textBox, callback function: (none) */
#define  PANEL_COMMANDBUTTON              5       /* control type: command, callback function: sendDataBtn */
#define  PANEL_COMMANDBUTTON_2            6       /* control type: command, callback function: resetBtn */
#define  PANEL_COMMANDBUTTON_3            7       /* control type: command, callback function: clearSendBtn */
#define  PANEL_COMMANDBUTTON_4            8       /* control type: command, callback function: clearRcvBtn */
#define  PANEL_COMMANDBUTTON_5            9       /* control type: command, callback function: configBtn */
#define  PANEL_NUMERIC                    10      /* control type: numeric, callback function: (none) */
#define  PANEL_NUMERIC_2                  11      /* control type: numeric, callback function: (none) */
#define  PANEL_STRING                     12      /* control type: string, callback function: (none) */
#define  PANEL_STRING_2                   13      /* control type: string, callback function: (none) */
#define  PANEL_STRING_3                   14      /* control type: string, callback function: (none) */
#define  PANEL_RING                       15      /* control type: ring, callback function: (none) */
#define  PANEL_NUMERIC_3                  16      /* control type: numeric, callback function: (none) */


     /* Control Arrays: */

          /* (no control arrays in the resource file) */


     /* Menu Bars, Menus, and Menu Items: */

          /* (no menu bars in the resource file) */


     /* Callback Prototypes: */

int  CVICALLBACK clearRcvBtn(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK clearSendBtn(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK configBtn(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK mainPanelCB(int panel, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK resetBtn(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);
int  CVICALLBACK sendDataBtn(int panel, int control, int event, void *callbackData, int eventData1, int eventData2);


#ifdef __cplusplus
    }
#endif
