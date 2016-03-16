function [options,cutoffs] = calibrate (Image, ImagePar,thres,handles,typefile)
% function [options,cutoffs] = calibrate (Image, ImagePar,thres,handles,typefile)
% displays SubImage and detects peaks
% allows changing parameters
% in blue, all the detected peaks
% in red, the peaks left after cutoffs
% 
% MR - fev 06 - v 1.0  -  for gaussiantrack.m                                          MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[options,cutoffs]=readdetectionoptions; % default: file detecoptions.mat

% parameters and variables
cutoffs(1)=str2num(get (handles.edit9,'string'));
cutoffs(2)=str2num(get (handles.edit8,'string'));
cutoffs(3)=str2num(get (handles.edit10,'string'));

% creates file .mat with detection/cutoffs for calibrationgui.m
detoptions.output=options(1);
detoptions.minchi=options(2);
detoptions.mindchi=options(3);
detoptions.minparvar=options(4);
detoptions.loops=options(5);
detoptions.lamba=options(6);
detoptions.widthgauss=options(7);
detoptions.widthimagefit=options(8);
detoptions.threshold=str2num(get (handles.threshold,'string')); % threshold
detoptions.fit=options(10);
detoptions.confchi=options(11);
detoptions.confexp=options(12);
detoptions.confF=options(13);
detoptions.bleach=options(14);       
detoptions.difProb=options(15);
detoptions.concentr=options(16);
detoptions.recover=options(17);
detoptions.pixels=options(18);
detoptions.cutoff1=cutoffs(1);
detoptions.cutoff2=str2num(get (handles.edit8,'string')); % max intensity
detoptions.cutoff3=cutoffs(3);
detoptions.typefile=typefile; %.spe or .stk
detoptions.image=Image; % datamatrix movie
detoptions.imagepar=ImagePar; % image parameters

%gui
varargout=calibrationgui(detoptions);
uiwait;
clear Image;

%new values
tpath=fileparts(which('trackdiffusion.m'));       % CMT - 05/11/2007
mypath=fullfile(tpath,'parameters');              % CMT - 05/11/2007
pathdet=fullfile(mypath,'detecoptions.mat');      % CMT - 05/11/2007
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
options(18)=detoptions.pixels;
cutoffs(1)=detoptions.cutoff1;
cutoffs(2)=detoptions.cutoff2;
cutoffs(3)=detoptions.cutoff3;

clear det, detopt;

% end of file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

