# CHANGES to the 'datastructures' GAP package

## 0.3.1 (2024-08-26)

  - Require GAP >= 4.12
  - Ensure compatibility of source code with future C compilers
  - Various janitorial changes

## 0.3.0 (2022-11-04)

  - Improve printing of HashSets and HashMaps
  - Allow giving initial values for HashMaps and HashSets
  - Make sure `rec(1:=2,3:=4)` and `rec(1:=4,2:=3)` have different hashes
  - Various janitorial changes

## 0.2.7 (2022-03-03)

  - Various janitorial changes

## 0.2.6 (2021-04-13)

  - Prepare for GAP 4.12
  - Various janitorial changes

## 0.2.5 (2019-11-11)

  - Replace the build system with a new one that doesn't use autotool
  - Fix loading workspaces which use datastructures
  - Fix some issues in the documentation
  - Adjust test suite to pass in both GAP 4.10 and 4.11

## 0.2.4 (2019-09-03)

  - Require GAP >= 4.10
  - Switch to a stable hash function for records
  - Avoid creation of recursive slice objects
  - Add ViewObj for slices
  - Fix rank of ViewString for slices, so that it is called even if e.g.
    all packages are loaded
  - Various janitorial changes

## 0.2.3 (2018-12-18)

  - Add Slices

## 0.2.2 (2018-08-20)

  - Fix crash when using datastructures in workspaces

## 0.2.1 (2018-07-04)

  - Add documentation for UnionFind

## 0.2.0 (2018-07-04)

## 0.1.3 (2018-06-19)

## 0.1.1 (2017-11-13)

  - initial public release
