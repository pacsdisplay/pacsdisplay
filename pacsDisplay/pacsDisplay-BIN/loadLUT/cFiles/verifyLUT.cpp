/**************************************************************
*                                                             *
* verifyLUT -- program to check display LUTs and compare them *
*            to LUTs stored in files after running loadLUT.   *
*                                                             *
* Authors:   M. Flynn                                         *
*            P. Tchou                                         *
*                                                             *
* History:													  *
*	Version 1.0   31 Dec 2003 - Initial release for 1 monitor *
*								systems						  *
*	Version 1.3	  18 May 2005 - Updated to support loadLUT	  *
*								version 1.3					  *
*	Version 2.1   31 Oct 2005 - Updated to support loadLUT    *
*								version 2.1					  *
*                                                             *
* Usage:     'verifyLUT.exe [working directory (optional)]'	  *
*                                                             *
*            LUT file must be in the format produced by       *
*            the HFHS LUTgenerate application.                *
*                                                             *
*            verifyLUT checks for errors after loadLut has    *
*            been run on a system.  It first checks 'log.txt' *
*            for an error flag.  If none is found, it reads   *
*            parameters from 'configLL.txt' and checks that   *
*            the LUTs indicated are still present.			  *
*															  *
*			 The 'log.txt' file must be in the same directory *
*			 as verifyLUT.  If a working directory is		  *
*			 specified, then verifyLUT will look for		  *
*            'configLL.txt' and the LUT files in that		  *
*            directory.										  *
*                                                             *
* Summary:                                                    *
*   The Microsoft Windows Graphic Device Interface (GDI)      *
*   library has routines communicating with display           *
*   controller cards using ICM type procedures.               *
*   modern cards will support these controls.                 *
*   This program used GDI procedures to load look-up tables   *
*   (ie LUTs) into the graphic card. LUTs are read from a text*
*   file as 8-bit numbers ranging from 0 to 255 for each      *
*   of three channels (R,G, and B). 8 bit color values are    *
*   converted from the display value sent to the card (0-255) *
*   to the value loaded in the card from the LUT.             *
*                                                             *
*   Windows defines the LUT as 16 bit integers (WORD type).   *
*   In this program 8 bit LUT values are converted to 16 bits *
*   using a multiplication by 256. Some advanced devices may  *
*   support graphic objects of more that 8 bits per channel   *
*   This is not supported in this program.                    *
*                                                             *
*   Testing indicates that some LUT entries can cause the     *
*   SetDeviceGammaRamp procedure to fail. These seem to be    *
*   extreme values like 0 0 255 that were inserted for test   *
*   purposes. The reason is not known. The procedure may test *
*   for irrational conditions. Relatively discontinuouse      *
*   LUT changes as in testLUT.txt do load.                    *
*                                                             *
*   A loaded LUT will be applied globally to all applications *
*   and will remain in place until the computer is rebooted.  *
*   The LUT will remain loaded for all users as they may log  *
*   on and off to the system. A LUT may be sheduled to load at*
*   each startup using the task scheduler.                    *
**************************************************************/

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
		error = 1;
		fprintf_s(stderr, "\nERROR opening %s (log file) for output\n", logFile);
		sprintf_s(title, sizeof(title), "%s - ERROR CREATING LOG FILE", version);
		sprintf_s(temp, sizeof(temp), "Unable to create %s.", logFile);
		MessageBox(NULL, temp, title, MB_OK);
		exit (EXIT_FAILURE);
	} else {

		/* write log file */
		output << "# log file for " << version << endl;
		SYSTEMTIME date;
		GetLocalTime(&date);
		output << date.wMonth << "/" << date.wDay << "/" << date.wYear << " " << date.wHour << ":" << date.wMinute << endl;
		output << error << endl;
		output << log;

		output.close();
	}

	/* message box */
	if (error) {
		sprintf_s(title, sizeof(title), "%s - ERROR FOUND", version);
		sprintf_s(temp, sizeof(temp), "Error found - see %s.", logFile);
		MessageBox(NULL, temp, title, MB_OK);
	}


	return 0;
}
/******************************************************************/

/* main program */

