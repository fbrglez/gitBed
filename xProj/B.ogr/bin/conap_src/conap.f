cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        Program to construct Golomb rulers from affine planes
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c                  IBM SOFTWARE DISCLAIMER
c
c   conap.f (version 1.1)
c   Copyright (1998,1986)
c   International Business Machines Corporation
c
c   Permission to use, copy, modify and distribute this software for
c any purpose and without fee is hereby granted, provided that this
c copyright and permission notice appear on all copies of the software.
c The name of the IBM corporation may not be used in any advertising or
c publicity pertaining to the use of the software.  IBM makes no
c warranty or representations about the suitability of the software
c for any purpose.  It is provided "AS IS" without any express or
c implied warranty, including the implied warranties of merchantability,
c fitness for a particular purpose and non-infringement.  IBM shall not
c be liable for any direct, indirect, special or consequential damages
c resulting from the loss of use, data or projects, whether in action
c of contract or tort, arising out or in the connection with the use or
c performance of this software.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        Author: James B. Shearer
c        email:  jbs@watson.ibm.com
c        website: http://www.research.ibm.com/people/s/shearer/)
c        date: 1998 based on code written in 1986
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        Version 1.1 (12/11/98) - Rename some variables to conform
c   with exhaustive search routines.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        Requires: ESSL library or portable versions of ESSL routines
c   durand, isort (see essl.f)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        This program constructs good but not necessarily optimal Golomb
c   rulers from finite affine planes.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c                  Theory
c
c   Suppose p is a prime power.  Consider the Galois field GF(p)
c and the extension field GF(p**2).  Let x be a generator of the
c cyclic multiplicative group of GF(p**2).  Then the elements of
c GF(p**2) can be represented in the form a+b*x where a,b are
c elements of GF(p).  (Note in particular x**2 can be so written,
c so we may take x to be a root of a quadratic polynomial over
c GF(p).)  Consider the p elements of the form {x+a}.  Let x+a =
c x**ia.  We claim the n integers {ia} form a distinct difference
c set mod p**2-1 (ie if ia-ib=ic-id mod p**2-1 then (ia=ic and ib=id)
c or (ia=ib and ic=id)).  For suppose ia-ib=ic-id mod p**2-1.
c Then (x+a)/(x+b) = (x+c)/(x+d) (since x**(p**2-1)=1) ->
c (a+d)*x+a*d=(b+c)*x+b*c -> a+d=b+c and a*d=b*c.  So {a,d} = {b,c}
c (since they are the roots of the same quadratic polynomial).
c The claim follows easily.
c   Modular distinct difference sets can then be unwound to give
c Golomb rulers.  Note we may multiply a modular distinct difference
c set by anything prime to the modulus to obtain another modular
c distinct difference set.  The program below tries all possibilities
c in order to obtain the shortest rulers.
c   The modular difference set construction is due to Bose [1], the
c application to golomb rulers to Atkinson and Hassenklover [2].
c   The program below finds the best Golomb rulers using this
c construction for prime powers up to maxn.  It may fail if maxn**4
c overflows integer*4 arithmetic (loop 230).  A program which just
c handled primes and not prime powers would be simpler.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c        References
c
c  1. R. C. Bose, "An affine analogue of Singer's theorem", J. Ind.
c     Math. Soc., 6(1942), 1-15.
c  2. M. D. Atkinson and A. Hassenklover, "Sets of integers with
c     distinct differences", SCS-TR-63, Carleton University, October
c     1984.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      Parameter (maxn=160,maxpow=10)
      integer*4 len(maxn),nval(maxn),mrec(maxn,maxn)
      integer*4 is(maxn*maxn)
      integer*4 ids(maxn)
      integer*4 mw(2*maxn)
      integer*4 ipc(2*maxpow),iit(2*maxpow),itemp(2*maxpow)
      real*8 buf(2*maxpow)
c initialize best rulers so far
      do 5 j=2,maxn
      len(j)=maxn*maxn
      nval(j)=0
    5 continue
