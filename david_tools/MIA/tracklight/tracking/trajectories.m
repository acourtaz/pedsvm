function [TraceData,inddata] = trajectories (file, p, D, cutoffs, Opts,handles,waitbarhandle)
% function [TraceData,inddata] = trajectories (file, p, D, cutoffs, Opts,handles,waitbarhandle)
% clrear peaks with cutoffs and calls mktraceext
%
% from redotrace (LC), for detectrack (gaussiantrack.m)
% MR mar 06 - v1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Xdim=p(1);
Ydim=p(2)/p(4);
clear  p;
[namefile,rem]=strtok(file,'.');  % sin extension
savename=[file];
pkdata=[];
maxim=0;
% by Cezar M. Tigaret on 23/02/2007
% str=['pk\',namefile,'.pk'];
str=['pk',filesep,namefile,'.pk'];
if length(dir(str))>0		% is there new peakdata?
      Spkdata =load(str);
      SPok=1;
else
      Spkdata=[];
      SPok=0;
end
if SPok>0
      Spkdata(:,1)=Spkdata(:,1)+maxim;		% new imagenumber
end
   pkdata=[pkdata; Spkdata];
if ~isempty(pkdata)
      maxim=max(pkdata(:,1))+20;
end
antes=size(pkdata,1);
disp(['There are ',num2str(antes),' peaks before cutoffs.']);

% clear peaks
pkdata=clearpkTL(pkdata,1,3,Opts(18)); % vire les peaks dont les largeurs sont en dehors de [1., opts(18)]
pkind = find(pkdata(:,10)<(pkdata(:,5)*cutoffs(1)) & pkdata(:,5)> 0 & pkdata(:,5)< cutoffs(2)) ;
pkdata = pkdata(pkind,:);
disp(['After cutoffs there are ',num2str(size(pkdata,1)),' peaks left.']);
if nargin==6
    text=[num2str(antes),' peaks were detected in total and there are ',num2str(size(pkdata,1)),' peaks left after cutoffs.'];
    updatereport(handles,text)
end

% from SEQTRACE
nSeq=max(pkdata(:,1));
Xmax=Xdim;
Ymax=Ydim;
TraceData=[];
Iend   = max(pkdata(:,1));
Iseq = fix(min(pkdata(:,1))/nSeq)*nSeq+1;
Itrc = 0;
while Iseq<Iend 
  SeqPk = pkdata(find((pkdata(:,1)>=Iseq)&(pkdata(:,1)<Iseq+nSeq)),:);
  options(1:17)=Opts(1:17);
  SeqTrc = mktraceext (SeqPk, D, Xmax, Ymax, options,waitbarhandle);
  if length(SeqTrc)>0
    SeqTrc(:,1) = SeqTrc(:,1)+Itrc;
    TraceData = [TraceData; SeqTrc];
    IAllTrace=TraceData(:,1);
    Itrc = max(TraceData(:,1));
  end
  Iseq = Iseq+nSeq;
end
if isempty(TraceData)==0
	NTrace = max(TraceData(:,1));
    inddata=traceind(pkdata,TraceData);
    ntrclen=sum(inddata(:,2:end)>0,2);
    nTracedata=[];
    ok=0;
else
    disp(' no trajectories left...')
    inddata=[];
end


%end of file
	
