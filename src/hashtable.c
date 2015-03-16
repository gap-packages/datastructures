/***************************************************************************
**
*A  hashtable.c               GAPData-package               Max Neunhoeffer
**
**  Copyright (C) 2009  Max Neunhoeffer
**  This file is free software, see license information at the end.
**
**  Exported to the GAPData package by Markus Pfeiffer 2014 
*/

#include <stdlib.h>
#include <stdint.h>

#include "src/compiled.h"          /* GAP headers                */
#include "avltree.h"

#undef PACKAGE
#undef PACKAGE_BUGREPORT
#undef PACKAGE_NAME
#undef PACKAGE_STRING
#undef PACKAGE_TARNAME
#undef PACKAGE_URL
#undef PACKAGE_VERSION

#include "pkgconfig.h"             /* our own configure results */

/* Note that SIZEOF_VOID_P comes from GAP's config.h whereas
 * SIZEOF_VOID_PP comes from pkgconfig.h! */
#if SIZEOF_VOID_PP != SIZEOF_VOID_P
#error GAPs word size is different from ours, 64bit/32bit mismatch
#endif

#include <avltree.h>

Obj HTGrow;         /* Operation function imported from the library */

static Int RNam_accesses = 0;
static Int RNam_collisions = 0;
static Int RNam_hfd = 0;
static Int RNam_hf = 0;
static Int RNam_els = 0;
static Int RNam_vals = 0;
static Int RNam_nr = 0;
static Int RNam_cmpfunc = 0;
static Int RNam_allocsize = 0;
static Int RNam_cangrow = 0;
static Int RNam_len = 0;

static inline void initRNams(void)
{
    /* Find RNams if not already done: */
    if (!RNam_accesses) {
        RNam_accesses = RNamName("accesses");
        RNam_collisions = RNamName("collisions");
        RNam_hfd = RNamName("hfd");
        RNam_hf = RNamName("hf");
        RNam_els = RNamName("els");
        RNam_vals = RNamName("vals");
        RNam_nr = RNamName("nr");
        RNam_cmpfunc = RNamName("cmpfunc");
        RNam_allocsize = RNamName("allocsize");
        RNam_cangrow = RNamName("cangrow");
        RNam_len = RNamName("len");
    }
}

Obj HTAdd_TreeHash_C(Obj self, Obj ht, Obj x, Obj v)
{
    Obj els;
    Obj vals;
    Obj tmp;
    Obj hfd;
    Int h;
    Obj t;
    Obj r;

    /* Find RNams if not already done: */
    initRNams();

    /* Increment accesses entry: */
    tmp = ElmPRec(ht,RNam_accesses);
    tmp = INTOBJ_INT(INT_INTOBJ(tmp)+1);
    AssPRec(ht,RNam_accesses,tmp);

    if (ElmPRec(ht,RNam_cangrow) == True &&
        INT_INTOBJ(ElmPRec(ht,RNam_nr))/10 > INT_INTOBJ(ElmPRec(ht,RNam_len)))
    {
        CALL_2ARGS(HTGrow,ht,x);
    }

    /* Compute hash value: */
    hfd = ElmPRec(ht,RNam_hfd);
    tmp = ElmPRec(ht,RNam_hf);
    h = INT_INTOBJ(CALL_2ARGS(tmp,x,hfd));

    /* Lookup slot: */
    els = ElmPRec(ht,RNam_els);
    vals = ElmPRec(ht,RNam_vals);
    tmp = ELM_PLIST(els,h);    /* Note that hash values are always within
                                  the boundaries of this list */
    if (tmp == 0L) { /* Unbound entry! */
        SET_ELM_PLIST(els,h,x);
        CHANGED_BAG(els);
        if (v != True) ASS_LIST(vals,h,v);
        AssPRec(ht,RNam_nr,INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_nr))+1));
        return INTOBJ_INT(h);
    }

    /* Count collision: */
    AssPRec(ht,RNam_collisions,
            INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_collisions))+1));
    
    /* Now check whether it is an AVLTree or not: */
    if (TNUM_OBJ(tmp) != T_POSOBJ || 
        (TYPE_POSOBJ(tmp) != AVLTreeTypeMutable &&
         TYPE_POSOBJ(tmp) != AVLTreeType)) {
        r = NEW_PREC(2);   /* This might trigger a garbage collection */
        AssPRec(r,RNam_cmpfunc,ElmPRec(ht,RNam_cmpfunc));
        AssPRec(r,RNam_allocsize,INTOBJ_INT(3));
        t = CALL_1ARGS(AVLTree,r);
        if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L) {
            AVLAdd_C(self,t,tmp,ELM_PLIST(vals,h));
            UNB_LIST(vals,h);
        } else {
            AVLAdd_C(self,t,tmp,True);
        }
        SET_ELM_PLIST(els,h,t);
        CHANGED_BAG(els);
    } else t = tmp;

    /* Finally add value into tree: */
    if (v != True) {
        r = AVLAdd_C(self,t,x,v);
    } else {
        r = AVLAdd_C(self,t,x,True);
    }

    if (r != Fail) {
        AssPRec(ht,RNam_nr,INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_nr))+1));
        return INTOBJ_INT(h);
    } else
        return Fail;
}

