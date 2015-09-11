This readme is under gitPublic
Created by Franc Brglez, Sat Jan 24 15:34:45 EST 2015 …

***************************************************************************
***************************************************************************
WARNING!
This directory is undergoing changes, so DO NOT download any materials
until this notice is removed. 

***************************************************************************
***************************************************************************

Created in in January 2015, gitPublic is an open-source archive with intent
to facilitate well-structured rapid prototyping of combinatorial solvers
while also providing the infrastructure to support statistically
significant performance testing of such solvers.

Under the banner of "student engagement", involving a small group of
undergraduate students in research during Spring 2015, the directory
xProj499 includes source code and experiments that are driven by a
project-based undergraduate honors class on "On Rapid Prototyping of
Combinatorial Solvers" at Computer Science at NC State.  The directory xBed
continues to evolve: it contains binaries and libraries that are being
shared between the Spring 2015 project and any future projects.  All
students will have installed the R shell, the tcl/TkCon shell, the python
shell, and various LaTeX templates.  The working shell is bash, either
under linux or MacOSX.

All of the initial prototypes of combinatorial solvers are written in tcl
and are introduced, with required tcl commands and test cases, during the
weekly class meetings by the instructor.  There are several goals of the
Spring 2015 project.  First, we learn about properties of each solver and
observe the asymptotic performance in real time by executing tcl command
lines as well as by modifying the tcl code, rather than by studying the
pseudo code only in the abstract.  Second, we learn about python code to
construct a solver that is comparable to the tcl implementation, not only
in conciseness and clarity but most importantly, is expected to exceed the
runtime performance of the tcl solver.  Third, we instrument each solver
for asymptotic performance evaluation on a large number of instances
running on the same CPU, so we can infer statistically significant
performance differences between solvers.  Three solver prototypes from very
different domains are being considered: the blackout puzzle problem, the
linear ordering problem, and the ciphertext decryption problem.

The documented and tested combinatorial solver prototypes are expected to
serve as a "detailed command-line specification" for state-of-the-art C or
C++ solvers.  These high-performance compiled-code solvers can then be
applied, using the command-line syntax of "scripted solver prototypes", to
problem instances that cannot be solved within weeks when using solvers
based on either tcl or python.

Both directories, xProj499 and xBed, are still evolving during Spring 2015.
Both will continue with weekly updates (at the minimum) until further
notice.
