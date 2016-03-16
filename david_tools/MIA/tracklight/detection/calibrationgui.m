function varargout = calibrationgui(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALIBRATIONGUI M-file for calibrationgui.fig
%
% Executes peak detection to select threshold and some detection parameters
% allows looking all the images
%
% MR - fev 06 - v 1.0                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last Modified by GUIDE v2.5 24-Mar-2006 08:27:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibrationgui_OpeningFcn, ...
                   'gui_OutputFcn',  @calibrationgui_OutputFcn, ...
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
%--------------------------------------------------------------------------
% --- Executes just before calibrationgui is made visible.
function calibrationgui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(handles.output,'userdata',varargin{1}(1));
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = calibrationgui_OutputFcn(hObject, eventdata, handles,detoptions)
varargout{1} = handles.output;

detoptions=get(handles.output,'userdata');
set(handles.thresh,'String',num2str(detoptions.threshold));
set(handles.maxinten,'String',num2str(detoptions.cutoff2));
options(1)=detoptions.output;
options(2)=detoptions.minchi;
options(3)=detoptions.mindchi;
options(4)=detoptions.minparvar;
options(5)=detoptions.loops;
options(6)=detoptions.lamba;
options(7)=detoptions.widthgauss;
options(8)=detoptions.widthimagefit;
options(9)=detoptions.threshold;
options(10)=detoptions.fit;
options(11)=detoptions.confchi;
options(12)=detoptions.confexp;
options(13)=detoptions.confF;
options(18)=detoptions.pixels;
cutoffs(1)=detoptions.cutoff1;
cutoffs(2)=detoptions.cutoff2;
cutoffs(3)=detoptions.cutoff3;
typefile=detoptions.typefile;
Image=detoptions.image;
ImagePar=detoptions.imagepar;

%figure;
axes(handles.axes1);
set(handles.text8,'value',ImagePar(4)); %nro frames
set(handles.skip,'value',1); %frame #1

showdetection(options,cutoffs,typefile,handles);

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function thresh_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function maxinten_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function skip_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function thresh_Callback(hObject, eventdata, handles)
handles.threshold=get(hObject,'String');
guidata(hObject, handles);

function maxinten_Callback(hObject, eventdata, handles)
handles.maxintensity=get(hObject,'String');
guidata(hObject, handles);

function skip_Callback(hObject, eventdata, handles)
handles.skipframes=get(hObject,'String');
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in backbutton.
function backbutton_Callback(hObject, eventdata, handles)

skipframes=str2num(get(handles.skip,'string'));
actualframe=get(handles.skip,'value');
lastframe=get(handles.text8,'value');
if actualframe-skipframes>0
    actualframe=actualframe-skipframes;
else
    actualframe=1;
end
set(handles.skip,'value',actualframe);
set(handles.text8,'string',['Frame = ',num2str(actualframe),' (of ',num2str(lastframe),')']);
showimage(handles);
axes(handles.axes1);
hold off;

guidata(gcbo,handles) ;

%-------------------------------------------------------------------------
% --- Executes on button press in forwardbutton.
function forwardbutton_Callback(hObject, eventdata, handles)

skipframes=str2num(get(handles.skip,'string'));
actualframe=get(handles.skip,'value');
lastframe=get(handles.text8,'value');
if actualframe+skipframes<lastframe+1
    actualframe=actualframe+skipframes;
else
    actualframe=lastframe;
end
set(handles.text8,'string',['Frame = ',num2str(actualframe),' (of ',num2str(lastframe),')']);
set(handles.skip,'value',actualframe)
showimage(handles);
axes(handles.axes1);
hold off;

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in detect.
function detect_Callback(hObject, eventdata, handles)

% options: initialization
detoptions=get(handles.output,'userdata');
options(1)=detoptions.output;
options(2)=detoptions.minchi;
options(3)=detoptions.mindchi;
options(4)=detoptions.minparvar;
options(5)=detoptions.loops;
options(6)=detoptions.lamba;
options(7)=detoptions.widthgauss;
options(8)=detoptions.widthimagefit;
options(9)=str2num(get(handles.thresh,'string'));detoptions.threshold=options(9);
options(10)=detoptions.fit;
options(11)=detoptions.confchi;
options(12)=detoptions.confexp;
options(13)=detoptions.confF;
options(18)=detoptions.pixels;
cutoffs(1)=detoptions.cutoff1;
cutoffs(2)=str2num(get(handles.maxinten,'string'));detoptions.cutoff2=cutoffs(2);
cutoffs(3)=detoptions.cutoff3;
typefile=detoptions.typefile;
set(handles.output,'userdata',detoptions);

showdetection(options,cutoffs,typefile,handles);

guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in accept.
function accept_Callback(hObject, eventdata, handles,detoptions)

detoptions=get(handles.output,'userdata');
detoptions.image=[];
detoptions.imagepar=[];
% % by CMT - 05/11/2007
tpath=fileparts(which('trackdiffusion.m'));
% parfile=fullfile(tpath,'parameters','default.par');
mypath=fullfile(tpath,'parameters');
%msgbox('Saving options file','Please wait...');
save(fullfile(mypath,'detecoptions.mat'),'detoptions','-mat');
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)

