##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2018  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##
SetPackageInfo( rec(

PackageName := "datastructures",
Subtitle := "Collection of standard data structures for GAP",
Version := "0.3.1",
Date := "26/08/2024", # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec(
    LastName      := "Pfeiffer",
    FirstNames    := "Markus",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "markus.pfeiffer@st-andrews.ac.uk",
    WWWHome       := "http://www.morphism.de/~markusp",
    PostalAddress := Concatenation(
                       "School of Computer Science\n",
                       "University of St Andrews\n",
                       "Jack Cole Building, North Haugh\n",
                       "St Andrews, Fife, KY16 9SX\n",
                       "United Kingdom" ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),
  rec(
    LastName      := "Horn",
    FirstNames    := "Max",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "mhorn@rptu.de",
    WWWHome       := "https://www.quendi.de/math",
    PostalAddress := Concatenation(
                       "Fachbereich Mathematik\n",
                       "RPTU Kaiserslautern-Landau\n",
                       "Gottlieb-Daimler-Straße 48\n",
                       "67663 Kaiserslautern\n",
                       "Germany" ),
    Place         := "Kaiserslautern, Germany",
    Institution   := "RPTU Kaiserslautern-Landau"
  ),
  rec(
    LastName      := "Jefferson",
    FirstNames    := "Christopher",
    IsAuthor      := true,
    IsMaintainer  := true,
    WWWHome       := "http://caj.host.cs.st-andrews.ac.uk/",
    Email         := "caj21@st-andrews.ac.uk",
    PostalAddress := Concatenation(
                       "School of Computer Science\n",
                       "University of St Andrews\n",
                       "Jack Cole Building, North Haugh\n",
                       "St Andrews, Fife, KY16 9SX\n",
                       "United Kingdom" ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),
  rec(
    LastName      := "Linton",
    FirstNames    := "Steve",
    IsAuthor      := true,
    IsMaintainer  := true,
    WWWHome       := "http://sl4.host.cs.st-andrews.ac.uk/",
    Email         := "steve.linton@st-andrews.ac.uk",
    PostalAddress := Concatenation(
                       "School of Computer Science\n",
                       "University of St Andrews\n",
                       "Jack Cole Building, North Haugh\n",
                       "St Andrews, Fife, KY16 9SX\n",
                       "United Kingdom" ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),
],

Status := "deposited",

SourceRepository := rec(
  Type := "git",
  URL := "https://github.com/gap-packages/datastructures"
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://gap-packages.github.io/datastructures",
README_URL      := Concatenation( ~.PackageWWWHome, "/README.md" ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/datastructures-", ~.Version ),

ArchiveFormats := ".tar.gz",

AbstractHTML :=
  "The <span class=\"pkgname\">datastructures</span> package provides some \
   standard data structures.",

PackageDoc := [ rec(
  BookName  := "datastructures",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0_mj.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "datastructures - GAP Data Structures",
) ],


##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?
Dependencies := rec(
  GAP := ">= 4.12",
  NeededOtherPackages := [["GAPDoc", "1.5"]],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := function()
  if not IsKernelExtensionAvailable("datastructures") then
    LogPackageLoadingMessage(PACKAGE_WARNING,
                             ["the kernel module is not compiled, ",
                              "the package cannot be loaded."]);
    return fail;
  fi;
  return true;
end,

TestFile := "tst/testall.g",

Keywords := ["data structures", "algorithms"],

AutoDoc := rec(
    TitlePage := rec(
        Copyright :=
"""&copyright; 2015-18 by Chris Jefferson, Steve Linton, Markus Pfeiffer, Max Horn, Reimer Behrends and others<P/>
&datastructures; package is free software;
you can redistribute it and/or modify it under the terms of the
<URL Text="GNU General Public License">https://www.fsf.org/licenses/gpl.html</URL>
as published by the Free Software Foundation; either version 2 of the License,
or (at your option) any later version.""",
        Acknowledgements :=
"""We appreciate very much all past and future comments, suggestions and
contributions to this package and its documentation provided by &GAP;
users and developers.""",
    ),
),

));