int main (int argc, char *argv[])
{
	/* version information */
	char	version[50] = "verifyLUT v2.1";

	/* variable definitions */
	WORD	currentLUT[256*3];
	WORD	newLUT[256*3];
	int		RED;
	int		GRN;
	int		BLU;
	int		dateTolerance = 3;
	int		lutCnt = 0;
	char	lut[5];
	char    lutChk[5];
	char	log[10000] = "";
	char	configFileName[100] = "configLL.txt";	// default config
	char	configModelName[100] = "";
	char	configSerialName[50] = "";
	char	newLUTFileName[500] = "";
	char	bakLUTFileName[500] = "";
	char	test_newLUTFileName[500] = "";
	char	logFile[200] = "log.txt";			// default log file
	char	directory[500] = "";		// working directory
	char	slash_str[2] = "\\";

	/* temporary variables */
	int		i;
	int		j;
	int		k;
	int		test = 0;
	char	c;
	char	string[500] = "";
	char	*string_ptr;
	char	*char_ptr;
	char	temp[10000] = "";
	char	temp2[10000] = "";

	/* flag and counter variables */
	int		option = 0;			// option flag
	int		numOptions = 0;		// number of options
	int		noload = 0;			// option to not load any LUTs
	int		serialcheck = 0;	// option to check monitor serial numbers
	int		LUTsearch = 0;		// option to find the LUT file based on model and S/N
	int		LDTsearch = 0;		// option to find the LUT file based on model and date of manufacture
	int		error = 0;			// error flag
	int		EDID;				// EDID read flag
	int		check = 0;			// serial check flag
	int		search = 0;			// LUT search flag
	int		date = 0;			// date search flag
	int		verifyCnt;			// LUT verification counter
	int		displayN;			// display counter
	int		deviceN;			// device information element counter
	int		regKeyN;			// registry key counter

	/* file I/O variables */
	FILE	*config_file;			// config file
	FILE	*bakLUT_file;			// backup LUT file
	FILE	*newLUT_file;			// new LUT file to be loaded
	long	hFile;						// file find handle
	struct	_finddata_t findFile;	// file find data structure

	/* display variables */
	int numdisplays;
	HDC		P_display;			// display device context
	DWORD	dev;
	DWORD	devMon;
	DISPLAY_DEVICE dd;
	dd.cb = sizeof(dd);
	DISPLAY_DEVICE ddMon;
	ddMon.cb = sizeof(ddMon);
	DEVMODE	dm;
/*	HMONITOR hm = 0;
	MONITORINFOEX mi_ex;
/**/
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


	/* -------------------------
	   check arguments and usage
	   ------------------------- */

	/* output executable */
	sprintf_s(temp, sizeof(temp), "\nargc =  %d\n",argc);
	strcat_s(log, sizeof(log), temp);

	fprintf_s(stdout, "argv[0] =  %s\n", argv[0]);
	sprintf_s(temp, sizeof(temp), "argv[0] =  %s\n", argv[0]);
	strcat_s(log, sizeof(log), temp);

	/* output arguments */
	for (i = 1; i < argc; i++) {
		fprintf_s(stdout, "argv[%d] =  %s\n", i, argv[i]);
		sprintf_s(temp, sizeof(temp), "argv[%d] =  %s\n", i, argv[i]);
		strcat_s(log, sizeof(log), temp);
	}

	if (argc == 2) {
		/* get working directory and setup filenames */
		strcpy_s(directory, sizeof(directory), argv[1]);

		i = strlen(directory);

		for (j=0; j < i; ++j) {
			if (directory[j] == '/') {
				directory[j] = '\\';
			}
		}

		--i;
		if (directory[i] != '\\') {			//check for slash at end of directory
			strcat_s(directory, sizeof(directory), slash_str);
		}

		fprintf_s(stdout, "\nWorking directory =  %s\n",directory);
		sprintf_s(temp, sizeof(temp), "\nWorking directory =  %s\n",directory);
		strcat_s(log, sizeof(log), temp);

		strcpy_s(temp, sizeof(temp), directory);			//set working filenames
		strcat_s(temp, sizeof(temp), configFileName);
		strcpy_s(configFileName, sizeof(configFileName), temp);
		strcpy_s(temp, sizeof(temp), directory);
		strcat_s(temp, sizeof(temp), logFile);
		strcpy_s(logFile, sizeof(logFile), temp);

	}
	
	if (argc > 2) {
		printf("Usage: loadLUT.exe [(working directory)]\n");
		sprintf_s(temp, sizeof(temp), "\nUsage: loadLUT.exe [(working directory)]\n");
		strcat_s(log, sizeof(log), temp);

		/* error message */
		sprintf_s(temp, sizeof(temp), "%s - USAGE ERROR", version);
		MessageBox(NULL, log, temp, MB_OK);
		exit (EXIT_FAILURE);
	}

	/* list current working files */
	fprintf_s(stdout, "Config file = %s\nLog file = %s\n",configFileName, logFile);
	sprintf_s(temp, sizeof(temp), "Config file = %s\nLog file = %s\n",configFileName, logFile);
	strcat_s(log, sizeof(log), temp);


	/* -------------------------
	   begin reading config file
	   ------------------------- */

	/* open config file */
	if (fopen_s(&config_file, configFileName, "r")) {
		fprintf_s(stderr, "\nERROR opening %s for read\n", configFileName);
		sprintf_s(temp, sizeof(temp), "\nERROR opening %s for read\n", configFileName);
		strcat_s(log, sizeof(log), temp);

		/* write log file */
		error = 1;
		createlog(logFile, version, error, log);
		exit (EXIT_FAILURE);
	}

	/* read and echo text header */
	fprintf_s(stdout, "\n==> Comment lines (1-2) from %s:\n",configFileName);
	sprintf_s(temp, sizeof(temp), "\n==> Comment lines (1-2) from %s:\n",configFileName);
	strcat_s(log, sizeof(log), temp);

	for (i=1; i <= 2; ++i) {
		string_ptr = fgets(string, sizeof(string), config_file);
		if (string_ptr == NULL) {
			fprintf_s(stderr, "\nERROR reading line %d of %s\n", i, configFileName);
			sprintf_s(temp, sizeof(temp), "\nERROR reading line %d of %s\n", i, configFileName);
			strcat_s(log, sizeof(log), temp);

			/* write log file */
			error = 1;
			createlog(logFile, version, error, log);
			exit (EXIT_FAILURE);
		} else {
			fputs(string, stdout);
			strcat_s(log, sizeof(log), string);
		}
	}

	/* read options and get number of displays*/
	numOptions = 0;

	while (option == 0) {
		string_ptr = fgets(string, sizeof(string), config_file);
		if (string_ptr == NULL) {
			fprintf_s(stderr, "\nERROR reading line %d of config file\n", numOptions+3);
			sprintf_s(temp, sizeof(temp), "\nERROR reading line %d of config file\n", numOptions+3);
			strcat_s(log, sizeof(log), temp);

			/* write log file */
			error = 1;
			createlog(logFile, version, error, log);
			exit (EXIT_FAILURE);
		} else {
			c = string[0];

			if (c == '/') {	//check for options
				numOptions++;
				sscanf_s(string, "%s", &temp2, sizeof(temp2));

				if (!strcmp(temp2, "/noload")) {
					noload = 1;
					fprintf_s(stderr, "\nOption /noload found.  No LUT loaded during last execution.");
					strcat_s(log, sizeof(log), "\nOption /noload found.  No LUT loaded during last execution.");

					/* write log file */
					createlog(logFile, version, error, log);
					return 0;
				} else {
					if (!strcmp(temp2, "/LUTsearch")) {
						LUTsearch = 1;
					} else {
						if (!strcmp(temp2, "/LDTsearch")) {
							LDTsearch = 1;
							sscanf_s(string, "/LDTsearch %d", &dateTolerance);	//get date tolerance (in weeks)
							sprintf_s(temp2, sizeof(temp2), "/LDTsearch %d", dateTolerance);
						} else {
							fprintf_s(stderr, "\nERROR: invalid option (%s)\n", temp2);
							sprintf_s(temp, sizeof(temp), "\nERROR: invalid option (%s)\n", temp2);
							strcat_s(log, sizeof(log), temp);

							/* write log file */
							error = 1;
							createlog(logFile, version, error, log);
							exit (EXIT_FAILURE);
						}
					}
				}

				fprintf_s(stdout, "\n==> Option %d = %s\n", numOptions, temp2);
				sprintf_s(temp, sizeof(temp), "\n==> Option %d = %s\n", numOptions, temp2);
				strcat_s(log, sizeof(log), temp);

			} else {
				option = 1;

				/* read number of displays */
				sscanf_s(string, "%d", &numdisplays);

				if (numdisplays < 1) {
					fprintf_s(stderr, "\nERROR: number of displays is less than 1 (%s)\n", string);
					sprintf_s(temp, sizeof(temp), "\nERROR: number of displays is less than 1 (%s)\n", string);
					strcat_s(log, sizeof(log), temp);

					/* write log file */
					error = 1;
					createlog(logFile, version, error, log);
					exit (EXIT_FAILURE);
				}

				fprintf_s(stdout, "\n==> Display devices = %i\n", numdisplays);
				sprintf_s(temp, sizeof(temp), "\n==> Display devices = %i\n", numdisplays);
				strcat_s(log, sizeof(log), temp);
			}
		}
	}		//end while loop


	/* cycle through each display */
	for (displayN=0; displayN < numdisplays; ++displayN) {


		/* --------------
		   select display 
		   -------------- */

		/* display number */
		string_ptr = fgets(string, sizeof(string), config_file);
		if (string_ptr == NULL) {
			fprintf_s(stderr,	"\nERROR reading line %i of config file\n", displayN*3+1);
			sprintf_s(temp, sizeof(temp), "\nERROR reading line %i of config file\n", displayN*3+1);
			strcat_s(log, sizeof(log), temp);

			/* write log file */
			error = 1;
			createlog(logFile, version, error, log);
			exit (EXIT_FAILURE);
		} else {
			sscanf_s(string, "%d", &dev);

			fprintf_s(stdout, "\n\nDISPLAY %d: \n", dev);
			sprintf_s(temp, sizeof(temp), "\n\nDISPLAY %d: \n", dev);
			strcat_s(log, sizeof(log), temp);
		}


		/* ----------------------
		   get config information
		   ---------------------- */

		/* model */
		string_ptr = fgets(string, sizeof(string), config_file);
		if (string_ptr == NULL) {
			fprintf_s(stderr, "\nERROR reading line %i of config file\n", displayN*3+2);
			sprintf_s(temp, sizeof(temp), "\nERROR reading line %i of config file\n", displayN*3+2);
			strcat_s(log, sizeof(log), temp);

			/* write log file */
			error = 1;
			createlog(logFile, version, error, log);
			exit (EXIT_FAILURE);
		} else {
			c = string[0];

			if (c == '\"') {	//check for spaces in model name
				sprintf_s(configModelName, sizeof(configModelName), "");

				for (i=1; i < sizeof(string); i++) {
					c = string[i];

					if (c == '\"') {
						break;
					} else {
						sprintf_s(temp, sizeof(temp), "%c", c);
						strcat_s(configModelName, sizeof(configModelName), temp);
					}
				}
			} else {
				sscanf_s(string, "%s", &configModelName, sizeof(configModelName));
			}

			fprintf_s(stdout, " Expected Model = %s\n", configModelName);
			sprintf_s(temp, sizeof(temp), " Expected Model = %s\n", configModelName);
			strcat_s(log, sizeof(log), temp);
		}

		/* serial number */
		string_ptr = fgets(string, sizeof(string), config_file);
		if (string_ptr == NULL) {
			fprintf_s(stderr, "\nERROR reading line %i of config file\n", displayN*3+2);
			sprintf_s(temp, sizeof(temp), "\nERROR reading line %i of config file\n", displayN*3+2);
			strcat_s(log, sizeof(log), temp);

			/* write log file */
			error = 1;
			createlog(logFile, version, error, log);
			exit (EXIT_FAILURE);
		} else {
			c = string[0];
			if (c == '\"') {	// check for spaces in serial number
				sprintf_s(configSerialName, sizeof(configSerialName), "");
				for (i=1; i < sizeof(string); i++) {
					c = string[i];
					if (c == '\"') {
						break;
					} else {
						sprintf_s(temp, sizeof(temp), "%c", c);
						strcat_s(configSerialName, sizeof(configSerialName), temp);
					}
				}
			} else {			// no spaces
				sscanf_s(string, "%s", &configSerialName, sizeof(configSerialName));
			}

			fprintf_s(stdout, " Expected S/N = %s\n", configSerialName);
			sprintf_s(temp, sizeof(temp), " Expected S/N = %s\n", configSerialName);
			strcat_s(log, sizeof(log), temp);
		}

		/* new LUT filename */
		string_ptr = fgets(string,sizeof(string),config_file);
		if (string_ptr == NULL) {
			fprintf_s(stderr, "\nERROR reading line %i of config file\n", displayN*3+2);
			sprintf_s(temp, sizeof(temp), "\nERROR reading line %i of config file\n", displayN*3+2);
			strcat_s(log, sizeof(log), temp);

			/* write log file */
			error = 1;
			createlog(logFile, version, error, log);
			exit (EXIT_FAILURE);
		} else {
			if (argc > 1) {		//include working directory
				strcpy_s(newLUTFileName, sizeof(newLUTFileName), directory);
			} else {
				sprintf_s(newLUTFileName, sizeof(newLUTFileName), "");		//clear previous filenames
			}

			c = string[0];
			if (c == '\"') {	// check for spaces in LUT filename
				sprintf_s(temp2, sizeof(temp2), "");
				for (i=1; i < sizeof(string); i++) {
					c = string[i];
					if (c == '\"') {
						break;
					} else {
						sprintf_s(temp, sizeof(temp), "%c", c);
						strcat_s(temp2, sizeof(temp2), temp);
					}
				}
			} else {			// no spaces
				sscanf_s(string, "%s", &temp2, sizeof(temp2));
			}

			strcat_s(newLUTFileName, sizeof(newLUTFileName), temp2);

			fprintf_s(stdout, "\n Default LUT = %s\n", newLUTFileName);
			sprintf_s(temp, sizeof(temp), "\n Default LUT = %s\n", newLUTFileName);
			strcat_s(log, sizeof(log), temp);
		}

		/* backup LUT filename */
		if (argc > 1) {		//include working directory
			strcpy_s(bakLUTFileName, sizeof(bakLUTFileName), directory);
		} else {
			sprintf_s(bakLUTFileName, sizeof(bakLUTFileName), "");
		}

		sprintf_s(string, sizeof(string), "bakLUT%d.txt", dev);
		strcat_s(bakLUTFileName, sizeof(bakLUTFileName), string);

		fprintf_s(stdout, " Backup LUT = %s\n", bakLUTFileName);
		sprintf_s(temp, sizeof(temp), " Backup LUT = %s\n", bakLUTFileName);
		strcat_s(log, sizeof(log), temp);


		/* ----------------------
		   get display information
		   ---------------------- */

		/* adjust display index for GDI function calls */
		if (--dev < 0) {
			dev = 0;
		}

		/* get information on the display devices */
		if (EnumDisplayDevices(0, dev, &dd, 0)) {
			ZeroMemory(&dm, sizeof(dm));
			dm.dmSize = sizeof(dm);
			if (EnumDisplaySettingsEx(dd.DeviceName, ENUM_CURRENT_SETTINGS, &dm, 0) == FALSE)
				EnumDisplaySettingsEx(dd.DeviceName, ENUM_REGISTRY_SETTINGS, &dm, 0);

			/* get the currently active display mode */
			devMon = 0;
			while (EnumDisplayDevices(dd.DeviceName, devMon, &ddMon, 0))
			{
				if (ddMon.StateFlags & DISPLAY_DEVICE_ACTIVE)
					break;

				devMon++;
			}

			/* output device information */
			fprintf_s(stdout, "\n Adapter Information: \n");
			fprintf_s(stdout, "  Adapter Name = %s \n  Adapter String = %s \n", dd.DeviceName, dd.DeviceString);
			fprintf_s(stdout, "  Adapter ID (PnP) = %s \n", dd.DeviceID);
			fprintf_s(stdout, "\n Monitor Information: \n");
			fprintf_s(stdout, "  Monitor Name = %s \n  Monitor String = %s \n", ddMon.DeviceName, ddMon.DeviceString);
			fprintf_s(stdout, "  Monitor ID (PnP) = %s \n", ddMon.DeviceID);
			fprintf_s(stdout, "  Monitor Key = %s \n", ddMon.DeviceKey);
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

			/* get the device context and info */
			if (dd.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) {
				// display is enabled, only enabled displays have a monitor handle
				
				/* display device context */
				P_display = CreateDC(TEXT("DISPLAY"), dd.DeviceName, NULL, NULL);
				
				/* monitor handle 
				POINT pt = { dm.dmPosition.x, dm.dmPosition.y };
				hm = MonitorFromPoint(pt, MONITOR_DEFAULTTONULL);

				/* monitor info 
				mi_ex.cbSize = sizeof(mi_ex);
				GetMonitorInfo(hm, &mi_ex);


			/* BEGIN SERIAL CHECK, LUTSEARCH, AND/OR LDTsearch */
				if (serialcheck || LUTsearch || LDTsearch) {
					EDID = 0;			//initialize EDID read flag

				/* registry info */

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
						fprintf_s(stdout, "\nERROR: Cannot create device information set. (SetupDiGetClassDevsEx)\n");
						strcat_s(log, sizeof(log), "\nERROR: Cannot create device information set. (SetupDiGetClassDevsEx)\n");

						/* error codes */
						error = 1;
					} else {

						/* find matching registry entry */
						match = 0;

						for (deviceN=0; ERROR_NO_MORE_ITEMS != GetLastError() ;deviceN++) {

							memset(&devInfoData,0,sizeof(devInfoData));
							devInfoData.cbSize = sizeof(devInfoData);

							/* get device information element */
							test = SetupDiEnumDeviceInfo(devInfoSet,deviceN,&devInfoData);
							
							if (!test) {
								fprintf_s(stdout, "\nERROR: Cannot get device information element. (SetupDiEnumDeviceInfo)\n");
								strcat_s(log, sizeof(log), "\nERROR: Cannot get device information element. (SetupDiEnumDeviceInfo)\n");

								/* write log file */
								error = 1;
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
								fprintf_s(stdout, "\nERROR: Cannot find hardware ID. (SetupDiGetDeviceRegistryProperty)\n");
								strcat_s(log, sizeof(log), "\nERROR: Cannot find hardware ID. (SetupDiGetDeviceRegistryProperty)\n");

								/* write log file */
								error = 1;
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
								/**/
							} else {
								fprintf_s(stdout, "\nERROR: Cannot find device driver key. (SetupDiGetDeviceRegistryProperty)\n");
								strcat_s(log, sizeof(log), "\nERROR: Cannot find device driver key. (SetupDiGetDeviceRegistryProperty)\n");

								/* write log file */
								error = 1;
								createlog(logFile, version, error, log);
								exit(EXIT_FAILURE);
							}

							/* check for a match */
							if (!strcmp(string, ddMon.DeviceID)) {
								match = 1;

								fprintf_s(stdout, "\n Registry Information: \n");
								fprintf_s(stdout, "  Hardware ID = %s \n  Driver Key = %s \n", hardwareID, driverKey);
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
								KEY_ALL_ACCESS);

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

											fprintf_s(stdout, "\n ==> Found EDID\n");
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
								fprintf_s(stdout, "\nERROR: Unable to open registry entry.\n");
								strcat_s(log, sizeof(log), "\nERROR: Unable to open registry entry.\n");
							}

						} else {
							fprintf_s(stdout, "\nERROR: Cannot find matching registry entry.\n");
							strcat_s(log, sizeof(log), "\nERROR: Cannot find matching registry entry.\n");

							/* write log file */
							error = 1;
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

						fprintf_s(stdout, "\n EDID information:\n");
						strcat_s(log, sizeof(log), "\n EDID information:\n");

						for (i=8; i < 10; i++) {		//Manufacturer ID (08h-09h)
							sprintf_s(temp, sizeof(temp), "%02X ", EDIDdata[i]);
							strcat_s(regManID, sizeof(regManID), temp);
						}
						fprintf_s(stdout, "  Manufacturer ID (hex) = %s \n", regManID);
						sprintf_s(temp, sizeof(temp), "  Manufacturer ID (hex) = %s \n", regManID);
						strcat_s(log, sizeof(log), temp);

						for (i=10; i < 12; i++) {		//Product ID (0Ah-0Bh)
							sprintf_s(temp, sizeof(temp), "%02X ", EDIDdata[i]);
							strcat_s(regProID, sizeof(regProID), temp);
						}
						fprintf_s(stdout, "  Product ID (hex) = %s \n", regProID);
						sprintf_s(temp, sizeof(temp), "  Product ID (hex) = %s \n", regProID);
						strcat_s(log, sizeof(log), temp);

						for (i=15; i > 11; i--) {		//Serial Number (0Ch-0Fh, reversed)
							sprintf_s(temp, sizeof(temp), "%c", EDIDdata[i]);
							strcat_s(regSerialA, sizeof(regSerialA), temp);
						}
						fprintf_s(stdout, "  4-digit S/N = %s \n", regSerialA);
						sprintf_s(temp, sizeof(temp), "  4-digit S/N = %s \n", regSerialA);
						strcat_s(log, sizeof(log), temp);

						regWeek = EDIDdata[16];			//Week of manufacture (10h)
						fprintf_s(stdout, "  Week of manufacture = %d \n", regWeek);
						sprintf_s(temp, sizeof(temp), "  Week of manufacture = %d \n", regWeek);
						strcat_s(log, sizeof(log), temp);

						regYear = 1990 + EDIDdata[17];	//Year of manufacture (11h)
						fprintf_s(stdout, "  Year of manufacture = %d \n", regYear);
						sprintf_s(temp, sizeof(temp), "  Year of manufacture = %d \n", regYear);
						strcat_s(log, sizeof(log), temp);

						for (i=54; i < 126 ;i++) {		//Detailed Timing Section (36h-7Dh)

							if (EDIDdata[i] == 255) {	//Extended S/N? (type FFh)
								for (j=i+2; (EDIDdata[j] != 10 && EDIDdata[j] != 32) && (j < i+15); j++) {
									sprintf_s(temp, sizeof(temp), "%c", EDIDdata[j]);
									strcat_s(regSerialB, sizeof(regSerialB), temp);
								}
								fprintf_s(stdout, "  Extended S/N = %s \n",regSerialB);
								sprintf_s(temp, sizeof(temp), "  Extended S/N = %s \n",regSerialB);
								strcat_s(log, sizeof(log), temp);
							}

							if (EDIDdata[i] == 252) {	//Monitor Name Descriptor (type FCh)
								for (j=i+2; (EDIDdata[j] != 10) && (j < i+15); j++) {
									sprintf_s(temp, sizeof(temp), "%c", EDIDdata[j]);
									strcat_s(regName, sizeof(regName), temp);
								}
								fprintf_s(stdout, "  Monitor Descriptor = %s \n",regName);
								sprintf_s(temp, sizeof(temp), "  Monitor Descriptor = %s \n",regName);
								strcat_s(log, sizeof(log), temp);
							}
						}

						/* EDID read complete */
						EDID = 1;

						/* check/search */
						if (EDID && serialcheck) {			//serial check

							/* check model */
							if (strcmp(configModelName, "*") && strcmp(configModelName, regName)) {
								error = 1;
								fprintf_s(stdout, "\n**MODEL NAME CHECK FAILED - LUT NOT LOADED**\n");
								strcat_s(log, sizeof(log), "\n**MODEL NAME CHECK FAILED - LUT NOT LOADED**\n");

								continue;					//continue to next display
							}

							/* check serial number */
							if (strcmp(configSerialName, "*") && strcmp(configSerialName, regSerialA) && strcmp(configSerialName, regSerialB)) {
								error = 1;
								fprintf_s(stdout, "\n**SERIAL NUMBER CHECK FAILED - LUT NOT LOADED**\n");
								strcat_s(log, sizeof(log), "\n**SERIAL NUMBER CHECK FAILED - LUT NOT LOADED**\n");

								continue;					//continue to next display
							}

							fprintf_s(stdout, "\n ==> Model and S/N check passed\n");
							strcat_s(log, sizeof(log), "\n ==> Model and S/N check passed\n");
						}

						if (EDID && (LUTsearch || LDTsearch)) {		//LUTsearch and/or LDTsearch
							if (LUTsearch) {						//LUTsearch
								fprintf_s(stdout, "\n LUT search:\n");
								sprintf_s(temp, sizeof(temp), "\n LUT search:\n");
								strcat_s(log, sizeof(log), temp);

								search = 0;							//initialize LUT search flag

								/* build target LUT filename */
								strcpy_s(test_newLUTFileName, sizeof(test_newLUTFileName), directory);
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "LUT\\LUT_");
								strcpy_s(string, sizeof(string), regName);		//replace spaces with underscores
								char_ptr = strchr(string, ' ');
								while (char_ptr) {
									*char_ptr = '_';
									char_ptr = strchr(string, ' ');
								}
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), string);
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "_");
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), regSerialB);
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "_*");

								fprintf_s(stdout, "  Target LUT file name: %s\n", test_newLUTFileName);
								sprintf_s(temp, sizeof(temp), "  Target LUT file name = %s\n", test_newLUTFileName);
								strcat_s(log, sizeof(log), temp);

								/* search for matching LUT file */
								if ((hFile = _findfirst(test_newLUTFileName, &findFile)) != -1L) {
									search = 1;

									strcpy_s(newLUTFileName, sizeof(newLUTFileName), directory);
									strcat_s(newLUTFileName, sizeof(newLUTFileName), "LUT\\");
									strcat_s(newLUTFileName, sizeof(newLUTFileName), findFile.name);
									_findclose( hFile );

									fprintf_s(stdout, "  Found LUT file: %s\n", newLUTFileName);
									sprintf_s(temp, sizeof(temp), "  Found LUT file: %s\n", newLUTFileName);
									strcat_s(log, sizeof(log), temp);

									fprintf_s(stdout, "\n ==> LUT search successful\n");
									strcat_s(log, sizeof(log), "\n ==> LUT search successful\n");
								} else {
									fprintf_s(stdout, "  File not found\n", newLUTFileName);
									sprintf_s(temp, sizeof(temp), "  LUT file not found\n", newLUTFileName);
									strcat_s(log, sizeof(log), temp);

									fprintf_s(stdout, "\n ==> LUT search failed\n");
									strcat_s(log, sizeof(log), "\n ==> LUT search failed\n");
								}
							}

							if (LDTsearch && !search) {				//LDTsearch
								fprintf_s(stdout, "\n LDT search:\n");
								sprintf_s(temp, sizeof(temp), "\n LDT search:\n");
								strcat_s(log, sizeof(log), temp);

								date = 0;							//initialize date search flag

								/* build target LDT filename */
								strcpy_s(test_newLUTFileName, sizeof(test_newLUTFileName), directory);
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "LDT\\LDT_");
								strcpy_s(string, sizeof(string), regName);		//replace spaces with underscores
								char_ptr = strchr(string, ' ');
								while (char_ptr) {
									*char_ptr = '_';
									char_ptr = strchr(string, ' ');
								}
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), string);
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "_");
								strcpy_s(string, sizeof(string), test_newLUTFileName);		//filename for tolerance search

								/* begin LDT search within tolerance */
								for(i=0; i <= dateTolerance; i++) {
									k = regWeek - i;
									if (k < 1) {
										k = k + 52;
										j = regYear - 1;
									} else {
										j = regYear;
									}

									sprintf_s(temp, sizeof(temp), "%d%d", j, k);
									strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), temp);
									strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "_*");

									fprintf_s(stdout, "  Target = %s\n", test_newLUTFileName);
									sprintf_s(temp, sizeof(temp), "  Target = %s\n", test_newLUTFileName);
									strcat_s(log, sizeof(log), temp);

									/* search for matching LDT file */
									if ((hFile = _findfirst(test_newLUTFileName, &findFile)) != -1L) {
										date = 1;

										strcpy_s(newLUTFileName, sizeof(newLUTFileName), directory);
										strcat_s(newLUTFileName, sizeof(newLUTFileName), "LDT\\");
										strcat_s(newLUTFileName, sizeof(newLUTFileName), findFile.name);
										_findclose( hFile );
										break;
									} else {
										_findclose( hFile );
										strcpy_s(test_newLUTFileName, sizeof(test_newLUTFileName), string);		//reset test filename

										fprintf_s(stdout, "  File not found\n");
										sprintf_s(temp, sizeof(temp), "  File not found\n");
										strcat_s(log, sizeof(log), temp);
									}

									if (i != 0) {
										k = regWeek + i;
										if (k > 52) {
											k = k - 52;
											j = regYear + 1;
										} else {
											j = regYear;
										}

										sprintf_s(temp, sizeof(temp), "%d%d", j, k);
										strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), temp);
										strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "_*");

										fprintf_s(stdout, "  Target = %s\n", test_newLUTFileName);
										sprintf_s(temp, sizeof(temp), "  Target = %s\n", test_newLUTFileName);
										strcat_s(log, sizeof(log), temp);

										/* search for matching LDT file */
										if ((hFile = _findfirst(test_newLUTFileName, &findFile)) != -1L) {
											date = 1;

											strcpy_s(newLUTFileName, sizeof(newLUTFileName), directory);
											strcat_s(newLUTFileName, sizeof(newLUTFileName), findFile.name);
											_findclose( hFile );
											break;
										} else {
											_findclose( hFile );
											strcpy_s(test_newLUTFileName, sizeof(test_newLUTFileName), string);		//reset test filename

											fprintf_s(stdout, "  File not found\n");
											sprintf_s(temp, sizeof(temp), "  File not found\n");
											strcat_s(log, sizeof(log), temp);
										}
									}
								}

								if (date) {
									fprintf_s(stdout, "  Found LDT file: %s\n", newLUTFileName);
									sprintf_s(temp, sizeof(temp), "  Found LDT file: %s\n", newLUTFileName);
									strcat_s(log, sizeof(log), temp);

									fprintf_s(stdout, "\n ==> Date search successful\n");
									strcat_s(log, sizeof(log), "\n ==> Date search successful\n");
								} else {
									fprintf_s(stdout, "\n ==> LDT search failed\n");
									strcat_s(log, sizeof(log), "\n ==> LDT search failed\n");
								}
							}

							if (!search && !date) {
								fprintf_s(stdout, "\n ==> Using default LUT file\n");
								strcat_s(log, sizeof(log), "\n ==> Using default LUT file\n");
							}
						}
					}
				}
			/* END SERIAL CHECK, LUTSEARCH, AND/OR LDTsearch */
						
			} else {
				fprintf_s(stdout, "\n**NOT ATTACHED TO DESKTOP - LUT NOT LOADED**\n");
				strcat_s(log, sizeof(log), "\n**NOT ATTACHED TO DESKTOP - LUT NOT LOADED**\n");

				continue;
			}
		} else {
			fprintf_s(stdout, "\n**DISPLAY NOT FOUND - LUT NOT LOADED**\n");
			strcat_s(log, sizeof(log), "\n**DISPLAY NOT FOUND - LUT NOT LOADED**\n");

			continue;
		}



		/* -------------------------------------
		   read new LUT and format for GammaRamp
		   ------------------------------------- */

		if (noload == 0) {

			/* open new LUT file */
			if (fopen_s(&newLUT_file, newLUTFileName, "r")) {
				fprintf_s(stderr, "\nERROR opening %s for read\n",newLUTFileName);
				sprintf_s(temp, sizeof(temp), "\nERROR opening %s for read\n",newLUTFileName);
				strcat_s(log, sizeof(log), temp);

				/* write log file */
				error = 1;
				createlog(logFile, version, error, log);
				exit (EXIT_FAILURE);
			}

			/* read and echo text header */
			fprintf_s(stdout, "\n ==> Comment lines (1-5) from %s:\n",newLUTFileName);
			sprintf_s(temp, sizeof(temp), "\n ==> Comment lines (1-5) from %s:\n",newLUTFileName);
			strcat_s(log, sizeof(log), temp);

			for (i=1; i <= 5; ++i) {
				string_ptr = fgets(string,sizeof(string),newLUT_file);
				if (string_ptr == NULL) {
					fprintf_s(stderr, "\nERROR reading line %d of %s\n",i,newLUTFileName);
					sprintf_s(temp, sizeof(temp), "\nERROR reading line %d of %s\n",i,newLUTFileName);
					strcat_s(log, sizeof(log), temp);

					/* write log file */
					error = 1;
					createlog(logFile, version, error, log);
					exit (EXIT_FAILURE);
				} else {
					fputs(string, stdout);
					strcat_s(log, sizeof(log), string);
				}
			}

			/* convert text LUT into GammaRamp format */
			for (i=0; i <= 255; ++i) {
				string_ptr = fgets(string,sizeof(string),newLUT_file);
				if (string_ptr == NULL) {
					fprintf_s(stderr,	"\nERROR reading line 5 + %d of LUT file\n",i+1);
					sprintf_s(temp, sizeof(temp), "\nERROR reading line 5 + %d of LUT file\n",i+1);
					strcat_s(log, sizeof(log), temp);

					/* write log file */
					error = 1;
					createlog(logFile, version, error, log);
					exit (EXIT_FAILURE);
				} else {
					sscanf_s(string,"%s %d %d %d", &lut, sizeof(lut), &RED, &GRN, &BLU);
					/* NOTE: sscanf_s caused an artifact when the LUT was directly
					   indicated as &newLUT[i],&newLUT[i+256],&newLUT[i+512] */

					/* verify the #: format of each line */
					_itoa_s(i+1, lutChk, sizeof(lutChk), 10);
					strcat_s(lutChk, sizeof(lutChk), ":");
					if (strcmp(lut,lutChk)) {
						fprintf_s(stdout, "lut = %s\nlutChk = %s\n", lut, lutChk);
						fprintf_s(stderr,	"\nERROR in format of line 5 + %d of LUT file\n",i+1);
						sprintf_s(temp, sizeof(temp), "\nERROR in format of line 5 + %d of LUT file\n",i+1);
						strcat_s(log, sizeof(log), temp);

						/* write log file */
						error = 1;
						createlog(logFile, version, error, log);
						exit (EXIT_FAILURE);
					}

					/* convert LUT values to 16 bit unsigned int (WORD type) */
					newLUT[i]     = RED * 256;
					newLUT[i+256] = GRN * 256;
					newLUT[i+512] = BLU * 256;

					/*test output to confirm read format
					fprintf_s(stdout,"%s  %s  %d  %d  %d\n",
						lutChk,lut,newLUT[i],newLUT[i+256],newLUT[i+512]);
					*/
				}
			}

			/* close new LUT file */
			fclose(newLUT_file);


			/* ------------------------
			   verify the loaded values 
			   ------------------------ */

			if (!GetDeviceGammaRamp(P_display, currentLUT)) {
				fprintf_s(stderr, "\nERROR: Cannot read current LUT\n");
				strcat_s(log, sizeof(log), "\nERROR reading LUT file\n");

				/* write log file */
				error = 1;
				createlog(logFile, version, error, log);
				exit(EXIT_FAILURE);
			} else {
				fprintf_s(stdout, "\n ==> Verifying loaded LUT values\n");
				strcat_s(log, sizeof(log), "\n ==> Verifying loaded LUT values\n");

				verifyCnt = 0;

				for (i=0; i <= 255; ++i) {

					if (newLUT[i] != currentLUT[i]) {
						++verifyCnt;
						fprintf_s(stdout,"%dR: %d expected, %d loaded\n", i+1, newLUT[i]/256, currentLUT[i]/256);
						sprintf_s(temp, sizeof(temp), "%dR: %d expected, %d loaded\n", i+1, newLUT[i]/256, currentLUT[i]/256);
						strcat_s(log, sizeof(log), temp);

					}
					if (newLUT[i+256] != currentLUT[i+256]) {
						++verifyCnt;
						fprintf_s(stdout,"%dG: %d expected, %d loaded\n", i+1, newLUT[i+256]/256, currentLUT[i+256]/256);
						sprintf_s(temp, sizeof(temp), "%dG: %d expected, %d loaded\n", i+1, newLUT[i+256]/256, currentLUT[i+256]/256);
						strcat_s(log, sizeof(log), temp);
					}
					if (newLUT[i+512] != currentLUT[i+512]) {
						++verifyCnt;
						fprintf_s(stdout,"%dB: %d expected, %d loaded\n", i+1, newLUT[i+512]/256, currentLUT[i+512]/256);
						sprintf_s(temp, sizeof(temp), "%dB: %d expected, %d loaded\n", i+1, newLUT[i+512]/256, currentLUT[i+512]/256);
						strcat_s(log, sizeof(log), temp);
					}
				}

				if (verifyCnt == 0) {
					fprintf_s(stdout, " ==> New LUT successfully read and loaded\n");
					strcat_s(log, sizeof(log), " ==> New LUT successfully read and loaded\n");

				} else {
					fprintf_s(stdout, "\n ==> WARNING: LUT loaded but %d entries changed\n", verifyCnt);
					sprintf_s(temp, sizeof(temp), "\n ==> WARNING: LUT loaded but %d entries changed\n", verifyCnt);
					strcat_s(log, sizeof(log), temp);
				}
			}
		}


		/* ---------------------
		   delete device context
		   --------------------- */

		if (DeleteDC(P_display) == 0) {
			fprintf_s(stdout, "\n ==> WARNING: device context did not delete\n");
			strcat_s(log, sizeof(log), "\n ==> WARNING: device context did not delete\n");
		} else {
			fprintf_s(stdout, " ==> Device context deleted\n");
			strcat_s(log, sizeof(log), " ==> Device context deleted\n");
		}
	}


	/* --------------------------------------------------
	                         END
	   --------------------------------------------------*/

	/* write log file */
	if (error == 0) {
		fprintf_s(stdout, "\n==> No errors found in display calibrations");
		sprintf_s(temp, sizeof(temp), "\n==> No errors found in display calibrations.");
	} else {
		fprintf_s(stdout, "\n**Errors found in display calibrations**");
		sprintf_s(temp, sizeof(temp), "\n**Errors found in display calibrations**");
	}
	strcat_s(log, sizeof(log), temp);
	createlog(logFile, version, error, log);

	/* clean up */
	fclose(config_file);

	fprintf(stdout, "\n==> Process complete\n");


	return 0;
}