c loop over n
      do 10 n=3,maxn
c check if n is a prime power
c first find smallest prime divisor
      do 20 j=2,n
      if(mod(n,j).eq.0)go to 30
   20 continue
      stop "error 20"
   30 np=j
      npow=1
      nprod=j
c next check if n is a power of the smallest prime divisor
   40 if(nprod.eq.n)go to 50
      nprod=nprod*np
      npow=npow+1
      if(nprod.le.n)go to 40
c n is not a prime power, go to next n
      go to 10
c n is a prime power, construct GF(n**2)=GF(np**ndeg)
   50 ndeg=2*npow
c generate random coefficients for monic polynomial P,
c with degree ndeg over GF(np)
   60 call irand(ipc,np,ndeg,buf)
c check if constant term is 0, if so generate another polynomial
      if(ipc(1).eq.0)go to 60
c check if x is a multiplicative generator mod P
c initialize iit (x**0) to the unit vector
      do 70 j=1,ndeg
      iit(j)=0
   70 continue
      iit(1)=1
c generate powers of x
      do 80 j=1,n*n-2
c multiply iit by x
      itemp(1)=ipc(1)*iit(ndeg)
      do 90 i=2,ndeg
      itemp(i)=iit(i-1)+ipc(i)*iit(ndeg)
   90 continue
      do 100 i=1,ndeg
      iit(i)=mod(itemp(i),np)
  100 continue
c check if power of x is 1 prematurely
      if(iit(1).ne.1)go to 80
      do 110 i=2,ndeg
      if(iit(i).ne.0)go to 80
  110 continue
c this polynomial no good, go generate another
      go to 60
   80 continue
c   All powers of x ok.  We now have a representation of GF(n**2) as
c arithmetic mod a polynomial.
c   The field GF(n**2) is an extension of the field GF(n).  We need
c a way of identifying elements of the subfield GF(n).  This is easy
c when n is a prime rather than a prime power, the field elements
c are linear polynomials mod a quadratic polynomial and the subfield
c consists of the constant polynomials.  Unfortunately I don't
c know of an elegant test for the prime power case so we do the
c following brute force approach.  We construct a table with n**2
c entries (one entry for each element of GF(n**2)) each entry
c being 0 or 1 where 1 means the corresponding element of GF(n**2)
c is also an element of GF(n) and 0 means it is not.  The table
c is generated by running through the powers of x.  The non-zero
c elements of GF(n) are generated by x**(n+1).
c   First zero the index vector
      isq=n*n
      do 85 j=1,isq
      is(j)=0
   85 continue
c   Mark 0,1 as elements of base field (note index is offset by 1)
      is(1+0)=1
      is(1+1)=1
c initialize iit (x**0) to the unit vector
      do 120 j=1,ndeg
      iit(j)=0
  120 continue
      iit(1)=1
c generate powers of x
      do 130 j=1,n*n-2
c multiply iit by x
      itemp(1)=ipc(1)*iit(ndeg)
      do 140 i=2,ndeg
      itemp(i)=iit(i-1)+ipc(i)*iit(ndeg)
  140 continue
      do 150 i=1,ndeg
      iit(i)=mod(itemp(i),np)
  150 continue
c check if power of x is in GF(n)
      if(mod(j,n+1).ne.0)go to 130
c if yes, encode element as base np number
      ia=iit(ndeg)
      do 160 i=2,ndeg
      ia=ia*np+iit(ndeg+1-i)
  160 continue
c mark element as member of base field
      is(1+ia)=1
  130 continue
c generate modular difference set (mod n**2-1)
      nd=0
c check if 0 is an element of difference set
c ie if x**0-x is an element of the base field GF(n)
      if(is(1+(1+(np-1)*np)).eq.0)go to 165
      nd=nd+1
      ids(nd)=0
  165 continue
c initialize iit (x**0) to the unit vector
      do 170 j=1,ndeg
      iit(j)=0
  170 continue
      iit(1)=1
