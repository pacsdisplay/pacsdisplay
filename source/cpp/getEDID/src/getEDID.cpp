/****************************************************************
*																*
* getEDID - a stripped down version of loadLUT designed to take	*
*			a display number and get the corresponding EDID		*
*			information from the Windows registry.				*
*																*
* Authors:   M. Flynn											*
*            P. Tchou											*
*																*
* History:														*
*	Version 1.0   26 Jul 2006 - initial release					*
*	Version 1.0b  26 Mar 2007 - removal of unused code			*
*	Version 1.1   27 Mar 2007 - retrieved display dimensions	*
*                 09 Apr 2007 - reformatted output to STDIO and	*
*                               error codes						*
*                 10 Apr 2007 - removed error message box		*
*                 11 Apr 2007 - added display dimensions (mm)	*
*                               and reformatted the log output	*
*                 12 Apr 2007 - added pseudo display device     *
*                               detection and updated error     *
*                               codes.                          *
*                 23 Apr 2007 - removed all error message boxes *
*	Version 1.1a  04 Oct 2008 - added adapter information to	*
*								standard output					*
*																*
* Usage:														*
*	'getEDID.exe [display number]'								*
*																*
*		display number - the number for the diplay as given by	*
*				the Display Properties window.					*
*																*
* Output:                                                       *
*   The standard output for getEDID is a record with a string   *
*   of pipe ("|") delineated element values given in the        *
*   following order:                                            *
*                                                               *
*   Index   Output                                              *
*   0       Error code:                                         *
*           0 = Display device found and attached to desktop    *
*           1 = Display device found but not attached to desktop*
*           2 = Pseudo display device found                     *
*           3 = Display device not found                        *
*   1       Display number                                      *
*   2       Manufacturer ID (hex)                               *
*   3       Product ID (hex)                                    *
*   4       4-digit S/N                                         *
*   5       Extended S/N                                        *
*   6       Monitor Descriptor                                  *
*   7       Week of manufacture                                 *
*   8       Year of manufacture                                 *
*   9       Max. horizontal image size                          *
*   10      Max. vertical image size                            *
*   11      Max. horizontal image size (mm)                     *
*   12      Max. vertical image size (mm)                       *
*   13      Native horizontal resolution                        *
*   14      Native vertical resolution                          *
*   15      Current horizontal resolution (not from EDID)       *
*   16      Current vertical resolution (not from EDID)         *
*	17		Adapter name										*
*	18		Adapter string										*
*																*
*   A verbose log is written to getEDIDlog.txt that has         *
*   information regarding the enumeration of the display as     *
*   well as the decoded EDID results.                           *
*																*
****************************************************************/

/*#define _WINGDI_*/
#define  WINVER      0x0500
#define _WIN32_WINNT 0x0500

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <setupapi.h>		// requires "setupapi.lib"
#include <initguid.h>
#include <mbstring.h>
#include <io.h>

using namespace std;		//hoist the new headers from the std namespace into the global namespace (Visual Studio 2005)

#define NAME_SIZE 128
#define PRINT(_x_) printf _x_

DEFINE_GUID (GUID_CLASS_MONITOR, 0x4d36e96e, 0xe325, 0x11ce, 0xbf, 0xc1, 0x08, 0x00, 0x2b, 0xe1, 0x03, 0x18);


/* functions */

/******************************************************************/
int createlog (char *logFile, char *version, int error, char *log)
{
	/* temporary variables */
	char title[200];
	char temp[200];

	/* setup log file */

	ofstream output;	//create output file
	output.open(logFile);

	if (!output) {
		fprintf_s(stderr, "\nWARNING: Unable to create log file: \n %s", logFile);
	} else {

		/* write log file */
		output << "# log file for " << version << endl;
		SYSTEMTIME date;
		GetLocalTime(&date);
		output << date.wMonth << "/" << date.wDay << "/" << date.wYear << " " << date.wHour << ":" << date.wMinute << endl;
		output << "Error Code = " << error << endl;
		output << log;

		output.close();
	}

	return 0;
}
/******************************************************************/


