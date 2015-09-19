TestDirectory(
  Filename( DirectoriesPackageLibrary("datastructures", "tst"), "basictests" ),
            rec(exitGAP := true, testOptions := rec(compareFunction := "uptowhitespace") ) );

# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E