c generate powers of x
      do 180 j=1,n*n-2
c multiply iit by x
      itemp(1)=ipc(1)*iit(ndeg)
      do 190 i=2,ndeg
      itemp(i)=iit(i-1)+ipc(i)*iit(ndeg)
  190 continue
      do 200 i=1,ndeg
      iit(i)=mod(itemp(i),np)
  200 continue
c check if x**j-x is in GF(n)
c subtract x
      iit(2)=mod(iit(2)+np-1,np)
c encode field element
      ia=iit(ndeg)
      do 210 i=2,ndeg
      ia=ia*np+iit(ndeg+1-i)
  210 continue
c check
      if(is(1+ia).eq.0)go to 180
c add this j to modular difference set
      nd=nd+1
      ids(nd)=j
c add x back
  180 iit(2)=mod(iit(2)+1,np)
c check that modular difference set is right size
      if(nd.ne.n)stop "error 180"
c sort modular difference set
c     call isort(ids,1,n)
c output difference set
c     write(6,1000)n,(ids(j),j=1,nd)
c1000 format(1x,i5,5x,(10i5))
c check for better rulers
c cycle over multipliers, do not need to try j and -j mod (n*n-1)
c     do 220 j=1,n*n-2
      do 220 j=1,(n*n-1)/2
c check if multiplier prime to modulus
      if(igcd(j,n*n-1).ne.1)go to 220
c multiply difference set
      do 230 i=1,n
      mw(i)=mod(ids(i)*j,n*n-1)
  230 continue
c sort new difference set
      call isort(mw,1,n)
c unwrap difference set
      do 240 i=1,n
      mw(i+n)=mw(i)+n*n-1
  240 continue
c check for new records
      do 250 ia=1,n
      do 260 ib=1,n-1
      if(mw(ia+ib)-mw(ia).ge.len(ib+1))go to 260
c new record ruler
      len(ib+1)=mw(ia+ib)-mw(ia)
      nval(ib+1)=n
      do 270 ja=1,ib+1
      mrec(ja,ib+1)=mw(ia+ja-1)-mw(ia)
  270 continue
  260 continue
  250 continue
  220 continue
   10 continue
c output maximum rulers
      do 500 j=2,maxn
      if(nval(j).eq.0)go to 500
c put ruler in standard form (flip if needed)
      if(mrec((j+1)/2,j)+mrec((j+2)/2,j).lt.len(j))go to 520
c flip ruler
      do 510 i=1,(j+1)/2
      mtemp=mrec(i,j)
      mrec(i,j)=len(j)-mrec(j+1-i,j)
      mrec(j+1-i,j)=len(j)-mtemp
  510 continue
  520 continue
c
c write results for j marks
c
c j, length and prime power to unit 6 (terminal)
c j, length and prime power to unit 1 (disk)
c ruler to unit 1 (disk)
c
      write(6,1010)j,len(j),nval(j)
      write(1,1020)j,len(j),nval(j)
      write(1,1030)(mrec(i,j),i=1,j)
 1010 format(1x,3i10)
 1020 format(3i10)
 1030 format(10i6)
  500 continue
c mark end of unit 1 (disk) file
      write(1,1020)0,0,0
      stop
      end
c generate random vector of n integers 0,...,np-1
      subroutine irand(l,np,n,x)
      integer*4 l(*)
      real*8 x(*)
      real*8 dseed/1.d0/
      save dseed
c generate random 0-1 real*8 vector
      call durand(dseed,n,x)
c convert to integer 0,...,np-1
      do 10 j=1,n
      l(j)=np*x(j)
   10 continue
      return
      end
c find gcd of ia,ib using Euler's method
      function igcd(ia,ib)
      ja=ia
      jb=ib
    1 jc=mod(ja,jb)
      ja=jb
      jb=jc
      if(jb.ne.0)go to 1
      igcd=ja
      return
      end

