The datastructures GAP package
==============================

The datastructures package aims at providing standard datastructures, consolidating
existing code and improving on it, in particular in view of HPC-GAP.

The datastructures package consists of two parts: Interface declarations and implementations.

Interface Declarations
======================

The goal of interface declarations is to define standard interfaces for
datastructures and decouple them from the implementations. This enables
easy exchangability of implementations, for example for more efficient
implementations, or implementations more suited for parallelisation or
sequential use.

The datastructures package declares interfaces for the following datastructures
* queues
* doubly linked lists
* heaps
* priority queues
* hashtables
* caches
* dictionaries

Implementations
===============

Queues
------
List queues based on Reimer Behrends' implementation in HPC-GAP

AVL Trees
---------
Originally part of the orb package, written by Max Neunhöffer, Felix Noeske, and Jürgen Müller

Caches
------
Originally part of the orb package, written by Max Neunhöffer, Felix Noeske, and Jürgen Müller
