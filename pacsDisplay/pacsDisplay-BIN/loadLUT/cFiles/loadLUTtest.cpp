/**************************************************************
*                                                             *
* loadLUTtest -- program called by a TCL script to read a     *
*                display LUT and load it into the display     *
*                card to set the luminance response           *
*                                                             *
* Authors:   M. Flynn                                         *
*            P. Tchou                                         *
*                                                             *
* History:                                                    *
*	Version 1.0   18 Mar 2004 - initial release for multi-    *
*								monitor systems.              *
*   Version 1.1   09 Jan 2007 - increased string buffer sizes *
*                               to prevent read overflow.     *
*                                                             *
* Usage:     'loadLUTtest.exe [display] [filename]'			  *
*                                                             *
*            LUT file must be in the format produced by       *
*            the HFHS LUTgenerate application.                *
*                                                             *
*            loadLut reads parameters from a command line.    *
*				                                              *
*            display  - display number/identifier             *
*            filename - name and location of the LUT file     *
*                                                             *
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
*   on and off to the system. A LUT may be sheduled to load   *
*   at each startup using the task scheduler.                 *
**************************************************************/

/*#define _WINGDI_*/
#define  WINVER      0x0500
#define _WIN32_WINNT 0x0500


#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

/* functions */

/******************************************************************/
int createlog (char *logFile, int error, char *log)
{
	/* setup log file */
	FILE *log_file;

	log_file = fopen(logFile, "w");
	if (log_file == NULL) {
		fprintf(stderr, "\nERROR opening %s for output\n", logFile);
		exit (EXIT_FAILURE);
	} else {
		fputs("# log file for loadLUT.exe\n",log_file);
	}

	/* write log file */
	SYSTEMTIME date;
	GetSystemTime(&date);
	fprintf(log_file, "%i/%i/%i\n", date.wMonth, date.wDay, date.wYear);
	fprintf(log_file,"%d \n %s", error, log);
	fclose(log_file);

	return 0;
}
/******************************************************************/

/* main program */

