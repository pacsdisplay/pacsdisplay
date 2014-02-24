Notepad.exe was previously included in LIB
and executed there.

On W7 64bit, it won't exec from LIB.
However, just using,
  exec notepad filename
seems to use the windows distribution version
and works fine.

This has been used in lumResponse, but the
notepad.exe is being left in LIB in case
other programs may be using it.

MJF Nov 2013

--------------------------------------------

May want to add a tcl text file viewer
that would be linux/mac compatable.

There is a procedure in lumResponse.tcl for 
putting up the INSTRUCTIONS.txt text file that
looks like it would work well.