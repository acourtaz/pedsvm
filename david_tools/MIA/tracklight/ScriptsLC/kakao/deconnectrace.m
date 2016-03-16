function res=deconnectrace(file,msdflag,minTrace)

% function res=deconnectrace(file,msdflag,minTrace) est utilis�dans affectsynapses
% 
% redeconnecte les traces pour les s�arer en portions de meme localization (synapse, peri, extra) apr� avoir appel�connectrace et synapses
% les synapses doivent avoir ��affect�s aux traces par cr�s par affectsynapse (extension .spe.syn.trc)
% cr� une nouvelle matrice des traces (trc/cut/file.spe.syn.trc) et les msd correspondants (msd/cut/file.spe.msd)
%
% file: fichier.spe


if nargin<1, help deconnectrace, return, end
if nargin<2, msdflag=0, end
if nargin<3, minTrace=3, end
    
global MASCHINE

%DoIt  = ['load trc\',file,'.syn.trc'];

% by Cezar M. Tigaret on 23/02/07
% str=['trc\',file,'.con.syn.trc'];
str=['trc',filesep,file,'.con.syn.trc'];
if length(dir(str))>0		
      Trc =load(str);
end

% str=['pk\',file,'.pk'];
str=['pk',filesep,file,'.pk'];
      if length(dir(str))>0
      pkdata =load(str);
      end

Ntraceinit=max(Trc(:,1));
Points=size(Trc(:,1),1);

% disp([' On a, avant d�oupage ', Num2str(Ntraceinit), ' traces, soit ', Num2str(Points), ' points.' ]);
disp([' On a, avant d�oupage ', num2str(Ntraceinit), ' traces, soit ', num2str(Points), ' points.' ]);

nwTrc=Trc;

% d�oupe
curTrc=nwTrc(4,1);

for i=4:Points-1
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


Ntracefinal=max(nwTrc(:,1));
% disp([' Le d�oupage cr� ', Num2str(Ntracefinal), ' traces, soit ', Num2str(Points), ' points.' ]);
disp([' Le d�oupage cr� ', num2str(Ntracefinal), ' traces, soit ', num2str(Points), ' points.' ]);

Trc=nwTrc;
% s�ectionne les traces de longueur sup�ieure �minTrace
    inddata=traceind(pkdata,Trc(:,1:5)); % Trc(:,1:5): traces sans synapse
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
%renum�ote les nouvelles traces sans chiffre manquant
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


%cr� les indices
nwIdx=traceind(pkdata,Trc(:,1:5));

% r�ultat final
resindx=nwIdx;
res=Trc;

Ntracefin=max(Trc(:,1));
% disp(['Finalement, il reste ' Num2str(Ntracefin) ' traces de longueur sup�ieure �' Num2str(minTrace) ' points).']);
disp(['Finalement, il reste ' num2str(Ntracefin) ' traces de longueur sup�ieure �' num2str(minTrace) ' points).']);
disp(' ');


if msdflag==1
    [msddata, fullmsddata]=newMSD(res,150); %%%%%%%%%%% !!! MSD de 150 points au max

% by Cezar M. Tigaret on 23/02/07
    if length(dir([filesep,'trc',filesep,'cut']))==0 
        warning off MATLAB:MKDIR:DirectoryExists;
        mkdir([filesep,'trc',filesep,'cut']); mkdir([filesep,'msd',filesep,'cut']);
		disp(['Les traces et msd coup� sont sauv�s dans: ',filesep,'trc',filesep,'cut and ',filesep,'msd',filesep,'cut ');
    else           
    end
% by Cezar M. Tigaret on 23/02/07
    save(['trc',filesep,'cut',filesep,file,'.deco.syn.trc'],'res','-ascii'); 
    save(['msd',filesep,'cut',filesep,file,'.deco.syn.msd'],'msddata','-ascii'); 
    %%%%converti pour msd turbo
            filetxt=['trc',filesep,'cut',filesep,file,'.deco.syn.trc'];% by Cezar M. Tigaret on 23/02/07
            fi = fopen(filetxt,'w');
            if fi<3
              error('File not found or readerror.');
            else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.2f\r',res');
            end
            % close
            fclose(fi);
    %%%%%%%%%%fin conversion

else
% by Cezar M. Tigaret on 23/02/07
    if length(dir([filesep,'trc',filesep,'cut']))==0
        warning off MATLAB:MKDIR:DirectoryExists;
   		mkdir([filesep,'trc',filesep,'cut']);
		disp(['Les traces sont sauv�s dans: ',filesep,'trc',filesep,'cut']);
    else           
    end
    save(['trc',filesep,'cut',filesep,file,'.deco.syn.trc'],'res','-ascii'); 
    %%%%converti pour msd turbo
            filetxt=['trc',filesep,'cut',filesep,file,'.deco.syn.trc']; % by Cezar M. Tigaret on 23/02/07
            fi = fopen(filetxt,'w');
            if fi<3
              error('File not found or readerror.');
            else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.2f\r',res');
            end
            % close
            fclose(fi);
    %%%%%%%%%%fin conversion
    disp('!!! Les msd ne sont pas calcul� : il faut l''option msdflag=1 pour les calculer');
end
else
    disp(' !!!!!!!!!!!!!! R�ultat: il ne reste plus de trace de longueur suffisante');
end