int main (int argc, char *argv[])
{
	/* usage test */

	if (argc != 3) {
		printf("Usage: \n  loadLUTtest [display] [filename]\n");
		exit(EXIT_FAILURE);
	}

	
	/*  variable definitions 	*/

	WORD	currentLUT[256*3];
	WORD	newLUT[256*3];
	WORD	RED;
	WORD	GRN;
	WORD	BLU;
	FILE	*bLUT_file;			// backup LUT file
	FILE	*nLUT_file;			// new LUT file to be loaded
	HDC		P_display;			// display device context
	int		i;
	int		error = 0;			// error flag
	int		verifyCnt;			// LUT verification counter
	int		lutCnt = 0;
	char	lut[5];
	char    lutChk[5];
	char	log[10000] = "";
	char	inFile[200];
	char	bakFile[80] = "oldLUT.txt";			// backup LUT file
	char	logFile[80] = "log.txt";			// default log file
	char	string[500];
	char	*string_ptr;
	char	temp[200];

	/* multidisplay variables */
	DWORD	dev; 
	DISPLAY_DEVICE dd;
	dd.cb = sizeof(dd);
	DEVMODE dm;
	HMONITOR hm = 0;


	/* display number */
	sscanf(argv[1],"%d", &dev);
	if (--dev < 0) {
		dev = 0;
	}
	sprintf(temp, "\nDEV = %d \n", dev);
	strcat(log, temp);


	/* new LUT filename */
	strcpy(inFile, argv[2]);
	sprintf(temp, " New LUT = %s\n", inFile);
	strcat(log, temp);


	/* backup LUT filename */
	sprintf(temp, " Backup LUT = %s\n", bakFile);
	strcat(log, temp);


	/* --------------
	   select display 
	   -------------- */

	/* get information about the display's position and the current display mode */
	if (EnumDisplayDevices(0, dev, &dd, 0)!=0) {
		ZeroMemory(&dm, sizeof(dm));
		dm.dmSize = sizeof(dm);
		if (EnumDisplaySettingsEx(dd.DeviceName, ENUM_CURRENT_SETTINGS, &dm, 0) == FALSE)
			EnumDisplaySettingsEx(dd.DeviceName, ENUM_REGISTRY_SETTINGS, &dm, 0);

		/* get the monitor handle and workspace */
		if (dd.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) {
			// display is enabled, only enabled displays have a monitor handle
			
			POINT pt = { dm.dmPosition.x, dm.dmPosition.y };
			hm = MonitorFromPoint(pt, MONITOR_DEFAULTTONULL);

			sprintf(temp, " Device Name = %X \n Device Handle = 0x%X \n", dev, dd.DeviceName, hm);
			strcat(log, temp);

			P_display = CreateDC(TEXT("DISPLAY"), dd.DeviceName, NULL, NULL);

		} else {
			fprintf(stderr, "\nDEV = %d \n**NOT ATTACHED TO DESKTOP - LUT NOT LOADED**\n", dev);
			strcat(log, "\n**NOT ATTACHED TO DESKTOP - LUT NOT LOADED**\n");

			/* write log file */
			error = 1;
			createlog(logFile, error, log);
			printf("1");
			return 1;
		}
	} else {
		fprintf(stderr, "\nDEV = %d \n**DISPLAY NOT FOUND - LUT NOT LOADED**\n", dev);
		strcat(log, "\n**DISPLAY NOT FOUND - LUT NOT LOADED**\n");

		/* write log file */
		error = 1;
		createlog(logFile, error, log);
		printf("1");
		return 1;
	}


	/* -------------------------
	   backup current gamma ramp 
	   ------------------------- */

	/* get gamma ramp */
	if (!GetDeviceGammaRamp(P_display, currentLUT)) {
		fprintf(stderr, "\nERROR: Cannot read current LUT.\n");
		strcat(log, "\nERROR: Cannot read current LUT.\n");

		/* write log file */
		error = 1;
		createlog(logFile, error, log);
		printf("1");
		return 1;
	}
	else
	{
		/* open backup file */
		bLUT_file = fopen(bakFile, "w");
		if (bLUT_file == NULL) {
			fprintf(stderr, "\nERROR opening %s for output\n", bakFile);
			sprintf(temp, "\nERROR opening %s for output\n", bakFile);
			strcat(log, temp);

			/* write log file */
			error = 1;
			createlog(logFile, error, log);
			printf("1");
			return 1;
		}

		/* write current LUT to backup file in 8-bit LUT format */
		fputs("# Current display LUT\n",bLUT_file);
		fputs("# Read using loadLUT.exe\n",bLUT_file);
		fputs("# \n",bLUT_file);
		fputs("# entry  R   G   B\n",bLUT_file);
		fputs("# \n",bLUT_file);


		for (i=0; i <= 255; ++i) {
			fprintf(bLUT_file,"%d:  %d %d %d\n",
				i+1,currentLUT[i]/256,
				currentLUT[i+256]/256,
				currentLUT[i+512]/256);
		}

		/* close backup file */
		fclose(bLUT_file);
	 }


	/* -------------------------------------
	   read new LUT and format for GammaRamp
	   ------------------------------------- */

	/* open new LUT file */
	nLUT_file = fopen(inFile, "r");
	if (nLUT_file == NULL) {
		fprintf(stderr, "\nERROR opening %s for read\n",inFile);
		sprintf(temp, "\nERROR opening %s for read\n",inFile);
		strcat(log, temp);

		/* write log file */
		error = 1;
		createlog(logFile, error, log);
		printf("1");
		return 1;
	}

	/* read and echo text header */
	sprintf(temp, "\n==> Comment lines (1-5) from %s:\n",inFile);
	strcat(log, temp);

	for (i=1; i <= 5; ++i) {
		string_ptr = fgets(string,sizeof(string),nLUT_file);
		if (string_ptr == NULL) {
			fprintf(stderr, "\nERROR reading line %d of %s\n",i,inFile);
			sprintf(temp, "\nERROR reading line %d of %s\n",i,inFile);
			strcat(log, temp);

			/* write log file */
			error = 1;
			createlog(logFile, error, log);
			printf("1");
			return 1;
		} else {
			strcat(log, string);
		}
	}

	/* convert text LUT into GammaRamp format */
	for (i=0; i <= 255; ++i) {
		string_ptr = fgets(string,sizeof(string),nLUT_file);
		if (string_ptr == NULL) {
			fprintf(stderr,	"\nERROR reading line 5 + %d of LUT file\n",i+1);
			sprintf(temp, "\nERROR reading line 5 + %d of LUT file\n",i+1);
			strcat(log, temp);

			/* write log file */
			error = 1;
			createlog(logFile, error, log);
			printf("1");
			return 1;
		} else {
			sscanf(string,"%s %d %d %d", &lut, &RED, &GRN, &BLU);
			/* NOTE: sscanf caused an artifact when the LUT was directly
			   indicated as &newLUT[i],&newLUT[i+256],&newLUT[i+512] */

			/* verify the #: format of each line */
			itoa(i+1, lutChk, 10);
			strcat(lutChk,":");
			if (strcmp(lut,lutChk) != 0) {
				fprintf(stderr,	"\nERROR in format of line 5 + %d of LUT file\n",i+1);
				sprintf(temp, "\nERROR in format of line 5 + %d of LUT file\n",i+1);
				strcat(log, temp);

				/* write log file */
				error = 1;
				createlog(logFile, error, log);
				printf("1");
				return 1;
			}

			/* convert LUT values to 16 bit unsigned int (WORD type) */
			newLUT[i]     = RED * 256;
			newLUT[i+256] = GRN * 256;
			newLUT[i+512] = BLU * 256;
		}
	}

	/* close new LUT file */
	fclose(nLUT_file);


	/* --------------------------------
	   load new LUT to the graphic card
	   -------------------------------- */

	if (!SetDeviceGammaRamp(P_display, newLUT)) {
		fprintf(stderr, "\nERROR: Cannot load new LUT\n");
		strcat(log, "\nERROR: Cannot load new LUT\n");

		/* write log file */
		error = 1;
		createlog(logFile, error, log);
		printf("1");
		return 1;
	}

	/* ------------------------
	   verify the loaded values 
	   ------------------------ */

	if (!GetDeviceGammaRamp(P_display, currentLUT)) {
		fprintf(stderr, "\nERROR: Cannot read current LUT\n");
		strcat(log, "\nERROR reading LUT file\n");

		/* write log file */
		error = 1;
		createlog(logFile, error, log);
		printf("1");
		return 1;
	}
	else
	{
		strcat(log, "\n==> Verifying loaded LUT values\n");

		verifyCnt = 0;

		for (i=0; i <= 255; ++i) {

			if (newLUT[i] != currentLUT[i]) {
				++verifyCnt;
				sprintf(temp, "%dR: %d expected, %d loaded\n", i+1, newLUT[i]/256, currentLUT[i]/256);
				strcat(log, temp);

			}
			if (newLUT[i+256] != currentLUT[i+256]) {
				++verifyCnt;
				sprintf(temp, "%dG: %d expected, %d loaded\n", i+1, newLUT[i+256]/256, currentLUT[i+256]/256);
				strcat(log, temp);
			}
			if (newLUT[i+512] != currentLUT[i+512]) {
				++verifyCnt;
				sprintf(temp, "%dB: %d expected, %d loaded\n", i+1, newLUT[i+512]/256, currentLUT[i+512]/256);
				strcat(log, temp);
			}
		}

		if (verifyCnt == 0) {
			strcat(log, "==> New LUT successfully read and loaded\n");

		} else {
			fprintf(stderr, "\n==> WARNING: LUT loaded but %d entries changed\n", verifyCnt);
			sprintf(temp, "\n==> WARNING: LUT loaded but %d entries changed\n", verifyCnt);
			strcat(log, temp);
		}

	}


	/* ---------------------
	   delete device context
	   --------------------- */

	if (DeleteDC(P_display) == 0) {
		fprintf(stderr, "\n==> WARNING: device context did not delete\n");
		strcat(log, "\n==> WARNING: device context did not delete\n");
	} else {
		strcat(log, "==> Device context deleted\n");
	}


	/* --------------------------------------------------
	                         END
	   --------------------------------------------------*/

	/* write log file */
	error = 0;
	createlog(logFile, error, log);

	strcat(log, "\n==> Process complete\n");

	printf("0");
	return 0;
}