Obj HTValue_TreeHash_C(Obj self, Obj ht, Obj x)
{
    Obj els;
    Obj vals;
    Obj hfd;
    Int h;
    Obj t;

    /* Find RNams if not already done: */
    initRNams();

    /* Increment accesses entry: */
    t = ElmPRec(ht,RNam_accesses);
    t = INTOBJ_INT(INT_INTOBJ(t)+1);
    AssPRec(ht,RNam_accesses,t);

    /* Compute hash value: */
    hfd = ElmPRec(ht,RNam_hfd);
    t = ElmPRec(ht,RNam_hf);
    h = INT_INTOBJ(CALL_2ARGS(t,x,hfd));

    /* Lookup slot: */
    els = ElmPRec(ht,RNam_els);
    vals = ElmPRec(ht,RNam_vals);
    t = ELM_PLIST(els,h);    /* Note that hash values are always within
                                  the boundaries of this list */
    if (t == 0L)  /* Unbound entry! */
        return Fail;

    /* Now check whether it is an AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ || 
        (TYPE_POSOBJ(t) != AVLTreeType &&
         TYPE_POSOBJ(t) != AVLTreeTypeMutable)) {
        if (CALL_2ARGS(ElmPRec(ht,RNam_cmpfunc),x,t) == INTOBJ_INT(0)) {
            if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L) 
                return ELM_PLIST(vals,h);
            else
                return True;
        }
        return Fail;
    }

    h = AVLFind(t,x);
    if (h == 0) return Fail;
    return AVLValue(t,h);
}

Obj HTDelete_TreeHash_C(Obj self, Obj ht, Obj x)
{
    Obj els;
    Obj vals;
    Obj hfd;
    Int h;
    Obj t;
    Obj v;

    /* Find RNams if not already done: */
    initRNams();

    /* Compute hash value: */
    hfd = ElmPRec(ht,RNam_hfd);
    t = ElmPRec(ht,RNam_hf);
    h = INT_INTOBJ(CALL_2ARGS(t,x,hfd));

    /* Lookup slot: */
    els = ElmPRec(ht,RNam_els);
    vals = ElmPRec(ht,RNam_vals);
    t = ELM_PLIST(els,h);    /* Note that hash values are always within
                                  the boundaries of this list */
    if (t == 0L)  /* Unbound entry! */
        return Fail;

    /* Now check whether it is an AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ ||
        (TYPE_POSOBJ(t) != AVLTreeType &&
         TYPE_POSOBJ(t) != AVLTreeTypeMutable)) {
        if (CALL_2ARGS(ElmPRec(ht,RNam_cmpfunc),x,t) == INTOBJ_INT(0)) {
            if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L) {
                v = ELM_PLIST(vals,h);
                UNB_LIST(vals,h);
            } else v = True;
            SET_ELM_PLIST(els,h,0L);
            AssPRec(ht,RNam_nr,INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_nr))-1));
            return v;
        }
        return Fail;
    }

    v = AVLDelete_C(self,t,x);
    if (v != Fail)
        AssPRec(ht,RNam_nr,INTOBJ_INT(INT_INTOBJ(ElmPRec(ht,RNam_nr))-1));

    return v;
}

Obj HTUpdate_TreeHash_C(Obj self, Obj ht, Obj x, Obj v)
{
    Obj els;
    Obj vals;
    Obj hfd;
    Int h;
    Obj t;
    Obj old;

    /* Find RNams if not already done: */
    initRNams();

    /* Compute hash value: */
    hfd = ElmPRec(ht,RNam_hfd);
    t = ElmPRec(ht,RNam_hf);
    h = INT_INTOBJ(CALL_2ARGS(t,x,hfd));

    /* Lookup slot: */
    els = ElmPRec(ht,RNam_els);
    vals = ElmPRec(ht,RNam_vals);
    t = ELM_PLIST(els,h);    /* Note that hash values are always within
                                  the boundaries of this list */
    if (t == 0L)  /* Unbound entry! */
        return Fail;

    /* Now check whether it is an AVLTree or not: */
    if (TNUM_OBJ(t) != T_POSOBJ || 
        (TYPE_POSOBJ(t) != AVLTreeType &&
         TYPE_POSOBJ(t) != AVLTreeTypeMutable)) {
        if (CALL_2ARGS(ElmPRec(ht,RNam_cmpfunc),x,t) == INTOBJ_INT(0)) {
            if (LEN_PLIST(vals) >= h && ELM_PLIST(vals,h) != 0L) {
                old = ELM_PLIST(vals,h);
                SET_ELM_PLIST(vals,h,v);
                CHANGED_BAG(vals);
                return old;
            } else return True;
        }
        return Fail;
    }

    h = AVLFind(t,x);
    if (h == 0) return Fail;
    old = AVLValue(t,h);
    SetAVLValue(t,h,v);
    return old;
}

