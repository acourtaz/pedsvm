function res=blinkingLC(file,maxblink,distmax,mintrace,handles,waitbarhandle)
% function  res=blinking(file,maxblink,distmax,mintrace,handles,waitbarhandle)
%  connecte les traces entre elles.
% path: data folder
% file: .trc file made by MIA
% maxblink=dur?e maximale entre la derni?re image et la premi?re des deux traces connect?es
% distmax : distance maximale des mol?cules (pxl) entre la derni?re image et la premi?re 
% des deux traces connect?es
% minTrace : dur?e minimum des traces que l'on conserve
% waitbarhandle: to actualize wait bar
%
% from connectraceMIA.m, modified by MR (mar 06) for gaussiantrack.m
% author: LC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<1, help blinking, return, end

warning off MATLAB:MKDIR:DirectoryExists
controlf=1;

if length(dir(file))>0		
      TrcInit=load(file);
      disp(['File ' ,file, ' loaded.']);
   else
      disp(['Couldn''t find MIA.trc file ',file]);
      TrcInit = [];
      res=[];
      controlf=0;
end

if controlf==1

%%%%%%%%On va maintenant travailler sur une matrice all?g?e des traces qui ne contient que les d?buts et fins des traces
Points=size(TrcInit(:,1),1);
Ntrace=max(TrcInit(:,1));

TrcShort=[];
TrcShort=[TrcShort;[TrcInit(1,:),1]];
for i=2:Points-1
    if (TrcInit(i,1)-TrcInit(i-1,1)==0 & TrcInit(i+1,1)-TrcInit(i,1)==0)
    else
    TrcShort=[TrcShort;[TrcInit(i,:),i]];
    end
end
TrcShort=[TrcShort;[TrcInit(Points,:),Points]];
%
Trc=TrcShort;
NPoints=size(Trc(:,1),1);
%Trc
%disp(['On travaille sur ' num2str(NPoints), ' points, au lieu de ' num2str(Points), ' en n''utilisant que les d?buts et fins de traces']);

% d?but de la reconnection
Ntraceinit=max(Trc(:,1));

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

% trouve les d?but et fin de trace
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

% trouve les d?buts de trace
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
%disp(['Num?ro de la passe : ' num2str(h)]);
% actualizes waitbar
if exist('waitbarhandle')
   waitbar(h/Ntraceinit,waitbarhandle,['Iteration # ',num2str(h)]);
end

% cr?e la matrice des distances
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

%cr?e la matrice des distances minimum entre traces: IdxLesmin contient les indices des traces et les valeurs des distances
Lesmin=zeros(Ntrace,1);
IdxLesmin=[];
for i=1:Ntrace-1
    lespi=find((Dist(i,:)<distmax));
    if ~isempty(lespi)
        lepi=min(lespi);
        Lesmin(i)=Dist(i,lepi);
        clear lepi;
        clear lespi;
    else 
        Lesmin(i)=100;
    end
end

Lesmin(Ntrace)=100;
%Lesmin

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

%renum?rote les nouvelles traces sans chiffre manquant
newPoints=size(nwTrc(:,1),1);
tmp=[];
tmp(1)=nwTrc(1,1);
for i=2:newPoints
    if (nwTrc(i,1)-nwTrc(i-1,1))>0
       tmp(i)=tmp(i-1)+1;
    else
        tmp(i)=tmp(i-1);
    end
end
for i=2:newPoints
    nwTrc(i,1)=tmp(i);
end

%s?pare r?initialise la trace
clear Trc;
Trc(:,1)=nwTrc(:,1);
Trc(:,2)=nwTrc(:,3);
Trc(:,3)=nwTrc(:,4);
Trc(:,4)=nwTrc(:,5);
Trc(:,5)=nwTrc(:,6);
Trc(:,6)=nwTrc(:,7);
Trc(:,7)=nwTrc(:,8);

clear nwTrc
end %fin du if dans de la boucle sur Nt(h)

end % fin de la boucle sur Nt(h)

%disp(['Patience ! Avancement de l''?criture de la matrice finale de traces ... ']);

% s?lectionne les traces de longueur sup?rieure ? minTrace
Ntracereconnect=max(Trc(:,1));
Np=newPoints/2;
numTrace=1;
longTrc=0;
tempoTrc=[];
tempo=[];
longTrc=zeros(Ntrace,2); %%% va contenir le num?ro de la trace et la longueur de la trace

for i=1:Np
longTrc(numTrace,1)=numTrace;
    if Trc(2*i,1)==numTrace
    longTrc(numTrace,2)=longTrc(numTrace,2)+Trc(2*i,7)-Trc(2*i-1,7)+1;
    else
    numTrace=numTrace+1;
    longTrc(numTrace,2)=longTrc(numTrace,2)+Trc(2*i,7)-Trc(2*i-1,7)+1;
    
    end
end
longTrc(Ntrace,1)=Ntrace;
%longTrc : matrice de la longueur des traces

for i=1:newPoints
   if longTrc(Trc(i,1),2)>mintrace
       tempoTrc=[tempoTrc;[Trc(i,:)]];
   end
end
Trc=tempoTrc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if size(Trc)>0    
%renum?rote les nouvelles traces sans chiffre manquant
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

%%%%%%%%%%%%%%%%refabrique la matrice compl?te des traces ? partir de trace
NPoints=size(Trc(:,1),1);
Np=NPoints/2;
fullTrc=[];
for i=1:Np
    debut=Trc(2*i-1,7);
    fin=Trc(2*i,7);
    for j=debut:fin
        fullTrc=[fullTrc;[Trc(2*i-1,1),TrcInit(j,2:6)]];
    end
end
%disp(['On r?cup?re ' num2str(size(fullTrc(:,1),1)), ' points qui constituent les traces de d?part, apr?s filtrage des traces trops courtes.']);

%resindx=nwIdx;
res=fullTrc;

Ntracefin=max(fullTrc(:,1));
%disp([num2str(Ntraceinit) ' traces au d?part.']);
%disp([num2str(Ntracereconnect) ' traces apr?s reconnection.']);
%disp(['Finalement, ' num2str(Ntracefin) ' traces apr?s filtrage des traces trop courtes (inf?rieures ? ' num2str(minTrace) ' points).']);
disp([num2str(Ntraceinit) ' trajectories at the beginning.']);
disp([num2str(Ntracereconnect) ' trajectories after reconnection.']);
disp([num2str(Ntracefin) ' trajectories after filtering the short ones (less than ' num2str(mintrace) ' points).']);
disp(' ');
  %report
  text=[num2str(Ntracereconnect) ' trajectories after reconnection and ',num2str(Ntracefin) ' trajectories after filtering the short ones (less than ' num2str(mintrace) ' points).'];
  updatereport(handles,text)

else
    disp('No trajectory left with enough number of points.');
    text=['No trajectory left with enough number of points.'];
   updatereport(handles,text,1)
    res=[];
end

end

% end of file
