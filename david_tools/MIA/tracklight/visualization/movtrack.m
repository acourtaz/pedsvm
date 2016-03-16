function varargout = movtrack(varargin)
% MOVTRACK M-file1 for movtrack.fig
%
%  visualization for tracking 
%
% MR - jun 06 - v 1.1                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last Modified by GUIDE v2.5 30-Mar-2006 16:58:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @movtrack_OpeningFcn, ...
                   'gui_OutputFcn',  @movtrack_OutputFcn, ...
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

% --- Executes just before movtrack is made visible.
function movtrack_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for movtrack
handles.output = hObject;
%set(gcf,'name','Movie maker');
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = movtrack_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
% inicializa handles (todos los valores que puden ser ingresados)
handles.grayparam=[];   %merging
handles.graytypefile=0;
handles.redparam=[];
handles.redtypefile=0;
handles.greenparam=[];
handles.greentypefile=0;
handles.blueparam=[];
handles.bluetypefile=0;
handles.factorgray=['1'];  %contrast merging
handles.factorred=['1'];
handles.factorgreen=['1'];
handles.factorblue=['1'];
handles.colalltraj='r';    %color code trajectories
handles.colextratraj='b';
handles.colperitraj='y';
handles.colsyntraj='r';
handles.colblinktraj='b';
handles.localiz= 0;   %display
handles.identify= 0;
handles.back=0;
handles.traject=0;
handles.tlag='50';
handles.mia=0;
handles.title=0;
handles.time=1;
handles.alltraj=0;
handles.blink=1;
handles.firstf='1';
handles.lastf='1';
set(handles.filetrc,'userdata',[]);
set(handles.filetrc,'value',0);  
dataframe(1)=1; %first frame
dataframe(2)=1; %actual frame
dataframe(3)=1; %last frame
dataframe(4)=1; %last frame with trc
handles.dataframe=dataframe;  % frame data
handles.nromolecule='all';  % frame data
handles.delay='200';
set(handles.plottraj,'value',0);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% edit
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function till_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function firstframe_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function lastframe_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function molindiv_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function fgray_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function fred_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function fgreen_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function fblue_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%--------------------------------------------------------------------------
function delay_Callback(hObject, eventdata, handles)
handles.delay=get(hObject,'String');
guidata(hObject, handles);

function molindiv_Callback(hObject, eventdata, handles)
handles.nromolecule=get(hObject,'String');
guidata(hObject, handles);

function lastframe_Callback(hObject, eventdata, handles)
handles.lastf=get(hObject,'String');
set(handles.lastframe,'string',handles.lastf)
guidata(hObject, handles);

function firstframe_Callback(hObject, eventdata, handles)
handles.firstf=get(hObject,'String');
first=str2num(handles.firstf);
if first<1
    handles.firstf='1';
end
set(handles.firstframe,'string',handles.firstf)
guidata(hObject, handles);

function till_Callback(hObject, eventdata, handles)
handles.tlag=get(hObject,'String');
guidata(hObject, handles);

function loc_Callback(hObject, eventdata, handles)
handles.localiz=get(hObject,'Value');
guidata(hObject, handles);

function miacorr_Callback(hObject, eventdata, handles)
handles.mia=get(hObject,'Value');
guidata(hObject, handles);

function showname_Callback(hObject, eventdata, handles)
handles.title=get(hObject,'Value');
guidata(hObject, handles);

function ident_Callback(hObject, eventdata, handles)
handles.identify=get(hObject,'Value');
guidata(hObject, handles);

function popupmenu1_Callback(hObject, eventdata, handles)
handles.time= get(hObject,'Value');
guidata(hObject, handles);

function static_Callback(hObject, eventdata, handles)
handles.alltraj=get(hObject,'Value');
guidata(hObject, handles);

function blinking_Callback(hObject, eventdata, handles)
handles.blink=get(hObject,'Value');
guidata(hObject, handles);

function fgray_Callback(hObject, eventdata, handles)
handles.factorgray=get(hObject,'String');
guidata(hObject, handles);

function fred_Callback(hObject, eventdata, handles)
handles.factorred=get(hObject,'String');
guidata(hObject, handles);

function fgreen_Callback(hObject, eventdata, handles)
handles.factorgreen=get(hObject,'String');
guidata(hObject, handles);

function fblue_Callback(hObject, eventdata, handles)
handles.factorblue=get(hObject,'String');
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% todo el merging.....load files

% --- Executes on button press in gray.
function gray_Callback(hObject, eventdata, handles)

% loads image DIC
[file,path] = uigetfile('*.*','Load DIC file (.spe or .tif)');
filename = [path,file];
if filename==0
    set(handles.grayname,'string',[]);
    handles.grayparam=[];
    handles.graytypefile=0;
    return
end
set(handles.grayname,'string',file);
[datamatrix,Xdim,Ydim,nfram,stktrue]=readimage(filename);
set(handles.grayname,'userdata',datamatrix); %image
handles.grayparam=[Xdim, Ydim, nfram];
handles.graytypefile=stktrue;
guidata(gcbo,handles) ;

%----------------------------------------------------------
% --- Executes on button press in red.
function red_Callback(hObject, eventdata, handles)

% loads image 
[file,path] = uigetfile('*.*','Load RED file (.spe, .stk or .tif)');
filename = [path,file];
if filename==0
    set(handles.redname,'string',[]);
    handles.redparam=[];
    handles.redtypefile=0;
    return
end
set(handles.redname,'string',file);
% movie
[datamatrix,Xdim,Ydim,nfram,stktrue]=readimage(filename);
set(handles.redname,'userdata',datamatrix); %images
handles.redparam=[Xdim, Ydim, nfram];
handles.redtypefile=stktrue;
guidata(gcbo,handles) ;