Obj GenericHashFunc_C(Obj self, Obj x, Obj data)
{
     Int mult = INT_INTOBJ(ELM_PLIST(data,1));
     UChar *p = (UChar *) ADDR_OBJ(x) + INT_INTOBJ(ELM_PLIST(data,2));
     Int len = INT_INTOBJ(ELM_PLIST(data,3));
     UInt mod = INT_INTOBJ(ELM_PLIST(data,4));
     UInt n = 0;
     Int i;
     for (i = 0;i < len;i++) n = ((n*mult)+(UInt)(*p++));
     return INTOBJ_INT((n % mod) + 1);
}

/* For the time being we copy the Jenkins Hash stuff here: */

/******************************************************************************
 *
 *    jhash.h     The Bob Jenkins Hash Function
 *
 *    File      : $RCSfile: jhash.h,v $
 *    Author    : Henrik Bäärnhielm 
 *    Dev start : 2006-07-16 
 *
 *    Version   : $Revision: 1.7 $
 *    Date      : $Date: 2010/02/23 15:12:39 $
 *    Last edit : $Author: gap $
 *
 *    @(#)$Id: jhash.h,v 1.7 2010/02/23 15:12:39 gap Exp $
 *
 *    Definitions for Jenkins Hash
 *
 *****************************************************************************/

#include <sys/types.h>

#ifdef linux
# include <endian.h>
#endif

// xxx
#if 0
#if !defined(__CYGWIN__)
typedef u_int32_t uint32_t;
typedef u_int16_t uint16_t;
typedef u_int8_t uint8_t;
#endif
#endif


