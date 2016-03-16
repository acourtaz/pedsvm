function varargout = miatrack(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MIATRACK M-file for MIAtrack.fig
%
% Launches MatLab programs to make tracking analysis
% Manages parameters: saving, reload, peaks detection,
% initial D. 
% uses MIA trajecoties
%
% MR - fev 06 - v 1.0                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last Modified by GUIDE v2.5 21-Mar-2006 19:16:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MIAtrack_OpeningFcn, ...
                   'gui_OutputFcn',  @MIAtrack_OutputFcn, ...
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
% --- Executes just before MIAtrack is made visible.
function MIAtrack_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

warning off MATLAB:break_outside_of_loop
%path
path=cd;
set(handles.datafolder,'string',path);

handles.folder=get(handles.datafolder,'string');
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Outputs from this function are returned to the command line.
function varargout = MIAtrack_OutputFcn(hObject, eventdata, handles)
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

function edit5_CreateFcn(hObject, eventdata, handles) %points to fit
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit6_CreateFcn(hObject, eventdata, handles) % pixel size
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit7_CreateFcn(hObject, eventdata, handles) %till
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
% data folder (window)
function datafolder_Callback(hObject, eventdata, handles)
% only to show the name
%--------------------------------------------------------------------------
% --- Executes on button press in selectfolder.
function selectfolder_Callback(folderhObject, eventdata, handles)

% ask the path of the data 
start_path=cd;
dialog_title=['Select data folder'];
datapath = uigetdir(start_path,dialog_title);
if datapath==0
    return
end
cd(datapath);
% by Cezar M. Tigaret on 23/02/07
% datapath=[datapath,'\'];
datapath=[datapath,filesep];

% reinitialize handles
set(handles.datafolder,'string',datapath);
handles.folder=get(handles.datafolder,'string');
set (handles.moviefile, 'string','') ; %cleans file name
handles.file=get(handles.moviefile, 'string');
set(handles.datafolder,'string',datapath);
set(handles.golocalize,'enable','off');

%report
text=['Folder: ', handles.folder];
updatereport(handles,text,1)

%check for previous analysis
previous=check(handles.folder);
    if previous>0
        set (handles.goMSD, 'Enable','on')    ; %msd
        set (handles.goD, 'Enable','on')    ; %fit
    else
        set (handles.goMSD, 'Enable','off')    ; 
        set (handles.goD, 'Enable','off')    ; 
    end
set(handles.datafolder,'value',previous);
    
%parameters
par=get(handles.paramfile,'value');
p=get(handles.paramfile,'string');
if par==0 %if nothing is loaded, loads default
% by Cezar M. Tigaret on 23/02/07
    % parfile=['\MATLAB6p5p1\tracklight\parameters\defaultparMIA.par'];
    tpath=fileparts(which('trackdiffusion.m'));
    parfile=fullfile(tpath,'parameters','defaultparMIA.par');
    set(handles.paramfile,'value',1);
    loadparametersMIA(parfile,handles);
    set(handles.paramfile,'string','defaultparMIA.par');
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

%-------------------------------------------------------------------------
% --- Executes on button press in param.
function param_Callback(hObject, eventdata, handles)

% file selection
% by Cezar M. Tigaret on 23/02/07
% path=['\MATLAB6p5p1\tracklight\parameters\*.par'];
% loadpath=['\MATLAB6p5p1\tracklight\parameters\'];
tpath=fileparts(which('trackdiffusion.m'));
mypath=fullfile(tpath,'parameters','*.par');
loadpath=fullfile(tpath,'parameters');
if length(dir(mypath))>0
   d = dir(mypath);
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
    fileparam=fullfile(loadpath,'defaultparMIA'); %ojo falta diferenciar entre gaussian y mia
    savename=['defaultparMIA'];    
    set(handles.paramfile,'value',0);
    set (handles.paramfile,'string','defaultpar'); % name of parameters file
    handles.parameters=get(handles.paramfile,'string');
end

loadparametersMIA (fileparam,handles);
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
% by Cezar M. Tigaret on 23/02/07
% path=['\MATLAB6p5p1\tracklight\parameters\'];
tpath=fileparts(which('trackdiffusion.m'));
savepath=fullfile(tpath,'parameters',savename);
saveparametersMIA(savepath,handles);
guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load movies 
% --- Executes on button press in loadcomplete.
function loadcomplete_Callback(hObject, eventdata, handles)

% folder
path=get(handles.datafolder,'string');
handles.folder=get(handles.datafolder,'string');
% by Cezar M. Tigaret on 23/02/07
% handles.folder=[handles.folder,'\'];
handles.folder=[handles.folder,filesep];
if isdir(path)
    currentdir=cd;
else
    path=cd;
    set(handles.datafolder,'string',path);
end
cd(path);

% loc MIA
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

% file list
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
   
if isempty(st)==1
    d=dir('*SPE*');
    st = {d.name};
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
if ultimo>1 %batch
  set (handles.moviefile, 'string',['Batch: File ',filename,' (1/',num2str(ultimo),')']) ;
else
  set (handles.moviefile, 'string',handles.file) ;
end

%pushbuttons & radiobuttons
set (handles.golocalize, 'Enable','on');

%parameters
par=get(handles.paramfile,'value');
p=get(handles.paramfile,'string');
if par==0 %if nothing is loaded, loads default
% by Cezar M. Tigaret on 23/02/07
    % parfile=['\MATLAB6p5p1\tracklight\parameters\defaultparMIA.par'];
    tpath=fileparts(which('trackdiffusion.m'));
    parfile=fullfile(tpath,'parameters','defaultparMIA.par');
    set(handles.paramfile,'value',1);
    loadparametersMIA(parfile,handles);
    set(handles.paramfile,'string','defaultparMIA');
    handles.parameters=get(handles.paramfile,'string');
end
set (handles.saveparam,'enable','on'); 

%check for previous analysis
previous=check(handles.folder);
   if previous>0
        set (handles.goMSD, 'Enable','on')    ; %msd
        set (handles.goD, 'Enable','on')    ; %fit msd
    else
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
    set (handles.golocalize, 'Enable','on');
else
    msgbox('File not found in the data folder','Enter movie file','error')
end

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% complete analysis: selection of posibilities

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
% --- Executes on button press in golocalize>>>>>>>>>>>> analysis
function golocalize_Callback(hObject, eventdata, handles)

% reads/loads parameters
handles.till=get (handles.edit7,'string');
handles.sizepixel=get (handles.edit6,'string');
handles.longfit=get (handles.edit5,'string');
handles.mintrace=get (handles.minpoints,'string');
handles.blink=get (handles.maxblink,'string');
handles.distmax=get (handles.maxdist,'string');
till=str2num(handles.till);
sizepixel=str2num(handles.sizepixel);
mintrace=str2num(handles.mintrace);
longFIT=str2num(handles.longfit);

%report
posrep=get(handles.report,'value');
if posrep<2
text=['Folder: ',handles.folder];
updatereport(handles,text,1) 
end
report=get(handles.report,'userdata');
posrep=get(handles.report,'value');
linearep={};
linearep{1}=['Parameters :'];
linearep{2}=['Max blink =',handles.blink,'      Max distance blink =',handles.distmax];
linearep{3}=['Acquisition time =',handles.till,'        Size pixel =',handles.sizepixel];
linearep{4}=['Min points =',handles.mintrace,'      D calculation: fit over ',handles.longfit,' points.'];
linearep{5}=['  '];
for i=1:5
           report{posrep+1}=linearep{i};
           posrep=posrep+1;
           set(handles.report,'userdata',report);
end
set(handles.report,'value',posrep+1);
linearep={};

deco=get(handles.dolocalize,'value'); % localization & deconnection
msdflag=get(handles.radiobutton6,'value'); %MSD and fit

% dialog box to confirm selection
qstring=['Confirm selection?'];
button = questdlg(qstring); 
if strcmp(button,'Yes')
  else 
     return
end

% loop fo analysis
handles.listafiles=get(handles.moviefile,'userdata');
[fil, col]=size(handles.listafiles);
file=handles.listafiles{1}; % to control MIA
control=1;
path=cd;
%report
c=fix(clock);
text=['Analysis started at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text)

for nromovie=1:col
    file=handles.listafiles{nromovie}
    handles.file=file;
%    str=['Batch: File ',file,' (',num2str(nromovie),'/',num2str(col),')'];
    str=['Batch: File ',file,' (',num2str(nromovie),filesep,num2str(col),')'];
    set (handles.moviefile, 'string', str);
    [namefile,rem]=strtok(file,'.');
% by Cezar M. Tigaret on 23/02/07
    % MIAfolder=[path,'\',namefile,'.MIA\tracking\'];
%     MIAfolder=[path,filesep,namefile,'.MIA',filesep,'tracking',filesep];
%   deal with case sensitivity for r.MIA on UN*X platforms (where r.MIA is
%   not the same thing as r.mia)
% path    
% assignin('base','sPath',path);
% namefile
% assignin('base','nFile',namefile);
files=dir(path);
    fcell=struct2cell(files);
    miaDIR=strfind(fcell(1,:),[namefile,'.MIA']);
    miaDIRNdx=find(~cellfun('isempty',miaDIR));
    if(length(miaDIRNdx)~=1)
        miaDIR=strfind(fcell(1,:),[namefile,'.mia'])
        miaDIRNdx=find(~cellfun('isempty',miaDIR));
        if(length(miaDIRNdx)~=1)
          text=['Subdirectory ',namefile,'.mia or ',namefile,'.MIA not found or not unique'];
            warning(text);
            updatereport(text);
            return;
        end;      
    end;
%     miadir=regexpi(strcat(fcell(1,:)), [namefile, '.MIA']);
%     miadirfound=find(~cellfun('isempty',miadir));
%     disp(miadirfound)
%     if (isempty(miadirfound))
%       disp(['Subdirectory ',namefile,'.mia or ',namefile,'.MIA not found']);
%       text=['Subdirectory ',namefile,'.mia or ',namefile,'.MIA not found'];
%       updatereport(handles, text);
%       return;
%     elseif(length(miadirfound)>1)
%       disp(['Several ',namefile,'.mia or ',namefile,'.MIA were found']);
%       disp(['Rename one of them and try again']);
%       text=(['Oops: Several ',namefile,'.mia or ',namefile,'.MIA were found, cannot go on like this...']);
%       updatereport(handles, text);
%       return;
%     end;
%     miadirname=files(miadirfound).name;
    miadirname=files(miaDIRNdx).name;
    MIAfolder=fullfile(path,miadirname,'tracking');
    MIAtrc=fullfile(MIAfolder,[namefile,'_MIA.trc']);
%     disp(MIAtrc)
    control=1;
    
    if length(dir(MIAtrc))==0
       disp(['.trc file not found for ',file]);
       %report
       text=['.trc file not found for ',file];
       updatereport(handles,text)
       control=0;
    end
    pause(0.001) % to show waitbar
    
  if control>0
    %report
    text=['File: ',handles.file];
    updatereport(handles,text)
    rectrc=elongatetrackMIA(file, MIAtrc, handles); % reconnection
    
    if length(rectrc)>0
      [namefile,rem]=strtok(file,'.');
      deco=get(handles.dolocalize,'value'); % localization & deconnection
      
      if deco==1
        spelist=dir('*-loc_MIA.spe*');
        if isempty(spelist)==1
            domainfile=[namefile,'-loc_MIA.tif'];
        else
            domainfile=[namefile,'-loc_MIA.spe'];
        end
        if length(dir(domainfile))>0
            %report
            text=['Domain file: ',domainfile];
            updatereport(handles,text)
            nwtrcsyn=localiz(rectrc,domainfile,handles); %localization/cut
% by Cezar M. Tigaret on 23/02/07
           % filetxt=['trc\',namefile,'.MIA.con.syn.trc'];
            filetxt=fullfile('trc',[namefile,'.MIA.con.syn.trc']);
            fi = fopen(filetxt,'w');
            if fi<3
              error('File not found or readerror.');
            else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',nwtrcsyn');
            end
            % close
            fclose(fi);
            % cutting
% by Cezar M. Tigaret on 23/02/07
            % if isdir(['trc\cut']); else mkdir ('trc\cut'); end
%             if isdir(['trc',filesep,'cut']); else mkdir (['trc',filesep,'cut']); end
            if isdir(fullfile('trc','cut')); else mkdir (fullfile('trc','cut')); end
            tic %% by CMT on 19/10/2007
            nwtrccut=deconnect(nwtrcsyn,handles); %corta trajectorias que cambian de localizacion
%             nwtrccut=deconnectLC(nwtrcsyn,handles); %corta trajectorias que cambian de localizacion
            toc
%             disp('... in deconnect.m');
            %save(['trc\cut\',namefile,'.MIA.deco.syn.trc'],'nwtrccut','-ascii','-tabs'); % trayectorias mol con loc
% by Cezar M. Tigaret on 23/02/07
            % filetxt=['trc\cut\',namefile,'.MIA.deco.syn.trc'];
            filetxt=fullfile('trc','cut',[namefile,'.MIA.deco.syn.trc']);
            fi = fopen(filetxt,'w');
            if fi<3
              error('File not found or readerror.');
            else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',nwtrccut');
            end
            % close
            fclose(fi);

            disp('  ');
            disp(['New trajectories saved in trc',filesep,'cut']);
            %MSD
            if msdflag==1
               waitbarhandle=waitbar( 0,'Please wait...','Name',['Calculating MSD in ',file]);
               disp('  ');
               disp([' MSD calculation of cut trajectories...' ]);
               [msddata, fullmsddata]=newMSDTL(nwtrccut,150,waitbarhandle); %%%%%%%%%%% !!! MSD de 150 points au max
% by Cezar M. Tigaret on 23/02/07
               % mkdir ('msd\cut');
               % save(['msd\cut\',namefile,'.MIA.deco.syn.msd'],'msddata','-ascii'); 
               mkdir (fullfile('msd','cut'));
               save(fullfile('msd','cut',[namefile,'.MIA.deco.syn.msd']),'msddata','-ascii'); 
               close(waitbarhandle);
               %fitting cut trajectories
% by Cezar M. Tigaret on 23/02/07
               % if isdir(['msd\cut\fits']); else mkdir ('msd\cut\fits'); end
               if isdir(fullfile('msd','cut','fits')); else mkdir (fullfile('msd','cut','fits')); end
               waitbarhandle=waitbar( 0,'Please wait...','Name',['Fitting MSD in ',file]);
               touslesfits=fitMSD(till,sizepixel,longFIT,mintrace,msddata,nwtrccut,1,waitbarhandle);
               touslesfits=sortrows(touslesfits,5);
% by Cezar M. Tigaret on 23/02/07
               % save(['msd\cut\fits\',namefile,'.MIA.deco.fit.msd'],'touslesfits','-ascii'); 
               save(fullfile('msd','cut','fits',[namefile,'.MIA.deco.fit.msd']),'touslesfits','-ascii'); 
               disp('  ');
               disp(['MSD and fits of cut trajectories saved in msd',filesep,'cut']);% by Cezar M. Tigaret on 23/02/07
               close(waitbarhandle);
               %report
               text=['MSD and fits of cut trajectories saved in msd',filesep,'cut'];% by Cezar M. Tigaret on 23/02/07
               updatereport(handles,text)
           end
        else                                                       % without loc
            disp(['File ',domainfile,' not found']);
             %report
            text=['File ',domainfile,' not found'];
            updatereport(handles,text)
            if msdflag==1
               waitbarhandle=waitbar( 0,'Please wait...','Name',['Calculating MSD in ',file]);
               disp('  ');
               disp([' MSD calculation...' ]);
               [msddata, fullmsddata]=newMSDTL(rectrc,150,waitbarhandle); %%%%%%%%%%% !!! MSD de 150 points au max
               if isdir('msd'); else mkdir ('msd'); end;               % by Cezar M. Tigaret on 23/02/07
               save(fullfile('msd',[namefile,'.MIA.con.msd']),'msddata','-ascii');           % by Cezar M. Tigaret on 23/02/07
               close(waitbarhandle);  
               %fitting cut trajectories
               if isdir(fullfile('msd','fits')); else mkdir (fullfile('msd','fits')); end;   % by Cezar M. Tigaret on 23/02/07
               waitbarhandle=waitbar( 0,'Please wait...','Name',['Fitting MSD in ',file]);
               touslesfits=fitMSD(till,sizepixel,longFIT,mintrace,msddata,rectrc,0,waitbarhandle);
               touslesfits=sortrows(touslesfits,4);
               save(fullfile('msd','fits',[namefile,'.MIA.con.msd']),'touslesfits','-ascii'); % by Cezar M. Tigaret on 23/02/07
               disp('  ');
               disp(['MSD and fits saved in msd',filesep]);                                % by Cezar M. Tigaret on 23/02/07
               close(waitbarhandle);   
               %report
               text=['MSD and fits saved in msd',filesep];                                 % by Cezar M. Tigaret on 23/02/07
               updatereport(handles,text)
           end
         end %presence file loc_MIA
         
      else                                % no localization
         if msdflag==1
           waitbarhandle=waitbar( 0,'Please wait...','Name',['Calculating MSD in ',file]);
           disp('  ');
           disp([' MSD calculation...' ]);
           [msddata, fullmsddata]=newMSDTL(rectrc,150,waitbarhandle); %%%%%%%%%%% !!! MSD de 150 points au max
           if isdir('msd'); else mkdir ('msd'); end;  % by Cezar M. Tigaret on 23/02/07
           save(fullfile('msd',[namefile,'.MIA.con.msd']),'msddata','-ascii');   % by Cezar M. Tigaret on 23/02/07
           close(waitbarhandle);  
           %fitting cut trajectories
           if isdir(fullfile('msd','fits')); else mkdir (fullfile('msd','fits')); end; % by Cezar M. Tigaret on 23/02/07
           waitbarhandle=waitbar( 0,'Please wait...','Name',['Fitting MSD in ',file]);
           touslesfits=fitMSD(till,sizepixel,longFIT,mintrace,msddata,rectrc,0,waitbarhandle);
           touslesfits=sortrows(touslesfits,4);
           save(fullfile('msd','fits',[namefile,'.MIA.con.msd']),'touslesfits','-ascii'); % by Cezar M. Tigaret on 23/02/07
           disp('  ');
           disp(['MSD and fits saved in msd',filesep]);% by Cezar M. Tigaret on 23/02/07
           close(waitbarhandle);   
           %report
           text=['MSD and fits saved in msd',filesep];% by Cezar M. Tigaret on 23/02/07
           updatereport(handles,text)
         end

      end % deco
    end   %rectrc
end % control

end % loop

%report
c=fix(clock);
text=['Analysis finished at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text,3)

%pushbuttons
set (handles.goreconnect, 'Enable','on')    ; %reconnect
set (handles.goMSD, 'Enable','on')    ; %msd
set (handles.goD, 'Enable','on')    ; %fit

% saves actual parameters as default
savename=['defaultparMIA.par'];
% by Cezar M. Tigaret on 23/02/07
% path=['\MATLAB6p5p1\tracklight\parameters\'];
tpath=fileparts(which('trackdiffusion.m'));
savepath=fullfile(tpath,'parameters',savename);
% disp(savepath)
saveparametersMIA(savepath,handles);
figure(MIAtrack); % to activate the figure
%figure(miatrack); % to activate the figure
    
msgbox('Analysis finished. Actual parameters saved as defaultpar')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% partial analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reconnection

% --- Executes on button press in goreconnect.
function goreconnect_Callback(hObject, eventdata, handles)

% trajetories reconnection
set(handles.golocalize,'enable','off');
currentdir=cd;

%initialize handles
handles.mintrace=get (handles.minpoints,'string');
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
linearep{3}=['Min points =',handles.mintrace];
linearep{4}=['  '];
for i=1:4
           report{posrep+1}=linearep{i};
           posrep=posrep+1;
           set(handles.report,'userdata',report);
end
set(handles.report,'value',posrep+1);
linearep={};

% movies to recognize folder
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
if isempty(st)==1
    d=dir('*SPE*');
    st = {d.name};
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
if isdir(['trc']); else; mkdir(['trc']);end
control=1;

%report
c=fix(clock);
text=['Analysis started at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text)

% analysis
for cont=1:ultimo   % all list
    
    filename=st{listafiles(cont)}; % con extension
    handles.file=filename;
    if ultimo>1 %batch
       set (handles.moviefile, 'string',['Trajectory reconnection: File ',filename,' (',num2str(cont),'/',num2str(ultimo),')']) ;
    else
       set (handles.moviefile, 'string',['Trajectory reconnection: File ',filename]) ;
    end
    [namefile,rem]=strtok(filename,'.');
% by Cezar M. Tigaret on 23/02/07
    % MIAfolder=[currentdir,'\',namefile,'.MIA\tracking\'];
%     MIAfolder=fullfile(currentdir,[namefile,'.MIA'],'tracking');
    MIAtrc=fullfile(currentdir,[namefile,'.MIA'],'tracking',[namefile,'_MIA.trc']);
    if length(dir(MIAtrc))==0
       disp(['.trc file not found for ',filename]);
       %report
       text=['.trc file not found for ',filename];
       updatereport(handles,text)
       control=0;
    end
    pause(0.001) % to show waitbar
  if control>0
    %report
    text=['File: ',handles.file];
    updatereport(handles,text)
    rectrc=elongatetrackMIA(filename, handles);                            %reconnection
    % if there is -loc_MIA files, does the localization and cut
    domainfile=[namefile,'-loc_MIA.spe'];
    if length(dir(domainfile))==0
        domainfile=[namefile,'-loc_MIA.tif'];
        if length(dir(domainfile))>0
            %report
            text=['Domain file: ',domainfile];
            updatereport(handles,text)
            localiz(rectrc,domainfile,handles);                             % localization .tif
        end
    else
        %report
        text=['Domain file: ',domainfile];
        updatereport(handles,text)
        localiz(rectrc,domainfile,handles);                                 % localization .tif
    end
  end
end

%report
c=fix(clock);
text=['Analysis finished at ',num2str(c(4)),':',num2str(c(5))];
updatereport(handles,text,3)

set (handles.goMSD, 'Enable','on')    ; %MSD
msgbox('Attention: no MSD calculation done')

guidata(gcbo,handles) ;

%----------------------------------------------------------
% MSD: --- Executes on button press in goMSD.
function goMSD_Callback(hObject, eventdata, handles)

% by Cezar M. Tigaret on 23/02/07
if isdir('msd');else;mkdir('msd');end

% MSD calculation
set(handles.golocalize,'enable','off');
currentdir=cd;
msddeco=get(handles.msdcut,'value');
if msddeco==0
   path=fullfile(cd,'trc'); % by Cezar M. Tigaret on 23/02/07
   tag='con';
else
   path=fullfile(cd,'trc','cut'); % by Cezar M. Tigaret on 23/02/07
   tag='deco';
   if isdir(fullfile('msd','cut')); else; mkdir(fullfile('msd','cut')); end % by Cezar M. Tigaret on 23/02/07
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
    disp('  ');
    disp(['MSD calculation for file ',filename]);
    %report
    text=['File: ',handles.file];
    updatereport(handles,text,2)
    waitbarhandle=waitbar( 0,'Please wait...','Name',['Calculating MSD in ',filename]);
    if ultimo>1 %batch
       set (handles.moviefile, 'string',['MSD for ',filename,' (',num2str(cont),'/',num2str(ultimo),')']) ;
    else
       set (handles.moviefile, 'string',['MSD for ',filename]) ;
    end
    pause(0.001) % to show wait bar
    if msddeco==0
% by Cezar M. Tigaret on 23/02/07
      % trcfile=[cd,'\trc\',namefile,'.MIA.con.trc'];
      % savename=['msd\',namefile,'.MIA.con.msd']; 
       trcfile=fullfile(cd,'trc',[namefile,'.MIA.con.trc']);
       savename=fullfile('msd',[namefile,'.MIA.con.msd']); 
    else
      % trcfile=[cd,'\trc\cut\',namefile,'.MIA.deco.syn.trc'];
      % savename=['msd\cut\',namefile,'.MIA.deco.syn.msd']; 
       trcfile=fullfile(cd,'trc','cut',[namefile,'.MIA.deco.syn.trc']);
       savename=fullfile('msd','cut',[namefile,'.MIA.deco.syn.msd']); 
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
    close(waitbarhandle);
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

if msddeco==0
   path=fullfile(cd,'msd');
   tag='con';
   if isdir(fullfile('msd','fits')); else; mkdir(fullfile('msd','fits')); end;  % by Cezar M. Tigaret on 23/02/07
else
   path=fullfile(cd,'msd','cut');% by Cezar M. Tigaret on 23/02/07
   tag='deco';
   if isdir(fullfile('msd','cut','fits')); else; mkdir(fullfile('msd','cut','fits')); end ; % by Cezar M. Tigaret on 23/02/07
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
    disp('  ');
    disp(['Fitting MSD for file ',filename]);
    filename=st{listafiles(cont)} % con extension
    %report
    text=['File: ',handles.file];
    updatereport(handles,text,2)
    waitbarhandle=waitbar( 0,'Please wait...','Name',['Fitting MSD in ',filename]);
    if ultimo>1 %batch
       set (handles.moviefile, 'string',['MSD fit for  ',filename,' (',num2str(cont),'/',num2str(ultimo),')']) ;
    else
       set (handles.moviefile, 'string',['MSD fit for ',filename]) ;
    end
    pause(0.001) % to show waitbar
    [namefile,rem]=strtok(filename,'.'); %sin extension
    if msddeco==0
% by Cezar M. Tigaret on 23/02/07
      % msdfile=[cd,'\msd\',namefile,'.MIA.con.msd'];
      % trcfile=[cd,'\trc\',namefile,'.MIA.con.trc'];
      % savename=['msd\fits\',namefile,'.MIA.fit.con.msd']; 
       msdfile=fullfile(cd,'msd',[namefile,'.MIA.con.msd']);
       trcfile=fullfile(cd,'trc',[namefile,'.MIA.con.trc']);
       savename=fullfile('msd','fits',[namefile,'.MIA.fit.con.msd']); 
    else
% by Cezar M. Tigaret on 23/02/07
       msdfile=fullfile(cd,'msd','cut',[namefile,'.MIA.deco.syn.msd']);
       trcfile=fullfile(cd,'trc','cut',[namefile,'.MIA.deco.syn.trc']);
       savename=fullfile('msd','cut','fits',[namefile,'.MIA.fit.deco.syn.msd']); 
    end
    if length(dir(msdfile))>0
       if length(dir(trcfile))>0
          msddata=load(msdfile); 
          trcdata=load(trcfile); 
           if msddeco==0
           touslesfits=fitMSD(till,sizepixel,longFIT,minTrace,msddata,trcdata,msddeco,waitbarhandle); % fit without loc
               touslesfits=sortrows(touslesfits,4);
% by Cezar M. Tigaret on 23/02/07
              % save(['msd\fits\',namefile,'.MIA.fit.msd'],'touslesfits','-ascii'); 
               save(fullfile('msd','fits',[namefile,'.MIA.fit.msd']),'touslesfits','-ascii'); 
               disp('  ');
               disp(['Fits saved in ', fullfile('msd','fits')]); % by Cezar M. Tigaret on 23/02/07
               %report
               text=['File ', fullfile('msd','fits',[namefile,'.fit.msd']),' saved']; % by Cezar M. Tigaret on 23/02/07
               updatereport(handles,text)
          else
               touslesfits=fitMSD(till,sizepixel,longFIT,minTrace,msddata,trcdata,msddeco,waitbarhandle); % fit with loc
               touslesfits=sortrows(touslesfits,5);
% by Cezar M. Tigaret on 23/02/07
               save(fullfile('msd','cut','fits',[namefile,'.MIA.deco.fit.msd']),'touslesfits','-ascii'); 
               disp('  ');
               disp(['Fits of cut trajectories saved in ', fullfile('msd','cut','fits')]); % by Cezar M. Tigaret on 23/02/07
               %report
               text=['File ', fullfile('msd','cut','fits',[namefile,'.deco.fit.msd']),' saved']; % by Cezar M. Tigaret on 23/02/07
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
      disp(['File ',msdfile,' not found']);
      %report
      text=['File ',msdfile,' not found'];
      updatereport(handles,text,2)
    end
      close(waitbarhandle);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% help

% --- Executes on button press in helpbutton.
function helpbutton_Callback(hObject, eventdata, handles)

%helptrackingTL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUIT
% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)

qstring=['Do you want to quit?'];
button = questdlg(qstring); 
if strcmp(button,'Yes')
        disp('  ');
        close
    else
        return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% additional functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveparametersMIA(savepath,handles)

   till=num2str(get (handles.edit7,'string')); %handles.till);
   sizepixel=num2str(get (handles.edit6,'string')) ;%handles.sizepixel);
   minTrace=num2str(get (handles.minpoints,'string'));  %handles.mintrace);
   longFit=num2str(get (handles.edit5,'string'));%handles.longfit);
   maxblink=num2str(get (handles.maxblink,'string')) ;%handles.blink);
   distmax=num2str(get (handles.maxdist,'string')); %handles.distmax);
   opt=['empty'];
   opt9=1.9; %(handles.opt9);
   diffconst= 1;%handles.diffconst);
   interr=1/3; %handles.intensityerror);
   maxint=1000 ;%handles.maxintensity);
   maxtraj=100 ;%handles.maxpoints);
   init=num2str(1);
   deco=num2str(0);
   msdflag=num2str(1);
   comments=('');
    % open files for writing in binary format
    fi = fopen(savepath,'w');
    if fi<3
       error('File not found or readerror.');
    end;
%     fprintf(fi,'%4s %4s %4s %5s %5s %5s %4s %4s %4s %4s %4s %4s %1s %1s %4s %20s',opt,opt9,diffconst,interr,maxint,maxtraj,till,sizepixel,maxblink,distmax,minTrace,init,deco,longFit,comments);
    fprintf(fi,'%4s %4s %4s %5s %5s %5s %4s %4s %4s %4s %4s %4s %1s %1s %4s %20s',opt,num2str(opt9),num2str(diffconst),num2str(interr),num2str(maxint),num2str(maxtraj),till,sizepixel,maxblink,distmax,minTrace,init,deco,longFit,comments);
    fclose(fi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadparametersMIA (fileparam,handles)

fileload=get(handles.paramfile,'value');
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
set (handles.maxblink,'string',maxblink{1});
set (handles.maxdist,'string',distmax{1});
%[Dopt,nada,nada] = detectpar;

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
guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% end of file

