function [newsynpeakdata,indice,total]=doublesynloc(newpeakdata,gfpimage,synfile,Xdim,Ydim,cutoffs)
% image: binaria
% detecta localizacion sinaptica para sobel.m, dentro de tracking.m
% peaks ya filtrados por cutoffs!!!
%
% MR - oct 05 - v 1.1                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

control=1;
pkdata=[];
maxim=0;

% load les pics et les filtre
      Spkdata =newpeakdata;
      SPok=1;
   if SPok>0
      Spkdata(:,1)=Spkdata(:,1)+maxim;		% new imagenumber
   end
   pkdata=[pkdata; Spkdata];
   
   if ~isempty(pkdata)
      maxim=max(pkdata(:,1))+20;
   end
%pkdata=clearpk(pkdata,1,3); % vire les peaks dont les largeurs sont en dehors de [1., 4]
%pkind = find(pkdata(:,10)<(pkdata(:,5)*cutoffs(1)) & pkdata(:,5)> 0 & pkdata(:,5)< cutoffs(2)) ;
%pkdata = pkdata(pkind,:);


%dimension des images

Npics=size(pkdata,1);
total=Npics;

% peaks en syn 
indice=1;
newsynpeakdata=[];

for cont=1:Npics
    xpos=round(pkdata(cont,2));
    ypos=round(pkdata(cont,3));
    if xpos==0  % posible error por round
        xpos=1;
    end
    if ypos==0
        ypos=1;
    end 
    if xpos<Ydim+1 & ypos<Xdim+1  % las dimensiones estan traslocadas
      if synfile(xpos,ypos)>0
        % hay peak dentro del dominio
        newsynpeakdata(indice,:)=pkdata(cont,:);
        indice=indice+1;
      end
    end
end

indice=indice-1;
    
disp(['We found ',num2str(indice), ' peaks inside synapses of the domain']);

%save(['double\',peakfile],'newsynpeakdata','-ascii');