/******************************************************************************
 *
 *    jhash.c     The Bob Jenkins Hash Function
 *
 *    File      : $RCSfile: jhash.c,v $
 *    Author    : Bob Jenkins (cosmetic changes by Henrik Bäärnhielm) 
 *    Dev start : 2006-07-16 
 *
 *    Version   : $Revision: 1.2 $
 *    Date      : $Date: 2006/09/01 16:46:00 $
 *    Last edit : $Author: sal $
 *
 *    @(#)$Id: jhash.c,v 1.2 2006/09/01 16:46:00 sal Exp $
 *
 *    According to Prof. Viggo Kann at the CS department, Royal Institute of 
 *    Technology, Stockholm, Sweden, this is the best hash function known to
 *    humanity. It is fast and results in extremely few collisions. 
 *    Bob Jenkins original documentation is left in the code. 
 *    The file was fetched from http://burtleburtle.net/bob/c/lookup3.c
 *
 *****************************************************************************/

/*
-------------------------------------------------------------------------------
lookup3.c, by Bob Jenkins, May 2006, Public Domain.

These are functions for producing 32-bit hashes for hash table lookup.
hashword(), hashlittle(), hashbig(), mix(), and final() are externally 
useful functions.  Routines to test the hash are included if SELF_TEST 
is defined.  You can use this free for any purpose.  It has no warranty.

You probably want to use hashlittle().  hashlittle() and hashbig()
hash byte arrays.  hashlittle() is is faster than hashbig() on
little-endian machines.  Intel and AMD are little-endian machines.

If you want to find a hash of, say, exactly 7 integers, do
  a = i1;  b = i2;  c = i3;
  mix(a,b,c);
  a += i4; b += i5; c += i6;
  mix(a,b,c);
  a += i7;
  final(a,b,c);
then use c as the hash value.  If you have a variable length array of
4-byte integers to hash, use hashword().  If you have a byte array (like
a character string), use hashlittle().  If you have several byte arrays, or
a mix of things, see the comments above hashlittle().
-------------------------------------------------------------------------------
*/
//#define SELF_TEST 1

/*
 * My best guess at if you are big-endian or little-endian.  This may
 * need adjustment.
 */
#if (defined(__BYTE_ORDER) && defined(__LITTLE_ENDIAN) && \
     __BYTE_ORDER == __LITTLE_ENDIAN) || \
    (defined(i386) || defined(__i386__) || defined(__i486__) || \
     defined(__i586__) || defined(__i686__) || defined(vax) || defined(MIPSEL))
# define HASH_LITTLE_ENDIAN 1
# define HASH_BIG_ENDIAN 0
#elif (defined(__BYTE_ORDER) && defined(__BIG_ENDIAN) && \
       __BYTE_ORDER == __BIG_ENDIAN) || \
      (defined(sparc) || defined(POWERPC) || defined(mc68000) || defined(sel))
# define HASH_LITTLE_ENDIAN 0
# define HASH_BIG_ENDIAN 1
#else
# define HASH_LITTLE_ENDIAN 0
# define HASH_BIG_ENDIAN 0
#endif

#define hashsize(n) ((uint32_t)1<<(n))
#define hashmask(n) (hashsize(n)-1)
#define rot(x,k) (((x)<<(k)) ^ ((x)>>(32-(k))))