%------------------------------------------------------------
% --- Executes on button press in green.
function green_Callback(hObject, eventdata, handles)

% loads image 
[file,path] = uigetfile('*.*','Load GREEN file (.spe, .stk or .tif)');
filename = [path,file];
if filename==0
    set(handles.greenname,'string',[]);
    handles.greenparam=[];
    handles.greentypefile=0;
    return
end
set(handles.greenname,'string',file);
% movie
[datamatrix,Xdim,Ydim,nfram,stktrue]=readimage(filename);
set(handles.greenname,'userdata',datamatrix); %images
handles.greenparam=[Xdim, Ydim, nfram];
handles.greentypefile=stktrue;
guidata(hObject,handles) ;

%-----------------------------------------------------------------
% --- Executes on button press in blue.
function blue_Callback(hObject, eventdata, handles)

% loads image 
[file,path] = uigetfile('*.*','Load file BLUE (.spe, .stk or .tif)');
filename = [path,file];
if filename==0
    set(handles.bluename,'string',[]);
    handles.blueparam=[];
    handles.bluetypefile=0;
    return
end
set(handles.bluename,'string',file);
% movie
[datamatrix,Xdim,Ydim,nfram,stktrue]=readimage(filename);
set(handles.bluename,'userdata',datamatrix); %images
handles.blueparam=[Xdim, Ydim, nfram];
handles.bluetypefile=stktrue;
guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in images.
function images_Callback(hObject, eventdata, handles)

% loads image 
[file,path] = uigetfile('*.*','Load background file (.spe, .stk or .tif)');
filename = [path,file];
if filename==0
    return
end
set(handles.file1,'string',path);
handles.path=get(handles.file1,'string');
set(handles.file1,'string',filename);
handles.background=get(handles.file1,'string');
set(handles.file1,'string',file);
handles.name=get(handles.file1,'string');

% movie
stktrue=0;
msgbox('Reading file...');

answer=findstr(filename,'.spe'); answerb=findstr(filename,'.SPE');
if isempty(answer)==1 & isempty(answerb)==1
            answer2=findstr(filename,'.stk');
            if isempty(answer2)==1
                answer3=findstr(filename,'.tif');
                if isempty(answer3)==1
                    answer4=findstr(filename,'.mat');
                    if isempty(answer4)==1
                       msgbox('Wrong type of file','Error','error');
                       return
                   else
                       % mat file, producto de cosmepeaks
                       [namefile,rem]=strtok(file,'.'); %sin extension
                       pathmovie=[matlabroot,filesep,namefile,'.mat'];
                       mov=load(pathmovie);
                       mov = struct2cell(mov);
                       movie=mov{1};
                       ImagePar=movie.imagepar;
                       Xdim=ImagePar(1)
                       Ydim=ImagePar(2)/ImagePar(4)
                       nfram=ImagePar(4)
                       datamatrix=movie.image';
                       clear mov, movie
                       set(handles.file1,'userdata',datamatrix); %images
                       typefile=0;  % lo lee como .spe
                   end
               else
                    % .tif file       
                    [stack_info,datamatrix] = tifdataread(filename);
                    Xdim=stack_info.x;
                    Ydim=stack_info.y;
                    stktrue=2;
                    [fil,col]=size(datamatrix);               
                    if col/Xdim==3  %rgb
                        stktrue=3;
                    end
                    nfram=1;
                    set(handles.file1,'userdata',datamatrix); %images
                end
            else
                 % .stk file       
                 [stack_info,stackdata] = stkdataread(filename);
                 Xdim=stack_info.x;
                 Ydim=stack_info.y;
                 nfram=stack_info.frames;
                 stktrue=1;
                 set(handles.file1,'userdata',stackdata); %images

             end
        else
            % .spe file
            [datamatrix p]= spedataread (filename);
            Xdim=p(1);
            Ydim=p(2)/p(4);
            nfram=p(4);
            set(handles.file1,'userdata',datamatrix); %images

end

handles.param=[Xdim, Ydim, nfram];
handles.typefile=stktrue;

% positions
dataframe=handles.dataframe;
dataframe(1)=1; %first frame
dataframe(2)=1; %actual frame
dataframe(3)=nfram; %last frame
stopframe=dataframe(4);
if nfram>stopframe
   dataframe(4)=nfram; %last frame with trc
end
set(handles.lastframe,'string',num2str(dataframe(4)));
handles.dataframe=dataframe;  % frame data
handles.firstf=1;
set(handles.firstframe,'string','1');
handles.lastf=nfram;

close %msgbox

%first image
axes(handles.axes1);
showbackground(handles);
hold off;

%buttons
set(handles.go,'enable','on');  
set(handles.avibutton,'enable','on');  
set(handles.backbutton,'enable','on');  
set(handles.forwardbutton,'enable','on');  
set(handles.plottraj,'enable','on'); 
set(handles.saveimage,'enable','on');  

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in traces.
function traces_Callback(hObject, eventdata, handles)

% loads traces file1 
[trcf,tpath] = uigetfile('*.trc','Load trajectories file'); 
trcfile = [tpath,trcf];
if trcfile==0
    set(handles.filetrc,'userdata',[]);
    set(handles.filetrc,'value',1);  
    set(handles.plottraj,'enable','off');  
    set(handles.filetrc,'string',['']);
    return
end
set(handles.filetrc,'string',trcfile);
handles.traject=get(handles.filetrc,'string');
set(handles.filetrc,'string',trcf);

handles.name=get(handles.file1,'string');
if isempty(handles.name)==0
   set(handles.plottraj,'enable','on'); 
end

