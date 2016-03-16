function res=deconnectraceMIA(file,msdflag)

% function res=deconnectraceMIA(file,msdflag) est utilis�dans affectsynapses
% 
% redeconnecte les traces pour les s�arer en portions de meme localization (synapse, peri, extra) apr� avoir appel�connectrace et synapses
% les synapses doivent avoir ��affect�s aux traces par cr�s par affectsynapseMIA (extension .spe.MIA.syn.trc)
% cr� une nouvelle matrice des traces (trc/cut/file.spe.syn.trc) et les msd correspondants (msd/cut/file.spe.msd)
%
% file: fichier.spe


if nargin<1, help deconnectraceMIA, return, end
if nargin<2, msdflag=0, end

    
global MASCHINE


% by Cezar M. Tigaret on 23/02/07
% str=['trc\' ,file, '.MIA.con.syn.trc'];
str=['trc',filesep ,file, '.MIA.con.syn.trc'];
if length(dir(str))>0		
      Trc =load(str);
end

Ntraceinit=max(Trc(:,1));
Points=size(Trc(:,1),1);

% by Cezar M. Tigaret on 23/02/07
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

Trc=nwTrc;
Ntracefinal=max(Trc(:,1));
% disp([' Le d�oupage cr� ', Num2str(Ntracefinal), ' traces, soit ', Num2str(Points), ' points.' ]);
disp([' Le d�oupage cr� ', num2str(Ntracefinal), ' traces, soit ', num2str(Points), ' points.' ]);

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



% r�ultat final
res=Trc;



if msdflag==1
    disp([' Calcul du MSD...' ]);
    [msddata, fullmsddata]=newMSD(res,150); %%%%%%%%%%% !!! MSD de 150 points au max

    if length(dir('/trc/cut'))==0
        warning off MATLAB:MKDIR:DirectoryExists;
        mkdir('/trc/cut'); mkdir('/msd/cut');
		disp('Les traces et msd coup� sont sauv�s dans: /trc/cut and /msd/cut ');
    else           
    end
    save(['trc\cut\',file,'.MIA.deco.syn.trc'],'res','-ascii','-tabs');
    %%%%converti pour msd turbo
            filetxt=['trc\cut\',file,'.MIA.deco.syn.trc'];
            fi = fopen(filetxt,'w');
            if fi<3
              error('File not found or readerror.');
            else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f %6.2f %6.8f\r',res');
            end
            % close
            fclose(fi);
    %%%%%%%%%%fin conversion
    save(['msd\cut\',file,'.MIA.deco.syn.msd'],'msddata','-ascii'); 
else
    if length(dir('/trc/cut'))==0
        warning off MATLAB:MKDIR:DirectoryExists;
   		mkdir('/trc/cut');
		disp('Les traces sont sauv�s dans: /trc/cut');
    else           
    end
    save(['trc\cut\',file,'.MIA.deco.syn.trc'],'res','-ascii','-tabs');
    %%%%converti pour msd turbo
            filetxt=['trc\cut\',file,'.MIA.deco.syn.trc'];
            fi = fopen(filetxt,'w');
            if fi<3
              error('File not found or readerror.');
            else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f %6.2f %6.8f\r',res');
            end
            % close
            fclose(fi);
    %%%%%%%%%%fin conversion
    disp('!!! Les msd ne sont pas calcul� : il faut l''option msdflag=1 pour les calculer');
end
else
    disp(' !!!!!!!!!!!!!! R�ultat: il ne reste plus de trace de longueur suffisante');
end