/*
-------------------------------------------------------------------------------
mix -- mix 3 32-bit values reversibly.

This is reversible, so any information in (a,b,c) before mix() is
still in (a,b,c) after mix().

If four pairs of (a,b,c) inputs are run through mix(), or through
mix() in reverse, there are at least 32 bits of the output that
are sometimes the same for one pair and different for another pair.
This was tested for:
* pairs that differed by one bit, by two bits, in any combination
  of top bits of (a,b,c), or in any combination of bottom bits of
  (a,b,c).
* "differ" is defined as +, -, ^, or ~^.  For + and -, I transformed
  the output delta to a Gray code (a^(a>>1)) so a string of 1's (as
  is commonly produced by subtraction) look like a single 1-bit
  difference.
* the base values were pseudorandom, all zero but one bit set, or 
  all zero plus a counter that starts at zero.

Some k values for my "a-=c; a^=rot(c,k); c+=b;" arrangement that
satisfy this are
    4  6  8 16 19  4
    9 15  3 18 27 15
   14  9  3  7 17  3
Well, "9 15 3 18 27 15" didn't quite get 32 bits diffing
for "differ" defined as + with a one-bit base and a two-bit delta.  I
used http://burtleburtle.net/bob/hash/avalanche.html to choose 
the operations, constants, and arrangements of the variables.

This does not achieve avalanche.  There are input bits of (a,b,c)
that fail to affect some output bits of (a,b,c), especially of a.  The
most thoroughly mixed value is c, but it doesn't really even achieve
avalanche in c.

This allows some parallelism.  Read-after-writes are good at doubling
the number of bits affected, so the goal of mixing pulls in the opposite
direction as the goal of parallelism.  I did what I could.  Rotates
seem to cost as much as shifts on every machine I could lay my hands
on, and rotates are much kinder to the top and bottom bits, so I used
rotates.
-------------------------------------------------------------------------------
*/
#define mix(a,b,c) \
{ \
  a -= c;  a ^= rot(c, 4);  c += b; \
  b -= a;  b ^= rot(a, 6);  a += c; \
  c -= b;  c ^= rot(b, 8);  b += a; \
  a -= c;  a ^= rot(c,16);  c += b; \
  b -= a;  b ^= rot(a,19);  a += c; \
  c -= b;  c ^= rot(b, 4);  b += a; \
}

/*
-------------------------------------------------------------------------------
final -- final mixing of 3 32-bit values (a,b,c) into c

Pairs of (a,b,c) values differing in only a few bits will usually
produce values of c that look totally different.  This was tested for
* pairs that differed by one bit, by two bits, in any combination
  of top bits of (a,b,c), or in any combination of bottom bits of
  (a,b,c).
* "differ" is defined as +, -, ^, or ~^.  For + and -, I transformed
  the output delta to a Gray code (a^(a>>1)) so a string of 1's (as
  is commonly produced by subtraction) look like a single 1-bit
  difference.
* the base values were pseudorandom, all zero but one bit set, or 
  all zero plus a counter that starts at zero.

These constants passed:
 14 11 25 16 4 14 24
 12 14 25 16 4 14 24
and these came close:
  4  8 15 26 3 22 24
 10  8 15 26 3 22 24
 11  8 15 26 3 22 24
-------------------------------------------------------------------------------
*/
#define final(a,b,c) \
{ \
  c ^= b; c -= rot(b,14); \
  a ^= c; a -= rot(c,11); \
  b ^= a; b -= rot(a,25); \
  c ^= b; c -= rot(b,16); \
  a ^= c; a -= rot(c,4);  \
  b ^= a; b -= rot(a,14); \
  c ^= b; c -= rot(b,24); \
}