close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showimage(handles)

datamatrix=[];
detoptions=get(handles.output,'userdata');
actualframe=get(handles.skip,'value');
lastframe=get(handles.text8,'value');
typefile=detoptions.typefile;
Image=detoptions.image;
ImagePar=detoptions.imagepar;
YDim=ImagePar(2)/ImagePar(4);
actualframe=get(handles.skip,'value');
if actualframe==1
    firsty=actualframe;
    lasty=YDim;
else
    firsty=(actualframe-1)*YDim;
    lasty=firsty+YDim;
end
if typefile==0
        YDim=ImagePar(2)/ImagePar(4);
        datamatrix=Image(firsty:lasty,:);
    else
        %datamatrix=Image(:,:,actualframe);
        datamatrix=Image(actualframe).data;
end
set(handles.skip,'userdata',datamatrix);

%figure;
axes(handles.axes1);
set(handles.text8,'string',['Frame = ',num2str(actualframe),' (of ',num2str(lastframe),')']);
[Xdim,Ydim]=size(datamatrix);

if typefile==0
          datamatrix=datamatrix-min(min(datamatrix));
          datamatrix=abs(datamatrix/max(max(datamatrix)));
          ver=str2num(version('-release'));
          if(ver<=14)
          imshow(datamatrix,'notruesize');
          else
          imshow(datamatrix,'InitialMagnification','Fit'); % CMT  - 05/11/2007
          end;
          hold on
      else
          stackmin=(min(min(min(datamatrix))));
          stackmax=(max(max(max(datamatrix))));
          ver=str2num(version('-release'));
          if(ver<=14)
          %imshow((datamatrix(:,:,1)),[stackmin stackmax],'notruesize');
           imshow(datamatrix,[stackmin stackmax],'notruesize');
          else
          imshow(datamatrix,[stackmin stackmax],'InitialMagnification','fit');% CMT  - 05/11/2007
          end;
          hold on
end
axis([0,Ydim,0,Xdim]);
hold on
datamatrix=[];
guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showdetection(options,cutoffs,typefile,handles)

showimage(handles);
datamatrix=get(handles.skip,'userdata');

%figure;
axes(handles.axes1);
actualframe=get(handles.skip,'value');
lastframe=get(handles.text8,'value');
set(handles.text8,'string',['Frame = ',num2str(actualframe),' (of ',num2str(lastframe),')']);
result = findpeakext (datamatrix, options);
if(isempty(result))
  disp('No peaks found');
  return;
end;
result=[ones(size(result,1),1),result];
      
if length(result)>0
      pkdata=clearpkTL(result,1,3,options(18)); % vire les peaks dont les largeurs sont en dehors de [1., opts(18)]
      pkind = find(pkdata(:,10)<(pkdata(:,5)*cutoffs(1)) & pkdata(:,5)> 0 & pkdata(:,5)< cutoffs(2)) ;
      pkdata = pkdata(pkind,:);
      plot (result(:,2), result(:,3),'o','markeredgecolor',[0 0 1]); 
      hold on;
      set(handles.text9,'string',['Peaks detected : ',num2str(size(result,1))]);
      if length(pkdata)>0
         plot (pkdata(:,2), pkdata(:,3),'o','markeredgecolor',[1 0 0],'markersize',8);
         set(handles.text10,'string',['After size cutoff : ',num2str(size(pkdata,1))]);
      else
         set(handles.text10,'string',['After size cutoff : 0']);
      end
      hold off
else
      set(handles.text9,'string',['Peaks detected : 0']);
      hold off
end
datamatrix=[];    
guidata(gcbo,handles) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in advanced.
function advanced_Callback(hObject, eventdata, handles)

detoptions=get(handles.output,'userdata');
options7=detoptions.widthgauss;
options8=detoptions.widthimagefit;
options18=detoptions.pixels;

prompt = {'Width of gaussian correlation function','Width of the image to be fit','Maximum size allowed'};
num_lines= 1;
dlg_title = 'Advanced detection parameters';
def = {num2str(options7),num2str(options8),num2str(options18)}; % default values
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);
if exit(1) == 0;
   return; 
end
detoptions=get(handles.output,'userdata');
detoptions.widthgauss=str2num(answer{1});
detoptions.widthimagefit=str2num(answer{2});
detoptions.pixels=str2num(answer{3});
set(handles.output,'userdata',detoptions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%end of file
