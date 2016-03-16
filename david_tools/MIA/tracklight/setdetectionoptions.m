function  setdetectionoptions
%
%                     OptIn(1) : control-output out (0) or in (1)
%                     OptIn(2) : minimal chi
%                     OptIn(3) : minimal delta chi
%                     OptIn(4) : minimal parameter variance
%                     OptIn(5) : maximal # of loops in fitting procedure
%                     OptIn(6) : maximal lambda allowed (see Marquard algorithm)
%                     OptIn(7) : width of Gaussian correlation function
%                     OptIn(8) : width of image around peak which is fitted
%                     OptIn(9) : threshold for locating a peak
%                     OptIn(10): fit-mode chisqared (0), abs.deviation (1)
%                     OptIn(11): confidence limit exponential test
%                     OptIn(12): confidence limit for chi-test
%                     OptIn(13): confidence limit for F-test
%                     OptIn(14): bleaching time (images)
%                     OptIn(15): limit for the diffusion probability
%                     OptIn(16): average # molecules per image
%                     OptIn(17): time for recovery

% creates file .mat with detection/cutoffs for calibrationgui.m
detoptions.output=0;
detoptions.minchi=1.E-4;
detoptions.mindchi=1.E-3;
detoptions.minparvar=1.E-3;
detoptions.loops=100;
detoptions.lamba=1E8;
detoptions.widthgauss=1.7;
detoptions.widthimagefit=9;
detoptions.threshold=2;
detoptions.fit=0;
detoptions.confchi=0.00000000000001;
detoptions.confexp=0.9;
detoptions.confF=0;
detoptions.bleach   = inf;
detoptions.difProb  = 0.01;
detoptions.concentr = 0;
detoptions.recover  = inf;
detoptions.pixels=4;

detoptions.cutoff1=1/3;
detoptions.cutoff2=1000;
detoptions.cutoff3=100;
detoptions.typefile=0;
detoptions.image=[];
detoptions.imagepar=[];

% path=[matlabroot,filesep,'tracklight',filesep,'parameters',filesep];
% by Cezar M. Tigaret on 24/12/2007
tpath=fileparts(which('trackdiffusion.m'));
save(fullfile(tpath,'parameters','detecoptions.mat'),'detoptions','-mat');
% path=['\MATLAB6p5p1\tracklight\parameters\'];
% save([path,'detecoptions.mat'],'detoptions','-mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