%trfile
if isempty(trcfile)==0
 x=load(trcfile);
 nrotraj=max(x(:,2));
else
    x=[];
    nrotraj=1;
end
set(handles.filetrc,'userdata',x);
set(handles.filetrc,'value',nrotraj)  

% positions
dataframe=handles.dataframe;  % frame data
dataframe(4)=nrotraj; %last frame with trc
handles.dataframe=dataframe;  % frame data

%lastframe
laststr=get(handles.lastframe,'string');
if isempty(laststr)==0
    last=str2num(laststr);
    if last==1
        set(handles.lastframe,'string',num2str(dataframe(4)));
    end
end

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)

if handles.background==0
    msgbox('No movie file!','Error','error')
    return
end

filename = (handles.background);
trcfile = (handles.traject);
synflag=handles.localiz;
tlag=str2num(handles.tlag);
nfram=handles.param(3);
delay=str2num(handles.delay);

if synflag==1
    answer=findstr(trcfile,'deco');
    if isempty(answer)==1
            msgbox('To distinguish localization enter a deconnected traces file','Error','error')
            return
    end
end

%positions
firstframe=str2num(get(handles.firstframe,'string')); % value entered
lastframechoose=str2num(get(handles.lastframe,'string'));
dataframe=handles.dataframe;  % frame data
lasttrcframe=dataframe(4);

if nfram>lasttrcframe
    lastframe=nfram;
else
    lastframe=lasttrcframe;
end
if lastframe>lastframechoose
    stopframe=lastframechoose;
else
    stopframe=lastframe;
end

dataframe(1)=firstframe; %first frame
dataframe(2)=firstframe; %actual frame
dataframe(3)=stopframe; %last frame
handles.dataframe=dataframe;  % frame data

% movie
%waitbarhandle=waitbar( 0,'Stream visualization','Name',['Frame ',firstframe]) ;
   
for frame=firstframe:stopframe
       dataframe(2)=frame; %actual frame
       handles.dataframe=dataframe;  % frame data
       showbackground(handles);
       hold on
       showtraj(handles);
        hold off
        pause(delay/1000);
        %if exist('waitbarhandle')
        %    waitbar(frame/stopframe,waitbarhandle,['Frame # ',frame]);
        % end
end

dataframe=handles.dataframe;  % frame data
dataframe(1)=firstframe; %first frame
dataframe(2)=stopframe; %actual frame
dataframe(3)=stopframe; %last frame
dataframe(4)=lasttrcframe; %last frame with trc
handles.dataframe=dataframe;  % frame data

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in avibutton.
function avibutton_Callback(hObject, eventdata, handles)

dataframe=handles.dataframe;  % frame data
firstframe=str2num(get(handles.firstframe,'string'));
lastframe=str2num(get(handles.lastframe,'string'));
%lastframe=dataframe(3);
Ydim=handles.param(2);
Xdim=handles.param(1);

prompt = {'File name ','Frames per second'};
num_lines= 1;
dlg_title = '.avi file';
def = {'movie','5'}; % default values
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);
   if exit(1) == 0;
       return; 
   end
savename=answer{1};
speed=str2num(answer{2});

if firstframe>lastframe
    msgbox('Wrong values','error','error')
    return
end

%figure;
axes(handles.axes1);

for nroframe=firstframe:lastframe
    dataframe(2)=nroframe;  % frame data
    handles.dataframe=dataframe;
    %image
    showbackground(handles)
    hold on
    %trajectories
    showtraj(handles)
    hold off
    peli(nroframe)=getframe(gca);  % gets the figure for the movie
end

% avi file
msgbox(['Saving avi file ',savename])
set(gca,'xlim',[0 500],'ylim',[0 500],'NextPlot','replace','Visible','off');
movi = avifile(savename,'compression','none','fps',speed,'quality',100)
%movi = avifile(savename,'compression','CinePak','fps',speed,'quality',100)
movi = addframe(movi,peli);
movi = close(movi);
close %msgbox

showbackground(handles)
hold on
showtraj(handles)
hold off

%end
axes(handles.axes1)

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in backbutton.
function backbutton_Callback(hObject, eventdata, handles)

nfram=handles.param(3);
dataframe=handles.dataframe;  % frame data
actualframe=dataframe(2); %actual frame
lasttrcframe=dataframe(4); %last frame with trc

if nfram>lasttrcframe
    lastframe=nfram;
else
    lastframe=lasttrcframe;
end
if actualframe-1>0
    actualframe=actualframe-1;
else
    actualframe=1;
end
axes(handles.axes1);

dataframe(2)=actualframe; %actual frame
dataframe(3)=lastframe; %last frame
handles.dataframe=dataframe;  % frame data

set(handles.go,'userdata',actualframe); % new actualframe
set(handles.text11,'string',['Frame = ',num2str(actualframe),' (of ',num2str(lastframe),')']);
showbackground(handles)
hold on
showtraj(handles)
hold off;

guidata(gcbo,handles) ;

%--------------------------------------------------------------------------
% --- Executes on button press in forwardbutton.
function forwardbutton_Callback(hObject, eventdata, handles)

nfram=handles.param(3);
dataframe=handles.dataframe;  % frame data
actualframe=dataframe(2); %actual frame
lasttrcframe=dataframe(4); %last frame with trc

if nfram>lasttrcframe
    lastframe=nfram;
else
    lastframe=lasttrcframe;
end
if actualframe+1<lastframe+1
    actualframe=actualframe+1;
else
    actualframe=lastframe;
end
axes(handles.axes1);

dataframe(2)=actualframe; %actual frame
dataframe(3)=lastframe; %last frame
handles.dataframe=dataframe;  % frame data

