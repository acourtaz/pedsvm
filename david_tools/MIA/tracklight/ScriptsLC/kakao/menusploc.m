function menusploc(file,deco,msdflag,maxblink,distmax,minTrace,till,sizepixel,longFIT)
% menusmloc(file,detectpk,init,opts,diffconst,cutoffs,maxblink,distmax,minTrace,deco,till,sizepixel,longFIT)
% created in base of batchSynMIA.m (LC 2004)
% for tracking.m v1.0 (MR 2005)
%
% batchSynMIA(file,deco,msdflag,maxblink,distmax,minTrace,till,sizepixel,longFIT)
% batch les datas en utilisant , affectsynapsesMIA et extractsynMIA
%       file: fichier (sans extension)
%       maxblink: blinking max autorisé lors de la reconnection (en images)
%       distmax: distance maximale de connection des traces en pixels
%       minTrace : durée minimum des traces que l'on conserve
%       si deco==1 appelle deconnectraceMIA qui crée des traces (.deco.) en fonction de leurs localisation et les sauve dans trc/cut... et msd/cut...
%       si msdflag=1, calcule le MSD dans deconnectrace
%       till : temps en ms entre deux images (illumination+tlag)
%       sizepixel=taille des pixels en nm
%       longFIT: nombre de points fittés pour la constante de diff
%       instantannée
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% il faut que:
%       fichier de synapse: file-loc_MIA.spe
%       fichier de dic: file-dic.spe


strFile=file;
[file,rem]=strtok(file,'.');
control=1;

strDIC=[file,'-dic.spe'];
strSyn=[file,'-loc_MIA.spe'];
str=['trc\',file,'_MIA.trc'];

if length(dir(str))>0		
      control = 1;
   else
      disp(['Couldn''t find trc\ MIA file ',str]);
      control = 0;
end

if control==1
    
if length(dir(strSyn))>0	                                                %check existencia movie
    disp(['Fichiers actuels: ', strFile, ' et ', strSyn]);
              figure(Tracking);

          affectsynapsesMIA(file,strSyn,maxblink,distmax,minTrace,deco,msdflag);
          if msdflag==1
              %figure;
          extractsynPCSMIA(strFile,strSyn,strDIC,till,sizepixel,longFIT);
          %close;
          else
          end
      end
  end
end

end % control existencia trc file

