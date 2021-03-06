function touslesfits=fitMSD(till,sizepixel,longFIT,minTrace,msddata,trcdata,deco,waitbarhandle)
%function touslesfits=fitMSD(till,sizepixel,longFIT,minTrace,msddata,trcdata,waitbarhandle)
% fit avec fonction affine les traces affect�es aux localisations par affectsynapses
% param�tres:
%       till : temps entre deux images
%       sizepixel : taille des pixels en nm
%       longFIT : nombre de points sur lesquels les fits sont faits
% minTrace
%EXTRACT the msd(t) of each molecule from the files cut.msd 
%    store it in 'cut\msd\molecules\FILENAME.moleculei.dat'
%FIT every trace
%    store all the fit results (molecule number, D, dD, syn) in '\cutmsd\fits\FILENAME.fit.dat'

%if nargin<7
 %   deco=0
 %else
 %   deco=1
 %end

maxtrc=0;

u=0;

Lesmax=max(msddata);
Maxtrace=Lesmax(1);
touslesfits=[];
   
ymax=0;

% extrait les traces des fichiers .msd
for i=1:Maxtrace
    temp=[];
    %temp(1,:)=[0,0,0,0];
    lesfits=[];
    p=1;
    for j=1:size(msddata(:,1))
            if  msddata(j,1)==i
                temp(p,:)=[msddata(j,1),msddata(j,2)*till,msddata(j,3),msddata(j,4)];
                p=p+1;
            end
    end
           % actualizes waitbar
       if exist('waitbarhandle')
          waitbar(i/Maxtrace,waitbarhandle,['Trajectory # ',num2str(i)]);
       end

 if p>4       
    % d�but du fit
    if size(temp)>0
        sizex=size(temp(:,2));
        maxfit=min(sizex(1),longFIT); %nombre de points fitt�s, ici au max longFIT
        [F, resFIT]=lsqcurvefit(@affine,[0 0],temp(1:maxfit,2),temp(1:maxfit,3)); %fitte les traces par une droite de pente F(1) et d'offset F(2)
        resFIT=sqrt(resFIT)/(2*p)/till; %erreur sur le fit
    
        FIT=F(1)
        offset=F(2);
    else
        FIT=-100;
        offset=-100;
    end
        %conversion en constante de diffusion et de pxl^2/ms en �m^2/s
    if FIT>=0
       FIT=1/4*FIT*1000*(sizepixel/1000)^2;
     else
       if FIT>=-0.014/(1/4*1000*(sizepixel/1000)^2);
           FIT=0;
          else
       FIT=-1;
       end
    end
    resFIT=1/4*resFIT*1000*(sizepixel/1000)^2;
    
    indsyn = find (trcdata(:,1)==i);% trouve les positions de la trace dans trcdata
    
    % met les FIT dans un tableau
    lesfits
    if deco>0
       lesfits(i,:)=[i, FIT, resFIT,offset*(sizepixel/1000)^2,trcdata(indsyn(1),6)]; % ajoute en derni�re colonne la localisation (# syn, -1: peri, 0: extra
    else
       lesfits(i,:)=[i, FIT, resFIT,offset*(sizepixel/1000)^2]; 
    end
    if (resFIT>10^(-10) & FIT>=0)
        u=1+u;
        if deco>0
            touslesfits(u,:)=[i, FIT, resFIT,offset*(sizepixel/1000)^2,trcdata(indsyn(1),6)];
        else
            touslesfits(u,:)=[i, FIT, resFIT,offset*(sizepixel/1000)^2];
        end
    else    
        u=u;
        if deco>0; touslesfits(u+1,:)=[i 0 0 0 0];else;touslesfits(u+1,:)=[i 0 0 0 ];end;
    end
    
  
end%if p>4     

end %%%%%%%%%%%% fin des fits et de la boucle maxtrace

end
% end of file