set(handles.text11,'string',['Frame = ',num2str(actualframe),' (of ',num2str(lastframe),')']);
set(handles.go,'userdata',actualframe) % new actualframe
showbackground(handles)
hold on;
showtraj(handles)
hold off;

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showbackground(handles)
% shows spe, stk or tif images (one or more)

typefile=handles.typefile;
XDim=(handles.param(1));
YDim=(handles.param(2));
Nfram=(handles.param(3));
dataframe=handles.dataframe;  % frame data
actualframe=dataframe(2); %actual frame
lastframe=dataframe(3);
tlag=str2num(handles.tlag);
name=get(handles.file1,'string');
imagedim=[num2str(XDim),' x ',num2str(YDim)];
set(handles.imagedim,'string',imagedim);

if typefile<4                                       % salvo merge: lee matriz
   framematrix=get(handles.file1,'userdata'); %image
   
 if Nfram>1
   if actualframe==1
      firsty=actualframe;
      lasty=YDim;
   else
      firsty=(actualframe-1)*YDim+1;
      lasty=firsty+YDim-1;
   end
   if typefile==0 
        datamatrix=framematrix(firsty:lasty,:); %spe
   else
        datamatrix=framematrix(actualframe).data; %stk
   end
   
 else % one image
   datamatrix=framematrix(:,:); %para todos
 end
 
end

%figure
plottraj=get(handles.plottraj,'value');
if plottraj==0
   axes(handles.axes1);
else
   figure;  % for plotting trajectories over one image
end
axis([0 XDim 0 YDim]);
set(handles.text11,'string',['Frame = ',num2str(actualframe),' (of ',num2str(lastframe),')']);

if typefile==0
          datamatrix=datamatrix-min(min(datamatrix));
          datamatrix=abs(datamatrix/max(max(datamatrix)));
          imshow(datamatrix,'notruesize');
          hold on
      else
          if typefile== 3
              %imshow(datamatrix,'notruesize');
              tiffile=get(handles.file1,'string'); % tif no metamorph
              imshow(tiffile,'notruesize');
              hold on;
          elseif typefile== 1 | typefile==2
              stackmin=(min(min(min(datamatrix))));
              stackmax=(max(max(max(datamatrix))));
              imshow((datamatrix(:,:,1)),[stackmin stackmax],'notruesize');
              hold on
         elseif typefile== 4
             datamatrix=showmerge(handles);
             imshow(datamatrix,'notruesize');
             hold on
          end
end

resx=XDim/4;
resy=YDim/18;
time=actualframe*tlag;
switch handles.time
       case 1
       text((XDim/20),(YDim-resy),sprintf('Frame : %0.0f',actualframe),'Color',[1 1 1]);
       case 2
       text((XDim/20),(YDim-resy),sprintf('Time : %0.0f',time),'Color',[1 1 1]);
end    
if handles.title==1
     text ((XDim/20), resy, sprintf (name),'Color',[1 1 1]);
end
  %    plot(XDim,YDim,'.k');  %just no avoid crash!
 %     hold on     


guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showtraj(handles)
% for each frame, makes an array with traces of the molecules and plots them

x=get(handles.filetrc,'userdata'); %trc data
molnro=handles.nromolecule;
k=strfind(molnro,'all');
if isempty(k)==0
    plotall=1;
else
    plotall=0;
    moltoshow=str2num(molnro);
end

if isempty(x)==0  % if the trc file is loaded
    
axes(handles.axes1);
Xdim=(handles.param(1));
Ydim=(handles.param(2));
axis([0 Xdim 0 Ydim]);

synflag=handles.localiz;
tlag=str2num(handles.tlag);
blinking=handles.blink;
name=get(handles.file1,'string');
dataframe=handles.dataframe;  % frame data
actualframe=dataframe(2); %actual frame
lastframe=dataframe(3);
codenormal=handles.colalltraj;
codecol=codenormal;
indexmol=[];
indexframes=[];
actualtraces=[];
indexmolblink=[];
indexmolafter=[];
indexpointsafter=[];
maxmol=max(x(:,1));
    
for nromol=1:maxmol
    actualtraces=[];
    indextracemol=[];
    count=1;
    j=1;
    if plotall==0; % called by plottraj
            indextracemol=[];
          if nromol==moltoshow;
            indextracemol=find(x(:,1)==nromol); % all points of the molecule nromol
         end
     else
         indextracemol=find(x(:,1)==nromol); % all points of the molecule nromol
    end
    if isempty(indextracemol)==0
        if x(indextracemol(1),2)<actualframe+1 % mol present at this frame or before
           if x(max(indextracemol(:)),2)>actualframe-1 % if it is present now or after
               while j<size(indextracemol,1)+1    
                   if x(indextracemol(j),2)<actualframe+1    %picks the points that happen before actualtraces
                      actualtraces(count,:)=x(indextracemol(j),:);
                      count=count+1;
                      j=j+1;
                   else
                      j=size(indextracemol,1)+1; %array finished
                   end
               end
           end
        end
     end
     [j,col]=size(actualtraces);
     j=j+1;
    
     if col>0 % array not empty
            
        if synflag==1
          if actualtraces(j-1,6)<0 %peri
             codecol=handles.colperitraj;
          elseif actualtraces(j-1,6)>0 %syn
             codecol=handles.colsyntraj;
          elseif actualtraces(j-1,6)==0 %extra
             codecol=handles.colextratraj;
          end
        end
        codenormal=codecol;
        if blinking==1 % blinking
            presence=find(actualtraces(:,2)==actualframe);  % present at actualframe
            if isempty(presence)==1 
                codecol=handles.colblinktraj;
            else
                codecol=codenormal;
            end
        end
        if handles.mia==1
           plot((actualtraces(:,3)+1),(actualtraces(:,4)+1),codecol,'Linewidth',1.5);
        else
           plot(actualtraces(:,3),actualtraces(:,4),codecol,'Linewidth',1.5);
        end
        
        if handles.identify==1
           text(actualtraces(j-1,3)+1,actualtraces(j-1,4)+1,sprintf('%0.0f',actualtraces(j-1,1)),'Color',[1 1 0]);
           cifras=num2str(actualtraces(j-1,1)); space=size(cifras,2);
           text(actualtraces(j-1,3)+(space*5),actualtraces(j-1,4)+1,sprintf('(%0.0f)',(j-1)),'Color',[1 1 1],'FontSize',7);
        end

        hold on
      end %array empty

      plot(Xdim,Ydim,'.k');  %just no avoid crash!
      hold on     

 %end of general loop 
