function localizetrack(Trc,domainfile,handles)
% function localizetrack(Trc,domainfile,handles)
% cr� une nouvelle matrice des traces (nwtrcsyn) avec dans la 6eime colonne 
% le num�o de la synapse dans laquelle est la mol�ule
% appelle domainfile pour num�oter les synapses
% file: fichier.spe ou .stk
% filesynapse: fichier_MIA.spe ou .tif
%
% modify from affectsynapses.m by MR (mar 06) for gaussiantrack.m
% author LC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitbarhandle=waitbar( 0,'Please wait...','Name',['Localizing trajectories over ',domainfile]);

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

if (length(Trc)>0) 
   disp('  ');
   disp(['Performing localization of trajectories of molecules...']);
   Points=size(Trc(:,1),1);
   temp=[];
   for i=1:Points
       if exist('waitbarhandle')
            waitbar(i/Points,waitbarhandle,['Row # ',num2str(i)]);
        end
       temp=[temp;[Trc(i,:),numsynapse(max(min(round(Trc(i,4)+1),Ydim),1),max(min(round(Trc(i,3)+1),Xdim),1))]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
   end
   nwtrcsyn=temp;
else
   nwtrcsyn=[];
   disp('Empty .con.syn.trc file');
   %report
   text=['Localization not done.'];
   updatereport(handles,text,1)
end
file=handles.file;
[namefile,rem]=strtok(file,'.');

% guarda trajectorias con localiz con formato para msdturbo
filetxt=['trc',filesep,namefile,'.con.syn.trc'];
fi = fopen(filetxt,'w');
if fi<3
   error('File not found or readerror.');
else
   fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',nwtrcsyn');
end
% close
fclose(fi);

% cutting
if isdir(['trc',filesep,'cut']); else mkdir (['trc',filesep,'cut']); end
nwtrccut=deconnect(nwtrcsyn,handles); %corta trajectorias que cambian de localizacion
%save(['trc\cut\',namefile,'.deco.syn.trc'],'nwtrccut','-ascii','-tabs'); % trayectorias mol con loc
% guarda trajectorias con localiz con formato para msdturbo
filetxt=['trc',filesep,'cut',filesep,namefile,'.deco.syn.trc'];
fi = fopen(filetxt,'w');
if fi<3
   error('File not found or readerror.');
else
   fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',nwtrccut');
end
% close
fclose(fi);

disp('  ');
disp(['New trajectories saved in trc',filesep,'cut']);

close(waitbarhandle);

% end of file