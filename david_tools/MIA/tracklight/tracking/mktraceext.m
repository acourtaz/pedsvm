function Trc = mktraceext (Peaks, D, Xmax, Ymax, Opts,waitbarhandle)
% function Trc = mktraceext (Peaks, D, Xmax, Ymax, Opts,waitbarhandle)
% generates a trace from image-tracking data
% input:     Peaks  -     peak-matrix as output of seqfind().
%            D      -     estimated 2-D diffusion coefficient
%                         in units of the Peak-matrix.
%            Xmax,  -     maximal size of the image
%            Ymax
%            Opts   - (o) fitting options 
% output:    Trc - trace of molecules with:
%                  Trc = [#, Image, X-pos, Y-pos]
% modified by MR from: MKTRACE.m (author: ts, version: <02.11> from <950809.0000>
%------------------------------------------------------------


if nargin<5, Opts=[]; end
trace    = [];
Trc      = [];
[Opt,Conf,TOpts] = fitopt ([Opts]);
%TOpts =[Inf 0.0100 0 Inf];
DiffProb = TOpts(2);
OMode=Opt(1);

%clear input-data
%Peaks = clearpk (Peaks,Conf,3); %enlève les doubles peaks et les peaks de largeur>4 pixels et <1 pixels
No_Pk = length(Peaks);
if No_Pk==0, return, end,

%------------------------------------------------------
% loop through the images
ind1 = find(Peaks(:,1)==Peaks(1,1));
Im1  = Peaks(ind1,2:3);
Im0=[]; indb0=[];



for iImage=Peaks(1,1)+1:max(Peaks(:,1))
  ind2 = find(Peaks(:,1)==iImage);
  Im2  = Peaks(ind2,2:3);
% bypass function name conflict; by Cezar M. Tigaret 04/04/08
  cm   = trackFun (Im1,Im2,D,Xmax,Ymax,TOpts,OMode);


  if exist('waitbarhandle')
     waitbar(iImage/max(Peaks(:,1)),waitbarhandle,['Frame # ',num2str(iImage)]);
  end

  %traces
  indc = find(cm(:,3)>=DiffProb & ...
	      cm(:,1)<=length(ind1) & cm(:,2)<=length(ind2));
  if (length(indc>0))
    trace = [trace;ind1(cm(indc,1)),ind2(cm(indc,2)),cm(indc,3)];
  end
  indr  = cm(find((cm(:,1)>length(ind1)&cm(:,2)<=length(ind2)) | ...
		  (cm(:,1)<=length(ind1)&cm(:,2)<=length(ind2)& ...
		   cm(:,3)<DiffProb)),2);
  indb1 = cm(find((cm(:,1)<=length(ind1)&cm(:,2)>length(ind2)) | ...
		  (cm(:,1)<=length(ind1)&cm(:,2)<=length(ind2)& ...
		   cm(:,3)<DiffProb)),1);

  %recovering peaks
% bypass function name conflict; by Cezar M. Tigaret 04/04/08
  cr = trackFun (Im0(indb0,:),Im2(indr,:),4*D,Xmax,Ymax,TOpts,OMode);
  indcr = find(cr(:,3)>DiffProb & ...
	       cr(:,1)<=length(indb0) & cr(:,2)<=length(indr));
  if (length(indcr>0))
    trace = [trace;ind0(indb0(cr(indcr,1))),ind2(indr(cr(indcr,2))), ...
             cr(indcr,3)];
  end

  indb0 = indb1;
  ind0  = ind1;
  ind1  = ind2;
  Im0   = Im1;
  Im1   = Im2;
end

%--------------------------------------------------------
% loop through the traces
ipk=0;

while (length(trace)>0)
  ipk  = ipk+1;
  npos = trace(1,2);
  Trc  = [Trc;ipk,Peaks(trace(1,1),1:3),trace(1,3)];
  Trc  = [Trc;ipk,Peaks(npos,1:3),-1];
  trace(1,:) = [];
  if isempty(trace) break, end
  indx = find(trace(:,1)==npos);
  while ~isempty(indx)
    Trc(size(Trc,1),5) = trace(indx,3);
    npos = trace(indx,2);
    Trc  = [Trc;ipk,Peaks(npos,1:3),-1];
    trace(indx,:) = [];
    if isempty(trace) break, end
    indx = find(trace(:,1)==npos);
  end

  %calculate bleaching probability
  nb = size(Trc,1);
% bypass function name conflict; by Cezar M. Tigaret 04/04/08
  [tb,zb] = trackFun (Trc(nb,3:4),Trc(nb,3:4),D,Xmax,Ymax,[inf,TOpts(2:4)],OMode);
  if zb(1,2)>DiffProb
    Trc(nb,5) = zb(1,2);
  end
  if exist('waitbarhandle')
     waitbar(ipk/max(Peaks(:,1)),waitbarhandle,['Please wait...']);
  end

end



% Nested function wrapper to bypass the name conflict with track.m
% routine by David Perrais 
% by Cezar M. Tigaret 04/04/08
function varargout=trackFun(varargin)
  trackpath=fileparts(which('trackdiffusion.m'));
  currentDir=pwd;
  cd(fullfile(trackpath,'ScriptsLC','FnCommunes'));
  [a,b]=track(varargin{:});
  cd(currentDir);
  switch(nargout)
    case 1
      varargout{1}=a;
    case 2
      varargout{1}=a;
      varargout{2}=b;
  end;
end

end