/* main program */

int main (int argc, char *argv[])
{

	/* version information */
	char	version[50] = "getEDID v1.1";
	
	/* variable definitions */
	char	log[10000] = "";
	char	logFile[200] = "getEDIDlog.txt";			// default log file
	char	directory[500] = "";		// working directory
	char	slash_str[2] = "\\";

	/* temporary variables */
	int		i;
	int		j;
	int		test = 0;
	char	string[500] = "";
	char	temp[10000] = "";
	char	temp2[10000] = "";

	/* flag and counter variables */
	int		error = 0;			// error flag
	int		EDID;				// successful EDID read flag
	int		registry = 0;		// successful registry read flag (required for EDID information)
	int		deviceN;			// device information element counter
	int		regKeyN;			// registry key counter


	/* display variables */
	int		displayNum;
//	HDC		P_display;			// display device context
	DWORD	dev;
	DWORD	devMon;
	DISPLAY_DEVICE dd;
	dd.cb = sizeof(dd);
	DISPLAY_DEVICE ddMon;
	ddMon.cb = sizeof(ddMon);
	DEVMODE	dm;

	/* device driver and registry variables */
	HDEVINFO devInfoSet = NULL;
	SP_DEVINFO_DATA devInfoData;
    HKEY	hDevRegKey;
	LONG	retValue;
	DWORD	dwType;
	DWORD	AcutalValueNameLength= NAME_SIZE;
	CHAR	valueName[NAME_SIZE];
	unsigned char EDIDdata[1024];
	DWORD	edidsize=sizeof(EDIDdata);
	char	regManID[50];
	char	regProID[50];
	char	regSerialA[50];
	char	regSerialB[50];
	char	regName[50];
	char	hardwareID[200];
	char	driverKey[200];
	int		match = 0;
	int		regWeek;
	int		regYear;
	int		regHsizeCM;
	int		regVsizeCM;
	int		regHsizeMM;
	int		regVsizeMM;
	int		regtempA;
	int		regtempB;
	int		NativeHor;
	int		NativeVer;
	int		CurrentHor;
	int		CurrentVer;

/*	char deviceInstanceID[200];
/**/

	/* -------------------------
	   check arguments and usage
	   ------------------------- */

	sprintf_s(temp, sizeof(temp), "argv[0] =  %s\n", argv[0]);
	strcat_s(log, sizeof(log), temp);

	/* output arguments */
	for (i = 1; i < argc; i++) {
		sprintf_s(temp, sizeof(temp), "argv[%d] =  %s\n", i, argv[i]);
		strcat_s(log, sizeof(log), temp);
	}

	if (argc == 2) {
		sscanf_s(argv[1], "%d", &displayNum);		// get display number
		sprintf_s(temp, sizeof(temp), "\n\nDISPLAY %d: \n", displayNum);
		strcat_s(log, sizeof(log), temp);

	} else {
		/* error codes */
		error = 1;

		fprintf_s(stdout, "%d", error);
		fprintf_s(stdout, "|Usage: getEDID.exe [display number]");

		exit (EXIT_FAILURE);
	}


	/* initialize variables */
	registry = 0;				//initialize registry search flag
	EDID = 0;					//initialize EDID read flag


	/* -----------------------
	   get display information
	   ----------------------- */

	/* adjust display index for GDI function calls */
	dev = displayNum;
	if (--dev < 0) {
		dev = 0;
	}

	/* get information on the display devices */
	if (EnumDisplayDevices(0, dev, &dd, 0)) {
		ZeroMemory(&dm, sizeof(dm));
		dm.dmSize = sizeof(dm);
		if (EnumDisplaySettingsEx(dd.DeviceName, ENUM_CURRENT_SETTINGS, &dm, 0) == FALSE)
			EnumDisplaySettingsEx(dd.DeviceName, ENUM_REGISTRY_SETTINGS, &dm, 0);

		/* check for pseudo display devices */
		if (dd.StateFlags & DISPLAY_DEVICE_MIRRORING_DRIVER) {
			/* error codes */
			error = 2;

			fprintf_s(stdout, "%d", error);
			fprintf_s(stdout, "|ERROR: **PSEUDO DISPLAY DEVICE FOUND**\n");
			strcat_s(log, sizeof(log), "\nERROR: **PSEUDO DISPLAY DEVICE FOUND**\n");

			/* write log file */
			createlog(logFile, version, error, log);
			exit(EXIT_FAILURE);
		}

		/* get the device context and info */
		if (dd.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) {
			// display is enabled, only enabled displays have a monitor handle

			/* display device context 
			P_display = CreateDC(TEXT("DISPLAY"), dd.DeviceName, NULL, NULL);
			*/

			/* monitor handle 
			POINT pt = { dm.dmPosition.x, dm.dmPosition.y };
			hm = MonitorFromPoint(pt, MONITOR_DEFAULTTONULL);
			*/

			/* monitor info 
			mi_ex.cbSize = sizeof(mi_ex);
			GetMonitorInfo(hm, &mi_ex);
			*/

			/* get the currently active display mode and EDID */
			devMon = 0;
			while (EnumDisplayDevices(dd.DeviceName, devMon, &ddMon, 0))
			{
				test = (ddMon.StateFlags & DISPLAY_DEVICE_ACTIVE);
				if (test) {
					break;
				}

				devMon++;
			}

			if (test) {
				registry = 1;
			} else {
				/* error codes */
				error = 2;

				fprintf_s(stdout, "%d", error);
				fprintf_s(stdout, "|ERROR: Cannot find active display device EDID. (EnumDisplayDevices: StateFlags & DISPLAY_DEVICE_ACTIVE)");
				strcat_s(log, sizeof(log), "\nERROR: Cannot find active display device EDID.\n (EnumDisplayDevices: StateFlags & DISPLAY_DEVICE_ACTIVE)\n");

				/* write log file */
				createlog(logFile, version, error, log);
				exit(EXIT_FAILURE);
			}

			/* output device information */
			sprintf_s(temp, sizeof(temp), "\n Adapter Information: \n");
			strcat_s(log, sizeof(log), temp);
			sprintf_s(temp, sizeof(temp), "  Adapter Name = %s \n  Adapter String = %s \n", dd.DeviceName, dd.DeviceString);
			strcat_s(log, sizeof(log), temp);
			sprintf_s(temp, sizeof(temp), "  Adapter ID (PnP) = %s \n", dd.DeviceID);
			strcat_s(log, sizeof(log), temp);
			sprintf_s(temp, sizeof(temp), "  Adapter Key = %s \n", ddMon.DeviceKey);
			strcat_s(log, sizeof(log), temp);
			sprintf_s(temp, sizeof(temp), "\n Monitor Information: \n");
			strcat_s(log, sizeof(log), temp);
			sprintf_s(temp, sizeof(temp), "  Monitor Name = %s \n  Monitor String = %s \n", ddMon.DeviceName, ddMon.DeviceString);
			strcat_s(log, sizeof(log), temp);
			sprintf_s(temp, sizeof(temp), "  Monitor ID (PnP) = %s \n", ddMon.DeviceID);
			strcat_s(log, sizeof(log), temp);
			sprintf_s(temp, sizeof(temp), "  Monitor Key = %s \n", ddMon.DeviceKey);
			strcat_s(log, sizeof(log), temp);

		/* ---------------------------
		BEGIN REGISTRY SEARCH FOR EDID
		------------------------------ */

			/* registry info */
			if (registry) {

				// adapted from code written by:
				// Calvin Guan Software Engineer
				// ATI Technologies Inc. www.ati.com
				//
				// found at:
				// http://www.tech-archive.net/Archive/Development/microsoft.public.development.device.drivers/2004-08/0294.html


				/* build device information set */
				devInfoSet = SetupDiGetClassDevsEx(
					&GUID_CLASS_MONITOR, //class GUID
					NULL, //enumerator
					NULL, //HWND
					DIGCF_PRESENT, // Flags
					NULL, // device info, create a new one.
					NULL, // machine name, local machine
					NULL);// reserved

				if (NULL == devInfoSet)	{
					/* error codes */
					error = 2;

					fprintf_s(stdout, "%d", error);
					fprintf_s(stdout, "|ERROR: Cannot create device information set. (SetupDiGetClassDevsEx)");
					strcat_s(log, sizeof(log), "\nERROR: Cannot create device information set. (SetupDiGetClassDevsEx)\n");

				} else {

					/* find matching registry entry */
					match = 0;

					for (deviceN=0; ERROR_NO_MORE_ITEMS != GetLastError() ;deviceN++) {

						memset(&devInfoData,0,sizeof(devInfoData));
						devInfoData.cbSize = sizeof(devInfoData);

						/* get device information element */
						test = SetupDiEnumDeviceInfo(devInfoSet,deviceN,&devInfoData);
						
						if (!test) {
							/* error codes */
							error = 2;

							fprintf_s(stdout, "%d", error);
							fprintf_s(stdout, "|ERROR: Cannot get device information element. (SetupDiEnumDeviceInfo)");
							strcat_s(log, sizeof(log), "\nERROR: Cannot get device information element. (SetupDiEnumDeviceInfo)\n");

							/* write log file */
							createlog(logFile, version, error, log);
							exit(EXIT_FAILURE);
						}

						/* get device element registry properties */
						if (SetupDiGetDeviceRegistryProperty(		//hardware ID
							devInfoSet,
							&devInfoData,
							SPDRP_HARDWAREID,
							NULL,
							(PBYTE)(&hardwareID),
							sizeof(hardwareID),
							NULL))
						{
							strcpy_s(string, sizeof(string), hardwareID);
							strcat_s(string, sizeof(string), slash_str);

							/*
							fprintf_s(stdout, "\nHardware ID = %s\n", hardwareID);
							sprintf_s(temp, sizeof(temp), "\nHardware ID = %s\n", hardwareID);
							strcat_s(log, sizeof(log), temp);
							/**/
						} else {
							/* error codes */
							error = 2;

							fprintf_s(stdout, "%d", error);
							fprintf_s(stdout, "|ERROR: Cannot find hardware ID. (SetupDiGetDeviceRegistryProperty)");
							strcat_s(log, sizeof(log), "\nERROR: Cannot find hardware ID. (SetupDiGetDeviceRegistryProperty)\n");

							/* write log file */
							createlog(logFile, version, error, log);
							exit(EXIT_FAILURE);
						}

						if (SetupDiGetDeviceRegistryProperty(		//device driver key
							devInfoSet,
							&devInfoData,
							SPDRP_DRIVER,
							NULL,
							(PBYTE)(&driverKey),
							sizeof(driverKey),
							NULL))
						{
							strcat_s(string, sizeof(string), driverKey);

							/*
							fprintf_s(stdout, "\nDevice Driver Key = %s\n", driverKey);
							sprintf_s(temp, sizeof(temp), "\nDevice Driver Key = %s\n", driverKey);
							strcat_s(log, sizeof(log), temp);
							*/
						} else {
							/* error codes */
							error = 2;

							fprintf_s(stdout, "%d", error);
							fprintf_s(stdout, "|ERROR: Cannot find device driver key. (SetupDiGetDeviceRegistryProperty)");
							strcat_s(log, sizeof(log), "\nERROR: Cannot find device driver key. (SetupDiGetDeviceRegistryProperty)\n");

							/* write log file */
							createlog(logFile, version, error, log);
							exit(EXIT_FAILURE);
						}

						/* check for a match */
						if (!strcmp(string, ddMon.DeviceID)) {
							match = 1;

							sprintf_s(temp, sizeof(temp), "\n Registry Information: \n");
							strcat_s(log, sizeof(log), temp);
							sprintf_s(temp, sizeof(temp), "  Hardware ID = %s \n  Driver Key = %s \n", hardwareID, driverKey);
							strcat_s(log, sizeof(log), temp);

							break;
						}
					}

					if (match == 1) {

						/* find EDID registry entry */
						hDevRegKey = SetupDiOpenDevRegKey(
							devInfoSet,
							&devInfoData,
							DICS_FLAG_GLOBAL,
							0,
							DIREG_DEV,
							KEY_READ);

						if (hDevRegKey) {
							for (regKeyN=0, retValue = ERROR_SUCCESS; retValue != ERROR_NO_MORE_ITEMS; regKeyN++)	{

								retValue = RegEnumValue(
								hDevRegKey,
								regKeyN,
								&valueName[0],
								&AcutalValueNameLength,
								NULL,//reserved
								&dwType,
								EDIDdata, // buffer
								&edidsize); // buffer size

								if (retValue == ERROR_SUCCESS )	{

									if (!strcmp(valueName,"EDID")) {

										strcat_s(log, sizeof(log), "\n ==> Found EDID\n");

										/* print out EDID 
										for (i=0; i < edidsize; i++) {
											if (i % 16 == 0) {
												fprintf_s(stdout, "\n");
												strcat_s(log, sizeof(log), "\n");
											}

											fprintf_s(stdout, "%02x ",EDIDdata[i]);
											sprintf_s(temp, sizeof(temp), "%02x ",EDIDdata[i]);
											strcat_s(log, sizeof(log), temp);
										}

										fprintf_s(stdout, "\n");
										strcat_s(log, sizeof(log), "\n");
										/**/

										break;
									}
								}
							}

							RegCloseKey(hDevRegKey);

						} else {
							/* error codes */
							error = 2;

							fprintf_s(stdout, "%d", error);
							fprintf_s(stdout, "|ERROR: Unable to open registry entry.");
							strcat_s(log, sizeof(log), "\nERROR: Unable to open registry entry.\n");

							/* write log file */
							createlog(logFile, version, error, log);
							exit(EXIT_FAILURE);
						}

					} else {
						/* error codes */
						error = 2;

						fprintf_s(stdout, "%d", error);
						fprintf_s(stdout, "|ERROR: Cannot find matching registry entry.");
						strcat_s(log, sizeof(log), "\nERROR: Cannot find matching registry entry.\n");

						/* write log file */
						createlog(logFile, version, error, log);
						exit(EXIT_FAILURE);
					}

					/* decode EDID */
					sprintf_s(regManID, sizeof(regManID), "");			//initialize variables
					sprintf_s(regProID, sizeof(regProID), "");
					sprintf_s(regSerialA, sizeof(regSerialA), "");
					sprintf_s(regSerialB, sizeof(regSerialB), "");
					sprintf_s(regName, sizeof(regName), "");
					regWeek = 0;
					regYear = 0;

					/* error code */
					error = 0;

					fprintf_s(stdout, "%d", error);
					fprintf_s(stdout, "|%d", displayNum);	//output display number
					strcat_s(log, sizeof(log), "\n EDID information:\n");

					for (i=8; i < 10; i++) {		//Manufacturer ID (08h-09h)
						sprintf_s(temp, sizeof(temp), "%02X ", EDIDdata[i]);
						strcat_s(regManID, sizeof(regManID), temp);
					}
					fprintf_s(stdout, "|%s", regManID);
					sprintf_s(temp, sizeof(temp), "  Manufacturer ID (hex)           = %s \n", regManID);
					strcat_s(log, sizeof(log), temp);

					for (i=10; i < 12; i++) {		//Product ID (0Ah-0Bh)
						sprintf_s(temp, sizeof(temp), "%02X ", EDIDdata[i]);
						strcat_s(regProID, sizeof(regProID), temp);
					}
					fprintf_s(stdout, "|%s", regProID);
					sprintf_s(temp, sizeof(temp), "  Product ID (hex)                = %s \n", regProID);
					strcat_s(log, sizeof(log), temp);

					for (i=15; i > 11; i--) {		//Serial Number (0Ch-0Fh, reversed)
						sprintf_s(temp, sizeof(temp), "%c", EDIDdata[i]);
						strcat_s(regSerialA, sizeof(regSerialA), temp);
					}
					fprintf_s(stdout, "|%s", regSerialA);
					sprintf_s(temp, sizeof(temp), "  4-digit S/N                     = %s \n", regSerialA);
					strcat_s(log, sizeof(log), temp);

					for (i=54; i < 126 ;i++) {		//Detailed Timing Section (36h-7Dh)

						if (EDIDdata[i] == 255) {	//Extended S/N? (type FFh)
							for (j=i+2; (EDIDdata[j] != 10 && EDIDdata[j] != 32) && (j < i+15); j++) {
								sprintf_s(temp, sizeof(temp), "%c", EDIDdata[j]);
								strcat_s(regSerialB, sizeof(regSerialB), temp);
							}
						}

						if (EDIDdata[i] == 252) {	//Monitor Name Descriptor (type FCh)
							for (j=i+2; (EDIDdata[j] != 10) && (j < i+15); j++) {
								sprintf_s(temp, sizeof(temp), "%c", EDIDdata[j]);
								strcat_s(regName, sizeof(regName), temp);
							}
						}
					}
					fprintf_s(stdout, "|%s", regSerialB);	//Extended S/N
					sprintf_s(temp, sizeof(temp), "  Extended S/N                    = %s \n",regSerialB);
					strcat_s(log, sizeof(log), temp);

					fprintf_s(stdout, "|%s", regName);		//Monitor descriptor
					sprintf_s(temp, sizeof(temp), "  Monitor Descriptor              = %s \n",regName);
					strcat_s(log, sizeof(log), temp);

					regWeek = EDIDdata[16];			//Week of manufacture (10h)
					fprintf_s(stdout, "|%d", regWeek);
					sprintf_s(temp, sizeof(temp), "  Week of manufacture             = %d \n", regWeek);
					strcat_s(log, sizeof(log), temp);

					regYear = 1990 + EDIDdata[17];	//Year of manufacture (11h)
					fprintf_s(stdout, "|%d", regYear);
					sprintf_s(temp, sizeof(temp), "  Year of manufacture             = %d \n", regYear);
					strcat_s(log, sizeof(log), temp);

					// Display size (cm)
					regHsizeCM = EDIDdata[21];			//Max. Horizontal Image Size (15h)
					fprintf_s(stdout, "|%d", regHsizeCM);
					sprintf_s(temp, sizeof(temp), "  Max. horizontal image size (cm) = %d\n", regHsizeCM);
					strcat_s(log, sizeof(log), temp);

					regVsizeCM = EDIDdata[22];			//Max. Vertical Image Size (16h)
					fprintf_s(stdout, "|%d", regVsizeCM);
					sprintf_s(temp, sizeof(temp), "  Max. vertical image size (cm)   = %d\n", regVsizeCM);
					strcat_s(log, sizeof(log), temp);

					// Display size (mm)
					regtempA = EDIDdata[66];			//Horizontal Image Size (42h)
					regtempB = EDIDdata[68];			//Horizontal Active high (44h - 4 upper bits)
					regHsizeMM = ((regtempB - (regtempB % 16)) * 16) + regtempA;
					fprintf_s(stdout, "|%d", regHsizeMM);
					sprintf_s(temp, sizeof(temp), "  Max. horizontal image size (mm) = %d\n", regHsizeMM);
					strcat_s(log, sizeof(log), temp);

					regtempA = EDIDdata[67];			//Vertical Active (Preferred/Native) (43h)
					regtempB = EDIDdata[68];			//Vertical Active high (44h - 4 lower bits)
					regVsizeMM = ((regtempB % 16) * 256) + regtempA;
					fprintf_s(stdout, "|%d", regVsizeMM);
					sprintf_s(temp, sizeof(temp), "  Max. vertical image size (mm)   = %d\n", regVsizeMM);
					strcat_s(log, sizeof(log), temp);

					// NOTE: The following are from the first detailed timing section and may vary (see EDID specification)
					regtempA = EDIDdata[56];			//Horizontal Active (Preferred/Native) (38h)
					regtempB = EDIDdata[58];			//Horizontal Active high (3Ah - 4 upper bits)
					NativeHor = ((regtempB - (regtempB % 16)) * 16) + regtempA;
					fprintf_s(stdout, "|%d", NativeHor);
					sprintf_s(temp, sizeof(temp), "  Native horizontal resolution    = %d\n", NativeHor);
					strcat_s(log, sizeof(log), temp);

					regtempA = EDIDdata[59];			//Vertical Active (Preferred/Native) (3Bh)
					regtempB = EDIDdata[61];			//Vertical Active high (3Dh - 4 upper bits)
					NativeVer = ((regtempB - (regtempB % 16)) * 16) + regtempA;
					fprintf_s(stdout, "|%d", NativeVer);
					sprintf_s(temp, sizeof(temp), "  Native vertical resolution      = %d\n", NativeVer);
					strcat_s(log, sizeof(log), temp);

					// Current display resolution
					CurrentHor = dm.dmPelsWidth;
					fprintf_s(stdout, "|%d", CurrentHor);
					sprintf_s(temp, sizeof(temp), "  Current horizontal resolution   = %d\n", CurrentHor);
					strcat_s(log, sizeof(log), temp);

					CurrentVer = dm.dmPelsHeight;
					fprintf_s(stdout, "|%d", CurrentVer);
					sprintf_s(temp, sizeof(temp), "  Current vertical resolution     = %d\n", CurrentVer);
					strcat_s(log, sizeof(log), temp);

					// Adapter name and description
					fprintf_s(stdout, "|%s", dd.DeviceName);
					fprintf_s(stdout, "|%s", dd.DeviceString);

					/* EDID read complete */
					EDID = 1;
				}
			}

			if (!EDID) {
				/* error codes */
				error = 2;

				fprintf_s(stdout, "%d", error);
				fprintf_s(stdout, "|ERROR: No EDID information\n");
				strcat_s(log, sizeof(log), "ERROR: No EDID information\n");
			}

			/* ---------------------
			   delete device context
			   --------------------- 

			if (DeleteDC(P_display) == 0) {
				strcat_s(log, sizeof(log), "\n ==> WARNING: device context did not delete\n");
			} else {
				strcat_s(log, sizeof(log), "\n ==> Device context deleted\n");
			}*/

		/* END REGISTRY SEARCH FOR EDID */
					
		} else {
			/* error codes */
			error = 1;

			fprintf_s(stdout, "%d", error);
			fprintf_s(stdout, "|**NOT ATTACHED TO DESKTOP**");
			strcat_s(log, sizeof(log), "\n**NOT ATTACHED TO DESKTOP**\n");

			/* write log file */
			createlog(logFile, version, error, log);
			exit(EXIT_FAILURE);
		}
	} else {
		/* error codes */
		error = 3;

		fprintf_s(stdout, "%d", error);
		fprintf_s(stdout, "|ERROR: **DISPLAY NOT FOUND**\n");
		strcat_s(log, sizeof(log), "\nERROR: **DISPLAY NOT FOUND**\n");

		/* write log file */
		createlog(logFile, version, error, log);
		exit(EXIT_FAILURE);
	}


	/* --------------------------------------------------
	                         END
	   --------------------------------------------------*/

	strcat_s(log, sizeof(log), "\n==> getEDID complete\n");

	createlog(logFile, version, error, log);

	/* clean up */

	return 0;
}