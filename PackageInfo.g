#############################################################################
##
##  PackageInfo.g for the package `datastructures'               Markus Pfeiffer
##
##  (created from the GAP example package, which is based on Frank Lübeck's
##   PackageInfo.g template file)
##
SetPackageInfo( rec(

PackageName := "datastructures",

##  This may be used by a default banner or on a Web page, should fit on
##  one line.
Subtitle := "datastructures is a collection of standard data structures for the GAP programming language",

Version := "0.0.0",
##
Date := "31/12/2013",
##  Optional: if the package manual uses GAPDoc, you may duplicate the
##  version and the release date as shown below to read them while building
##  the manual using GAPDoc facilities to distibute documents across files.
##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "0.0.0">
##  <!ENTITY RELEASEDATE "31 December 2013">
##  <#/GAPDoc>

PackageWWWHome :=
  Concatenation( "http://www-groups.mcs.st-andrews.ac.uk/~markusp/",
      LowercaseString( ~.PackageName ), "/" ),

ArchiveURL := Concatenation( ~.PackageWWWHome, "datastructures-", ~.Version ),

ArchiveFormats := ".tar.gz",

##  If not all of the archive formats mentioned above are provided, these
##  can be produced at the GAP side. Therefore it is necessary to know which
##  files of the package distribution are text files which should be unpacked
##  with operating system specific line breaks.
##  The package wrapping tools for the GAP distribution and web pages will
##  use a sensible list of file extensions to decide if a file
##  is a text file (being conservative, it may miss a few text files).
##  These rules may be optionally prepended by the application of rules
##  from the PackageInfo.g file. For this, there are the following three
##  mutually exclusive possibilities to specify the text files:
##
##    - specify below a component 'TextFiles' which is a list of names of the
##      text files, relative to the package root directory (e.g., "lib/bla.g"),
##      then all other files are taken as binary files.
##    - specify below a component 'BinaryFiles' as list of names, then all other
##      files are taken as text files.
##    - specify below a component 'TextBinaryFilesPatterns' as a list of names
##      and/or wildcards, prepended by 'T' for text files and by 'B' for binary
##      files.
##
##  (Remark: Just providing a .tar.gz file will often result in useful
##  archives)
##
##  These entries are *optional*.
#TextFiles := ["init.g", ......],
#BinaryFiles := ["doc/manual.dvi", ......],
#TextBinaryFilesPatterns := [ "TGPLv3", "Texamples/*", "B*.in", ......],


Persons := [
  rec(
    LastName      := "Pfeiffer",
    FirstNames    := "Markus",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "markusp@mcs.st-andrews.ac.uk",
    WWWHome       := "http://www.morphism.de/~markusp",
    PostalAddress := Concatenation( [
                       "School of Computer Science\n",
                       "University of St Andrews\n",
                       "Jack Cole Building, North Haugh\n",
                       "St Andrews, Fife, KY16 9SX\n",
                       "United Kingdom" ] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),
  rec( LastName      := "Horn",
       FirstNames    := "Max",
       IsAuthor      := true,
       IsMaintainer  := true,
       Email         := "max.horn@math.uni-giessen.de",
       WWWHome       := "http://www.quendi.de/math.php",
       PostalAddress := Concatenation( "AG Algebra\n",
                                       "Mathematisches Institut\n",
                                       "Justus-Liebig-Universität Gießen\n",
                                       "Arndtstraße 2\n",
                                       "35392 Gießen\n",
                                       "Germany" ),
       Place         := "Gießen, Germany",
       Institution   := "Justus-Liebig-Universität Gießen"
     ),
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Christopher",
    LastName := "Jefferson",
    WWWHome := "http://caj.host.cs.st-andrews.ac.uk/",
    Email := "caj21@st-andrews.ac.uk",
    PostalAddress := Concatenation(
               "St Andrews\n",
               "Scotland\n",
               "UK" ),
    Place := "St Andrews",
    Institution := "University of St Andrews",
  ),
  rec(
    LastName      := "Mueller",
    FirstNames    := "Juergen",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "juergen.mueller@math.rwth-aachen.de",
    WWWHome       := "http://www.math.rwth-aachen.de/~Juergen.Mueller",
    PostalAddress := Concatenation( [
                       "Juergen Mueller\n",
                       "Lehrstuhl D fuer Mathematik, RWTH Aachen\n",
                       "Templergraben 64\n",
                       "52056 Aachen\n",
                       "Germany" ] ),
    Place         := "Aachen",
    Institution   := "RWTH Aachen"
  ),
  rec(
    LastName      := "Neunhöffer",
    FirstNames    := "Max",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "max@9hoeffer.de",
    WWWHome       := "http://www-groups.mcs.st-and.ac.uk/~neunhoef",
    PostalAddress := Concatenation( [
                       "Gustav-Freytag-Straße 40\n",
                       "50354 Hürth\n",
                       "Germany" ] ),
    #Place         := "St Andrews",
    #Institution   := "University of St Andrews"
  ),
  rec(
    LastName      := "Noeske",
    FirstNames    := "Felix",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "felix.noeske@math.rwth-aachen.de",
    WWWHome       := "http://www.math.rwth-aachen.de/~Felix.Noeske",
    PostalAddress := Concatenation( [
                       "Felix Noeske\n",
                       "Lehrstuhl D fuer Mathematik, RWTH Aachen\n",
                       "Templergraben 64\n",
                       "52056 Aachen\n",
                       "Germany" ] ),
    Place         := "Aachen",
    Institution   := "RWTH Aachen"
  )
],

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
# Status := "accepted",
Status := "dev",

README_URL :=
  Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL :=
  Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

SourceRepository := rec( 
  Type := "git", 
  URL := "https://github.com/gap-packages/datastructures"
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),

##  Here you  must provide a short abstract explaining the package content
##  in HTML format (used on the package overview Web page) and an URL
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##
# AbstractHTML := "This package provides a collection of functions for \
# computing the Smith normal form of integer matrices and some related \
# utilities.",
AbstractHTML :=
  "The <span class=\"pkgname\">datastructures</span> package provides some \
   standard data structures.",

PackageDoc := rec(
  # use same as in GAP
  BookName  := "datastructures",
  # format/extension can be one of .tar.gz, .tar.bz2, -win.zip, .zoo.
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  # the path to the .six file used by GAP's help system
  SixFile   := "doc/manual.six",
  # a longer title of the book, this together with the book name should
  # fit on a single text line (appears with the '?books' command in GAP)
  LongTitle := "datastructures - GAP Data Structures",
),


##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?
Dependencies := rec(
  GAP := "4.8.0",
  NeededOtherPackages := [["GAPDoc", "1.5"]],
  SuggestedOtherPackages := [],
  # OtherPackagesLoadedInAdvance := [],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,

TestFile := "tst/testall.g",

Keywords := ["data structures", "algorithms"]

));
