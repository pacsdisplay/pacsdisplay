/****************************************************************
*																*
* loadLUT - program to read a display LUT and load it into the	*
*			display card to set the luminance response			*
*																*
* Authors:   M. Flynn											*
*            P. Tchou											*
*																*
* History:														*
*	Version 1.1													*
*	Version 1.2   30 Jan 2004 - initial release for multi-		*
*								monitor systems.				*
*	Version 1.3   07 Apr 2005 - added working directory			*
*								option, updated log and error	*
*								reporting, and "fstream.h"		*
*								commands were used for log		*
*								file output.					*
*				  19 May 2005 - Fixed minor error concerning	*
*								directory name syntax.			*
*				  25 Aug 2005 - Fixed minor errors with display *
*								information given.				*
*				  21 Sep 2005 - Altered information output to	*
*								include time stamp and device	*
*								info.  Removed monitor handle	*
*								call since it was not used.		*
*	Version 2.0   13 Oct 2005 - Added /serialcheck option to	*
*								read the EDID and verify the	*
*								display being calibrated.		*
*				  14 Oct 2005 - updated functions for Visual	*
*								Studio 2005.					*
*				  14 Oct 2005 - Allowed for spaces in model		*
*								names from the config file.		*
*	Version 2.1   25 Oct 2005 - Added /LUTsearch option to find	*
*								a LUT file based on model and	*
*								S/N in the EDID					*
*				  26 Oct 2005 - Added /LDTsearch option to find	*
*								a LUT file based on the date of	*
*								manufacture in the EDID.		*
*				  27 Oct 2005 - Changed /serialcheck so that it	*
*								is always active, and included	*
*								wildcard options.				*
*							  - Hardcoded the backup filename	*
*								as "bakLUT#" where "#" is the	*
*								display number.					*
*							  - Transferred "/" command line	*
*								options to within config file.	*
*				  28 Oct 2005 - Added date tolerance option.	*
*	Version 2.2	  09 Jan 2006 - Added /noEDID option to	bypass	*
*								the registry search.			*
*							  - updated the LUT/LDT searches to *
*								only use model and S/N names	*
*								from the config file if the		*
*								/noEDID option is used.			*
*                 31 May 2006 - changed the registry key access *
*								in SetupDiOpenDevRegKey from    *
*								KEY_ALL_ACCESS to KEY_READ so	*
*								that non-administrators could	*
*								also read the EDID information.	*
*				  13 Jun 2006 - Added a /noLog option to bypass	*
*								the error caused when the log	*
*								file could not be written under	*
*								user accounts that did not have	*
*								sufficient privelages.			*
*							  - Changed the error caused when	*
*								the log file cannot be written	*
*								so that only a warning message	*
*								is given and the error is non-	*
*								fatal.							*
*	Version 2.3	  28 Jul 2006 - Moved deletion of the display	*
*								device context so that all DCs	*
*								were individually deleted and	*
*								no deletion error messages are	*
*								brought up when no display		*
*								devices are found attached.		*
*                 22 Sep 2006 - Added more detailed messages in	*
*								the log output for the model	*
*								and serial number checks.		*
*                 21 Nov 2006 - Changed the /LDTsearch option   *
*                               so there is no date search if   *
*                               there is no EDID information to *
*                               supply the date of manufacture, *
*                               such as with /noEDID.           *
*	Version 2.4	  13 Dec 2006 - Changed LUTsearch so it would	*
*								check for both the 4-digit and	*
*								extended serial numbers.		*
*                             - Fixed an error with the search  *
*                               options where spaces in the     *
*                               directory names were changed to *
*                               underscores.                    *
*                 17 Dec 2006 - LUTsearch will now search for   *
*                               the LUT file in a LUT-Library   *
*                               directory with the display      *
*                               model name.  If it cannot find  *
*                               the file, then it will search   *
*                               for a generic LUT.              *
*                 28 Dec 2006 - Wildcards included in LUTsearch *
*                               for the LUT-Library directories *
*                               (...\LUT-Library\<model_name*>) *
*                             - LUTsearch will now search for   *
*                               the generic LUT directly in the *
*                               <model_name*> directory instead *
*                               of <model_name*>\LUTs.          *
*                             - fixed a minor error where the   *
*                               log file was incorrectly        *
*                               indicating that the LUTsearch   *
*                               function had failed when a      *
*                               4-digit S/N file was found but  *
*                               not an extended S/N file.       *
* Usage:														*
*	'loadLUT.exe [(working directory)]'							*
*																*
*			Command Line Options:								*
*				(working directory) - If a working directory	*
*				is specified, then all input files will be		*
*				read from that directory.  The log file will	*
*				also be written to that directory.				*
*																*
*			Config File Options:								*
*				/noload - when this option is set, loadLUT will	*
*				save the current display LUTs in backup files	*
*				without loading	new LUTs.						*
*																*
*				/noLOG - when this option is set, loadLUT will	*
*				not attempt to generate a log file.  This may	*
*				be needed if loadLUT is run under an account	*
*				that has limited access privelages.				*
*																*
*				/noEDID - this option prevents loadLUT from		*
*				searching the registry for EDID information.    *
*				This may allow loadLUT to avoid errors with		*
*				some display configurations, but also disables	*
*				loadLUT's ability to verify display information.*
*				THIS OPTION IS NOT RECOMMENDED.					*
*																*
*				/LUTsearch - when this option is set, loadLUT	*
*				gets the LUT filename from the config file, but	*
*				does not immediately use it.  It first checks	*
*				the registry for the EDID values of the monitor	*
*				and gets the model name and	serial number.  If  *
*               it cannot find them, it will instead get these  *
*               values from the config file.  It then uses them *
*               to find the appropriate LUT file from the       *
*               ...\LUT-Library\<model_name*>\LUTs directory.   *
*               The "*" denotes a wildcard.  If the folder name *
*               has characters beyond <model_name>, it will     *
*               still be accepted.                              *
*																*
*               If this search fails, loadLUT will look in the  *
*               ...\LUT-Library\<model_name*> directory for a   *
*               generic LUT file.  If that also fails, it will  *
*               use the default file.                           *
*																*
*               LUTsearch can take a directory string as an     *
*               argument, directing where it should search for  *
*               the <model_name> directories.  Long directory   *
*               names (those with spaces) should be enclosed in *
*               quotes (").  If no directory is specified, it   *
*               defaults to the standard LUT-Library directory: *
*																*
*          "C:\Program Files\HFHS\pacsDisplay\LUTs\LUT-Library" *
*																*
*				If the /noEDID option is set, then the model	*
*				name and serial number are taken from the		*
*				config file.									*
*																*
*				LUTsearch file format:							*
*				LUT_<model_name>_<S/N>_*						*
*               LUTsearch generic file formate:                 *
*				LUT_<model_name>_GENERIC*						*
*																*
*				/LDTsearch [#] - this option is similar to the	*
*				LUTsearch option, except that it uses the year	*
*				and week of manufacture, plus the model name	*
*				from the EDID to find the appropriate LUT file.	*
*				"#" indicates the date tolerance, i.e. - the	*
*				number of weeks before or after the specified	*
*				date that the search will accept.  The default	*
*				is 3 weeks.										*
*																*
*				If the /noEDID option is set, then the search   *
*               fails.		                                    *
*																*
*				file format:									*
*				LDT_<model_name>_<year(xxxx)><week(1-52)>_*		*
*																*
*				Note: If both LUTsearch and LDTsearch are set,	*
*				LUTsearch takes priority.  If LUTsearch fails,	*
*				loadLUT will still run LDTsearch.  If LDTsearch *
*				also fails, then loadLUT will use the default	*
*				LUT file.										*
*																*
*			loadLut reads parameters from 'configLL.txt'.  The	*
*			first two lines are reserved for comments.  The		*
*			third line lists the number of displays.  The		*
*			following lines list the enumeration, model name,	*
*			serial number LUT filename for each display.		*
*																*
*			For example:										*
*																*
*				# First two lines reserved for comments.		*
*				#												*
*				/LUTsearch		- Options...					*
*				/LDTsearch		- Options...					*
*				2				- Number of displays			*
*				1				- Display number				*
*				"DLL MMMM1"		- Model descriptor (or "*")		*
*				"SNSNSNSN1"		- S/N (or "*")					*
*				"calLUT1.txt"	- Default calibration filename	*
*				2												*
*				"DLL MMMM2"										*
*				"SNSNSNSN2"										*
*				"calLUT2.txt"									*
*																*
*				LUT files must be in the format produced by		*
*				the HFHS LUTgenerate application.				*
*																*
* Output:	loadLUT produces a single log file and backup LUT	*
*			files for each display.  The log file has the		*
*			following format:									*
*																*
*				# [comment line]								*
*				[date] [time]									*
*				[fatal error flag]								*
*																*
*				[argc (number of arguments)]					*
*				[argv (argument values)]						*
*																*
*				[working directory]								*
*				[config file]									*
*				[log file]										*
*																*
*				[program event summary]							*
*																*
*			Backup LUT files are named "bakLUT#.txt" where "#"	*
*			is the display number.								*
*																*
* Summary:														*
*	The Microsoft Windows Graphic Device Interface (GDI)		*
*	library has routines communicating with display controller	*
*	cards using ICM type procedures.  Modern cards will support	*
*	these controls.  This program used GDI procedures to load	*
*	look-up tables (LUTs) into the graphic card. LUTs are read	*
*	from a text	file as 8-bit numbers ranging from 0 to 255 for	*
*	each of three channels (R,G, and B). 8 bit color values are	*
*   converted from the display value sent to the card (0-255)	*
*   to the value loaded in the card from the LUT.				*
*																*
*   Windows defines the LUT as 16 bit integers (WORD type).  In	*
*	this program 8 bit LUT values are converted to 16 bits		*
*	using a multiplication by 256. Some advanced devices may	*
*	support graphic objects of more that 8 bits per channel.	*
*	This is not supported in this program.						*
*																*
*	Testing indicates that some LUT entries can cause the		*
*	SetDeviceGammaRamp procedure to fail. These seem to be		*
*	extreme values like 0 0 255 that were inserted for test		*
*	purposes. The reason is not known. The procedure may test	*
*   for irrational conditions. Relatively discontinuouse LUT	*
*	changes as in testLUT.txt do load.							*
*																*
*	A loaded LUT will be applied globally to all applications	*
*	and will remain in place until the computer is rebooted.	*
*	The LUT will remain loaded for all users as they may log on	*
*	and off to the system. A LUT may be sheduled to load at		*
*	each startup using the task scheduler or Startup folder.	*
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
		fprintf_s(stderr, "\nWARNING: Unable to create log file: \n %s\nIn order to avoid this message in the future, set the /noLOG option in the config file.", logFile);
		sprintf_s(title, sizeof(title), "%s - UNABLE TO CREATE LOG FILE", version);
		sprintf_s(temp, sizeof(temp), "WARNING: Unable to create log file: \n %s\nIn order to avoid this message in the future, set the /noLOG option in the config file.", logFile);
		MessageBox(NULL, temp, title, MB_OK);
	} else {

		/* write log file */
		output << "# log file for " << version << endl;
		SYSTEMTIME date;
		GetLocalTime(&date);
		output << date.wMonth << "/" << date.wDay << "/" << date.wYear << " " << date.wHour << ":" << date.wMinute << endl;
		output << "Errors = " << error << endl;
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
	char	version[50] = "loadLUT v2.4";
	
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
	char	newLUTDir[500] = "";
	char	newLUTFileName[500] = "";
	char	test_newLUTDir[500] = "";
	char	test_newLUTFileName[500] = "";
	char	test_newLUTFileName_B[500] = "";
	char	test_genericLUTFileName[500] = "";
	char	genericLUText[20] = "GENERIC";
	char	bakLUTFileName[500] = "";
	char	logFile[200] = "log.txt";			// default log file
	char	directory[500] = "";		// working directory
	char	LUT_Library_dir[500] = "";	// LUT-Library working directory
	char	LUT_Library_default[100] = "C:\\Program Files\\HFHS\\pacsDisplay\\LUTs\\LUT-Library\\";	// default LUT-Library directory
	char	slash_str[2] = "\\";

	/* temporary variables */
	int		i;
	int		j;
	int		k;
	int		test = 0;
	char	c;
	char	string[500] = "";
	char	string_B[500] = "";
	char	*string_ptr;
	char	*char_ptr;
	char	temp[10000] = "";
	char	temp2[10000] = "";

	/* flag and counter variables */
	int		option = 0;			// option flag
	int		numOptions = 0;		// number of options
	int		noload = 0;			// option to not load any LUTs
	int		noLOG = 0;			// option to not create the log file
	int		noEDID = 0;			// option to bypass the EDID check
	int		LUTsearch = 0;		// option to find the LUT file based on model and S/N
	int		LDTsearch = 0;		// option to find the LUT file based on model and date of manufacture
	int		error = 0;			// error flag
	int		EDID;				// successful EDID read flag
	int		registry = 0;		// successful registry read flag (required for EDID information)
	int		searchfiledirname = 0;	// successful build of directory name for LUT search flag
	int		searchfiledir = 0;	// successful LUT directory search flag
	int		searchfilename = 0;	// successful build of file name for LUT search flag
	int		search = 0;			// successful LUT search flag
	int		date = 0;			// successful date search flag
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

