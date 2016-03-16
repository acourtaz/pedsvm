function [Peaks]=doseqext (Image,ImagePar, D, SeqLen, Opts,typefile,waitbarhandle)
% function [Peaks]=doseqext (Image,ImagePar, D, SeqLen, Opts,typefile,waitbarhandle)
% Complete evaluation of the image-file <file>:
% (i)   the particles are recognized (seqfind())
% (ii)  initial traces are generated 
% Image   -    data
% ImagePar - image parameters
% D      -(o) estimated diffusion coefficient
% SeqLen -(o) length of a sequence
% Opts   -(o) fitting and output options
% typefile: .spe or .stk
% waitbarhandle: to actualize waitbar
% Peaks: peaks found
% alltrace: initial trajectories (peaks before cutoffs!!)
% Modify from: doseq.m by MR (mar 06) for gaussiantrack.m
% author:  ts
%--------------------------------------------------------------------------
Conf = Opts(11:13);
nSeq    = ImagePar(4);
Xmax= ImagePar(1);
Ymax= ImagePar(2)/nSeq;

%recognize peaks 
Peaks = seqfindext (Image, ImagePar, Opts,typefile,waitbarhandle);
if Peaks==0 
   Peaks=[];
  % AllTrace = [];
   return
end

%disp('  ');
%disp('Doing tracking...');

%generate traces and index file
%Iend   = max(Peaks(:,1));
%Iseq = fix(min(Peaks(:,1))/nSeq)*nSeq+1;
%Itrc = 0;
%AllTrace = [];

%while Iseq<Iend 
 % SeqPk = Peaks(find((Peaks(:,1)>=Iseq)&(Peaks(:,1)<Iseq+nSeq)),:);
 % Peaks = clearpk (SeqPk,Conf,3); %enlève les doubles peaks et les peaks de largeur>4 pixels et <1 pixels

 % SeqTrc = mktraceext (SeqPk, D, Xmax, Ymax, Opts);

 % if length(SeqTrc)>0
 %   SeqTrc(:,1) = SeqTrc(:,1)+Itrc;
 %   AllTrace = [AllTrace; SeqTrc];
 %   IAllTrace=AllTrace(:,1);
%    Itrc = max(AllTrace(:,1));
% end
 % Iseq = Iseq+nSeq;
 %end

%-------------------------------------------------
