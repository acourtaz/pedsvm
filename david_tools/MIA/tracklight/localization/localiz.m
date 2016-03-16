function temp=localiz(file,domainfile,handles)
% function temp=localiz(file,filesynapse)
% cr�� une nouvelle matrice des traces (nwtrcsyn) avec dans la 6eime colonne le num�ro de la synapse dans laquelle est la mol�cule
% de type .spe.syn.trc, dans la 5i�me, il y a les intensit�s et dans la
% 7i�me les largeurs des pics
% appelle synapses pour num�roter les synapses
% file: fichier.spe
% filesynapse: fichier_MIA.spe

if nargin<1, help localiz, return, end

% reads files
stktrue=0;
k=strfind(domainfile,'spe');
if isempty(k)==1                             %tif
   stktrue=1;
   info=imfinfo(domainfile);
   ImagePar(1)=info.Width;
   ImagePar(2)=info.Height;
   ImagePar(3)= 1;
   ImagePar(4)= 1;
   ImagePar(5)= 1;
   Image=imread(domainfile);
   Image=double(Image);
else
   [Image ImagePar]=spedataread(domainfile); %.spe
end
  

%dimension des images
Xdim=ImagePar(1);
Ydim=ImagePar(2)/ImagePar(4);

% numerotacion synapses
[maximas, numsynapse]=domains(Image,ImagePar,handles);   

x =file;

disp('  ');
disp(['Performing localization of trajectories of molecules...']);
Points=size(x(:,1),1);

temp=[];
for i=1:Points
    temp=[temp;[x(i,1:5),numsynapse(max(min(round(x(i,4)+1),Ydim),1),max(min(round(x(i,3)+1),Xdim),1)),x(i,6)]] ;% ! x et y sont invers� dans numsynapse par rapport � Trc
end

% end of file