/*
--------------------------------------------------------------------
 This works on all machines.  To be useful, it requires
 -- that the key be an array of uint32_t's, and
 -- that all your machines have the same endianness, and
 -- that the length be the number of uint32_t's in the key

 The function hashword() is identical to hashlittle() on little-endian
 machines, and identical to hashbig() on big-endian machines,
 except that the length has to be measured in uint32_ts rather than in
 bytes.  hashlittle() is more complicated than hashword() only because
 hashlittle() has to dance around fitting the key bytes into registers.
--------------------------------------------------------------------
*/
uint32_t hashword(register uint32_t *k, 
						register size_t length, 
						register uint32_t initval)
	/* the key, an array of uint32_t values */
	/* the length of the key, in uint32_ts */
	/* the previous hash, or an arbitrary value */
{
  register uint32_t a,b,c;

  /* Set up the internal state */
  a = b = c = 0xdeadbeef + (((uint32_t)length)<<2) + initval;

  /*------------------------------------------------- handle most of the key */
  while (length > 3)
  {
    a += k[0];
    b += k[1];
    c += k[2];
    mix(a,b,c);
    length -= 3;
    k += 3;
  }

  /*------------------------------------------- handle the last 3 uint32_t's */
  switch(length)                     /* all the case statements fall through */
  { 
  case 3: c+=k[2];
  case 2: b+=k[1];
  case 1: a+=k[0];
    final(a,b,c);
  case 0:     /* case 0: nothing left to add */
    break;
  }
  /*------------------------------------------------------ report the result */
  return c;
}


/*
-------------------------------------------------------------------------------
hashlittle() -- hash a variable-length key into a 32-bit value
  k       : the key (the unaligned variable-length array of bytes)
  length  : the length of the key, counting by bytes
  initval : can be any 4-byte value
Returns a 32-bit value.  Every bit of the key affects every bit of
the return value.  Two keys differing by one or two bits will have
totally different hash values.

The best hash table sizes are powers of 2.  There is no need to do
mod a prime (mod is sooo slow!).  If you need less than 32 bits,
use a bitmask.  For example, if you need only 10 bits, do
  h = (h & hashmask(10));
In which case, the hash table should have hashsize(10) elements.

If you are hashing n strings (uint8_t **)k, do it like this:
  for (i=0, h=0; i<n; ++i) h = hashlittle( k[i], len[i], h);

By Bob Jenkins, 2006.  bob_jenkins@burtleburtle.net.  You may use this
code any way you wish, private, educational, or commercial.  It's free.

Use for hash table lookup, or anything where one collision in 2^^32 is
acceptable.  Do NOT use for cryptographic purposes.
-------------------------------------------------------------------------------
*/

