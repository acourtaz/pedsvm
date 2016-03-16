function [maximas, numsynapse]=domains(d,p,handles);
% function [maximas, numsynapse]=domains(d,p,handles);
% traite l'image synapse après son traitement par transformée en ondelettes et affecte des numéros aux synapses
% maximas : matrice des maximas locaux (valeur 1 dans la matrice)
% numsynapse : matrice contenant les zones synaptiques perisyn et extrasyn (valeur=# de la synapse dans la matrice et -#synapse pour perisyn)
%
% needs image already read (d) and its parameters (p)
% modified from synapses.m by MR (mar06) for gaussiantrackM and MIAtrack.m
% author: LC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3
    handles.report=[];
end

% image
ymax=p(1);
xmax=p(2)/p(4);

% trouve les maximas locaux des synapses dans l'image mia
BW1 = imregionalmax(d);
maximas=BW1;

% numérote les synapses (ici, il s'agit de l'image mia seuillée)
level = graythresh(d);
bw = im2bw(d,level); %binarise avec le seuil level
[labeled,numObjects] = bwlabel(bw,4); 
disp([ num2str(numObjects) ' domains numbered.']);
if nargin==3
    text=[num2str(numObjects) ' domains numbered.'];
    updatereport(handles,text)
end

%créé les zones perisynaptiques : d'abord avec valeur -1
% taille de la zone = (expand-1)/2
expand=5;
zone=(expand-1)/2;
disp(['Peri-domain zone: ' num2str(zone) ' pixels.']);
M=zeros(expand,expand);
M=M+1;
BW2= conv2(labeled,M);
s=size(BW2);
BW2=BW2(zone+1:s(1)-zone,zone+1:s(2)-zone); %rescale l'image convoluée pour qu'elle ait la meme taille que labeled
BW2=sign(BW2);
d=sign(d);
BW2=imsubtract(BW2,d); % matrice des zones perisynaptiques
labeled=imsubtract(labeled, BW2);
numsynapse=labeled;

%%%% renumérote les zones périsynpatiques avec la valeur négative de la synapse la plus proche
temp=labeled;
% 1ère couronne
for i=2:xmax-1
    for j=2:ymax-1
        if labeled(i,j)==-1
           temp(i,j)=-max([labeled(i-1,j-1),labeled(i-1,j),labeled(i-1,j+1),labeled(i,j-1),labeled(i,j),labeled(i,j+1),labeled(i+1,j-1),labeled(i+1,j),labeled(i+1,j+1)]);
        else
        end
    end
end
%2ième couronne
for i=2:xmax-1
    for j=2:ymax-1
        if labeled(i,j)==-1
           numsynapse(i,j)=min([temp(i-1,j-1),temp(i-1,j),temp(i-1,j+1),temp(i,j-1),temp(i,j),temp(i,j+1),temp(i+1,j-1),temp(i+1,j),temp(i+1,j+1)]);
        else
        end
    end
end
%1ere et dernière colonne
for i=2:xmax-1
        if labeled(i,1)==-1
           numsynapse(i,1)=min([temp(i-1,1),temp(i-1,2),temp(i,1),temp(i,2),temp(i+1,1),temp(i+1,2)]);
        else
        end
        if labeled(i,ymax)==-1
           numsynapse(i,ymax)=min([temp(i-1,ymax-1),temp(i-1,ymax),temp(i,ymax-1),temp(i,ymax),temp(i+1,ymax-1),temp(i+1,ymax)]);
        else
        end
end
%1ere et dernière ligne
for j=2:ymax-1
        if labeled(1,j)==-1
           numsynapse(1,j)=min([temp(1,j-1),temp(2,j-1),temp(1,j),temp(2,j),temp(1,j+1),temp(2,j+1)]);
        else
        end
        if labeled(xmax,j)==-1
           numsynapse(xmax,j)=min([temp(xmax-1,j-1),temp(xmax,j-1),temp(xmax-1,j),temp(xmax,j),temp(xmax-1,j+1),temp(xmax,j+1)]);
        else
        end
end
% quatre coins
numsynapse(1,1)=min([temp(1,1),temp(1,2),temp(2,1),temp(2,2)]);
numsynapse(1,ymax)=min([temp(1,ymax-1),temp(1,ymax),temp(2,ymax-1),temp(2,ymax)]);
numsynapse(xmax,ymax)=min([temp(xmax,ymax-1),temp(xmax,ymax),temp(xmax-1,ymax-1),temp(xmax-1,ymax-1)]);
numsynapse(xmax,1)=min([temp(xmax-1,1),temp(xmax-1,2),temp(xmax,1),temp(xmax,2)]);
% fin renumération

% end of file