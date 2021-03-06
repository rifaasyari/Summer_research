% S4 Changelog
% Victor Liu (vkl@stanford.edu)
% Sep 17, 2011
<style type="text/css">
@import url(s4.css);
</style>

[S4 Home](index.html) | [Download](download.html) | [Lua API](s4_lua_api.html) | [Developer information](dev_info.html) | [Changelog](changelog.html)

# Changelog
=2011-11-21=
	Fixed bug with rotation and translation in OutputPatternDescription (thanks Aaswath).
=2011-09-16=
	Eigenvector basis for uniform layers not stored (identity matrix). Added option UseLessMemory to not store kp (k-cross) matrices.
=2011-09-06=
	Fixed minor bugs and passes Valgrind without problems (for a few test runs).
=2011-08-31=
	Added GetDiffractionOrder().
=2011-08-30=
	Fixed normal-vector bug, resolving convergence issues with subpixel-smoothing and rectangular shapes.
=2011-08-25=
	Added CHOLMOD direct solver to pattern.c.
=2011-08-23=
	Fixed segment-segment intersection code. Several cases of incorrect dielectric discretization have been fixed.
	Changed Enable/Disable* functions to Use*.
=2011-06-20=
	Added MPI support. Compile with HAVE_MPI. S4.MPIRank and MPISize are available regardless of MPI support.
=2011-04-22=
	Halved the Lanczos filter spatial width. This seems to improve convergence.
	Changed default resolution to 8 from 64.
=2011-04-21=
	Added Kottke's subpixel smoothing method. Disabled by default.
	SetLattice can now take a single number for 1D periodicity.
	SpectrumSampler can now be parallelized.
=2011-04-20=
	Changed PolarizationBasisOversamplingFactor to Resolution.
=2011-04-18=
	Fixed crash when using Kiss FFT. I overzealously converted free to S4_free for kiss_fft.
=2011-03-27=
	Switched numerical memory allocation to 16-byte alignment. LinearSolve's now use LAPACK blocked code. Fixed some memory leaks with S4_Simulation objects (field cache was not being freed).
=2011-03-20=
	Added Integrate function.
=2010-10-28=
	Fixed nan output due to uninitialized matrices Ml, Mlp1, Bl, Blp1 in rcwa.cpp.
=2010-09-10=
	Fixed incorrect output of z-components of E- and H-fields (missing in-plane k-vector dependent phase).
=2010-08-23=
	Fixed memory leak in S4_DestroySolution; kx and Bands and Solution structures were not freed.
=2010-08-10=
	Fixed erroneous generation of values for Fourier transform for non-tensor materials in the context of a with-tensor stack.
	Added S4.ConvertUnits.
=2010-08-09=
	Fixed a bug with S-Matrix generation between two identical layers (previous results were incorrect).
=2010-08-05=
	Added anisotropic material support (currently incompatible with polarization basis, but without warning). Added cubic hermite spline interpolation.
=2010-08-04=
	Added real material data for metals.
=2010-08-03=
	Traced a problem with incorrect multithreaded results back to LAPACK. It is critical that LAPACK not use static allocation for local arrays (fixed with `-frecursive`).
=2010-07-29=
	Fixed 1D lattice G selection (even numbers would cause duplicates)
=2010-07-28=
	Fixed planewave excitation calculations for off-normal incidence. Previous s- and p-polarizations were mixed up and wrong. Added command line switches `a` and `t`.
=2010-07-26=
	Fixed circular truncation code; was dropping certain orders (2,2 on a square lattice).
=2010-07-24=
	Fixed polygon patterning (incorrect Fourier transform formulation).
=2010-07-23=
	Added ability to output diffraction efficiency, obtain the G-vector list, and fixed the Fourier transforms for non-unit area unit cells.
=2010-07-22=
	Added caching of polarization basis vector field Fourier transform matrices.
	Repeated computation of the same structure at different frequencies or k-vectors is much faster now that the vector field does not need to be recreated each time.
=2010-07-21=
	Initial announcement of S4. Supports multithreading.
