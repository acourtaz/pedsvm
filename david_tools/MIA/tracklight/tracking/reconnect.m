function [res,resindx]=reconnect(path,file,maxblink,distmax,minTrace,handles,waitbarhandle)
% function [res,resindx]=reconnect(path,file,maxblink,distmax,minTrace,handles,waitbarhandle)
% connecte les traces entre elles.
% path: data folder
% file: .trc file
% maxblink=dur�e maximale entre la derni�re image et la premi�re des deux traces connect�es
% distmax : distance maximale des mol�cules (pxl) entre la derni�re image et la premi�re 
% des deux traces connect�es
% minTrace : dur�e minimum des traces que l'on conserve
% waitbarhandle: to actualize wait bar
%
% from connectrace.m, modified by MR (mar 06) for gaussiantrack.m
% author: LC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

controlf=1;
[namefile,rem]=strtok(file,'.');
% by Cezar M. Tigaret on 23/02/07
% TRCfile=[path,'\trc\',namefile,'.trc'];
TRCfile=[fullfile(path,'trc',namefile),'.trc'];
if length(dir(TRCfile))>0		
      Trc=load(TRCfile);
      disp(['File ' ,TRCfile, ' loaded.']);
   else
      disp(['Couldn''t find .trc file ',TRCfile]);
      Trc = [];
      res=[];
      return
end
if isempty(Trc)==1 
   controlf=0;
      resindx = [];
      res=[];
      disp('Empty .trc file');
      return
end
    
Ntraceinit=max(Trc(:,1));
% by Cezar M. Tigaret on 23/02/07
% str=[path,'\pk\',namefile,'.pk'];
str=[fullfile(path,'pk',namefile),'.pk'];
if length(dir(str))>0		% is there new peakdata?
      pkdata =load(str);
else
      pkdata=[];
end
% by Cezar M. Tigaret on 23/02/07
% str=[path,'\ind\',namefile,'.ind'];
str=[fullfile(path,'ind',namefile),'.ind'];
if length(dir(str))>0		% is there new indexdata? 
      IndexTrc=load(str);
      SIok=1;
else
      IndexTrc=[];
end
nwIdx=[];
clear a;
clear b;
Nt(1)=Ntraceinit+1;

for h=1:Ntraceinit

Points=size(Trc(:,1),1);
Ntrace=max(Trc(:,1));
Nt(h+1)=Ntrace;

if Nt(h+1)~=Nt(h)

Points;
Ntrace;

% trouve les d�but et fin de trace
dfTrc=[];
dfTrc=[dfTrc;[1,Trc(1,:)]];
for i=2:Points-1
    if Trc(i,1)-Trc(i-1,1)==1
    dfTrc=[dfTrc;[i,Trc(i,:)]];
    else
        if Trc(i+1,1)-Trc(i,1)==1
        dfTrc=[dfTrc;[i,Trc(i,:)]];
        end
    end
end
dfTrc=[dfTrc;[Points,Trc(Points,:)]];

% trouve les d�buts de trace
debTrc=[];
debTrc=[debTrc;Trc(1,:)];
for i=2:Points
    if Trc(i,1)-Trc(i-1,1)==1
    debTrc=[debTrc;Trc(i,:)];
    else
    end
end

% trouve les fins de trace
finTrc=[];
for i=1:Points-1
    if Trc(i+1,1)-Trc(i,1)==1
       finTrc=[finTrc;Trc(i,:)];
    end
end
finTrc=[finTrc;Trc(Points,:)];
Ntrace=size(finTrc(:,1),1);

% actualizes waitbar
if exist('waitbarhandle')
   waitbar(h/Ntraceinit,waitbarhandle,['Iteration # ',num2str(h)]);
end

% cr�e la matrice des distances
Dist=zeros(Ntrace,Ntrace);
Dist=Dist+100;
for i=1:Ntrace
    for j=1:Ntrace
        if (j>i & finTrc(i,2)<debTrc(j,2))
           Dist(i,j)=sqrt((finTrc(i,3)-debTrc(j,3))^2+(finTrc(i,4)-debTrc(j,4))^2);
        else
        end
    end
end

%cr�e la matrice des distances minimum entre traces: IdxLesmin contient les indices des traces et les valeurs des distances
Lesmin=zeros(Ntrace,1);
IdxLesmin=[];
for i=1:Ntrace-1
    lespi=find((Dist(i,:)<distmax));
    if ~isempty(lespi)
        lepi=min(lespi);
        Lesmin(i)=Dist(i,lepi);
    else 
        Lesmin(i)=100;
    end
end
Lesmin(Ntrace)=100;
for i=1:Ntrace
    for j=1:Ntrace
        if (Dist(i,j)==Lesmin(i) & Dist(i,j)<100) 
            IdxLesmin=[IdxLesmin;[i,j,Lesmin(i)]]; 
        else
            if (Dist(i,j)==Lesmin(i) & i==j & Dist(i,j)==100)
               IdxLesmin=[IdxLesmin;[i,i,100]]; 
            else
            end
        end
    end
end
IdxLesmin;
temp=Trc;

%Ntrace=size(IdxLesmin(:,1),1)
nwTrc=[];

%test les connections valides. Sinon, connecte la trace avec elle meme
for i=1:Ntrace
    if ((debTrc(IdxLesmin(i,2),2)-finTrc(IdxLesmin(i,1),2))>maxblink | IdxLesmin(i,3)>distmax)
        IdxLesmin(i,2)=IdxLesmin(i,1);
    else
    end
end    

IdxLesmin;

%construit la nouvelle matrice des traces 
for i=1:Ntrace%-1
    nwIdx(i,1)=i;
    if IdxLesmin(i,2)~=IdxLesmin(i,1)
        debuttrace1=dfTrc(2*IdxLesmin(i,1)-1,1); %
        fintrace1=dfTrc(2*IdxLesmin(i,1),1);
        debuttrace2=dfTrc(2*IdxLesmin(i,2)-1,1);
        fintrace2=dfTrc(2*IdxLesmin(i,2),1);
        for k=debuttrace1:fintrace1
            if temp(k,1)==0
            else
                nwTrc=[nwTrc;[i,temp(k,:)]];
                temp(k,1)=0;
            end
        end
        for k=debuttrace2:fintrace2
            if temp(k,1)==0
            else
                nwTrc=[nwTrc;[i,temp(k,:)]];
                temp(k,1)=0;
            end
        end
    else
        debuttrace1=dfTrc(2*IdxLesmin(i,1)-1,1); %
        fintrace1=dfTrc(2*IdxLesmin(i,1),1);
        for k=debuttrace1:fintrace1
            if temp(k,1)==0
            else
                nwTrc=[nwTrc;[i,temp(k,:)]];
                temp(k,1)=0;
            end
        end    
    end
end

%renum�rote les nouvelles traces sans chiffre manquant
Points=size(nwTrc(:,1),1);
tmp=[];
tmp(1)=nwTrc(1,1);
for i=2:Points
    if (nwTrc(i,1)-nwTrc(i-1,1))>0
       tmp(i)=tmp(i-1)+1;
    else
        tmp(i)=tmp(i-1);
    end
end
for i=2:Points
    nwTrc(i,1)=tmp(i);
end

%s�pare r�initialise la trace
clear Trc;
Trc(:,1)=nwTrc(:,1);
Trc(:,2)=nwTrc(:,3);
Trc(:,3)=nwTrc(:,4);
Trc(:,4)=nwTrc(:,5);
Trc(:,5)=nwTrc(:,6);

end %fin du if dans de la boucle sur Nt(h)

end % fin de la boucle sur Nt(h)

% s�lectionne les traces de longueur sup�rieure � minTrace
inddata=traceind(pkdata,Trc);
ntrclen=sum(inddata(:,2:end)>0,2);
nTraceData=[];
Ntracetmp=max(Trc(:,1));
for i=1:Ntracetmp
            if ntrclen(i)>=minTrace %keeps the traces >= minTrace
                k=Trc(Trc(:,1)==i,:);
                nTraceData=[nTraceData;k]; 
            else 
            end
end
Trc=nTraceData;

if size(Trc)>0    
%renum�rote les nouvelles traces sans chiffre manquant
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

%results
nwIdx=traceind(pkdata,Trc);
resindx=nwIdx;
res=Trc;
Ntracefin=max(Trc(:,1));
disp([num2str(Ntraceinit) ' trajectories at the beginning.']);
disp([num2str(Ntracetmp) ' trajectories after reconnection.']);
disp([num2str(Ntracefin) ' trajectories after filtering the short ones (less than ' num2str(minTrace) ' points).']);
disp(' ');
  %report
  text=[num2str(Ntracetmp) ' trajectories after reconnection and ',num2str(Ntracefin) ' trajectories after filtering the short ones (less than ' num2str(minTrace) ' points).'];
  updatereport(handles,text)
else
    disp('No trajectory left with enough number of points.');
      %report
   text=['No trajectory left with enough number of points.'];
   updatereport(handles,text,1)
    res=[];
    resindx=[];
end

% end of file
