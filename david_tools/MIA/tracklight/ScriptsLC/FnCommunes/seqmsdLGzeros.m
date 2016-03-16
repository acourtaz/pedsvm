 function  MeanD = seqmsdLGzeros (file)
%--------------------------------------------------------
% SEQMSDLG.M
% Initialise avec des z�os dans les fichiers de MSD pour chaque trace the traces
% in the input-file. The result is stored in <file>.msd
%
% call: MeanD =  seqmsdLGzeros (file)
%
% input: file   - path of the image-file. The trace is found in
%                 <file>.trc
%
% output:   the output ist stored in the file
%           <file>.msd - zeros for each trace
%           MeanD - average diffusion constant for timelag 1 of all traces
%
% 
%
%
% date:    30.7.1994
% author:  ts
% version: <01.02> from <000330.0000>
% modified from seqMSD LC 22 05 03
%--------------------------------------------------------
if nargin<1, help seqmsd, return, end
global MASCHINE

if strcmp(MASCHINE(1:2),'AT')
  DoIt  = ['load trc',filesep,file]
elseif strcmp(MASCHINE(1:2),'PC')
  DoIt  = ['load trc',filesep,file,'.trc']
else
  DoIt  = ['load ',file,'.trc']
end
eval(DoIt)
TrcName = file(1:find(file=='.')-1);
TrcName(TrcName=='-')='_';	% no '-' in variable names allowed => use '_' instead
Trc=eval(TrcName);


MSqDispl = zeros(3,4);
MeanD=zeros(3,4);


if strcmp(MASCHINE(1:2),'AT')
  DoIt  = ['save msd',filesep,file,' MSqDispl -ascii']
elseif strcmp(MASCHINE(1:2),'PC')
  DoIt  = ['save msd',filesep,file,'.msd MSqDispl -ascii']
else
  DoIt = ['save ', file, '.msd MSqDispl /ascii']
end
eval(DoIt)
