cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   Portable versions of ESSL routines durand and isort
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c                  IBM SOFTWARE DISCLAIMER
c
c   essl.f (version 1.0)
c   Copyright (1998,1990)
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
c        website: http://www.research.ibm.com/people/s/shearer/
c        date: 1998 (durand 1990)
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   These routines emulate essl routines for portability to machines
c without essl.  Performance will be inferior and, unlike essl, no
c error checking is performed.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   durand(seed,n,x)         psuedo-random number routine
c
c     seed    real*8         initalize to integer 1.0  -  2.**31-2.0
c                            updated on exit for next call
c     n       integer*4      length of random vector to be generated
c     x(*)    real*8         routine fills with n psuedo-random values
c                            uniform 0-1
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      SUBROUTINE DURAND(SEED,N,X)
      REAL*8 X(*)
      REAL*8 SEED
      REAL*8 S,T,XM,XMP,SCALEU,SCALED,ONEMEP,ONEPEP
      DATA XM/16807.D0/
      DATA XMP/16807.00000 78263 69255 78117 37060 54687 5D0/
      DATA SCALEU/2147483648.D0/
      DATA SCALED /.00000 00004 65661 28730 77392 57812 5D0/
      DATA ONEPEP/1.00000 00004 65661 28730 77392 57812 5D0/
      DATA ONEMEP/ .99999 99995 34338 71269 22607 42187 5D0/
      T=SEED*SCALED
      DO 1 J=1,N
      S=DINT(T*XMP)
      T=T*XM
      T=T-S*ONEMEP
    1 X(J)=T*ONEPEP
      SEED=T*SCALEU
      RETURN
      END
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c   isort(x,incx,n)          integer sort routine
c
c        x(*)     integer*4  vector of integers to be sorted
c        incx     integer*4  stride, + sort up, - sort down
c        n        integer*4  number of integers to be sorted
c
c   WARNING   -    This implementation is O(n**2).
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine isort(x,incx,n)
      integer*4 x(*),t
      integer*4 incx,n
      integer*4 ix,jx
c set start position
      ix=1
      if(incx.lt.0)ix=1-(n-1)*incx
      do 10 i=2,n
      ix=ix+incx
      t=x(ix)
      jx=ix
      do 20 j=1,i-1
      jx=jx-incx
      if(t.gt.x(jx))go to 10
      x(jx+incx)=x(jx)
      x(jx)=t
   20 continue
   10 continue
      return
      end