uint32_t hashlittle( register void *key, register size_t length, 
							register uint32_t initval)
{
  register uint32_t a,b,c;

  /* Set up the internal state */
  a = b = c = 0xdeadbeef + ((uint32_t)length) + initval;

  if (HASH_LITTLE_ENDIAN && !((((uint8_t *)key)-(uint8_t *)0) & 0x3)) {
    register uint32_t *k = key;                /* read 32-bit chunks */

    /*------ all but last block: aligned reads and affect 32 bits of (a,b,c) */
    while (length > 12)
    {
      a += k[0];
      b += k[1];
      c += k[2];
      mix(a,b,c);
      length -= 12;
      k += 3;
    }

    /*----------------------------- handle the last (probably partial) block */
    switch(length)
    {
    case 12: c+=k[2]; b+=k[1]; a+=k[0]; break;
    case 11: c+=k[2]&0xffffff; b+=k[1]; a+=k[0]; break;
    case 10: c+=k[2]&0xffff; b+=k[1]; a+=k[0]; break;
    case 9:  c+=k[2]&0xff; b+=k[1]; a+=k[0]; break;
    case 8:  b+=k[1]; a+=k[0]; break;
    case 7:  b+=k[1]&0xffffff; a+=k[0]; break;
    case 6:  b+=k[1]&0xffff; a+=k[0]; break;
    case 5:  b+=k[1]&0xff; a+=k[0]; break;
    case 4:  a+=k[0]; break;
    case 3:  a+=k[0]&0xffffff; break;
    case 2:  a+=k[0]&0xffff; break;
    case 1:  a+=k[0]&0xff; break;
    case 0:  return c;              /* zero length strings require no mixing */
    }

  } else if (HASH_LITTLE_ENDIAN && !((((uint8_t *)key)-(uint8_t *)0) & 0x1)) {
    register uint16_t *k = key;                      /* read 16-bit chunks */

    /*--------------- all but last block: aligned reads and different mixing */
    while (length > 12)
    {
      a += k[0] + (((uint32_t)k[1])<<16);
      b += k[2] + (((uint32_t)k[3])<<16);
      c += k[4] + (((uint32_t)k[5])<<16);
      mix(a,b,c);
      length -= 12;
      k += 6;
    }

    /*----------------------------- handle the last (probably partial) block */
    switch(length)
    {
    case 12: c+=k[4]+(((uint32_t)k[5])<<16);
             b+=k[2]+(((uint32_t)k[3])<<16);
             a+=k[0]+(((uint32_t)k[1])<<16);
             break;
    case 11: c+=((uint32_t)(k[5]&0xff))<<16;/* fall through */
    case 10: c+=k[4];
             b+=k[2]+(((uint32_t)k[3])<<16);
             a+=k[0]+(((uint32_t)k[1])<<16);
             break;
    case 9:  c+=k[4]&0xff;                /* fall through */
    case 8:  b+=k[2]+(((uint32_t)k[3])<<16);
             a+=k[0]+(((uint32_t)k[1])<<16);
             break;
    case 7:  b+=((uint32_t)(k[3]&0xff))<<16;/* fall through */
    case 6:  b+=k[2];
             a+=k[0]+(((uint32_t)k[1])<<16);
             break;
    case 5:  b+=k[2]&0xff;                /* fall through */
    case 4:  a+=k[0]+(((uint32_t)k[1])<<16);
             break;
    case 3:  a+=((uint32_t)(k[1]&0xff))<<16;/* fall through */
    case 2:  a+=k[0];
             break;
    case 1:  a+=k[0]&0xff;
             break;
    case 0:  return c;                     /* zero length requires no mixing */
    }

  } else {                        /* need to read the key one byte at a time */
    register uint8_t *k = key;

    /*--------------- all but the last block: affect some 32 bits of (a,b,c) */
    while (length > 12)
    {
      a += k[0];
      a += ((uint32_t)k[1])<<8;
      a += ((uint32_t)k[2])<<16;
      a += ((uint32_t)k[3])<<24;
      b += k[4];
      b += ((uint32_t)k[5])<<8;
      b += ((uint32_t)k[6])<<16;
      b += ((uint32_t)k[7])<<24;
      c += k[8];
      c += ((uint32_t)k[9])<<8;
      c += ((uint32_t)k[10])<<16;
      c += ((uint32_t)k[11])<<24;
      mix(a,b,c);
      length -= 12;
      k += 12;
    }

    /*-------------------------------- last block: affect all 32 bits of (c) */
    switch(length)                   /* all the case statements fall through */
    {
    case 12: c+=((uint32_t)k[11])<<24;
    case 11: c+=((uint32_t)k[10])<<16;
    case 10: c+=((uint32_t)k[9])<<8;
    case 9:  c+=k[8];
    case 8:  b+=((uint32_t)k[7])<<24;
    case 7:  b+=((uint32_t)k[6])<<16;
    case 6:  b+=((uint32_t)k[5])<<8;
    case 5:  b+=k[4];
    case 4:  a+=((uint32_t)k[3])<<24;
    case 3:  a+=((uint32_t)k[2])<<16;
    case 2:  a+=((uint32_t)k[1])<<8;
    case 1:  a+=k[0];
             break;
    case 0:  return c;
    }
  }

  final(a,b,c);
  return c;
}



/*
 * hashbig():
 * This is the same as hashword() on big-endian machines.  It is different
 * from hashlittle() on all machines.  hashbig() takes advantage of
 * big-endian byte ordering. 
 */
