function varargout = doubleloc(varargin)
% DOUBLELOC M-file for doubleloc.fig
% Last Modified by GUIDE v2.5 13-May-2006 09:31:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @doubleloc_OpeningFcn, ...
                   'gui_OutputFcn',  @doubleloc_OutputFcn, ...
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

% --- Executes just before doubleloc is made visible.
function doubleloc_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = doubleloc_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function image1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
% --- Executes during object creation, after setting all properties.
function image2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
% --- Executes during object creation, after setting all properties.
function perisize_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function image1_Callback(hObject, eventdata, handles)
handles.image1ident=get(hObject,'String');
guidata(hObject, handles);

function image2_Callback(hObject, eventdata, handles)
handles.image2ident=get(hObject,'String');
guidata(hObject, handles);


function perisize_Callback(hObject, eventdata, handles)
handles.sizeperzone=get(hObject,'String');
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in twocat.
function twocat_Callback(hObject, eventdata, handles)
% 
if isdir(['double',filesep,'trc',filesep,'cut']); else; mkdir(['double',filesep,'trc',filesep,'cut']); end

[st,files]=selectfiles;
handles.image1ident=get(handles.image1,'string');
handles.image2ident=get(handles.image2,'string');

if isempty(files)==0
    [f,ultimo]=size(files);

identif1=handles.image1ident;
identif2=handles.image2ident;
trcpath=['trc',filesep];

for nromovie=1:ultimo
    control=0;
    file=st{files(nromovie)};
    [namefile,rem]=strtok(file,'.');
    Image1name=[namefile,identif1]
    Image2name=[namefile,identif2]
    trcfile=[trcpath,file]
    if length(dir(Image1name))>0
        if length(dir(Image2name))>0
            if length(dir(trcfile))>0
               control=1;
           else
               disp(['File ',trcfile,' not found']);
           end
        else
            disp(['File ',Image2name,' not found']);
        end
    else
        disp(['File ',Image1name,' not found']);
    end            
    
    if control==1
        
       % reads trc file
       Trc=load(trcfile);
       answer=findstr(file,'MIA');
       if isempty(answer)==0
          controlMIA=1;
       else
          controlMIA=0;
       end

       % reads files
       [Image1,ImagePar1]=readimages(Image1name);
       [Image2,ImagePar2]=readimages(Image2name);
       %dimension des images
       Xdim1=ImagePar1(1);
       Ydim1=ImagePar1(2)/ImagePar1(4);
       Xdim2=ImagePar2(1);
       Ydim2=ImagePar2(2)/ImagePar2(4);
       control2=0;
       if Xdim1==Xdim2
          if Ydim1==Ydim2
             control2=1;
          else
             disp(['Images must have the same size'])
          end
       else
          disp(['Images must have the same size'])
       end
       
       if control2==1
           mergesynapse=zeros(Ydim1,Xdim1);
          % binarization & numeration
          disp('  ');
          disp(['Numbering domains...']);
          % Image 1
          level1 = graythresh(Image1);
          bwimage1 = im2bw(Image1,level1); %binarise avec le seuil level
          [numsynapse1,numObjects1] = bwlabel(bwimage1,4); 
          disp([ num2str(numObjects1) ' domains numbered in image 1']);
          % Image 2
          level2 = graythresh(Image2);
          bwimage2 = im2bw(Image2,level2); %binarise avec le seuil level
          [numsynapse2,numObjects2] = bwlabel(bwimage2,4); 
          disp([ num2str(numObjects2) ' domains numbered in image 2']);
          % re-numbering and negative values
          for i=1:Ydim1
              for j=1:Xdim1
                  if numsynapse1(i,j)>0 & numsynapse2(i,j)>0                   %loc on domain of image1 and domain of image2 that co-localize
                         mergesynapse(i,j)=-(numsynapse1(i,j));                 %takes the negative value of the domain 1
                     elseif numsynapse1(i,j)>0 & numsynapse2(i,j)==0 
                         mergesynapse(i,j)=numsynapse1(i,j);                    %loc on domain of image1
                     elseif numsynapse1(i,j)==0 & numsynapse2(i,j)>0 
                         mergesynapse(i,j)=-(numsynapse2(i,j)+numObjects1);     %loc on domain of image2: negative value, numbering from the number of domains in image 1
                  end
              end
          end
          
          disp('  ');
          disp(['Performing localization of trajectories of molecules...']);
          Points=size(Trc(:,1),1);
                 %   disp(size(Trc));
                %              disp(size(mergesynapse));