end

      plot(Xdim,Ydim,'.k');  %just no avoid crash!
      hold on     

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in plottraj.
function plottraj_Callback(hObject, eventdata, handles)

set(handles.plottraj,'value',1);
prevchoice=handles.time;
handles.time=3;

if handles.background==0
    msgbox('No background file!','Error','error')
    return
end
if handles.traject==0
    msgbox('No traces file!','Error','error')
    return
end

filename = (handles.background);
molnro=handles.nromolecule;
k=strfind(molnro,'all');
if isempty(k)==0
    plotall=1;
else
    plotall=0;
    nromol=str2num(molnro);
end

x=get(handles.filetrc,'userdata'); %trc data
[totfilas, columns] = size (x);

name=handles.name;
synflag=handles.localiz;
%rainbow=0;
option=1; 
trcname=get(handles.filetrc,'string');
if synflag==1
    k=strfind(trcname,'syn');
    if isempty(k)==1
            msgbox('To distinguish localization enter a syn traces file','Error','error')
            synflag=0;
    end
end

%background
showbackground(handles)
hold on;

% graph array to plot
for nro=1:max(x(:,1))     
    graph=[];
    if plotall==0
       if nromol==nro
          molcorrecta=1;
       else 
          molcorrecta=0;
       end
    else
       molcorrecta=1;
    end
    filcol=1;
    if molcorrecta==1
       graphindex=find(x(:,1)==nro);
       if isempty(graphindex)==0 
           [f,c]=size(graphindex);
        if f>3
          control=1;
          graph(1:f,:)=x(graphindex(1:f),:);
          codecol=handles.colalltraj;
          
           %if rainbow==1
           if synflag==1
              if graph(1,6)<0
                 rainbowcol=handles.colperitraj;
              else
                 if graph(1,6)==0;
                    rainbowcol=handles.colextratraj;
                 else
                    rainbowcol=handles.colsyntraj;
                 end
              end
              for u=2:f
                  step(1,1)=graph (u-1,3) ;
                  step(1,2)=graph (u-1,4);
                  step(2,1)=graph (u,3);
                  step(2,2)=graph (u,4);
                  if graph(u,6)==graph(u-1,6)
                  else
                        if graph(u,6)<0
                           rainbowcol=handles.colperitraj;
                        else
                           if graph(u,6)==0;
                              rainbowcol=handles.colextratraj;
                           else
                              rainbowcol=handles.colsyntraj;
                           end
                        end
                    end
                    if handles.mia==1
                       plot ((step (:,1)+1), (step (:,2)+1),rainbowcol,'Linewidth',1.5);   % grafica traces
                    else
                       plot ((step (:,1)), (step (:,2)),rainbowcol,'Linewidth',1.5);   % grafica traces
                    end
                 end  
             else
                 if handles.mia==1
                    plot ((graph (:,3)+1), (graph (:,4)+1), codecol,'Linewidth',1.5);   % grafica traces
                 else
                    plot ((graph (:,3)), (graph (:,4)), codecol,'Linewidth',1.5);   % grafica traces
                 end
         end
         if handles.identify==1
            text(graph(1,3),graph(1,4),sprintf('%0.0f',graph(1,1)),'Color',[1 1 0]);
       end
       hold on
     end
   end % at least 3 frames
  end   % not empty
end   % general loop
hold off
        
handles.time=prevchoice;

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in saveimage.
function saveimage_Callback(hObject, eventdata, handles)

[filename,path] = uiputfile('.tif','Save image as') ;
if filename==0
    return
end
presentimage=getframe(gca);  % gets the figure for the movie
[image,Map] = frame2im(presentimage);
imwrite(image,[path,filename],'tif');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MERGING
% --- Executes on button press in merge.
function merge_Callback(hObject, eventdata, handles)

handles.maxfram=[];
movie1=[];
movie2=[];
count=1;
grayname=get(handles.grayname,'string');
redname=get(handles.redname,'string');
greenname=get(handles.greenname,'string');
bluename=get(handles.bluename,'string');
fgray=str2num(handles.factorgray); % contraste
fred=str2num(handles.factorred);
fgreen=str2num(handles.factorgreen);
fblue=str2num(handles.factorblue);
handles.movie1=[];
handles.movie2=[];


set(handles.file1,'string','merged');
handles.background=get(handles.file1,'string');
set(handles.file1,'string','Merged image');

msgbox('Reading files...');

% image DIC
if isempty(grayname)==0
    grayimage=get(handles.grayname,'userdata');
    grayparam=handles.grayparam;
    graynfram=grayparam(3);
    handles.maxfram(count)=1;count=count+1;
    imagegray=grayimage;
    Xdim=grayparam(1);
    Ydim=grayparam(2);
    clear grayimage;
    imagegray=imagegray-min(min(imagegray));
    imagegray=abs(imagegray/max(max(imagegray)));
    handles.rgbgray=cat(3,imagegray,imagegray,imagegray); %dic gris
    handles.rgbgray = immultiply(handles.rgbgray,fgray); 
