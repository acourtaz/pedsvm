function partialMIA
% partialMIA
% separates trajectories 
%
% MR - jan 06 - v 1.2                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

control = 1;
direcname = cd;
savefolder='partial';


% dialog box to enter name of the directory to be created
   prompt = {'Folder name ','D min= ','D max= '};
 num_lines= 1;
dlg_title = 'Creating subgroup of trajectories';
def = {'partialtrc','min','max'}; % default values
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);
   if exit(1) == 0;
       return; 
   end
   
savefolder=answer{1};
Dmin=answer{2};
Dmax=answer{3};


%checks the existence of msd files
path=['msd',filesep,'cut',filesep,'fits',filesep];
d = dir(path);
st = {d.name};
  if isempty(st)==1
      path=['msd',filesep,'fits',filesep];
      d = dir(path);
      st = {d.name};
      if isempty(st)==1
           msgbox(['Wrong folder!!'],'','error')
           control=0;
           return
       else
           exten=['.MIA.con.trc'];
      end
  else
      path2=['trc',filesep,'cut',filesep];
      exten=['.MIA.deco.syn.trc'];
      option=1;
  end

namedirtrc=[filesep,savefolder,filesep,path2];
namedirmsd=[filesep,savefolder,filesep,path];
mkdir (namedirtrc); mkdir (namedirmsd);

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

   disp ('Searching the values of D of each molecule and creating new trc files')
   disp ('File: ');

for indice = 3 : col            %cell st
   control=1;
   
   strm = st{indice};
   [file,rem]=strtok(strm,'.');

   filemsd=[path,strm];
   filetrc=[path2,file,exten];
   if length(dir(filemsd))>0
                 x=load(filemsd);
           else
                 control=0;
   end
   if length(dir(filetrc))>0
                newtrctemp =load(filetrc);
                y=[];
                for t=1:6
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

save([savefolder,filesep,path2,file,exten,'.prt'],'newtrc','-ascii');
save([savefolder,filesep,path,strm,'.prt'],'newfit','-ascii');

   

end %control

end %loop files

%disp('Folder with partial trajectories created');
msgbox(['Partial trajectories saved in ',filesep,',savefolder],'Saving results')

disp(['Done']);