uint32_t hashbig(register void *key, 
					  register size_t length, 
					  register uint32_t initval)
{
	register uint32_t a,b,c;

  /* Set up the internal state */
  a = b = c = 0xdeadbeef + ((uint32_t)length) + initval;

  if (HASH_BIG_ENDIAN && !((((uint8_t *)key)-(uint8_t *)0) & 0x3)) {
    register uint32_t *k = key;                 /* read 32-bit chunks */

    /*------ all but last block: aligned reads and affect 32 bits of (a,b,c) */
    while (length > 12)
    {
      a += k[0];
      b += k[1];
      c += k[2];
      mix(a,b,c);
      length -= 12;
      k += 3;
    }

    /*----------------------------- handle the last (probably partial) block */
    switch(length)
    {
    case 12: c+=k[2]; b+=k[1]; a+=k[0]; break;
    case 11: c+=k[2]<<8; b+=k[1]; a+=k[0]; break;
    case 10: c+=k[2]<<16; b+=k[1]; a+=k[0]; break;
    case 9:  c+=k[2]<<24; b+=k[1]; a+=k[0]; break;
    case 8:  b+=k[1]; a+=k[0]; break;
    case 7:  b+=k[1]<<8; a+=k[0]; break;
    case 6:  b+=k[1]<<16; a+=k[0]; break;
    case 5:  b+=k[1]<<24; a+=k[0]; break;
    case 4:  a+=k[0]; break;
    case 3:  a+=k[0]<<8; break;
    case 2:  a+=k[0]<<16; break;
    case 1:  a+=k[0]<<24; break;
    case 0:  return c;              /* zero length strings require no mixing */
    }

  } else {                        /* need to read the key one byte at a time */
    register uint8_t *k = key;

    /*--------------- all but the last block: affect some 32 bits of (a,b,c) */
    while (length > 12)
    {
      a += ((uint32_t)k[0])<<24;
      a += ((uint32_t)k[1])<<16;
      a += ((uint32_t)k[2])<<8;
      a += ((uint32_t)k[3]);
      b += ((uint32_t)k[4])<<24;
      b += ((uint32_t)k[5])<<16;
      b += ((uint32_t)k[6])<<8;
      b += ((uint32_t)k[7]);
      c += ((uint32_t)k[8])<<24;
      c += ((uint32_t)k[9])<<16;
      c += ((uint32_t)k[10])<<8;
      c += ((uint32_t)k[11]);
      mix(a,b,c);
      length -= 12;
      k += 12;
    }

    /*-------------------------------- last block: affect all 32 bits of (c) */
    switch(length)                   /* all the case statements fall through */
    {
    case 12: c+=((uint32_t)k[11])<<24;
    case 11: c+=((uint32_t)k[10])<<16;
    case 10: c+=((uint32_t)k[9])<<8;
    case 9:  c+=k[8];
    case 8:  b+=((uint32_t)k[7])<<24;
    case 7:  b+=((uint32_t)k[6])<<16;
    case 6:  b+=((uint32_t)k[5])<<8;
    case 5:  b+=k[4];
    case 4:  a+=((uint32_t)k[3])<<24;
    case 3:  a+=((uint32_t)k[2])<<16;
    case 2:  a+=((uint32_t)k[1])<<8;
    case 1:  a+=k[0];
             break;
    case 0:  return c;
    }
  }

  final(a,b,c);
  return c;
}

Obj FuncJenkinsHashInOrb(Obj self, Obj x, Obj offset, Obj bytelen, Obj hashlen)
{
   void *input;
   uint32_t len;
   uint32_t key;
   uint32_t init = 0;
   uint32_t mod;
   
   input = (void *)((UChar *) ADDR_OBJ(x) + INT_INTOBJ(offset));
   len = (uint32_t)INT_INTOBJ(bytelen);
   mod = INT_INTOBJ(hashlen);
	
// Take advantage of endianness if possible
#ifdef WORDS_BIGENDIAN
   key = hashbig(input, len, init);
#else
   key = hashlittle(input, len, init);
#endif
   
   return INTOBJ_INT((Int)(key % mod + 1));
}


/*
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; version 2 of the License.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */


