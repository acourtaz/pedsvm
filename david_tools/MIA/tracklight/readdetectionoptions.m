function [options,cutoffs]=readdetectionoptions

%loadoptions=0;

%while loadoptions=0
    
% by Cezar M. Tigaret on 24/12/2007
tpath=fileparts(which('trackdiffusion.m'));
pathdet=fullfile(tpath, 'parameters','detecoptions.mat');
% path=['\MATLAB6p5p1\tracklight\parameters\'];
% pathdet=[path,'detecoptions.mat'];

if length(dir(pathdet))>0
    
det=load(pathdet);
detopt = struct2cell(det);
detoptions=detopt{1};

options(1)=detoptions.output;
options(2)=detoptions.minchi;
options(3)=detoptions.mindchi;
options(4)=detoptions.minparvar;
options(5)=detoptions.loops;
options(6)=detoptions.lamba;
options(7)=detoptions.widthgauss;
options(8)=detoptions.widthimagefit;
options(9)=detoptions.threshold;
options(10)=detoptions.fit;
options(11)=detoptions.confchi;
options(12)=detoptions.confexp;
options(13)=detoptions.confF;
options(14)=detoptions.bleach;
options(15)=detoptions.difProb;
options(16)=detoptions.concentr;
options(17)=detoptions.recover;
options(18)=detoptions.pixels;

cutoffs(1)=detoptions.cutoff1;
cutoffs(2)=detoptions.cutoff2;
cutoffs(3)=detoptions.cutoff3;

loadoptions=1;

else
    setdetectionoptions; %default
end;

%end;
