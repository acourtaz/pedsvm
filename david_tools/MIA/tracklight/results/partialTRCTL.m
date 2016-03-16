function partialTRC
% partialTRC
% separates trajectories for tracking.m
%
% MR - jan 06 - v 1.2                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

control = 1;
direcname = cd;
savefolder='partial';


% dialog box to enter name of the directory to be created
   prompt = {'Folder name ','D min= ','D max= ','File extension for trc:'};
 num_lines= 1;
dlg_title = 'Creating subgroup of trajectories';
def = {'partialtrc','min','max','.deco.syn.trc'}; % default values
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);
   if exit(1) == 0;
       return; 
   end
   
savefolder=answer{1};
Dmin=answer{2};
Dmax=answer{3};
extentrc=answer{4};

currentdir=cd;
%checks the existence of msd files
path=['msd',filesep,'cut',filesep,'fits',filesep];
if isdir(path);
  cd(path)
  d = dir('*fit*');
  st = {d.name};
  cd(currentdir);
  if isempty(st)==1
      msgbox(['No msd fit files!!'],'','error')
      control=0;
      return
  else
     path2=['trc',filesep,'cut',filesep];
     option=1;
     nrocol=6;
  end
else
  path=['msd',filesep,'fits',filesep];
  if isdir(path)
     cd(path)
     d = dir('*fit*');
     st = {d.name};
     cd(currentdir);
     if isempty(st)==1
        msgbox(['No msd fit files!!'],'','error')
        control=0;
        return
     else
        path2=['trc',filesep];
        option=0;
        nrocol=5;
     end
   end
end

cd(currentdir);
namedirtrc=[filesep,savefolder,filesep,path2];
namedirmsd=[filesep,savefolder,filesep,path];
if isdir(namedirtrc);else;mkdir (namedirtrc);end;
if isdir(namedirtrc);else;mkdir (namedirmsd);end;

k1=strfind(Dmin,'min');
k2=strfind(Dmax,'max');

if isempty(k1)==0
    mindif= -0.1;
else
    mindif=str2num(Dmin);
end

if isempty(k2)==0
    maxdif=1000;
else
    maxdif=str2num(Dmax);
end

    
ex=1;
ps = 1;
s=1;
trcperi = [];
trcextra = [];
trcsyn=[];
control = 1;
ultimaextra=0;
ultimaperi=0;
ultimasyn=0;

[fil,col]=size(st);

for indice = 1 : col            %cell st
   control=1;
   
   strm = st{indice};
   [file,rem]=strtok(strm,'.');

   filemsd=[path,strm];
   filetrc=[path2,file,extentrc];
   if length(dir(filemsd))>0
                 x=load(filemsd);
           else
                 control=0;
   end
   if length(dir(filetrc))>0
                newtrctemp =load(filetrc);
                y=[];
                for t=1:nrocol
                     y(:,t)=newtrctemp(:,t);  %control para mezclar archivos hechos con MIA
                end

           else
                disp(['File ',filetrc,' not found']);
                control=0;
   end
   
 if control>0
       
   [total, t] = size (x);
   x=sortrows(x,[1]);
   mol=1;
   fastmol=[];
   newfit=[];
   newtrc=[];
   contador=1;
   
   
   for fila = 1: total
    if x (fila, 2) > mindif  &   x (fila, 2) < maxdif     
        if fila == 1
            fastmol (1) = x (fila, 1);
            newfit(mol,:)=x(fila,:);
            mol = mol + 1;
        else
            if mol==1
                fastmol (1) = x (fila, 1);
                newfit(mol,:)=x(fila,:);
                mol = mol + 1;
            else
               if x (fila, 1) > (fastmol (mol-1))
                  fastmol (mol) = x (fila, 1) ;
                  newfit(mol,:)=x(fila,:);
                  mol = mol + 1;
               end
            end
        end
    end 
   end

[f,nromol]= size (fastmol);
[fil,c]= size (y); %archivo trc
cont=1;

disp (filetrc);

for j = 1: nromol
   for i = 1: fil
    if y (i, 1) == fastmol(j)   
        newtrc(cont,:)=y(i,:);
        newtrc(cont,1)=contador;
        newfit(j,1)=contador;
        cont=cont+1;
    end 
   end
   contador=contador+1;
end

save([savefolder,filesep,path2,file,extentrc,'.prt'],'newtrc','-ascii');
save([savefolder,filesep,path,strm,'.prt'],'newfit','-ascii');

   

end %control

end %loop files

%disp('Folder with partial trajectories created');
msgbox(['Partial trajectories saved in ',filesep,savefolder],'Saving results')

disp(['Done']);

