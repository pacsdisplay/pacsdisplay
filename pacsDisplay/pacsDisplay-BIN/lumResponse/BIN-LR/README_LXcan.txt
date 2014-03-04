/**************************************************************
*                                                             *
* LXcan -- program to attach the LXcan luminance meter        *
*          using the USB interface and acquire values.        *
*          This is a onsole application intended for use      *
*          with a script application (tcl/tk or other).       *
*                                                             *
* Authors:   M. Flynn                                         *
*                                                             *
* History:   Version 1.0 - 22 Sep 2008                        *
*                Initial release for pacsDisplay              *
*            Version 1.1 - 01 Oct 2008                        *
*                Option for continuous mode                   *
*                                                             *
* Usage:  'LXcan.exe'                                         *
*                                                             *
*            Required files;                                  *
*               hct99hid.dll                                  *
*                  USB Human Interface Device (HID)           *
*                  microsoft library file                     *
*               LightConNative.dll                            *
*                  LXcan library file                         *
*                  IBA Dosimetry Inc                          *
*                                                             *
*               Libraries hould be in the                     *
*               same directory as LXcan.exe                   *
*                                                             *
* Summary:                                                    *
*                                                             *
*    After excution, the application will reply with          *
*    the status of the USB channel                            *
*         0 lxCan USB port failed to open                     *
*         1 lxCan USB port opened                             *
*    If the port fails to open, 0, the application            *
*    returns and closes. If it open succesfully, 1,           *
*    the application waits for a stdin command to             *
*    obtain a luminance measure;                              *
*         GN where 0 <= N <= 9                                *
*         X  (or any char other than G)                       *
*    N indicates the number of measures to be averaged        *
*    before returning a std out result in the format of       *
*         1  12.34500                                         *
*                                                             *
*    Optionally, if a single argument is entered on the       *
*    command line as a non-zero integer, LXcan.exe [N],       *
*    the application will make N measure in as continuous     *
*    fashion with each returned to stdout as it is made.      *
*    The return format is the same as above. The calling      *
*    application should verify that the first returned value  *
*    is 1 to insure that the metered returned a proper value. *
*                                                             *
*    The LXcan can be set to intergrate measures over         *
*    100, 200, or 500 millisecond intervals.                  *
*    The time to request and get 100 measurements was         *
*    determined for each setting;                             *
*        100 ms    30 seconds for 100 measures                *
*        200 ms    56 seconds for 100 measures                *
*        500 ms   115 seconds for 100 measures                *
*    The user needs to set the intergration time using        *
*    the the menu entry functions with the meter.             *
*                                                             *
**************************************************************/
