function  [Dopt, thresh,Copt] = detectpar
% Detection parameters definition
%                     Dopt(1) : minimal chi
%                     Dopt(2) : minimal delta chi
%                     Dopt(3) : minimal parameter variance
%                     Dopt(4) : maximal # of loops in fitting procedure
%                     Dopt(5) : maximal lambda allowed (see Marquard algorithm)
%                     Dopt(6) : width of Gaussian correlation function
%                     Dopt(7) : width of image around peak which is fitted
%                     Dopt(8): limit for the diffusion probability
%
%                     thresh : threshold for locating a peak
%
%                     Copt(1): confidence limit for chi-test 
%                     Copt(2): confidence limit exponential test
%                     Copt(3): confidence limit for F-test
%

% default for fit-tracking options
Dopt(1)  = 1.E-4;
Dopt(2) = 1.E-3;
Dopt(3) = 1.E-3;
Dopt(4) = 100;
Dopt(5) = 1E8;
Dopt(6)  = 1.7;
Dopt(7)   = 9;
Dopt(8) = 0.01;
thresh   = 2;

% default for confidence limits
Copt(1) = 0.00000000000001;
Copt(2) = 0.9;
Copt(3)   = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
