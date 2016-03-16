function res=deconnect(file,handles)
% function res=deconnect(file,handles) 
% redeconnecte les traces pour les s???parer en portions de meme localization (synapse, peri, extra) 
% les domains doivent avoir ???t??? affect???es aux traces (extension .spe.MIA.syn.trc)
%
% Modified from deconnectrace.m by MR (mar 06) for gaussiantrack.m
% author: LC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>1
    filename=handles.file;
    [namefile,rem]=strtok(filename,'.');
%      waitbarhandle=waitbar( 0,'Please wait...','Name',['Cutting trajectories in ',namefile]);
else
%      waitbarhandle=waitbar( 0,'Please wait...','Name',['Cutting trajectories']);
end

Trc =file;
%  save('Trc_Deconnect', 'Trc', '-ascii');
% 
if (~isempty(Trc)) 
  Ntraceinit=max(Trc(:,1));
  Points=size(Trc(:,1),1);
  disp(['Before cutting there are ', num2str(Ntraceinit), ' trajectories (', num2str(Points), ' points).' ]);
  nwTrc=Trc;

  curTrc=nwTrc(4,1);
  
%% decoupure vecteurizee
  % % CMT - 02/11/2007
  
  kays=4:Points-1;
  d1=sparse(Trc(kays,6)==Trc(kays-1,6));                    % % Trc(i,6)   ==  Trc(i-1,6)
  d2=sparse(Trc(kays+1,6)==Trc(kays-1,6));                  % % Trc(i+1,6) ==  Trc(i-1,6)
  d3=sparse(Trc(kays,1)==Trc(kays-1,1));                    % % Trc(i,1)   ==  Trc(i-1,1)
  d4=sparse(Trc(kays,6)==Trc(kays-2,6));                    % % Trc(i,6)   ==  Trc(i-2,6)
  d5=sparse(Trc(kays,6)==Trc(kays-3,6));                    % % Trc(i,6)   ==  Trc(i-3,6)
  
  c1 = (d1 | d2) & d3;
  c2 = (d4 & d5) & d3;
  c3 = d5 & d3;
  c = (c1 |c2 | c3);
  nays = find(~c);
  nwTrc(nays+3,1)=[1:length(kays(nays))]+curTrc;
  trNew=ones(Points,1);                         % enforce monotonic increasing
  trTmp=trNew;                                  % trace numbers
  trNew(nays+3)=[1:length(kays(nays))]+curTrc;  
  ndx=find(trNew(:,1)>1);
% can't bypass a for `loop' here; luckily, is just an iteration over boundaries
% between traces (trace numbers), so unless the trace length is ridiculously
% short and the number of traces is ridiculously large, this `for' loop will 
% not deteriorate performance to a noticeable degree.
disp('Please wait: deconnecting new trajectories...');
  for (i=1:length(ndx))
% %     foggeddaboudit! waitbar just slows things down by about 30 times !!!
%     if exist('waitbarhandle')
%       waitbar(i/(length(ndx)),waitbarhandle,['Deconnecting trace # ',num2str(i)]);
%     end;
    trNew(ndx(i):end)=trTmp(ndx(i):end).*nwTrc(ndx(i),1);
  end;
  nwTrc(:,1)=trNew;
  clear c c1 c2 c3 d1 d2 d3 d4 d5 kays nays ndx trNew trTmp;
  nwTrc(Points,1)=nwTrc(Points-1,1);
  % %  CMT - 02/11/2007
  
%    for i=4:Points-1
%        if exist('waitbarhandle')
%              waitbar(i/(Points-1),waitbarhandle,['Row # ',num2str(i)]);
%          end
%      if ((Trc(i,6)==Trc(i-1,6) | Trc(i+1,6)==Trc(i-1,6)) & Trc(i,1)==Trc(i-1,1))
%         nwTrc(i,1)=nwTrc(i-1,1);
%      else
%         if ((Trc(i,6)==Trc(i-2,6) & Trc(i,6)==Trc(i-3,6)) & Trc(i,1)==Trc(i-1,1))
%            nwTrc(i,1)=nwTrc(i-1,1);
%         else
%             if (Trc(i,6)==Trc(i-3,6) & Trc(i,1)==Trc(i-1,1))
%                nwTrc(i,1)=nwTrc(i-1,1);
%            else
%                curTrc=curTrc+1;
%                nwTrc(i,1)=curTrc;
%            end   
%         end
%      end
%    end

%   nwTrc(Points,1)=nwTrc(Points-1,1);
  
  
  Trc=nwTrc;
  Ntracefinal=max(Trc(:,1));
  disp(['After cutting there are ', num2str(Ntracefinal), ' trajectories (', num2str(Points), ' points).']);
  if nargin==2
    text=['Before cutting there are ', num2str(Ntraceinit), ' trajectories; cutting created ', num2str(Ntracefinal), ' trajectories (', num2str(Points), ' points).'];
    updatereport(handles,text)
  end

%% consolidate trace numbering
  % %   The following is not required anymore; it was just to make sure there is
% no discontinuity in trace numbering. Frankly speaking, the trick with trcNew
% and trcTmp above ensures that all traces are numbered in monotonic increasing
% order.


%   if size(Trc)>0    
%      %renumerote les nouvelles traces sans chiffre manquant
%      Points=size(Trc(:,1),1);
%      %% renumerotation vectorizee
%      % %  CMT - 02/11/2007
%      kays=2:Points;
%      c=(Trc(kays,1)-Trc(kays-1,1))>0;
%      tmp=ones(Points,1);
%      tmp(1)=Trc(1,1);
% %      t2=ones(Points,1);
%      eyes=find(c);
%      t2=1:length(eyes);
%      nays=find(~c);
%      
%      tmp(nays+1)=tmp(nays);
%      
%      d=sparse(diff(Trc(:,1))>0);
%      eyes=find(d);
%      nays=find(~d);
%      tmp(eyes+1)=tmp(eyes)+t2';
%      tmp(nays+1)=tmp(nays);
%      clear c d eyes kays nays;
%      Trc(:,1)=tmp-(tmp(1)+1);
%      % %  CMT - 02/11/2007

%       tmp=[];
%       tmp(1)=Trc(1,1);
%       for i=2:Points
%          if (Trc(i,1)-Trc(i-1,1))>0
%             tmp(i)=tmp(i-1)+1;
%          else
%             tmp(i)=tmp(i-1);
%          end
%       end
% 
%       for i=1:Points
%          Trc(i,1)=tmp(i)-tmp(1)+1;
%      end
%   end
  
  % resultat final
  res=Trc;

else
  res=[];
end

%  if exist('waitbarhandle')
%      close(waitbarhandle);
%  end


% end of file