%disp(Xdim1);disp(Ydim1)

          temp=[];
          for i=1:Points
              %temp=[temp;[Trc(i,:),mergesynapse(max(min(round(Trc(i,4)+1),Ydim1),1),max(min(round(Trc(i,3)+1),Xdim1),1))]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
              if controlMIA==0
                  temp=[temp;[Trc(i,:),mergesynapse(max(min(round(Trc(i,4)+1),Ydim1),1),max(min(round(Trc(i,3)+1),Xdim1),1))]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
              else
                  temp=[temp;[Trc(i,1:5),mergesynapse(max(min(round(Trc(i,4)+1),Ydim1),1),max(min(round(Trc(i,3)+1),Xdim1),1)),Trc(i,6)]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
              end

          end
          nwtrcsyn=temp;
         % disp(size(temp));
          
         % guarda trajectorias con localiz con formato para msdturbo
         if controlMIA==0
            filetxt=['double',filesep,'trc',filesep,namefile,'.con.syn.trc']; fi = fopen(filetxt,'w'); 
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',nwtrcsyn');
            end; fclose(fi);
        else
            filetxt=['double',filesep,'trc',filesep,namefile,'.MIA.con.syn.trc']; fi = fopen(filetxt,'w'); 
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',nwtrcsyn');
            end; fclose(fi);
        end

         % cutting
         nwtrccut=deconnect(nwtrcsyn); %corta trajectorias que cambian de localizacion
         if controlMIA==0
            filetxt=['double',filesep,'trc',filesep,'cut',filesep,namefile,'.deco.syn.trc']; fi = fopen(filetxt,'w');
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',nwtrccut');
            end; fclose(fi);
        else
            filetxt=['double',filesep,'trc',filesep,'cut',filesep,namefile,'.MIA.deco.syn.trc']; fi = fopen(filetxt,'w');
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',nwtrccut');
            end; fclose(fi);
        end
         %save(['double\trc\cut\',namefile,'.deco.syn.trc'],'nwtrccut','-ascii','-tabs'); % trayectorias mol con loc
         disp('  ');
         disp(['New trajectories saved in double',filesep,'trc',filesep]);
         
     end % control2
     
 end  %control 1
 
end % loop


else
    disp('No files chosen');
end

%------------------------------------------------------
% --- Executes on button press in threecat.
function threecat_Callback(hObject, eventdata, handles)
%


[st,files]=selectfiles;
handles.image1ident=get(handles.image1,'string');
handles.image2ident=get(handles.image2,'string');
handles.sizeperzone=str2num(get(handles.perisize,'string'));
trcpath=[cd,filesep,'trc',filesep];

if isempty(files)==0
    [f,ultimo]=size(files);

identif1=handles.image1ident;
identif2=handles.image2ident;
perizone=handles.sizeperzone
   
for nromovie=1:ultimo
    control=0;
    trcfile=[trcpath,st{files(nromovie)}]
    [namefile,rem]=strtok(st{files(nromovie)},'.');
    Image1name=[namefile,identif1]
    Image2name=[namefile,identif2]
    if length(dir(Image1name))>0
        if length(dir(Image2name))>0
            if length(dir(trcfile))>0
               control=1;
           else
               disp(['File ',trcfile,' not found']);
           end
        else
            disp(['File ',Image2name,' not found']);
        end
    else
        disp(['File ',Image1name,' not found']);
    end            
    
    if control==1
        
       % reads trc file
       Trc=load(trcfile);
       answer=findstr(st{files(nromovie)},'MIA');
       if isempty(answer)==0
          controlMIA=1;
       else
          controlMIA=0;
       end
       % reads files
       [Image1,ImagePar1]=readimages(Image1name);
       [Image2,ImagePar2]=readimages(Image2name);
       %dimension des images
       Xdim1=ImagePar1(1);
       Ydim1=ImagePar1(2)/ImagePar1(4);
       Xdim2=ImagePar2(1);
       Ydim2=ImagePar2(2)/ImagePar2(4);
       control2=0;
       if Xdim1==Xdim2
          if Ydim1==Ydim2
             control2=1;
          else
             disp(['Images must have the same size'])
          end
       else
          disp(['Images must have the same size'])
       end
       
       if control2==1
           mergesynapse=zeros(Ydim1,Xdim1);
          % binarization & numeration
          disp('  ');
          disp(['Numbering domains...']);
          % Image 1
          [numsynapse1,numObjects1]=detectdomains(Image1,ImagePar1,perizone);
          disp([ num2str(numObjects1) ' domains numbered in image 1']);
          % Image 2
          [numsynapse2,numObjects2]=detectdomains(Image2,ImagePar2,2);   %ATTENTION: 2 pixel zone peri-domain in this case
          disp([ num2str(numObjects2) ' domains numbered in image 2']);
          
          % re-numbering and negative values
          for i=1:Ydim1
              for j=1:Xdim1
                 % if numsynapse2(i,j)==0
                 %  else
                %     numsynapse2(i,j)=(abs(numsynapse2(i,j)) + 1000) * (numsynapse2(i,j)/abs(numsynapse2(i,j)));    % image 2: values +
                % end
                 if numsynapse1(i,j)>0 & numsynapse2(i,j)>0    %loc on domain of image1 and on domain of image2: value of the domain 1 + 3000
                         mergesynapse(i,j)=numsynapse1(i,j) + 3000;                 
                     elseif numsynapse1(i,j)>0 & numsynapse2(i,j)<1  %loc on domain of image1 with extra or peri image 2: +1000 
                         mergesynapse(i,j)=numsynapse1(i,j)+1000;                    
                     elseif numsynapse1(i,j)<0 & numsynapse2(i,j)<1  %loc peri-domain of image1 with extra or peri image 2: -1000
                         mergesynapse(i,j)=-(numsynapse1(i,j)+1000);                    
                     elseif numsynapse1(i,j)<1 & numsynapse2(i,j)>0  %loc on domain of image2 with extra or peri image 1: +2000
                         mergesynapse(i,j)=numsynapse2(i,j)+2000;     
                     elseif numsynapse1(i,j)==0 & numsynapse2(i,j)<0  %loc peri-domain of image2 with extra in image 1: -2000
                         mergesynapse(i,j)=-(numsynapse2(i,j)+2000);     
                         
                         %  elseif numsynapse1(i,j)<0 & numsynapse2(i,j)>0 % loc on domain 2 and peri on domain 1
                   %      numsynapse2(i,j)=(abs(numsynapse2(i,j)) + 1000) * (numsynapse2(i,j)/abs(numsynapse2(i,j))); 
                       %  mergesynapse(i,j)=-(numsynapse2(i,j));   % -2000  
                  end
              end
          end
          
          disp('  ');
          disp(['Performing localization of trajectories of molecules...']);
          Points=size(Trc(:,1),1);
          temp=[];
          for i=1:Points
             % temp=[temp;[Trc(i,:),mergesynapse(max(min(round(Trc(i,4)+1),Ydim1),1),max(min(round(Trc(i,3)+1),Xdim1),1))]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
              if controlMIA==0
                  temp=[temp;[Trc(i,:),mergesynapse(max(min(round(Trc(i,4)+1),Ydim1),1),max(min(round(Trc(i,3)+1),Xdim1),1))]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
              else
                  temp=[temp;[Trc(i,1:5),mergesynapse(max(min(round(Trc(i,4)+1),Ydim1),1),max(min(round(Trc(i,3)+1),Xdim1),1)),Trc(i,6)]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
              end

         end
          nwtrcsyn=temp;
          
         % guarda trajectorias con localiz con formato para msdturbo
         if controlMIA==0
            filetxt=['trc',filesep,namefile,'.con.syn.trc']; fi = fopen(filetxt,'w'); 
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',nwtrcsyn');
            end; fclose(fi);
        else
            filetxt=['trc',filesep,namefile,'.MIA.con.syn.trc']; fi = fopen(filetxt,'w'); 
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',nwtrcsyn');
            end; fclose(fi);
        end

         % cutting
         nwtrccut=deconnect(nwtrcsyn); %corta trajectorias que cambian de localizacion
         if controlMIA==0
            filetxt=['trc',filesep,'cut',filesep,namefile,'.deco.syn.trc']; fi = fopen(filetxt,'w');
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',nwtrccut');
            end; fclose(fi);
        else
            filetxt=['trc',filesep,'cut',filesep,namefile,'.MIA.deco.syn.trc']; fi = fopen(filetxt,'w');
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',nwtrccut');
            end; fclose(fi);
        end

        disp('  ');
         disp(['New trajectories saved in trc',filesep]);
         
     end % control2
     
 end  %control 1
 
end % loop

          
else
    disp('No files chosen');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [st,listafiles]=selectfiles

listafiles=[];
st={};

currentdir=cd;
trcpath=[cd,filesep,'trc',filesep];
cd(trcpath)
%choose data
d = dir('*con.trc*');
st = {d.name};
if isempty(st)==1
   msgbox(['No files!!'],'Select files','error')
   return
end
[listafiles,v] = listdlg('PromptString','Select files:','SelectionMode','multiple','ListString',st);
if v==0
   return
end
[f,ultimo]=size(listafiles);
cd(currentdir)  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Image,ImagePar]=readimages(Imagename)

