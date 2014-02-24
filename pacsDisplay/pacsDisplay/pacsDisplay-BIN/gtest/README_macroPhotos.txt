
#------------------------------------------------------------

MACRO LCD RECORDINGS:

Recordings of LCD pixel structures should be done at maximum
luminence and two reduced brightness states of 1/4 Lmax and 1/16 Lmax.
This can be done by manually changing photographic exposure time
and aperture setting and then adjusting the gtest gray level to
obtain a centered histogram in the camera display.

For a monitor with Lmax of 350 and Lmin of 1 that has been
calibrated to the DICOM GSDF, the gray levels in relation
to fraction of maximum brightness are;
  step  DV    relLum
  17    255   1.000
  16    240    .794
  15    225    .629
  14    210    .496
  13    195    .390
  12    180    .304
  11    165    .236
  10    150    .181
   9    135    .139
   8    120    .105
   7    105    .078
   6    090    .057
   5    075    .040
   4    060    .028
   3    045    .019
   2    030    .012
   1    015    .007
   0    000    .003
For these calibrated display conditions, the max,1/4, and 1/16
brightness levels occur at gray levels of 255, 168, and 95.
For uncalibrated devices, determine the aperture and exposure
time for a gray level of 255. Then determine exposure factors
for the 1/4 and 1/16 conditions. This can be done using
the gtest controls to obtain centered histograms. The above
information for a calibrated display can be used as a guide.