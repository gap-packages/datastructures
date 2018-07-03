##
##  Datastructures: GAP package providing common datastructures.
##
##  Copyright (C) 2015-2017  The datastructures team.
##  For list of the team members, please refer to the COPYRIGHT file.
##
##  This package is licensed under the GPL 2 or later, please refer
##  to the COPYRIGHT.md and LICENSE files for details.
##

#! @Chapter Memoisation
#!
#! <Package>datastructures</Package> provides simple ways to cache return values of pure functions.
#!
#! @Section Memoisation with HashMap
#!
#! @Arguments function [, options]
#! @Returns A function
#! @Description
#!  <C>MemoizeFunction</C> returns a function which behaves the same as <A>function</A>,
#!  except that it caches the return value of <A>function</A>.
#!  The cache can be flushed by calling <Ref Func="FlushCaches" BookName="ref"/>.
#!
#!  This function does not promise to never call <A>function</A> more than
#!  once for any input -- values may be removed if the cache gets too large,
#!  or GAP chooses to flush all caches, or if multiple threads try to calculate
#!  the same value simultaneously.
#!  <P/>
#!  The optional second argument is a record which provides a number
#!  of configuration options. The following options are supported.
#!  <List>
#!  <Mark><C>flush</C> (default <K>true</K>)</Mark>
#!  <Item>
#!    If this is <K>true</K>, the cache is emptied whenever
#!    <Ref Func="FlushCaches" BookName="ref"/> is called.
#!  </Item>
#!  <Mark><C>contract</C> (defaults to <Ref Func="ReturnTrue" BookName="ref"/>)</Mark>
#!  <Item>
#!    A function that is called on the arguments given to <A>function</A>.
#!    If this function returns <K>false</K>, then <C>errorHandler</C> is
#!    called.
#!  </Item>
#!  <Mark><C>errorHandler</C> (defaults to none)</Mark>
#!  <Item>
#!    A function to be called when an input that does not fulfil
#!    <C>contract</C> is passed to the cache.
#!  </Item>
#!  </List>
#!  <P/>
DeclareGlobalFunction("MemoizeFunction");
