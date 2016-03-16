function varargout = gaussiantrack(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GAUSSIANTRACK M-file for gaussiantrack.fig
%
% Launches MatLab programs to make tracking analysis
% Manages parameters: saving, reload, peaks detection,
% initial D. 
%
% MR - fev 06 - v 1.0                                           MatLab6p5p1
%
% Modified by Cezar M. Tigaret on 23/02/2007 to make file paths platform
% independent, using filesep function (MATLAB7)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last Modified by GUIDE v2.5 20-Mar-2006 22:04:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gaussiantrack_OpeningFcn, ...
                   'gui_OutputFcn',  @gaussiantrack_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes just before gaussiantrack is made visible.
function gaussiantrack_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

warning off MATLAB:break_outside_of_loop

%path
path=cd;
set(handles.datafolder,'string',path);
handles.folder=get(handles.datafolder,'string');
% set initial options for detection (default or modified by calibrationgui.m)
[options,cutoffs]=readdetectionoptions;
%set(handles.threshold,'string',num2str(options(9))); % threshold to detect a peak (opt(9))
%set(handles.edit8,'string',num2str(cutoffs(2))); % max intensity (cutoff2)

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Outputs from this function are returned to the command line.
function varargout = gaussiantrack_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creation functions: Executes during object creation, after setting all properties.

function datafolder_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function paramfile_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function threshold_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function Dpred_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function maxblink_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function maxdist_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit5_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit6_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit7_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit8_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit9_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit10_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function minpoints_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function moviefile_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data folder 
function datafolder_Callback(hObject, eventdata, handles)
% window
%--------------------------------------------------------------------------
function selectfolder_Callback(folderhObject, eventdata, handles)
% ask the path of the data 

warning off MATLAB:break_outside_of_loop
start_path=cd;
dialog_title=['Select data folder'];
datapath = uigetdir(start_path,dialog_title);
if datapath==0
    return
end
cd(datapath);
% by Cezar M. Tigaret 23/02/2007
% datapath=[datapath,'\'];
datapath=[datapath, filesep];

% reinitialize handles
set(handles.datafolder,'string',datapath);
handles.folder=get(handles.datafolder,'string');
set (handles.moviefile, 'string','') ; %cleans file name
handles.file=get(handles.moviefile, 'string');
set(handles.golocalize,'enable','off');
set(handles.calibratepushbutton,'enable','off');

%report
text=['Folder: ',handles.folder];
updatereport(handles,text,1) 

%check for previous analysis
previous=check(handles.folder);
    if previous>0
        set (handles.godetect, 'Enable','on')    ; %detec
        set (handles.goreconnect, 'Enable','on')    ; %reconnect
        set (handles.goMSD, 'Enable','on')    ; %msd
        set (handles.goD, 'Enable','on')    ; %fit
    else
        set (handles.godetect, 'Enable','off')    ; 
        set (handles.goreconnect, 'Enable','off')    ; 
        set (handles.goMSD, 'Enable','off')    ; 
        set (handles.goD, 'Enable','off')    ; 
    end
set(handles.datafolder,'value',previous);
    
%parameters

par=get(handles.paramfile,'value');
p=get(handles.paramfile,'string');
if par==0 %if nothing is loaded, loads default
% by Cezar M. Tigaret 23/02/2007
%    parfile=['\MATLAB6p5p1\tracklight\parameters\defaultpar.par'];
    tpath=fileparts(which('trackdiffusion.m'));
    parfile=fullfile(tpath, 'parameters','defaultpar.par');
    set(handles.paramfile,'value',1);
    loadparameters(parfile,handles);
    set(handles.paramfile,'string','defaultpar');
    handles.parameters=get(handles.paramfile,'string');
end
set (handles.saveparam,'enable','on'); 

%checks presence of localization images
st=[];
locMIA=0;
d=dir(datapath);
files={d.name};
  [fil,col]=size(files);
  j=1;
  while j<col+1
      filename=files{j};
      k=strfind(filename,'-loc_MIA'); % checks for MIA files
      if isempty(k)==0
         locMIA=1;
         break
     end
     j=j+1;
 end
 if locMIA>0
     set(handles.dolocalize,'value',1,'enable','on')
     set(handles.msdcut,'value',1)
 else
     set(handles.dolocalize,'value',0,'enable','off')
     set(handles.msdcut,'value',0)
 end

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters

function paramfile_Callback(hObject, eventdata, handles)
% ingreso por ventana
handles.parameters=get(hObject,'String');
set (handles.saveparam,'enable','on'); 
guidata(hObject, handles);

% --- Executes on button press in param.
function param_Callback(hObject, eventdata, handles)

% file selection
% by Cezar M. Tigaret 23/02/2007
% path=['\MATLAB6p5p1\tracklight\parameters\*.par'];
% loadpath=['\MATLAB6p5p1\tracklight\parameters\'];
tpath=fileparts(which('trackdiffusion.m'));
path=fullfile(tpath,'parameters','*.par');
loadpath=fullfile(tpath,'parameters');
if length(dir(path))>0
   d = dir(path);
   st = {d.name};
   [listafiles,v] = listdlg('PromptString','Select file:','SelectionMode','multiple','ListString',st);
   if v==0    %cancel
     return
   else
       fileparam=fullfile(loadpath,st{listafiles});
       [savename rem]=strtok(st{listafiles},'.');
       set (handles.paramfile,'value',1);
   end
else
    % no previous file: loads default
    % by Cezar M. Tigaret 24/10/2007
    fileparam=fullfile(loadpath,'defaultpar'); %ojo falta diferenciar entre gaussian y mia
    savename=['defaultpar'];    
    set(handles.paramfile,'value',0);
    set (handles.paramfile,'string','defaultpar'); % name of parameters file
    handles.parameters=get(handles.paramfile,'string');
end

loadparameters (fileparam,handles);
set (handles.paramfile,'string',savename); % name of parameters file
set (handles.saveparam,'enable','on'); 
handles.parameters=get(handles.paramfile,'string');

guidata(gcbo,handles) ;
%--------------------------------------------------------------------------
% --- Executes on button press in saveparam.
function saveparam_Callback(hObject, eventdata, handles)
% saves actual parameters file

savename=handles.parameters; % name of parameters file
savename=[savename,'.par'];
% by Cezar M. Tigaret on 24/10/2007
tpath=fileparts(which('trackdiffusion.m'));
% path=['\MATLAB6p5p1\tracklight\parameters\'];
savepath=fullfile(tpath,'parameters',savename);
saveparameters(savepath,handles);
guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load movies 
% --- Executes on button press in loadcomplete.
function loadcomplete_Callback(hObject, eventdata, handles)

% folder
path=get(handles.datafolder,'string');
handles.folder=get(handles.datafolder,'string');
% by Cezar M. Tigaret on 23/02/2007
% handles.folder=[handles.folder,'\'];
handles.folder=[handles.folder,filesep];
if isdir(path)
    currentdir=cd;
else
    path=cd;
    set(handles.datafolder,'string',path);
end

cd(path);
controlf=1;
st=[];
locMIA=0;
d=dir(path);
files={d.name};
  [fil,col]=size(files);
  j=1;
  while j<col+1
      filename=files{j};
      k=strfind(filename,'-loc_MIA'); % checks for MIA files
     if isempty(k)==0
         locMIA=1;
         break
     end
     j=j+1;
end
if locMIA>0
     set(handles.dolocalize,'value',1)
     set(handles.msdcut,'value',1)
else
     set(handles.dolocalize,'enable','off')
     set(handles.msdcut,'value',0)
end

%files
d=dir('*spe*');
st=[];
lista = {d.name};
if isempty(lista)==0 %.spe files
  % only movies
  j=1;
  [fil,col]=size(lista);
  for i=1:col
      filename=lista{i};
      filename = regexprep(filename,'.SPE','.spe');
      k=strfind(filename,'dic.spe');
      if isempty(k)==1
          k=strfind(filename,'loc.spe');
          if isempty(k)==1
             k=strfind(filename,'loc_MIA.spe');
             if isempty(k)==1
                k=strfind(filename,'gfp.spe');
                if isempty(k)==1
                   k=strfind(filename,'clu.spe');
                   if isempty(k)==1
                       st{j}=filename;  %only movies
                       j=j+1;
                   end
                end
             end
          end
      end
  end
end

d=dir('*stk*'); % .stk files
if isempty(st)==1
       st={d.name};
else
       st=[st,{d.name}];
end
if isempty(st)==1
     msgbox(['No files!!'],'','error');
     controlf=0;
     return
end
%choose data
[files,v] = listdlg('PromptString','Select files:','SelectionMode','multiple','ListString',st);
if v==0
     return
end
[f,ultimo]=size(files);
for i=1:ultimo
      listafiles{i}=st{files(i)};
end
handles.file=listafiles{1};
set(handles.moviefile,'userdata',listafiles);
handles.listafiles=get(handles.moviefile,'userdata');  %selected files
filename=handles.file; %first file
if ultimo>2 %batch
  set (handles.moviefile, 'string',['Batch: File ',filename,' (1/',num2str(ultimo),')']) ;
else
  set (handles.moviefile, 'string',handles.file) ;
end

%pushbuttons & radiobuttons
set (handles.calibratepushbutton, 'Enable','on');
set (handles.peakdetect, 'value',1);
set (handles.godetect, 'Enable','on');
set (handles.golocalize, 'Enable','on');

%parameters
par=get(handles.paramfile,'value');
if par==0
% by Cezar M. Tigaret on 24/10/2007
    tpath=fileparts(which('trackdiffusion.m'));
    parfile=fullfile(tpath,'parameters','defaultpar.par');
    set(handles.paramfile,'value',1);
    loadparameters(parfile,handles);
    set(handles.paramfile,'string','defaultpar');
    handles.parameters=get(handles.paramfile,'string');
end

%check for previous analysis
previous=check(handles.folder);
   if previous>0
        set (handles.goreconnect, 'Enable','on')    ; %reconnect
        set (handles.goMSD, 'Enable','on')    ; %msd
        set (handles.goD, 'Enable','on')    ; %fit msd
    else
        set (handles.goreconnect, 'Enable','off')    ; %reconnect
        set (handles.goMSD, 'Enable','off')    ; %msd
        set (handles.goD, 'Enable','off')    ; %fit msd
    end

set(handles.datafolder,'value',previous);

guidata(gcbo,handles) ;

%--------------------------------------------------------------------------
function moviefile_Callback(hObject, eventdata, handles)
% ingreso por ventana

path=get(handles.datafolder,'string')
handles.file=get(hObject,'String')
d = dir(path);
st = {d.name};
resp=find(st(:)==handles.file) % checks existence
filename=handles.file

if resp>0 
    set(handles.moviefile,'userdata',handles.file)
    handles.listafiles=get(handles.moviefile,'userdata');
    set (handles.calibratepushbutton, 'Enable','on');
    set (handles.peakdetect, 'value',1);
    set (handles.godetect, 'Enable','on');
    set (handles.golocalize, 'Enable','on');
else
    msgbox('File not found in the data folder','Enter movie file','error')
end

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calibration of detection
% --- Executes on button press in calibratepushbutton.
function calibratepushbutton_Callback(hObject, eventdata, handles)

ImagePar=[];
Image=[];
filename=handles.file;
handles.cutoff2=str2num(get(handles.edit8,'string'));
msgbox('Reading movie','Please wait...')

% movie
stktrue=0;
answer=findstr(filename,'.spe'); answerb=findstr(filename,'.SPE');
if isempty(answer)==1 & isempty(answerb)==1
            answer2=findstr(filename,'.stk');
            if isempty(answer2)==1
            else
                 % .stk file       
                 [stack_info,Image] = stkdataread(filename);
                 ImagePar(1)=stack_info.x;
                 ImagePar(2)=stack_info.y * stack_info.frames;
                 ImagePar(3)= 1;
                 ImagePar(4)= stack_info.frames;
                 ImagePar(5)= 1;
                 stktrue=1;
             end
        else
                  % .spe file
                 [Image ImagePar]= spedataread (filename);
end

% by Cezar M. Tigaret 23/02/07
% close %msgbox

thresh=get(handles.threshold,'string');
thresh=str2num(thresh);
[options,cutoffs] = calibrate (Image, ImagePar,thresh, handles,stktrue);
set(handles.threshold,'string',num2str(options(9))); % threshold to detect a peak (opt(9))
set(handles.edit8,'string',num2str(cutoffs(2))); % max intensity (cutoff2)
handles.opt7=num2str(options(7)); % with of Gaussian correlation function
handles.opt18=num2str(options(18)); % #pixels
   
 guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% complete analysis: selection of posibilities

% --- Executes on button press in peakdetect.
function peakdetect_Callback(hObject, eventdata, handles)
handles.detection=get(hObject,'value');
guidata(hObject, handles);

% --- Executes on button press in dolocalize.
function dolocalize_Callback(hObject, eventdata, handles)
handles.localization=get(hObject,'value');
guidata(hObject, handles);

% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% calculate MSD
handles.msd=get(hObject,'value');
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GO
% --- Executes on button press in golocalize>>>>>>>>>>>>>>>>>>>>>>>analyse
function golocalize_Callback(hObject, eventdata, handles)

% reads/loads parameters
handles.till=get (handles.edit7,'string');
handles.sizepixel=get (handles.edit6,'string');
handles.longfit=get (handles.edit5,'string');
handles.mintrace=get (handles.minpoints,'string');
handles.opt9=get (handles.threshold,'string');
handles.diffconst=get  (handles.Dpred,'string');
handles.intensityerror=get (handles.edit9,'string');
handles.maxintensity=get (handles.edit8,'string');
handles.maxpoints=get (handles.edit10,'string');
handles.blink=get (handles.maxblink,'string');
handles.distmax=get (handles.maxdist,'string');
deco=get(handles.dolocalize,'value'); % localization & deconnection
detectpk=get(handles.peakdetect,'value'); %peak detect
msdflag=get(handles.radiobutton6,'value'); %MSD and fit

%report
posrep=get(handles.report,'value');
if posrep<2
text=['Folder: ',handles.folder];
updatereport(handles,text,1) 
end
report=get(handles.report,'userdata');
posrep=get(handles.report,'value');
linearep{1}=['Parameters :'];
linearep{2}=['Threshold =',handles.opt9,'       Predicted D =',handles.diffconst];
linearep{3}=['Cutoffs : Intensity error = ',handles.intensityerror,'        Max intensity =',handles.maxintensity,'     Max points =',handles.maxpoints];
linearep{4}=['Max blink =',handles.blink,'      Max distance blink =',handles.distmax];
linearep{5}=['Acquisition time =',handles.till,'        Size pixel =',handles.sizepixel];
linearep{6}=['Min points =',handles.mintrace,'      Calculation of D: fit MSD over ',handles.longfit,' points.'];
linearep{7}=['  '];
for i=1:7
           report{posrep+1}=linearep{i};
           posrep=posrep+1;
           set(handles.report,'userdata',report);
end
set(handles.report,'value',posrep+1);
linearep={};

if detectpk==0
% by Cezar M. Tigaret on 23/02/2007
%   pkpath=[handles.folder,'\pk'];
   pkpath=fullfile(handles.folder,'pk');
   p=dir(pkpath);
   if isempty(p)==1
      msgbox('There is no previous peak detection, you must do it!','error','error')
      return
   end
   else
   if isdir('pk'); else; mkdir('pk'); end
   if isdir('trc'); else; mkdir('trc'); end
   if isdir('msd'); else; mkdir('msd'); end
   if isdir('ind'); else; mkdir('ind'); end
end

% dialog box to confirm selection
qstring=['Confirm selection?'];
button = questdlg(qstring); 
if strcmp(button,'Yes')
  else 
     return
end

% loop analysis
handles.listafiles=get(handles.moviefile,'userdata');
[fil, col]=size(handles.listafiles);
%report
c=fix(clock);
text=['Analysis started at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text);
text=[];

for nromovie=1:col
    file=handles.listafiles{nromovie}
    handles.file=file;
    str=['Batch: File ',file,' (',num2str(nromovie),'/',num2str(col),')'];
    set (handles.moviefile, 'string', str);
    %report
    text=['File: ',handles.file];
    updatereport(handles,text,2);
    % cada parte
    if detectpk==1
       detecttrack(file,handles);                                               % peak detection
    end
    rectrc=elongatetrack(file, handles);   % reconnection
    if length(rectrc)>0        
      [namefile,rem]=strtok(file,'.');
      deco=get(handles.dolocalize,'value'); % localization & deconnection
      if deco==1
        spelist=dir('*-loc_MIA.spe*');
        if isempty(spelist)==1
            domainfile=[namefile,'-loc_MIA.tif']
        else
            domainfile=[namefile,'-loc_MIA.spe'];
        end
        if length(dir(domainfile))>0
            %report
            text=['Domain file: ',domainfile];
            updatereport(handles,text)
            localizetrack(rectrc,domainfile,handles);                           %localization/cut
        else
            disp(['File ',domainfile,' not found']);
            %report
            text=['Domain file not found'];
            updatereport(handles,text)
            deco=0;
        end
      end
      if msdflag==1
         MSDtrack(file,handles);                                                %msd & fit
      end
    end
end

%report
c=fix(clock);
text=['Analysis finished at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text,3)

%pushbuttons
set (handles.goreconnect, 'Enable','on')    ; %reconnect
set (handles.goMSD, 'Enable','on')    ; %msd
set (handles.goD, 'Enable','on')    ; %fit

% saves actual parameters as default
savename=['defaultpar.par']; % name of parameters file
% by Cezar M. Tigaret on 23/02/2007
% path=['\MATLAB6p5p1\tracklight\parameters\'];
tpath=fileparts(which('trackdiffusion.m'));
savepath=fullfile(tpath,'parameters', savename);
saveparameters(savepath,handles);
figure(gaussiantrack); % to activate the figure
    
msgbox('Analysis finished. Actual parameters saved as defaultpar')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% partial analysis

% peak detection
% --- Executes on button press in godetect.
function godetect_Callback(hObject, eventdata, handles)
%peak detection and initial tracking

set(handles.moviefile,'string','');
set(handles.golocalize,'enable','off');

%initialize handles
handles.opt9=get (handles.threshold,'string');
handles.diffconst=get  (handles.Dpred,'string');
handles.intensityerror=get (handles.edit9,'string');
handles.maxintensity=get (handles.edit8,'string');
handles.maxpoints=get (handles.edit10,'string');

%report
posrep=get(handles.report,'value');
if posrep<2
text=['Folder: ',handles.folder];
updatereport(handles,text,1) 
end
report=get(handles.report,'userdata');
posrep=get(handles.report,'value');
linearep{1}=['Parameters :'];
linearep{2}=['Threshold =',handles.opt9,'       Pred D =',handles.diffconst];
linearep{3}=['Cutoffs : Intensity error = ',handles.intensityerror,'        Max intensity =',handles.maxintensity,'     Max points =',handles.maxpoints];
linearep{4}=['  '];
for i=1:4
           report{posrep+1}=linearep{i};
           posrep=posrep+1;
           set(handles.report,'userdata',report);
end
set(handles.report,'value',posrep+1);
linearep={};

%initialize variables
D=str2num(handles.diffconst);
cutoffs(1)=str2num(handles.intensityerror);
cutoffs(2)=str2num(handles.maxintensity);
cutoffs(3)=str2num(handles.maxpoints);

% creates directories
if isdir('pk'); else; mkdir('pk'); end
if isdir('trc'); else; mkdir('trc'); end
if isdir('msd'); else; mkdir('msd'); end
if isdir('ind'); else; mkdir('ind'); end

%selects files
path=cd;
controlf=1;
st=[];
d=dir('*spe*');
lista = {d.name};
if isempty(lista)==0 %.spe files
  % only movies
  j=1;
  [fil,col]=size(lista);
  for i=1:col
      filename=lista{i};
      filename = regexprep(filename,'.SPE','.spe');
      k=strfind(filename,'dic.spe');
      if isempty(k)==1
          k=strfind(filename,'loc.spe');
          if isempty(k)==1
             k=strfind(filename,'loc_MIA.spe');
             if isempty(k)==1
                k=strfind(filename,'gfp.spe');
                if isempty(k)==1
                   k=strfind(filename,'clu.spe');
                   if isempty(k)==1
                       st{j}=filename;  %only movies
                       j=j+1;
                   end
                end
             end
          end
      end
  end
end

d=dir('*stk*'); % .stk files
if isempty(st)==1
       st={d.name};
else
       st=[st,{d.name}];
end
if isempty(st)==1
     msgbox(['No files!!'],'','error');
     controlf=0;
     return
end
%choose data
[listafiles,v] = listdlg('PromptString','Select files:','SelectionMode','multiple','ListString',st);
if v==0
     return
end
[f,ultimo]=size(listafiles);
%report
c=fix(clock);
text=['Peak detection. Analysis started at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text)

% analysis
for cont=1:ultimo   % loop through the list
    filename=st{listafiles(cont)} ; % con extension
    if ultimo>2 %batch
       set (handles.moviefile, 'string',['Peak detection: File ',filename,' (',num2str(cont),'/',num2str(ultimo),')']) ;
    else
       set (handles.moviefile, 'string',['Peak detection: File ',filename]) ;
    end
    %report
    text=['File: ',handles.file];
    updatereport(handles,text,2)
    detecttrack(filename, handles);
end

%report
c=fix(clock);
text=['Analysis finished at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text,3)

set (handles.goreconnect, 'Enable','on')    ; %reconnection
msgbox('Atention: ONLY peak detection and tracking done')

guidata(gcbo,handles) ;

%---------------------------------------------------------
% reconnection

% --- Executes on button press in goreconnect.
function goreconnect_Callback(hObject, eventdata, handles)
% trajetories reconnection

set(handles.calibratepushbutton,'enable','off');
set(handles.golocalize,'enable','off');

%initialize handles
handles.mintrace=get (handles.minpoints,'string');
handles.opt9=get (handles.threshold,'string');
handles.diffconst=get  (handles.Dpred,'string');
handles.intensityerror=get (handles.edit9,'string');
handles.maxintensity=get (handles.edit8,'string');
handles.maxpoints=get (handles.edit10,'string');
handles.blink=get (handles.maxblink,'string');
handles.distmax=get (handles.maxdist,'string');

%report
posrep=get(handles.report,'value');
if posrep<2
text=['Folder: ',handles.folder];
updatereport(handles,text,1) 
end
report=get(handles.report,'userdata');
posrep=get(handles.report,'value');
linearep{1}=['Parameters :'];
linearep{2}=['Max blink =',handles.blink,'      Max distance blink =',handles.distmax];
linearep{3}=['  '];
for i=1:3
           report{posrep+1}=linearep{i};
           posrep=posrep+1;
           set(handles.report,'userdata',report);
end
set(handles.report,'value',posrep+1);
linearep={};

% files
currentdir=cd;
% by Cezar M. Tigaret on 23/02/2007
% path=[cd,'\trc'];
path=fullfile(cd,'trc');
cd(path);
controlf=1;
st=[];
d=dir('*trc*');
lista = {d.name};
if isempty(lista)==0 %.spe files
  % only .trc
  j=1;
  [fil,col]=size(lista);
  for i=1:col
      filename=lista{i};
      k=strfind(filename,'con');
      if isempty(k)==1
         st{j}=filename;  
         j=j+1;
     end
  end
end
if isempty(st)==1
     msgbox(['No trc files to reconnect!!'],'','error');
     cd(currentdir)
     return
end
%choose data
[listafiles,v] = listdlg('PromptString','Select files:','SelectionMode','multiple','ListString',st);
if v==0
    cd(currentdir)
     return
end
[f,ultimo]=size(listafiles);
cd(currentdir); % comes back

%report
c=fix(clock);
text=['Reconnection of trajectories. Analysis started at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text)

% analysis
for cont=1:ultimo   % all list
    filename=st{listafiles(cont)}; % con extension
    handles.file=filename;
    if ultimo>2 %batch
       set (handles.moviefile, 'string',['Trajectory reconnection: File ',filename,' (',num2str(cont),'/',num2str(ultimo),')']) ;
    else
       set (handles.moviefile, 'string',['Trajectory reconnection: File ',filename]) ;
    end
    pause(0.001) % to show waitbar
    %report
    text=['File: ',handles.file];
    updatereport(handles,text,2)
    rectrc=elongatetrack(filename, handles);
    % if there is -loc_MIA files, does the localization and cut
    [namefile,rem]=strtok(filename,'.');
    domainfile=[namefile,'-loc_MIA.spe'];
    if length(dir(domainfile))==0
        domainfile=[namefile,'-loc_MIA.tif'];
        if length(dir(domainfile))>0
            %report
            text=['Localization: Domain file: ',domainfile]; %tif
            updatereport(handles,text)
           localizetrack(rectrc,domainfile,handles);
       else
           %report
            text=['Domain file not found'];
            updatereport(handles,text)
        end
    else
        localizetrack(rectrc,domainfile,handles); %spe
        %report
        text=['Localization: Domain file: ',domainfile]; %tif
        updatereport(handles,text)
    end
end

%report
c=fix(clock);
text=['Analysis finished at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text,3)

set (handles.goMSD, 'Enable','on')    ; %MSD
msgbox('Atention: no MSD calculation done')

guidata(gcbo,handles) ;

%----------------------------------------------------------
% MSD

% --- Executes on button press in goMSD.
function goMSD_Callback(hObject, eventdata, handles)
% MSD calculation

set(handles.calibratepushbutton,'enable','off');
set(handles.golocalize,'enable','off');
currentdir=cd;
msddeco=get(handles.msdcut,'value');
% by Cezar M. Tigaret on 23/02/2007
if msddeco==0
%   path=[cd,'\trc'];
   path=fullfile(cd,'trc');
   tag='con';
else
%   path=[cd,'\trc\cut'];
   path=fullfile(cd,'trc','cut');
   tag='deco';
%   if isdir('msd\cut'); else; mkdir('msd\cut'); end
   if isdir(['msd',filesep,'cut']); else; mkdir(['msd',filesep,'cut']); end
end
if isdir(path)
else
    msgbox('Wrong folder!','error','error')
    return
end

%files
cd(path);
controlf=1;
st=[];
d=dir('*trc*');
lista = {d.name};
if isempty(lista)==0 %.spe files
  % only trc
  j=1;
  [fil,col]=size(lista);
  for i=1:col
      filename=lista{i};
      k=strfind(filename,tag);
      if isempty(k)==0
         st{j}=filename;  
         j=j+1;
      end
  end
end
if isempty(st)==1
     msgbox(['No trc files!!'],'','error');
     controlf=0;
     cd(currentdir)
     return
end
%choose data
[listafiles,v] = listdlg('PromptString','Select files:','SelectionMode','multiple','ListString',st);
if v==0
    cd(currentdir)
     return
end
[f,ultimo]=size(listafiles);
cd(currentdir); % comes back
%report
posrep=get(handles.report,'value');
if posrep<2
text=['Folder: ',handles.folder];
updatereport(handles,text,1) 
end
report=get(handles.report,'userdata');
posrep=get(handles.report,'value');
c=fix(clock);
text=['MSD calculation. Analysis started at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text)

%analysis
for cont=1:ultimo   % toda la lista de archivos
    filename=st{listafiles(cont)}; % con extension
    [namefile,rem]=strtok(filename,'.'); %sin extension
    handles.file=filename;
    disp('  ');
    disp(['MSD calculation for file ',filename]);
    %report
    text=['File: ',handles.file];
    updatereport(handles,text,2)
    waitbarhandle=waitbar( 0,'Please wait...','Name',['Calculating MSD in ',filename]);
    if ultimo>2 %batch
       set (handles.moviefile, 'string',['MSD calculation: File ',filename,' (',num2str(cont),'/',num2str(ultimo),')']) ;
    else
       set (handles.moviefile, 'string',['MSD calculation: File ',filename]) ;
    end
    pause(0.001) % to show wait bar
    if msddeco==0
% by Cezar M. Tigaret on 23/02/2007
%       trcfile=['trc\',namefile,'.con.trc'];
%       savename=['msd\',namefile,'.con.msd'] ;
       trcfile=fullfile('trc',[namefile,'.con.trc']);
       savename=fullfile('msd',[namefile,'.con.msd']);
    else
%       trcfile=['trc\cut\',namefile,'.deco.syn.trc'];
%       savename=['msd\cut\',namefile,'.deco.syn.msd']; 
       trcfile=fullfile('trc','cut',[namefile,'.deco.syn.trc']);
       savename=fullfile('msd','cut',[namefile,'.deco.syn.msd']); 
    end
    if length(dir(trcfile))>0
       trcdata=load(trcfile); 
       [msddata, fullmsddata]=newMSDTL(trcdata,150,waitbarhandle); %%%%%%%%%%% !!! MSD de 150 points au max
       save(savename,'msddata','-ascii'); 
       disp('  ');
       disp(['Results saved.']);
       %report
       text=['File: ',savename,' saved'];
       updatereport(handles,text)
       set(handles.goD,'enable','on')
    else
       disp('  ')
       disp(['File ',trcfile,' not found']);
       %report
       text=['File: ',trcfile,' not found'];
       updatereport(handles,text)
    end
    close(waitbarhandle)
end

%report
c=fix(clock);
text=['Analysis finished at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text,3)

set (handles.goD, 'Enable','on')    ; %fit
msgbox('Atention: MSD calculation done, without calculation of D')

guidata(gcbo,handles) ;
%-------------------------------------------------------------
% D calculation
% --- Executes on button press in goD.
function goD_Callback(hObject, eventdata, handles)
% fit of MSD

set(handles.calibratepushbutton,'enable','off');
set(handles.golocalize,'enable','off');
currentdir=cd;

%initialize handles
handles.till=get (handles.edit7,'string');
handles.sizepixel=get (handles.edit6,'string');
handles.longfit=get (handles.edit5,'string');
handles.mintrace=get (handles.minpoints,'string');
msddeco=get(handles.msdcut,'value');
till=str2num(handles.till);
sizepixel=str2num(handles.sizepixel);
minTrace=str2num(handles.mintrace);
longFIT=str2num(handles.longfit);

%report
posrep=get(handles.report,'value');
if posrep<2
text=['Folder: ',handles.folder];
updatereport(handles,text,1) 
end
report=get(handles.report,'userdata');
posrep=get(handles.report,'value');
linearep{1}=['Parameters :'];
linearep{2}=['Acquisition time =',handles.till,'        Size pixel =',handles.sizepixel];
linearep{3}=['Min points =',handles.mintrace,'      Calculation of D: fit MSD over ',handles.longfit,' points.'];
linearep{4}=['  '];
for i=1:4
           report{posrep+1}=linearep{i};
           posrep=posrep+1;
           set(handles.report,'userdata',report);
end
set(handles.report,'value',posrep+1);
linearep={};

% by Cezar M. Tigaret on 23/02/2007
if msddeco==0
%   path=[cd,'\msd'];
   path=fullfile(cd,'msd');
   tag='con';
%   if isdir('msd\fits\'); else; mkdir('msd\fits\'); end
   if isdir(['msd',filesep,'fits',filesep]); else; mkdir(['msd',filesep,'fits',filesep]); end
else
%   path=[cd,'\msd\cut'];
   path=fullfile(cd,'msd','cut');
   tag='deco';
%   if isdir('msd\cut\fits\'); else; mkdir('msd\cut\fits\'); end
   if isdir(['msd',filesep,'cut',filesep,'fits',filesep]); else; mkdir(['msd',filesep,'cut',filesep,'fits',filesep]); end
end
if isdir(path)
else
    msgbox('Wrong folder!','error','error')
    return
end

%files
cd(path);
controlf=1;
st=[];
d=dir('*msd*');
lista = {d.name};
if isempty(lista)==0 %.spe files
  % only msd
  j=1;
  [fil,col]=size(lista);
  for i=1:col
      filename=lista{i};
      k=strfind(filename,tag);
      if isempty(k)==0
         st{j}=filename;  
         j=j+1;
      end
  end
end
if isempty(st)==1
     msgbox(['No msd files!!'],'','error');
     controlf=0;
     cd(currentdir)
     return
 end
  
%choose data
[listafiles,v] = listdlg('PromptString','Select files:','SelectionMode','multiple','ListString',st);
if v==0
    cd(currentdir)
     return
end
[f,ultimo]=size(listafiles);
cd(currentdir); % comes back

%report
c=fix(clock);
text=['D calculation. Analysis started at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text)

%analysis
for cont=1:ultimo   % toda la lista de archivos
    filename=st{listafiles(cont)} % con extension
    handles.file=filename;
    disp('  ');
    disp(['Fitting MSD for file ',filename]);
    %report
    text=['File: ',handles.file];
    updatereport(handles,text,2)
    waitbarhandle=waitbar( 0,'Please wait...','Name',['Fitting MSD in ',filename]);
    if ultimo>2 %batch
       set (handles.moviefile, 'string',['MSD linear fit: File ',filename,' (',num2str(cont),'/',num2str(ultimo),')']) ;
    else
       set (handles.moviefile, 'string',['MSD linear fit: File ',filename]) ;
    end
    pause(0.001) % to show waitbar
    [namefile,rem]=strtok(filename,'.'); %sin extension
% by Cezar M. Tigaret on 23/02/2007
    if msddeco==0
%       msdfile=[cd,'\msd\',namefile,'.con.msd'];
%       trcfile=[cd,'\trc\',namefile,'.con.trc'];
%       savename=['msd\fits\',namefile,'.fit.con.msd']; 
       msdfile=fullfile(cd,'msd',[namefile,'.con.msd']);
       trcfile=fullfile(cd,'trc',[namefile,'.con.trc']);
       savename=fullfile('msd','fits',[namefile,'.fit.con.msd']); 
    else
%       msdfile=[cd,'\msd\cut\',namefile,'.deco.syn.msd'];
%       trcfile=[cd,'\trc\cut\',namefile,'.deco.syn.trc'];
%       savename=['msd\cut\fits\',namefile,'.fit.deco.syn.msd']; 
       msdfile=fullfile(cd,'msd','cut',[namefile,'.deco.syn.msd']);
       trcfile=fullfile(cd,'trc','cut',[namefile,'.deco.syn.trc']);
       savename=fullfile('msd','cut','fits',[namefile,'.fit.deco.syn.msd']); 
    end
    if length(dir(msdfile))>0
       if length(dir(trcfile))>0
          msddata=load(msdfile); 
          trcdata=load(trcfile); 
           if msddeco==0
           touslesfits=fitMSD(till,sizepixel,longFIT,minTrace,msddata,trcdata,msddeco,waitbarhandle); % fit without loc
               touslesfits=sortrows(touslesfits,4);
%               save(['msd\fits\',namefile,'.fit.msd'],'touslesfits','-ascii'); 
               save(fullfile('msd','fits',[namefile,'.fit.msd']),'touslesfits','-ascii'); 
               disp('  ');
               disp(['Fits saved in ', fullfile('msd','fits')]);
               %report
               text=['File ', fullfile('msd','fits',[namefile,'.fit.msd']),' saved'];
               updatereport(handles,text)
          else
               touslesfits=fitMSD(till,sizepixel,longFIT,minTrace,msddata,trcdata,msddeco,waitbarhandle); % fit with loc
               touslesfits=sortrows(touslesfits,5);
               save(fullfile('msd','cut','fits',[namefile,'.deco.fit.msd']),'touslesfits','-ascii'); 
               disp('  ');
               disp(['Fits of cut trajectories saved in ', fullfile('msd','cut','fits')]);
               %report
               text=['File ', fullfile('msd','cut','fits',[namefile,'.deco.fit.msd']), saved'];
               updatereport(handles,text)
           end
       else
          disp('  ')
          disp('File ',trcfile,' not found');
          %report
           text=['File ',trcfile,' not found'];
           updatereport(handles,text)
       end
    else
          disp('  ')
          disp('File ',msdfile,' not found');
                    %report
           text=['File ',msdfile,' not found'];
           updatereport(handles,text,2)
    end
        close(waitbarhandle)
end

%report
c=fix(clock);
text=['Analysis finished at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text,3)

msgbox(['Fit of MSD done, fitting ',num2str(longFIT),' points'])
           
guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change of parameters

function threshold_Callback(hObject, eventdata, handles)
handles.opt9=get(hObject,'String') ;
guidata(hObject, handles);

function Dpred_Callback(hObject, eventdata, handles)
handles.diffconst=get(hObject,'String');
guidata(hObject, handles);

function maxblink_Callback(hObject, eventdata, handles)
handles.blink=get(hObject,'String');
guidata(hObject, handles);

function maxdist_Callback(hObject, eventdata, handles)
handles.distmax=get(hObject,'String');
guidata(hObject, handles);

function edit5_Callback(hObject, eventdata, handles)
handles.longfit=get(hObject,'String');
guidata(hObject, handles);

function edit6_Callback(hObject, eventdata, handles)
handles.sizepixel=get(hObject,'String');
guidata(hObject, handles);

function edit7_Callback(hObject, eventdata, handles)
handles.till=get(hObject,'String');
guidata(hObject, handles);

function edit8_Callback(hObject, eventdata, handles)
handles.maxintensity=get(hObject,'String');
guidata(hObject, handles);

function edit9_Callback(hObject, eventdata, handles)
handles.intensityerror=get(hObject,'String');
guidata(hObject, handles);

function edit10_Callback(hObject, eventdata, handles)
handles.maxpoints=get(hObject,'String');
guidata(hObject, handles);

function minpoints_Callback(hObject, eventdata, handles)
handles.mintrace=get(hObject,'String');
guidata(hObject, handles);

% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)

% --- Executes on button press in msdcut.
function msdcut_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUIT
% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)

qstring=['Do you want to quit?'];
button = questdlg(qstring); 
if strcmp(button,'Yes')
        disp('  ');
        setdetectionoptions  % resets options to default
        close
    else
        return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% additional functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveparameters(savepath,handles)

   till=num2str(get (handles.edit7,'string')); %handles.till);
   sizepixel=num2str(get (handles.edit6,'string')) ;%handles.sizepixel);
   minTrace=num2str(get (handles.minpoints,'string'));  %handles.mintrace);
   longFit=num2str(get (handles.edit5,'string'));%handles.longfit);
   maxblink=num2str(get (handles.maxblink,'string')) ;%handles.blink);
   distmax=num2str(get (handles.maxdist,'string')); %handles.distmax);
   opt=['empty'];
   opt9=num2str(get (handles.threshold,'string')); %(handles.opt9);
   diffconst=num2str(get  (handles.Dpred,'string'));%handles.diffconst);
   interr=num2str(get (handles.edit9,'string')); %handles.intensityerror);
   maxint=num2str(get (handles.edit8,'string')) ;%handles.maxintensity);
   maxtraj=num2str(get (handles.edit10,'string')) ;%handles.maxpoints);
   init=num2str(1);
   deco=num2str(0);
   msdflag=num2str(1);
   comments=('');
    % open files for writing in binary format
    fi = fopen(savepath,'w');
    if fi<3
       error('File not found or readerror.');
    end;
    fprintf(fi,'%4s %4s %4s %5s %5s %5s %4s %4s %4s %4s %4s %4s %1s %1s %4s %20s',opt,opt9,diffconst,interr,maxint,maxtraj,till,sizepixel,maxblink,distmax,minTrace,init,deco,longFit,comments);
    fclose(fi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadparameters (fileparam,handles)

fileload=get(handles.paramfile,'value');
disp(fileparam);

if fileload==1
   [opt,opt9,diffconst,interr,maxint,maxtraj,till,sizepixel,maxblink,distmax,minTrace,init,deco,longFit,comments] = textread(fileparam,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s');
else
   [opt,opt9,diffconst,interr,maxint,maxtraj,till,sizepixel,maxblink,distmax,minTrace,init,deco,longFit,comments]=nodefault(handles);
end
    
% common parameters
  set (handles.edit7, 'string',till{1}); %acquisition time
  set (handles.edit6, 'string',sizepixel{1});
  set (handles.edit5, 'string',longFit{1});
  set (handles.minpoints, 'string',minTrace{1});
  set (handles.threshold, 'enable','on','string',opt9{1});
  set (handles.Dpred, 'enable','on','string',diffconst{1});
  set (handles.edit9,'enable','on', 'string',interr{1}); %cutoff 1
  set (handles.edit8, 'enable','on','string',maxint{1});
  set (handles.edit10, 'enable','on','string',maxtraj{1});
  set (handles.maxblink,'string',maxblink{1});
  set (handles.maxdist,'string',distmax{1});
  [Dopt,nada,nada] = detectpar;
  set(handles.threshold,'value',Dopt(6)) %opt7
  set(handles.Dpred,'value',4) %opt18

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [opt,opt9,diffconst,interr,maxint,maxtraj,till,sizepixel,maxblink,distmax,minTrace,init,deco,longFit,comments]=nodefault(handles);

opt={'start'};
opt9={'1.9'};
diffconst={'1'};
interr={'1/3'};
maxint={'1000'};
maxtraj={'100'};
till={'58'};
sizepixel={'173'};
maxblink={'5'};
distmax={'5'};
minTrace={'4'};
longFit={'5'};
init={'0'};
deco={'1'};
comments={''};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function previous=check(path)

trcfolder=[path,'trc'];
if isdir(trcfolder)
    previous=1;
else
    previous=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in report.
function report_Callback(hObject, eventdata, handles)
% save report

report=get(handles.text10,'userdata');
posrep=get(handles.text10,'value');

if isempty(report)==0
   c=fix(clock);
   name=['report',num2str(c(4)),num2str(c(5)),'.txt'];
   fi = fopen(name,'w');
   if fi<3
      error('File not found or readerror.');
   end;
   fprintf(fi,'%-200s\r',report{1});
   for celda=2:posrep
       fseek(fi,200,0);
       fprintf(fi,'%-200s\r',report{celda});
   end
   fclose(fi);
else
    msgbox('No data to save','error','error');
end
set(handles.text10,'userdata',[]);
set(handles.text10,'value',0);
set(handles.report,'value',0);
guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% help

function helpbutton_Callback(hObject, eventdata, handles)

open(matlabroot,filesep,'tracklight',filesep,'help',filesep,'GaussianFit.pdf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%end of file