else
    graynfram=0;
    handles.grayparam=[0,0,0];
end


% red, green, blue
if isempty(redname)==0
    redimage=get(handles.redname,'userdata');
    redparam=handles.redparam;
    rednfram=redparam(3);
    handles.maxfram(count)=redparam(3);count=count+1;
        % transforma la imagen o la primera imagen si es una movie
    if rednfram>1
        if handles.redtypefile==0
           imagered=redimage(1:redparam(2),:);
        else
           imagered=redimage(1).data;
       end
       if isempty(handles.movie1)==1
          handles.movie1=redimage;
          handles.typefile1=handles.redtypefile;
          handles.Xdim1=redparam(1);
          handles.Ydim1=redparam(2);
          handles.color1=2;
       else
          handles.movie2=redimage;
          handles.typefile2=handles.redtypefile;
          handles.Xdim2=redparam(1);
          handles.Ydim2=redparam(2);
          handles.color2=2;
       end
       clear redimage;
    else
        imagered=redimage;
    end
    Xdim=redparam(1);
    Ydim=redparam(2);
       imagered=imagered-min(min(imagered));
       imagered=abs(imagered/max(max(imagered)));
       handles.rgbred=cat(3,imagered,zeros(Ydim,Xdim),zeros(Ydim,Xdim)); %rojo
       handles.rgbred = immultiply(handles.rgbred,fred); 
else
    rednfram=0;
    handles.redparam=[0,0,0];
end

if isempty(greenname)==0
    greenimage=get(handles.greenname,'userdata');
    greenparam=handles.greenparam;
    greennfram=greenparam(3);
    handles.maxfram(count)=greenparam(3);count=count+1;
        % transforma la imagen o la primera imagen si es una movie
    if greennfram>1
        if handles.greentypefile==0
           imagegreen=greenimage(1:greenparam(2),:);
        else
           imagegreen=greenimage(1).data;
       end
       if isempty(handles.movie1)==1
          handles.movie1=greenimage;
          handles.typefile1=handles.greentypefile;
          Xdim1=greenparam(1);
          Ydim1=greenparam(2);
          handles.color1=3;
       else
          handles.movie2=greenimage;
          handles.typefile2=handles.greentypefile;
           handles.Xdim2=greenparam(1);
          handles.Ydim2=greenparam(2);
          handles.color2=3;
       end
       clear greenimage;
    else
        imagegreen=greenimage;
    end
        Xdim=greenparam(1);
    Ydim=greenparam(2);
       imagegreen=imagegreen-min(min(imagegreen));
       imagegreen=abs(imagegreen/max(max(imagegreen)));
       handles.rgbgreen=cat(3,zeros(Ydim,Xdim),imagegreen,zeros(Ydim,Xdim)); %verde
       handles.rgbgreen = immultiply(handles.rgbgreen,fgreen); 
else
    greennfram=0;
    handles.greenparam=[0,0,0];
end

if isempty(bluename)==0
    blueimage=get(handles.bluename,'userdata');
    blueparam=handles.blueparam;
    bluenfram=blueparam(3);
    handles.maxfram(count)=blueparam(3);count=count+1;
        % transforma la imagen o la primera imagen si es una movie
    if bluenfram>1
        if handles.bluetypefile==0
           imageblue=blueimage(1:blueparam(2),:);
        else
           imageblue=blueimage(1).data;
       end
       if isempty(handles.movie1)==1
          handles.movie1=blueimage;
          handles.typefile1=handles.bluetypefile;
          handles.Xdim1=blueparam(1);
          handles.Ydim1=blueparam(2);
          handles.color1=4;
       else
          handles.movie2=blueimage;
          handles.typefile2=handles.bluetypefile;
          handles.Xdim2=blueparam(1);
          handles.Ydim2=blueparam(2);
          handles.color2=4;
       end
       clear blueimage;
    else
        imageblue=blueimage;
    end        
    Xdim=blueparam(1);
    Ydim=blueparam(2);

       imageblue=imageblue-min(min(imageblue));
       imageblue=abs(imageblue/max(max(imageblue)));
       handles.rgbblue=cat(3,zeros(Ydim,Xdim),zeros(Ydim,Xdim),imageblue); %azul
       handles.rgbblue = immultiply(handles.rgbblue,fblue); 
else
    bluenfram=0;
    handles.blueparam=[0,0,0];
end

nfram=max(handles.maxfram);
for r=1:size(handles.maxfram,2)  % ojo si las movies tienen nro frame distinto
    if handles.maxfram(r)>1
        if handles.maxfram(r)<nfram
            nfram=handles.maxfram(r);
        end
    end
end

close %msgbox

% poner todo en handles

handles.dataframe(2)=1;  % frame data
handles.dataframe(3)=nfram;  % frame data

handles.param=[Xdim,Ydim,nfram];
handles.typefile=4;
showbackground(handles);

guidata(gcbo,handles) ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function finalimage=showmerge(handles)
% prepares the merged image for showbackground


Xdim=(handles.param(1));
Ydim=(handles.param(2));
nfram=(handles.param(3));
dataframe=handles.dataframe;  % frame data
actualframe=dataframe(2); %actual frame
lastframe=dataframe(3);
rednfram=handles.redparam(3);
greennfram=handles.greenparam(3);
bluenfram=handles.blueparam(3);
graynfram=handles.grayparam(3);
fgray=str2num(handles.factorgray); % contraste
fred=str2num(handles.factorred);
fgreen=str2num(handles.factorgreen);
fblue=str2num(handles.factorblue);
finalimage=[];