/*	char deviceInstanceID[200];
/**/

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
				} else {
					if (!strcmp(temp2, "/LUTsearch")) {
						LUTsearch = 1;

						/* get LUT-Library directory */
						sprintf_s(temp2, sizeof(temp2), "");
						char_ptr = strchr( string, '\"');	// check for long directory name
						if (char_ptr != NULL) {		// look for the closing quotes
							for (i=(int)(char_ptr - string + 1); i < sizeof(string); i++) {
								c = string[i];
								if (c == '\"') {
									break;
								} else {
									sprintf_s(temp, sizeof(temp), "%c", c);
									strcat_s(temp2, sizeof(temp2), temp);
								}
							}
						} else {			// no spaces
							sscanf_s(string, "/LUTsearch %s", &temp2, sizeof(temp2));
						}

						if (strcmp(temp2, "")) {	// check if LUT-Library directory was given
							strcat_s(LUT_Library_dir, sizeof(LUT_Library_dir), temp2);

							/* check slashes in directory name */
							i = strlen(LUT_Library_dir);
							for (j=0; j < i; ++j) {
								if (LUT_Library_dir[j] == '/') {
									LUT_Library_dir[j] = '\\';
								}
							}
							--i;
							if (LUT_Library_dir[i] != '\\') {			// check for slash at end of directory
								strcat_s(LUT_Library_dir, sizeof(LUT_Library_dir), slash_str);
							}
						} else {	// use default LUT-Library directory
							strcat_s(LUT_Library_dir, sizeof(LUT_Library_dir), LUT_Library_default);
						}

						sprintf_s(temp2, sizeof(temp2), "/LUTsearch %s", LUT_Library_dir);
					} else {
						if (!strcmp(temp2, "/LDTsearch")) {
							LDTsearch = 1;
							sscanf_s(string, "/LDTsearch %d", &dateTolerance);	// get date tolerance (in weeks)
							sprintf_s(temp2, sizeof(temp2), "/LDTsearch %d", dateTolerance);
						} else {
							if (!strcmp(temp2, "/noEDID")) {
								noEDID = 1;
							} else {
								if (!strcmp(temp2, "/noLOG")) {
									noLOG = 1;
								} else {
									fprintf_s(stderr, "\nERROR: invalid option (%s)\n", temp2);
									sprintf_s(temp, sizeof(temp), "\nERROR: invalid option (%s)\n", temp2);
									strcat_s(log, sizeof(log), temp);

									/* write log file */
									error = 1;
									if (!noLOG) {
										createlog(logFile, version, error, log);
									}
									exit (EXIT_FAILURE);
								}
							}
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
					if (!noLOG) {
						createlog(logFile, version, error, log);
					}
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
		/* initialize variables */
		registry = 0;				//initialize registry search flag
		EDID = 0;					//initialize EDID read flag


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
			if (!noLOG) {
				createlog(logFile, version, error, log);
			}
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
			if (!noLOG) {
				createlog(logFile, version, error, log);
			}
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
			if (!noLOG) {
				createlog(logFile, version, error, log);
			}
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
			if (!noLOG) {
				createlog(logFile, version, error, log);
			}
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

			/* get the device context and info */
			if (dd.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) {
				// display is enabled, only enabled displays have a monitor handle

				/* display device context */
				P_display = CreateDC(TEXT("DISPLAY"), dd.DeviceName, NULL, NULL);
				
				/* monitor handle 
				POINT pt = { dm.dmPosition.x, dm.dmPosition.y };
				hm = MonitorFromPoint(pt, MONITOR_DEFAULTTONULL);
				*/

				/* monitor info 
				mi_ex.cbSize = sizeof(mi_ex);
				GetMonitorInfo(hm, &mi_ex);
				*/

				if (noEDID) {
					fprintf_s(stdout, "\n ==> Bypassing EDID - using default LUT\n");
					strcat_s(log, sizeof(log), "\n ==> Bypassing EDID - using default LUT\n");

				} else {
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
						fprintf_s(stdout, "\nERROR: Cannot find active display device EDID.\n (EnumDisplayDevices: StateFlags & DISPLAY_DEVICE_ACTIVE)\n");
						strcat_s(log, sizeof(log), "\nERROR: Cannot find active display device EDID.\n (EnumDisplayDevices: StateFlags & DISPLAY_DEVICE_ACTIVE)\n");

						/* write log file */
						error = 1;
						if (!noLOG) {
							createlog(logFile, version, error, log);
						}
						exit(EXIT_FAILURE);
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

				/* --------------------------------------------
				BEGIN SERIAL CHECK, LUTSEARCH, AND LDTsearch
				-------------------------------------------- */

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
									if (!noLOG) {
										createlog(logFile, version, error, log);
									}
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
									if (!noLOG) {
										createlog(logFile, version, error, log);
									}
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
									fprintf_s(stdout, "\nERROR: Cannot find device driver key. (SetupDiGetDeviceRegistryProperty)\n");
									strcat_s(log, sizeof(log), "\nERROR: Cannot find device driver key. (SetupDiGetDeviceRegistryProperty)\n");

									/* write log file */
									error = 1;
									if (!noLOG) {
										createlog(logFile, version, error, log);
									}
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
								if (!noLOG) {
									createlog(logFile, version, error, log);
								}
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
						}
					}

					if (EDID) {
						/* check model name */
						fprintf_s(stdout, "\n Model name check: \n  Expected = %s \n  Found    = %s \n",configModelName, regName);
						sprintf_s(temp, sizeof(temp), "\n Model name check: \n  Expected = %s \n  Found    = %s \n",configModelName, regName);
						strcat_s(log, sizeof(log), temp);

						if (strcmp(configModelName, "*") && strcmp(configModelName, regName)) {
							error = 1;
							fprintf_s(stdout, "\n**MODEL NAME CHECK FAILED - LUT NOT LOADED**\n");
							strcat_s(log, sizeof(log), "\n**MODEL NAME CHECK FAILED - LUT NOT LOADED**\n");

							continue;					//continue to next display
						}

						/* check serial number */
						fprintf_s(stdout, "\n S/N check: \n  Expected = %s \n  Found 1  = %s \n  Found 2  = %s \n",configSerialName, regSerialA, regSerialB);
						sprintf_s(temp, sizeof(temp), "\n S/N check: \n  Expected = %s \n  Found 1  = %s \n  Found 2  = %s \n",configSerialName, regSerialA, regSerialB);
						strcat_s(log, sizeof(log), temp);

						if (strcmp(configSerialName, "*") && strcmp(configSerialName, regSerialA) && strcmp(configSerialName, regSerialB)) {
							error = 1;
							fprintf_s(stdout, "\n**SERIAL NUMBER CHECK FAILED - LUT NOT LOADED**\n");
							strcat_s(log, sizeof(log), "\n**SERIAL NUMBER CHECK FAILED - LUT NOT LOADED**\n");

							continue;					//continue to next display
						}

						fprintf_s(stdout, "\n ==> Model and S/N check passed\n");
						strcat_s(log, sizeof(log), "\n ==> Model and S/N check passed\n");
					} else {
						fprintf_s(stdout, "\n ==> No EDID information - Model and S/N not verified\n");
						strcat_s(log, sizeof(log), "\n ==> No EDID information - Model and S/N not verified\n");
					}
				}

				/* LUTsearch and/or LDTsearch */
				if (LUTsearch || LDTsearch) {

					/* LUTsearch */
					if (LUTsearch) {
						searchfiledirname = 0;				//initialize search file directory name flag
						searchfiledir = 0;					//initialize search file directory flag
						searchfilename = 0;					//initialize search file name flag
						search = 0;							//initialize LUT search flag

						fprintf_s(stdout, "\n LUT search:\n");
						sprintf_s(temp, sizeof(temp), "\n LUT search:\n");
						strcat_s(log, sizeof(log), temp);

						/* build target LUT directory name */
						strcpy_s(test_newLUTDir, sizeof(test_newLUTDir), LUT_Library_dir);
						if (EDID) {
							strcpy_s(string, sizeof(string), regName);	// use EDID model name
							char_ptr = strchr(string, ' ');		//replace spaces with underscores
							while (char_ptr) {
								*char_ptr = '_';
								char_ptr = strchr(string, ' ');
							}
							strcat_s(test_newLUTDir, sizeof(test_newLUTDir), string);	//leave closing slash off for directory search
							strcat_s(test_newLUTDir, sizeof(test_newLUTDir), "*");		//include wildcard character

							searchfiledirname = 1;
						} else {
							fprintf_s(stdout, "  ==> No EDID model name or serial number - using values from %s\n\n", configFileName);
							sprintf_s(temp, sizeof(temp), "  ==> No EDID model name or serial number - using values from %s\n\n", configFileName);
							strcat_s(log, sizeof(log), temp);

							if (strcmp(configModelName, "*")) {
								strcpy_s(string, sizeof(string), configModelName);	// use config model name
								char_ptr = strchr(string, ' ');		//replace spaces with underscores
								while (char_ptr) {
									*char_ptr = '_';
									char_ptr = strchr(string, ' ');
								}
								strcat_s(test_newLUTDir, sizeof(test_newLUTDir), string);	//leave closing slash off for directory search
								strcat_s(test_newLUTDir, sizeof(test_newLUTDir), "*");		//include wildcard character

								searchfiledirname = 1;
							} else {
								fprintf_s(stdout, "\n  ==> Model name not provided - cannot create LUTsearch directory name\n\n");
								sprintf_s(temp, sizeof(temp), "\n  ==> Model name not provided - cannot create LUTsearch directory name\n\n");
								strcat_s(log, sizeof(log), temp);
							}
						}

						/* search for target LUT directory */
						if (searchfiledirname) {
							fprintf_s(stdout, "  Target LUT directory = %s\n", test_newLUTDir);
							sprintf_s(temp, sizeof(temp), "  Target LUT directory = %s\n", test_newLUTDir);
							strcat_s(log, sizeof(log), temp);

							if ((hFile = _findfirst(test_newLUTDir, &findFile)) != -1L) {
								strcpy_s(newLUTDir, sizeof(newLUTDir), LUT_Library_dir);
								strcat_s(newLUTDir, sizeof(newLUTDir), findFile.name);
								_findclose( hFile );

								searchfiledir = 1;

								fprintf_s(stdout, "  Found LUT directory = %s\n", newLUTDir);
								sprintf_s(temp, sizeof(temp), "  Found LUT directory = %s\n", newLUTDir);
								strcat_s(log, sizeof(log), temp);
							} else {
								fprintf_s(stdout, "  Directory not found\n");
								sprintf_s(temp, sizeof(temp), "  Directory not found\n");
								strcat_s(log, sizeof(log), temp);
							}
						}

						if (searchfiledir) {
							/* build target LUT filename */
							strcpy_s(test_newLUTFileName, sizeof(test_newLUTFileName), newLUTDir);
							strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "\\LUTs\\LUT_");

							if (EDID) {
								/* 4-digit S/N */
								strcpy_s(string, sizeof(string), regName);
								strcat_s(string, sizeof(string), "_");
								strcat_s(string, sizeof(string), regSerialA);
								strcat_s(string, sizeof(string), "_");

								/* extended S/N */
								strcpy_s(test_newLUTFileName_B, sizeof(test_newLUTFileName_B), test_newLUTFileName);
								strcpy_s(string_B, sizeof(string_B), regName);
								strcat_s(string_B, sizeof(string_B), "_");
								strcat_s(string_B, sizeof(string_B), regSerialB);
								strcat_s(string_B, sizeof(string_B), "_");

								searchfilename = 1;
							} else {
//								fprintf_s(stdout, "\n  ==> No EDID serial number - using values from %s\n", configFileName);
//								sprintf_s(temp, sizeof(temp), "\n  ==> No EDID serial number - using values from %s\n", configFileName);
//								strcat_s(log, sizeof(log), temp);

								strcpy_s(string, sizeof(string), "");
								if (strcmp(configSerialName, "*")) {
									strcat_s(string, sizeof(string), configModelName);
									strcat_s(string, sizeof(string), "_");
									strcat_s(string, sizeof(string), configSerialName);
									strcat_s(string, sizeof(string), "_");

									searchfilename = 1;
								} else {
									fprintf_s(stdout, "  ==> Serial number not provided - cannot create LUTsearch filename\n");
									sprintf_s(temp, sizeof(temp), "  ==> Serial number not provided - cannot create LUTsearch filename\n");
									strcat_s(log, sizeof(log), temp);					
								}
							}

							if (searchfilename) {					//finish LUTsearch filename
								char_ptr = strchr(string, ' ');		//replace spaces with underscores
								while (char_ptr) {
									*char_ptr = '_';
									char_ptr = strchr(string, ' ');
								}

								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), string);
								strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "*");

								fprintf_s(stdout, "  Target LUT file name = %s\n", test_newLUTFileName);
								sprintf_s(temp, sizeof(temp), "  Target LUT file name = %s\n", test_newLUTFileName);
								strcat_s(log, sizeof(log), temp);

								/* search for matching LUT file */
								if ((hFile = _findfirst(test_newLUTFileName, &findFile)) != -1L) {
									strcpy_s(newLUTFileName, sizeof(newLUTFileName), newLUTDir);
									strcat_s(newLUTFileName, sizeof(newLUTFileName), "\\LUTs\\");
									strcat_s(newLUTFileName, sizeof(newLUTFileName), findFile.name);
									_findclose( hFile );

									search = 1;

									fprintf_s(stdout, "  Found LUT file = %s\n", newLUTFileName);
									sprintf_s(temp, sizeof(temp), "  Found LUT file = %s\n", newLUTFileName);
									strcat_s(log, sizeof(log), temp);
								} else {
									fprintf_s(stdout, "  File not found\n", newLUTFileName);
									sprintf_s(temp, sizeof(temp), "  File not found\n", newLUTFileName);
									strcat_s(log, sizeof(log), temp);
								}

								if (EDID) {		// check extended serial number LUT filename
									char_ptr = strchr(string_B, ' ');		//replace spaces with underscores
									while (char_ptr) {
										*char_ptr = '_';
										char_ptr = strchr(string_B, ' ');
									}

									strcat_s(test_newLUTFileName_B, sizeof(test_newLUTFileName_B), string_B);
									strcat_s(test_newLUTFileName_B, sizeof(test_newLUTFileName_B), "*");

									fprintf_s(stdout, "  Target LUT file name (ext S/N) = %s\n", test_newLUTFileName_B);
									sprintf_s(temp, sizeof(temp), "  Target LUT file name (ext S/N) = %s\n", test_newLUTFileName_B);
									strcat_s(log, sizeof(log), temp);

									/* search for matching LUT file */
									if ((hFile = _findfirst(test_newLUTFileName_B, &findFile)) != -1L) {
										strcpy_s(newLUTFileName, sizeof(newLUTFileName), newLUTDir);
										strcat_s(newLUTFileName, sizeof(newLUTFileName), "\\LUTs\\");
										strcat_s(newLUTFileName, sizeof(newLUTFileName), findFile.name);
										_findclose( hFile );

										search = 1;

										fprintf_s(stdout, "  Found LUT file = %s\n", newLUTFileName);
										sprintf_s(temp, sizeof(temp), "  Found LUT file = %s\n", newLUTFileName);
										strcat_s(log, sizeof(log), temp);
									} else {
										fprintf_s(stdout, "  File not found\n");
										sprintf_s(temp, sizeof(temp), "  File not found\n");
										strcat_s(log, sizeof(log), temp);
									}
								}
							}

							/* search for generic LUT file */
							if (search == 0) {
								/* build generic LUT file name */
								strcpy_s(test_genericLUTFileName, sizeof(test_genericLUTFileName), newLUTDir);
								strcat_s(test_genericLUTFileName, sizeof(test_genericLUTFileName), "\\LUT_");
								if (EDID) {
									strcpy_s(string, sizeof(string), regName);
									char_ptr = strchr(string, ' ');		//replace spaces with underscores
									while (char_ptr) {
										*char_ptr = '_';
										char_ptr = strchr(string, ' ');
									}
									strcat_s(string, sizeof(string), "_");
								} else {
									strcpy_s(string, sizeof(string), configModelName);
									char_ptr = strchr(string, ' ');		//replace spaces with underscores
									while (char_ptr) {
										*char_ptr = '_';
										char_ptr = strchr(string, ' ');
									}
									strcat_s(string, sizeof(string), "_");
								}
								strcat_s(test_genericLUTFileName, sizeof(test_genericLUTFileName), string);
								strcat_s(test_genericLUTFileName, sizeof(test_genericLUTFileName), genericLUText);
								strcat_s(test_genericLUTFileName, sizeof(test_genericLUTFileName), "*");

								fprintf_s(stdout, "  Target GENERIC LUT file name = %s\n", test_genericLUTFileName);
								sprintf_s(temp, sizeof(temp), "  Target GENERIC LUT file name = %s\n", test_genericLUTFileName);
								strcat_s(log, sizeof(log), temp);

								/* search for matching generic LUT file */
								if ((hFile = _findfirst(test_genericLUTFileName, &findFile)) != -1L) {
									strcpy_s(newLUTFileName, sizeof(newLUTFileName), newLUTDir);
									strcat_s(newLUTFileName, sizeof(newLUTFileName), "\\");
									strcat_s(newLUTFileName, sizeof(newLUTFileName), findFile.name);
									_findclose( hFile );

									search = 1;

									fprintf_s(stdout, "  Found LUT file = %s\n", newLUTFileName);
									sprintf_s(temp, sizeof(temp), "  Found LUT file = %s\n", newLUTFileName);
									strcat_s(log, sizeof(log), temp);
								} else {
									search = 0;

									fprintf_s(stdout, "  Generic file not found\n");
									sprintf_s(temp, sizeof(temp), "  Generic file not found\n");
									strcat_s(log, sizeof(log), temp);
								}
							}

							if (search) {				//report LUTsearch results
								fprintf_s(stdout, "\n ==> LUT search successful\n");
								strcat_s(log, sizeof(log), "\n ==> LUT search successful\n");
							} else {
								fprintf_s(stdout, "\n ==> LUT search failed\n");
								strcat_s(log, sizeof(log), "\n ==> LUT search failed\n");
							}
						}
					}

					/* LDTsearch */
					if (LDTsearch && !search) {
						searchfilename = 0;					//initialize search file name flag
						date = 0;							//initialize date search flag

						fprintf_s(stdout, "\n LDT search:\n");
						sprintf_s(temp, sizeof(temp), "\n LDT search:\n");
						strcat_s(log, sizeof(log), temp);

						/* build target LDT filename */
						strcpy_s(test_newLUTFileName, sizeof(test_newLUTFileName), directory);
						strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), "LDT\\LDT_");

						if (EDID) {
							strcpy_s(string, sizeof(string), regName);
							strcat_s(string, sizeof(string), "_");
							searchfilename = 1;
						} else {
							fprintf_s(stdout, "  ==> No EDID information available - cannot create LDTsearch filename\n", configFileName);
							sprintf_s(temp, sizeof(temp), "  ==> No EDID information available - cannot create LDTsearch filename\n", configFileName);
							strcat_s(log, sizeof(log), temp);

//							fprintf_s(stdout, "  No EDID model name - using value from %s\n", configFileName);
//							sprintf_s(temp, sizeof(temp), "  No EDID model name - using value from %s\n", configFileName);
//							strcat_s(log, sizeof(log), temp);
//
//							strcpy_s(string, sizeof(string), "");
//							if (strcmp(configModelName, "*")) {
//								strcat_s(string, sizeof(string), configModelName);
//								strcat_s(string, sizeof(string), "_");
//								searchfilename = 1;
//							} else {
//								fprintf_s(stdout, "  Model name not provided - cannot create LDTsearch filename\n");
//								sprintf_s(temp, sizeof(temp), "  Model name not provided - cannot create LDTsearch filename\n");
//								strcat_s(log, sizeof(log), temp);					
//							}
						}

						if (searchfilename) {
							strcat_s(test_newLUTFileName, sizeof(test_newLUTFileName), string);
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

								char_ptr = strchr(temp, ' ');		//replace spaces with underscores
								while (char_ptr) {
									*char_ptr = '_';
									char_ptr = strchr(temp, ' ');
								}

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
										strcpy_s(newLUTFileName, sizeof(newLUTFileName), directory);
										strcat_s(newLUTFileName, sizeof(newLUTFileName), findFile.name);
										_findclose( hFile );

										date = 1;

										fprintf_s(stdout, "  Found LDT file = %s\n", newLUTFileName);
										sprintf_s(temp, sizeof(temp), "  Found LDT file = %s\n", newLUTFileName);
										strcat_s(log, sizeof(log), temp);

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
						}

						if (date) {
							fprintf_s(stdout, "\n ==> LDT search successful\n");
							strcat_s(log, sizeof(log), "\n ==> LDT search successful\n");
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
			
			/* END SERIAL CHECK, LUTSEARCH, AND LDTsearch */
						
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


		/* -------------------------
		   backup current gamma ramp 
		   ------------------------- */

		/* get gamma ramp */
		if (!GetDeviceGammaRamp(P_display, currentLUT)) {
			fprintf_s(stdout, "\nERROR: Cannot read current LUT.\n");
			strcat_s(log, sizeof(log), "\nERROR: Cannot read current LUT.\n");

			/* write log file */
			error = 1;
			if (!noLOG) {
				createlog(logFile, version, error, log);
			}
			exit(EXIT_FAILURE);
		} else {
			/* open backup file */
			if (fopen_s(&bakLUT_file, bakLUTFileName, "w")) {
				fprintf_s(stderr, "\nERROR opening %s (backup file) for output\n", bakLUTFileName);
				sprintf_s(temp, sizeof(temp), "\nERROR opening %s (backup file) for output\n", bakLUTFileName);
				strcat_s(log, sizeof(log), temp);

				/* write log file */
				error = 1;
				if (!noLOG) {
					createlog(logFile, version, error, log);
				}
				exit (EXIT_FAILURE);
			}

			/* write current LUT to backup file in 8-bit LUT format */
			fputs("# Current display LUT\n",bakLUT_file);
			fputs("# Read using loadLUT.exe\n",bakLUT_file);
			fputs("# \n",bakLUT_file);
			fputs("# entry  R   G   B\n",bakLUT_file);
			fputs("# \n",bakLUT_file);


			for (i=0; i <= 255; ++i) {
				fprintf_s(bakLUT_file,"%d:  %d %d %d\n",
					i+1,currentLUT[i]/256,
					currentLUT[i+256]/256,
					currentLUT[i+512]/256);
			}

			/* close backup file */
			fclose(bakLUT_file);

			fprintf_s(stdout, "\n ==> Current LUT values saved\n");
			strcat_s(log, sizeof(log), "\n ==> Current LUT values saved\n");
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
				if (!noLOG) {
					createlog(logFile, version, error, log);
				}
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
					if (!noLOG) {
						createlog(logFile, version, error, log);
					}
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
					if (!noLOG) {
						createlog(logFile, version, error, log);
					}
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
						if (!noLOG) {
							createlog(logFile, version, error, log);
						}
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


			/* --------------------------------
			   load new LUT to the graphic card
			   -------------------------------- */

			if (!SetDeviceGammaRamp(P_display, newLUT)) {
				fprintf_s(stderr, "\nERROR: Cannot load new LUT\n");
				strcat_s(log, sizeof(log), "\nERROR: Cannot load new LUT\n");

				/* write log file */
				error = 1;
				if (!noLOG) {
					createlog(logFile, version, error, log);
				}
				exit(EXIT_FAILURE);
			}

			/* ------------------------
			   verify the loaded values 
			   ------------------------ */

			if (!GetDeviceGammaRamp(P_display, currentLUT)) {
				fprintf_s(stderr, "\nERROR: Cannot read current LUT\n");
				strcat_s(log, sizeof(log), "\nERROR reading LUT file\n");

				/* write log file */
				error = 1;
				if (!noLOG) {
					createlog(logFile, version, error, log);
				}
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

	}		// end of loop through displays


	/* --------------------------------------------------
	                         END
	   --------------------------------------------------*/

	fprintf_s(stdout, "\n==> Process complete\n");
	strcat_s(log, sizeof(log), "\n==> Process complete\n");

	/* write log file */
	if (!noLOG) {
		createlog(logFile, version, error, log);
	}

	/* clean up */
	fclose(config_file);


	return 0;
}