stktrue=0;
k=strfind(Imagename,'spe');
if isempty(k)==1                             %tif
   stktrue=1;
   info=imfinfo(Imagename);
   ImagePar(1)=info.Width;
   ImagePar(2)=info.Height;
   ImagePar(3)= 1;
   ImagePar(4)= 1;
   ImagePar(5)= 1;
   Image=imread(Imagename);
   Image=double(Image);
else
   [Image ImagePar]=spedataread(Imagename); %.spe
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [numsynapse,numObjects]=detectdomains(d,p,perizone);

% image
ymax=p(1);
xmax=p(2)/p(4);

% numbering
level = graythresh(d);
bw = im2bw(d,level); 
[labeled,numObjects] = bwlabel(bw,4); 

%cr� les zones perisynaptiques : d'abord avec valeur -1
% taille de la zone = (expand-1)/2

%expand=5;
expand=(perizone*2)+1;   
zone=(expand-1)/2;
disp(['Peri-domain zone: ' num2str(zone) ' pixels.']);
M=zeros(expand,expand);
M=M+1;
BW2= conv2(labeled,M);
s=size(BW2);
BW2=BW2(zone+1:s(1)-zone,zone+1:s(2)-zone); %rescale l'image convolu� pour qu'elle ait la meme taille que labeled
BW2=sign(BW2);
d=sign(d);
BW2=imsubtract(BW2,d); % matrice des zones perisynaptiques
labeled=imsubtract(labeled, BW2);
numsynapse=labeled;

%%%% renum�ote les zones p�isynpatiques avec la valeur n�ative de la synapse la plus proche
temp=labeled;
% 1�e couronne
for i=2:xmax-1
    for j=2:ymax-1
        if labeled(i,j)==-1
           temp(i,j)=-max([labeled(i-1,j-1),labeled(i-1,j),labeled(i-1,j+1),labeled(i,j-1),labeled(i,j),labeled(i,j+1),labeled(i+1,j-1),labeled(i+1,j),labeled(i+1,j+1)]);
        else
        end
    end
end
%2i�e couronne
for i=2:xmax-1
    for j=2:ymax-1
        if labeled(i,j)==-1
           numsynapse(i,j)=min([temp(i-1,j-1),temp(i-1,j),temp(i-1,j+1),temp(i,j-1),temp(i,j),temp(i,j+1),temp(i+1,j-1),temp(i+1,j),temp(i+1,j+1)]);
        else
        end
    end
end
%1ere et derni�e colonne
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
%1ere et derni�e ligne
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
% fin renum�ation

% end of file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%