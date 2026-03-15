getEDID is a command executable program,

     >getEDID N

        where
           N is a Windows display number

The standard output for getEDID is a record with a
string of pipe ("|") delineated element values
given in the following order:

Index	Output
0	Error code:
	0 = Display device found and attached to desktop
	1 = Display device found but error ocurred (see message)
	2 = Pseudo display device found
	3 = Display device not found
1	Display number
2	Manufacturer ID (hex)
3	Product ID (hex)
4	4-digit S/N
5	Extended S/N
6	Monitor Descriptor
7	Week of manufacture
8	Year of manufacture
9	Max. horizontal image size (cm)
10	Max. vertical image size (cm)
11	Max. horizontal image size (mm)
12	Max. vertical image size (mm)
13	Native horizontal resolution
14	Native vertical resolution
15	Current horizontal resolution (not from EDID)
16	Current vertical resolution (not from EDID)
17	Adapter name
18	Adapter string

A verbose log is written to getEDIDlog.txt that
has information regarding the enumeration of the
display as well as the decoded EDID results.