function menusm(file,detectpk,opts,diffconst,cutoffs,maxblink,distmax,minTrace,till,sizepixel,longFIT)
% menusm(file,detectpk,opts,diffconst,cutoffs,maxblink,distmax,minTrace,till,sizepixel,longFIT)
% created in base of batch.m (LC 2004)
% for tracking.m v1.0 (MR 2005)
%
% batch les datas en utilisant edfPCS, affectsynapses et extractsyn
%    file: fichier
%   detectpk==1: fit les fichiers par edfPCS
%   distmax: distance maximale de connection des traces en pixels
%   minTrace : durée minimum des traces que l'on conserve
%   opt : options chargées par opt=start
%   diffconst : constante de diffusion ‘max’ typique que vous analysez (px2/tlag)
%   cutoffs : de reconnaissance des molécules uniques : [erreur sur l’intensité, intensité max, durée max des traces], typ :[1/3 1000 100]
%   si msdflag=1, calcule le MSD dans deconnectrace
%   till : temps en ms entre deux images (illumination+tlag)
%   sizepixel=taille des pixels en nm
%       longFIT: nombre de points fittés pour la constante de diff
% les fichiers dic doivent avoir la forme: file-dic.spe


actfile=file;

if detectpk==1
        edfPCS(actfile,diffconst,opts);
end

strFile=actfile;
strDIC=[file,'-dic.spe'];

disp(['Fichiers actuels: ', strFile, ' et ', strDIC]);
      if length(dir(strFile))>0		% is there new peakdata?
                    figure(Tracking);

          connectrace(strFile,maxblink,distmax,minTrace,1,diffconst,cutoffs,opts,1);
          %figure;
          extractPCS(strFile,strDIC,till,sizepixel,longFIT);
          %close;
      end
  end
