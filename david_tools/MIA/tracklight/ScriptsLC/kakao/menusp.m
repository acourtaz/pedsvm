function menusp(file,msdflag,maxblink,distmax,minTrace,till,sizepixel,longFIT)
% menusmloc(file,detectpk,init,opts,diffconst,cutoffs,maxblink,distmax,minTrace,deco,till,sizepixel,longFIT)
% created in base of batchMIA.m (LC 2004)
% for tracking.m v1.0 (MR 2005)
%
% batchMIA(file,msdflag,maxblink,distmax,minTrace,till,sizepixel,longFIT)
% batch les datas en utilisant , affectsynapsesMIA et extractsynMIA
%       file: fichier (sans extension)
%       maxblink: blinking max autorisé lors de la reconnection (en images)
%       distmax: distance maximale de connection des traces en pixels
%       minTrace : durée minimum des traces que l'on conserve
%       si msdflag=1, calcule le MSD dans connectrace et deconnectrace
%       till : temps en ms entre deux images (illumination+tlag)
%       sizepixel=taille des pixels en nm
%       longFIT: nombre de points fittés pour la constante de diff
%       instantannée
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% il faut que:
%       fichier de dic: file-dic.spe
%
% MR - oct 05 - v 1.1                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


strFile=file;
[file,rem]=strtok(file,'.');

strDIC=[file,'-dic.spe'];
str=['trc\',file,'_MIA.trc'];

if length(dir(str))>0		
      control = 1;
   else
      disp(['Couldn''t find trc\ MIA file ',str]);
      control = 0;
end

if control==1


   disp(['Fichiers actuels: ', strFile, ' et ', strDIC]);
      if length(dir(strFile))>0	
          figure(Tracking);
          connectraceMIA(file,maxblink,distmax,minTrace,msdflag,1);
            if msdflag==1
                %figure;
            extractPCSMIA(strFile,strDIC,till,sizepixel,longFIT);
            %close;
            else
            end
      end

  end % control existencia trc file