%if actualframe==1
   K1=[];

  % suma imagenes para la primera imagen
  if rednfram==1 
        if greennfram==1 
            if handles.redparam(1)==handles.greenparam(1) & handles.redparam(2)==handles.greenparam(2) 
                K1=imadd(handles.rgbred,handles.rgbgreen);
                Xdim=(handles.redparam(1));
                Ydim=(handles.redparam(2));
            else
                msgbox('Images must have the same size','error','error');
                return
            end
                if bluenfram==1 
                    if handles.redparam(1)==handles.blueparam(1) & handles.redparam(2)==handles.blueparam(2) 
                       K1=imadd(K1,handles.rgbblue);
                       Xdim=(handles.redparam(1));
                       Ydim=(handles.redparam(2));
                    else
                       msgbox('Images must have the same size','error','error');
                       return
                    end
                end
         else
            if bluenfram==1 
                if handles.redparam(1)==handles.blueparam(1) & handles.redparam(2)==handles.blueparam(2) 
                   K1=imadd(handles.rgbred,handles.rgbblue);
                   Xdim=(handles.redparam(1));
                   Ydim=(handles.redparam(2));
                else
                       msgbox('Images must have the same size','error','error');
                       return
                end
            else
               K1=handles.rgbred;
               Xdim=(handles.redparam(1));
               Ydim=(handles.redparam(2));
            end
         end % greennfram
  else   %rednfram
    if greennfram==1 
                if bluenfram==1 
                    if handles.greenparam(1)==handles.blueparam(1) & handles.greenparam(2)==handles.blueparam(2) 
                        K1=imadd(handles.rgbgreen,handles.rgbblue);
                        Xdim=(handles.greenparam(1));
                        Ydim=(handles.greenparam(2));
                   else
                       msgbox('Images must have the same size','error','error');
                       return
                   end
                else
                    K1=handles.rgbgreen;
                    Xdim=(handles.greenparam(1));
                    Ydim=(handles.greenparam(2));
                end
    else
        if bluenfram==1 
              K1=handles.rgbblue;
              Xdim=(handles.blueparam(1));
              Ydim=(handles.blueparam(2));
        else
        end
    end   % greennfram
  end  %rednfram
  % mascara binaria si hay DIC
  if graynfram==1 
    if handles.grayparam(1)==Xdim & handles.grayparam(2)==Ydim; 
        if isempty(K1)==0   % hay otro color
           level = graythresh(K1);
           BW = im2bw(K1,level);
           rgbbw=cat(3,BW,BW,BW); 
           coloc=rgbbw & handles.rgbgray;                      % resta la mascara a la imagen DIC (grayscale)
           coloc=immultiply(coloc,handles.rgbgray);
           rest=imabsdiff(handles.rgbgray,coloc);
           finalimage=imadd(K1,rest);
       else
           finalimage=handles.rgbgray; 
       end
    else
      msgbox('Images must have the same size','error','error');
      return
    end
  else
    finalimage=K1;
  end
  nfram=max(handles.maxfram);
  for r=1:size(handles.maxfram,2)  % ojo si las movies tienen nro frame distinto
    if handles.maxfram(r)>1
        if handles.maxfram(r)<nfram
            nfram=handles.maxfram(r);
        end
    end
  end
  % grabar resultado primera imagen
  handles.param=[Xdim, Ydim, nfram];
  set(handles.file1,'userdata',finalimage);
  %handles.K1=K1;

  %else  % ya tiene la suma para la primera imagen

 % finalimage=get(handles.file1,'userdata');
  %K1=cat(3,zeros(Ydim,Xdim),zeros(Ydim,Xdim),zeros(Ydim,Xdim));
 % K1=handles.K1;
  
  if nfram>1                                                         % hay movie!
    %if actualframe==1;
   %     frame=2
   % else
   maxK1=max(max(max(K1)));
   minK1=min(min(min(K1)));
        frame=actualframe;
        % end
      if handles.typefile1==0  
         firsty=((frame-1)*Ydim)+1;
         lasty=firsty+Ydim-1;
         imagemovie1=handles.movie1(firsty:lasty,:);
      else
        imagemovie1=handles.movie1(frame).data;
      end
      
      if max(max(imagemovie1))>maxK1
          imagemovie1=imagemovie1-minK1;
          imagemovie1=imagemovie1-min(min(imagemovie1));
          imagemovie1=abs(imagemovie1/maxK1);
          
      elseif max(max(imagemovie1))==0
          imagemovie1=zeros(Ydim,Xdim);
      else
          imagemovie1=abs(imagemovie1/max(max(imagemovie1)));
          imagemovie1=imagemovie1-min(min(imagemovie1));
     end
      switch handles.color1
           case 1
           case 2
               rgbmovie1=cat(3,imagemovie1,zeros(Ydim,Xdim),zeros(Ydim,Xdim)); %rojo
               rgbmovie1=immultiply(rgbmovie1,fred); 
           case 3
               rgbmovie1=cat(3,zeros(Ydim,Xdim),imagemovie1,zeros(Ydim,Xdim)); %verde
               rgbmovie1=immultiply(rgbmovie1,fgreen); 
           case 4
               rgbmovie1=cat(3,zeros(Ydim,Xdim),zeros(Ydim,Xdim),imagemovie1); %azul
               rgbmovie1=immultiply(rgbmovie1,fblue); 
      end
      
      K1m=imadd(K1,rgbmovie1);

      if isempty(handles.movie2)==0
         if handles.typefile2==0  
            firsty=((frame-1)*Ydim)+1;
            lasty=firsty+Ydim-1;
             imagemovie2=handles.movie2(firsty:lasty,:);
         else
            imagemovie2=handles.movie2(frame).data;
         end
         imagemovie2=imagemovie2-min(min(imagemovie2));
         imagemovie2=abs(imagemovie2/max(max(imagemovie2)));
         switch handles.color2
           case 1
           case 2
               rgbmovie2=cat(3,imagemovie2,zeros(Ydim,Xdim),zeros(Ydim,Xdim)); %rojo
               rgbmovie2=immultiply(rgbmovie2,fred); 
           case 3
               rgbmovie2=cat(3,zeros(Ydim,Xdim),imagemovie2,zeros(Ydim,Xdim)); %verde
               rgbmovie2=immultiply(rgbmovie2,fgreen); 
           case 4
               rgbmovie2=cat(3,zeros(Ydim,Xdim),zeros(Ydim,Xdim),imagemovie2); %azul
               rgbmovie2=immultiply(rgbmovie2,fblue); 
         end
         K1m=imadd(K1m,rgbmovie2);
     end
     
     % suma
     if graynfram>0
        level = graythresh(K1m);
        BW = im2bw(K1m,level);
        rgbbw=cat(3,BW,BW,BW); 
       % rgbbw=cat(3,imagemovie1,imagemovie1,imagemovie1); 
        coloc=rgbbw&handles.rgbgray;                      % resta la mascara a la imagen DIC (grayscale)
        coloc=immultiply(coloc,handles.rgbgray);
        rest=imabsdiff(handles.rgbgray,coloc);
        finalimage=imadd(K1m,rest);
     else
               finalimage=K1m;
     end

     handles.param=[Xdim, Ydim, nfram];
     set(handles.file1,'userdata',finalimage);

  end    % nfram

  %end   % actualframe

