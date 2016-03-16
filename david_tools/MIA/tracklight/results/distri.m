function varargout = distri(varargin)
% DISTRI M-file for distri.fig
%
% distribucion de moleculas para tracking.m
%
% MR - jan 06 - v 1.2                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Edit the above text to modify the response to help distri

% Last Modified by GUIDE v2.5 03-Oct-2005 09:16:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @distri_OpeningFcn, ...
                   'gui_OutputFcn',  @distri_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before distri is made visible.
function distri_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = distri_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
handles.option=1;
handles.path='';
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)

set(handles.message,'string','');
guidata(hObject, handles);
switch handles.option
    case 1
        counttrc(handles)
    case 2
        dist(handles)
    case 3
        distD(handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
handles.option=get(hObject,'Value');
set(handles.message,'string','');
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
start_path=cd;
switch handles.option
case 1  %countmol
     dialog_title=['Select trc',filesep,'cut folder'];
     goodfolder=['trc',filesep,'cut'];
case 2   %distsyn peaks
     dialog_title=['Select pk folder'];
     goodfolder='pk';
case 3   %distsyn D
     dialog_title=['Select msd',filesep,'cut',filesep,'fits folder'];
     goodfolder=['msd',filesep,'cut',filesep,'fits'];
end

set(handles.message,'string',dialog_title);
directory_name = uigetdir(start_path,dialog_title);
if directory_name==0
    return
end
k=strfind(directory_name,goodfolder);
if isempty(k)==1
      msgbox('Wrong folder!!','','error')
      return
end
path=directory_name;
d=dir(path);
st = {d.name};
[listafiles,v] = listdlg('PromptString','Select files:','SelectionMode','multiple','ListString',st);
if v==0
   return
end
set(handles.go,'enable','on');
set(handles.load,'userdata',listafiles);
set(handles.folder,'string','Files loaded');
handles.path=path;

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions counting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function counttrc(handles)
% a partir de countMolMR
% cuenta peaks de las trayectorias en los distintos compartimientos

path=[handles.path,filesep];
listafiles=get(handles.load,'userdata');
d=dir(path);
st = {d.name};
trcdata=[];
Nextra=0;
Nsyn=0;
Nperi=0;
count=0;
   npartial=[];

   disp('  ');
   disp(['Counting peaks']);
   disp('  ');

[f,ultimo]=size(listafiles);
  Strcdata=[];
  
for cont=1:ultimo
    
    file=[path,st{listafiles(cont)}];
        newtrctemp =load(file);
    Strcdata=[];
    for t=1:6
        Strcdata(:,t)=newtrctemp(:,t);  % if there are another column
    end

    count=count+1;
   Ntotpar=size(Strcdata,1);
   npartial(count,1)=count;
   npartialextra=0;
   npartialperi=0;
   npartialsyn=0;
   
for i=1:Ntotpar
    if Strcdata(i, 6)==0
        npartialextra=npartialextra+1;
    else 
       if Strcdata(i, 6)>0
           npartialsyn=npartialsyn+1;
       else
          npartialperi=npartialperi+1;
      end
  end
end
npartial(count,2)=npartialextra;
npartial(count,3)=npartialsyn;
npartial(count,4)=npartialperi;
npartial(count,5)=Ntotpar;
npartial(count,6)=npartialsyn/Ntotpar*100;

%totales
   trcdata=[trcdata; Strcdata];
end

Ntot=size(trcdata,1);

for i=1:Ntot
    if trcdata(i, 6)==0
       Nextra=Nextra+1;
   else 
       if trcdata(i, 6)>0
          Nsyn=Nsyn+1;
      else
          Nperi=Nperi+1;
      end
  end
end
disp(['There are ', Num2str(Nsyn), ' synaptic peaks and ', Num2str(Nperi), ' perisynaptic peaks over a total of ', Num2str(Ntot), '.'])
synmol=Nsyn/Ntot*100;
disp([Num2str(synmol), '% of synaptic molecules'])
disp('  ');

save (['nropeaks'],'npartial','-ascii')  

set(handles.message,'string','File nropeaks saved');
handles.path='';
set(handles.go,'enable','off');

guidata(gcbo, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dist(handles)
% distSyn 
% distancia al centroide del marcado sinaptico
% selecciona por carpeta pk

   disp('  ');
   disp(['Distances to centroid']);
   disp('  ');


path=[handles.path,filesep];
listafiles=get(handles.load,'userdata');
d=dir(path);
st = {d.name};

[f,ultimo]=size(listafiles);

% dialog box to enter cutoffs
   prompt = {'Error on intensity ','Max intensity','Max points','Pixel size'};
 num_lines= 1;
dlg_title = 'Enter';
def = {'1/3','1000','100','208'}; % default values
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);
   if exit(1) == 0;
       return; 
   end
   
cutoffs(1)=str2num(answer{1});
cutoffs(2)=str2num(answer{2});
cutoffs(3)=str2num(answer{3});
szpx=str2num(answer{4});

pkdistcent=[];
count=1;
histodistpeak=[];
nromovie=1;
   pkdistnew=[];
   countpar=1;

for cont=1:ultimo
    
control=1;
pkdata=[];
maxim=0;

filename=st{listafiles(cont)};
strp=[path,st{listafiles(cont)}];  %pk
[file,rem]=strtok(filename,'.');  %raiz

strs = [file,'-loc_MIA.spe'];   
if length(dir(strs))==0	  %check existencia imagen syn,
   strs = [file,'-loc_MIA.tif'];   
   if length(dir(strs))>0	  %syn is .tif
      if length(dir(strp))>0	  
      else
         disp(['File ',strp,' not found']);
         control = 0;
      end
   else
     disp(['File ',strs,' not found']);
     control = 0;
   end
  else
      if length(dir(strp))>0	  
      else
         disp(['File ',strp,' not found']);
         control = 0;
      end
end

if control==1
     
filesynapse=strs
% load les pics et les filtre
      Spkdata =load(strp);
      SPok=1;
   if SPok>0
      Spkdata(:,1)=Spkdata(:,1)+maxim;		% new imagenumber
   end
   pkdata=[pkdata; Spkdata];
   
   if ~isempty(pkdata)
      maxim=max(pkdata(:,1))+20;
   end
pkdata=clearpk(pkdata,1,3); % vire les peaks dont les largeurs sont en dehors de [1., 4]
pkind = find(pkdata(:,10)<(pkdata(:,5)*cutoffs(1)) & pkdata(:,5)> 0 & pkdata(:,5)< cutoffs(2)) ;
pkdata = pkdata(pkind,:);
Npics=size(pkdata,1);

% reads syn files
stktrue=0;
k=strfind(filesynapse,'spe');
if isempty(k)==1                             %tif
   stktrue=1;
   info=imfinfo(filesynapse);
   ImagePar(1)=info.Width;
   ImagePar(2)=info.Height;
   ImagePar(3)= 1;
   ImagePar(4)= 1;
   ImagePar(5)= 1;
   Image=imread(filesynapse);
   Image=double(Image);
else
   [Image ImagePar]=spedataread(filesynapse); %.spe
end
%dimension des images
Xdim=ImagePar(1);
Ydim=ImagePar(2)/ImagePar(4);
% numerotacion synapses
[maximas, numsynapse]=domains(Image,ImagePar);   
Nsyn=max(max(numsynapse))
%Recherche de maximas locaux
Nmaxloc=0
MaxdesSyn=[];
for i=1:Xdim
    for j=1:Ydim
        if maximas(j,i)==1
            Nmaxloc=Nmaxloc+1;
            MaxdesSyn=[MaxdesSyn;[numsynapse(j,i),i,j]];
        else
            
        end
    end
end
disp(['on trouve ',Num2str(Nmaxloc), ' maximas �partir de ', Num2str(Nsyn), ' synapses.']);
   disp('  ');
MaxdesSyn=sortrows(MaxdesSyn);
% recherche des centroides de synapses
CentredesSyn=[];
for k=1:Nsyn
    Syntemp=[];
    for i=1:Xdim
        for j=1:Ydim
            if numsynapse(j,i)==k 
                Syntemp=[Syntemp;[i,j]];
            else
            end
        end
    end
sSyntemp=size(Syntemp);
    if sSyntemp(1)==1
        CentredesSyn=[CentredesSyn;[k,Syntemp]];     
    else
        CentredesSyn=[CentredesSyn;[k,mean(Syntemp)]]; 
    end
end
% pic to maximas distances
DisttoMax=[];
max(pkdata(:,2));
max(pkdata(:,3));
for i=1:Npics
    distMaxtemp=[];
end
% pic to centroids distances
DisttoCentr=[];
for i=1:Npics
    distCentrtemp=[];
    for j=1:Nsyn
        dist=(pkdata(i,2)-CentredesSyn(j,2))^2+(pkdata(i,3)-CentredesSyn(j,3))^2;
    dist=dist^(0.5)*szpx/1000;
    if dist<1
       pkdistcent(count,1)=count;
       pkdistcent(count,2)=dist;
       pkdistnew(countpar,1)=count;
       pkdistnew(countpar,2)=dist;
       count=count+1;
       countpar=countpar+1;
    end
    end 
end
% histogram for each movie to do statistcs
% 0-1 interval on X, bin 0.05 (20 bin)
for b=1:20  % 20 intervals
    binvector(b)=0.05*(b-1)+0.025;  % bin center
end

if isempty(pkdistnew)==0
   %[n,xout]=hist(pkdistnew(:,2),20);
   [n,xout]=hist(pkdistnew(:,2),binvector)   ;
   histodistpeak(1,:)=xout;
   histodistpeak(nromovie+1,:)=n;
   nromovie=nromovie+1;
   pkdistnew=[];
   countpar=1;
else
    disp ('No peaks in synapses');
end

end
end

save(['distsynpk.txt'],'pkdistcent','-ascii');
save(['histodistsynpk.txt'],'histodistpeak','-ascii');

set(handles.message,'string','Files distsyn saved');
handles.path='';
set(handles.go,'enable','off');
guidata(gcbo, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function distD(handles)
% prepara archivo con las distancias al centroide del marcado sinaptico vs
% D

   disp('  ');
   disp(['Distances to centroid vs D']);
   disp('  ');

path=[handles.path,filesep];
listafiles=get(handles.load,'userdata');
d=dir(path);
st = {d.name};
trcdistcent=[];
count=1;
disttrcfittotal=[];
disttrcfit=[];
distdif=[];
nro=1;

[f,ultimo]=size(listafiles);

% dialog box to enter szpx
   prompt = {'Pixel size','file extension for trc files'};
 num_lines= 1;
dlg_title = 'Enter';
def = {'208','.deco.syn.trc'}; % default value
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);
if exit(1) == 0;
       return; 
end
szpx=str2num(answer{1});
exten=(answer{2});

for cont=1:ultimo
    
control=1;
filename=st{listafiles(cont)};
filefit=[path,st{listafiles(cont)}];  %fits
[file,rem]=strtok(filename,'.');  %raiz
strs = [file,'-loc_MIA.spe'];   %syn
[file,rem]=strtok(filename,'.');
strs = [file,'-loc_MIA.spe'];
strt = [file,exten];
filetrc=['trc',filesep,'cut',filesep,strt];

strs = [file,'-loc_MIA.spe'];   
if length(dir(strs))==0	  %check existencia imagen syn,
   strs = [file,'-loc_MIA.tif'];   
   if length(dir(strs))>0	  %syn is .tif
     if length(dir(filefit))>0	  
     else
         disp(['File ',strm,' not found']);
         control = 0;
     end
   else
     disp(['File ',strs,' not found']);
     control = 0;
   end
  else
     if length(dir(filefit))>0	  
     else
         disp(['File ',strm,' not found']);
         control = 0;
     end
end

if control==1
     
filesynapse=strs
pkdata=[];
maxim=0;
% molecules fit�s + D
    y =load(filefit);
    disp(['File ' ,filefit, ' loaded.']);
[r,c]=size(y);
    file=['trc',filesep,'cut',filesep,strt];
    x =load(file);
    disp(['File ' ,file, ' loaded.']);
[row,col]=size(x);

for i=1:r
    index=find(x(:,1)==y(i,1)); %primer punto
    disttrcfit(i,1)=y(i,1); %#mol
    disttrcfit(i,2)=x((index(1)),3); %pos x
    disttrcfit(i,3)=x((index(1)),4); %pos y
    disttrcfit(i,4)=x((index(1)),6); %loc
    disttrcfit(i,5)=y(i,2); %D
end

% reads syn files
stktrue=0;
k=strfind(filesynapse,'spe');
if isempty(k)==1                             %tif
   stktrue=1;
   info=imfinfo(filesynapse);
   ImagePar(1)=info.Width;
   ImagePar(2)=info.Height;
   ImagePar(3)= 1;
   ImagePar(4)= 1;
   ImagePar(5)= 1;
   Image=imread(filesynapse);
   Image=double(Image);
else
   [Image ImagePar]=spedataread(filesynapse); %.spe
end
%dimension des images
Xdim=ImagePar(1);
Ydim=ImagePar(2)/ImagePar(4);
% numerotacion synapses
[maximas, numsynapse]=domains(Image,ImagePar);   
Nsyn=max(max(numsynapse))

%Recherche de maximas locaux
Nmaxloc=0;
MaxdesSyn=[];
for i=1:Xdim
    for j=1:Ydim
        if maximas(j,i)==1
            Nmaxloc=Nmaxloc+1;
            MaxdesSyn=[MaxdesSyn;[numsynapse(j,i),i,j]];
        else
            
        end
    end
end

disp(['on trouve ',Num2str(Nmaxloc), ' maximas �partir de ', Num2str(Nsyn), ' synapses.']);
   disp('  ');

MaxdesSyn=sortrows(MaxdesSyn);


% recherche des centroides de synapses
CentredesSyn=[];
for k=1:Nsyn
    Syntemp=[];
    for i=1:Xdim
        for j=1:Ydim
            if numsynapse(j,i)==k 
                Syntemp=[Syntemp;[i,j]];
            else
            end
        end
    end
sSyntemp=size(Syntemp);
    if sSyntemp(1)==1
        CentredesSyn=[CentredesSyn;[k,Syntemp]];     
    else
        CentredesSyn=[CentredesSyn;[k,mean(Syntemp)]]; 
    end
end


% pic to centroids distances

for i=1:r
    distCentrtemp=[];
    numsyn=disttrcfit(i,4);
    if numsyn>0 %| numsyn<0 % syn 
        %numsyn=abs(numsyn);
       distCentrtemp=[distCentrtemp;(disttrcfit(i,2)-CentredesSyn(numsyn,2))^2+(disttrcfit(i,3)-CentredesSyn(numsyn,3))^2];
       disttrcfit(i,6)=distCentrtemp^(0.5)*szpx/1000; %dist syn
   else
       disttrcfit(i,6)=1000; %extra
    end
       disttrcfittotal(count,:)=disttrcfit(i,:);
       if disttrcfit(i,6)<1000
          distdif(nro,1)=nro;
          distdif(nro,2)=disttrcfit(i,4);
          distdif(nro,3)=disttrcfittotal(count,5);
          distdif(nro,4)=disttrcfittotal(count,6);
          nro=nro+1;
      end
       count=count+1;

end

    %disp(['Distance to synapse centroids of file ' ,file, ' calculated.']);

disttrcfit=[];

end



end

save(['distsyntrctotal.txt'],'disttrcfittotal','-ascii');
save(['distsyntrcD.txt'],'distdif','-ascii');

set(handles.message,'string','Files distsynD saved');
set(handles.go,'enable','off');
handles.path='';
guidata(gcbo, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function help_Callback(hObject, eventdata, handles)

helpdistri

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

