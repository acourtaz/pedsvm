function res=deconnectLC(file,handles)
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
    waitbarhandle=waitbar( 0,'Please wait...','Name',['Cutting trajectories in ',namefile]);
else
    waitbarhandle=waitbar( 0,'Please wait...','Name',['Cutting trajectories']);
end

Trc =file;
% 
if (~isempty(Trc)) 
%% init code 
   Ntraceinit=max(Trc(:,1));
   Points=size(Trc(:,1),1);
   disp(['Before cutting there are ', num2str(Ntraceinit), ' trajectories (', num2str(Points), ' points).' ]);
   nwTrc=Trc;

%% decoupe
  curTrc=nwTrc(4,1);
  for i=4:Points-1
      if exist('waitbarhandle')
            waitbar(i/(Points-1),waitbarhandle,['Row # ',num2str(i)]);
        end
    if ((Trc(i,6)==Trc(i-1,6) | Trc(i+1,6)==Trc(i-1,6)) & Trc(i,1)==Trc(i-1,1))
       nwTrc(i,1)=nwTrc(i-1,1);
    else
       if ((Trc(i,6)==Trc(i-2,6) & Trc(i,6)==Trc(i-3,6)) & Trc(i,1)==Trc(i-1,1))
          nwTrc(i,1)=nwTrc(i-1,1);
       else
           if (Trc(i,6)==Trc(i-3,6) & Trc(i,1)==Trc(i-1,1))
              nwTrc(i,1)=nwTrc(i-1,1);
          else
              curTrc=curTrc+1;
              nwTrc(i,1)=curTrc;
          end   
       end
    end
  end
  nwTrc(Points,1)=nwTrc(Points-1,1);
  Trc=nwTrc;
  Ntracefinal=max(Trc(:,1));
  disp(['After cutting there are ', num2str(Ntracefinal), ' trajectories (', num2str(Points), ' points).']);
  if nargin==2
    text=['Before cutting there are ', num2str(Ntraceinit), ' trajectories; cutting created ', num2str(Ntracefinal), ' trajectories (', num2str(Points), ' points).'];
    updatereport(handles,text)
  end

%% renum???rote les nouvelles traces sans chiffre manquant
  if size(Trc)>0    
     Points=size(Trc(:,1),1);
     tmp=[];
     tmp(1)=Trc(1,1);
     for i=2:Points
        if (Trc(i,1)-Trc(i-1,1))>0
           tmp(i)=tmp(i-1)+1;
        else
           tmp(i)=tmp(i-1);
        end
     end
     for i=1:Points
        Trc(i,1)=tmp(i)-tmp(1)+1;
    end
  end
  
  % r???sultat final
  res=Trc;

else
  res=[];
end

if exist('waitbarhandle')
    close(waitbarhandle);
end


% end of file