handles.typefile=4;
dataframe(3)=nfram; %last frame
stopframe=dataframe(4);
if nfram>stopframe
   dataframe(4)=nfram; %last frame with trc
end
set(handles.lastframe,'string',num2str(dataframe(4)));
handles.dataframe=dataframe;  % frame data
handles.firstf=1;
set(handles.firstframe,'string','1');
handles.lastf=nfram;

%buttons
set(handles.go,'enable','on');  
set(handles.avibutton,'enable','on');  
set(handles.backbutton,'enable','on');  
set(handles.forwardbutton,'enable','on');  
set(handles.plottraj,'enable','on'); 
set(handles.saveimage,'enable','on');  
guidata(gcbo,handles) ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [datamatrix,Xdim,Ydim,nfram,stktrue]=readimage(filename)

stktrue=0;
%msgbox('Reading file...');
answer=findstr(filename,'.spe'); answerb=findstr(filename,'.SPE');
if isempty(answer)==1 & isempty(answerb)==1
            answer2=findstr(filename,'.stk');
            if isempty(answer2)==1
                answer3=findstr(filename,'.tif');
                if isempty(answer3)==1
                    answer4=findstr(filename,'.mat');
                    if isempty(answer4)==1
                       msgbox('Wrong type of file','Error','error');
                       return
                   else
                       % mat file, producto de cosmepeaks
                       %[namefile,rem]=strtok(filename,'.'); %sin extension
                       %pathmovie=['\MATLAB6p5p1\',namefile,'.mat'];
                       mov=load(filename);
                       mov = struct2cell(mov);
                       movie=mov{1};
                       ImagePar=movie.imagepar;
                       Xdim=ImagePar(1)
                       Ydim=ImagePar(2)/ImagePar(4)
                       nfram=ImagePar(4)
                       datamatrix=movie.image';
                      % disp(size(datamatrix))
                       clear mov, movie
                       
                       %set(handles.file1,'userdata',datamatrix); %images
                       %typefile=0;  % lo lee como .spe
                   end
                else
                    % .tif file       
                    [stack_info,datamatrix] = tifdataread(filename);
                    Xdim=stack_info.x;
                    Ydim=stack_info.y;
                    stktrue=2;
                    [fil,col]=size(datamatrix);               
                    if col/Xdim==3  %rgb
                        stktrue=3;
                    else
                        datamatrix=double(datamatrix);
                    end
                    nfram=1;
                end
            else
                 % .stk file       
                 [stack_info,datamatrix] = stkdataread(filename);
                 Xdim=stack_info.x;
                 Ydim=stack_info.y;
                 nfram=stack_info.frames;
                 stktrue=1;
             end
        else
            % .spe file
            [datamatrix p]= spedataread (filename);
            Xdim=p(1);
            Ydim=p(2)/p(4);
            nfram=p(4);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trajcolor_Callback(hObject, eventdata, handles)


d1=handles.colalltraj ; %color code trajectories
d2=handles.colextratraj; 
d3=handles.colperitraj;
d4=handles.colsyntraj;
d5=handles.colblinktraj;

% dialog box to enter codes for trajectories color
prompt = {'Without localization ','Localization out of domains (extra: zero values)','Localization peri-domains (negative values)',...
           'Localization inside domains (positive values)','Blinking'};
num_lines= 1;
dlg_title = 'Enter codes for colors';
def = {d1,d2,d3,d4,d5}; % default values
msgbox('r: red, b: blue, g: green, y:yellow, w: white, m:magenta, c: cyan','Color codes','help')
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);

if exit(1) == 0;
   return; 
end
   
handles.colalltraj= answer{1};    %color code trajectories
handles.colextratraj=answer{2}; 
handles.colperitraj=answer{3}; 
handles.colsyntraj=answer{4}; 
handles.colblinktraj=answer{5}; 
close %msgbox

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function help_Callback(hObject, eventdata, handles)

open('C:\MATLAB6p5p1\tracklight\help\MovieMaker.pdf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)

clear all;
close;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


