function varargout = frontend_VII(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frontend_VII_OpeningFcn, ...
                   'gui_OutputFcn',  @frontend_VII_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before frontend_VII is made visible.
function frontend_VII_OpeningFcn(hObject, eventdata, handles, varargin)
handles.type = 1;
handles.frbef = 20;
handles.fraft = 20;
handles.signoise = 1.75;
handles.slope = 20;
set(findobj('Tag','radiobutton1'),'Value',1);
set(findobj('Tag','radiobutton2'),'Value',0);
set(findobj('Tag','radiobutton3'),'Value',0);
set(findobj('Tag','radiobutton5'),'Value',0);
set(findobj('Tag','radiobutton6'),'Value',0);
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = frontend_VII_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
handles.output = hObject;
guidata(hObject, handles);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
a = get(gco,'Value');
if a == 1;
    type = 1;
    set(findobj('Tag','radiobutton2'),'Value',0);
    set(findobj('Tag','radiobutton3'),'Value',0);
    set(findobj('Tag','radiobutton5'),'Value',0);
    set(findobj('Tag','radiobutton6'),'Value',0);
end
handles.type = type;
handles.output = hObject;
guidata(hObject, handles);

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
a = get(gco,'Value');
if a == 1;
    type = 2;
    set(findobj('Tag','radiobutton1'),'Value',0);
    set(findobj('Tag','radiobutton3'),'Value',0);
    set(findobj('Tag','radiobutton5'),'Value',0);
    set(findobj('Tag','radiobutton6'),'Value',0);
end
handles.type = type;
handles.output = hObject;
guidata(hObject, handles);

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
a = get(gco,'Value');
if a == 1;
    type = 3;
    set(findobj('Tag','radiobutton1'),'Value',0);
    set(findobj('Tag','radiobutton2'),'Value',0);
    set(findobj('Tag','radiobutton5'),'Value',0);
    set(findobj('Tag','radiobutton6'),'Value',0);
end
handles.type = type;
handles.output = hObject;
guidata(hObject, handles);

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
a = get(gco,'Value');
if a == 1;
    type = 4;
    set(findobj('Tag','radiobutton1'),'Value',0);
    set(findobj('Tag','radiobutton2'),'Value',0);
    set(findobj('Tag','radiobutton3'),'Value',0);
    set(findobj('Tag','radiobutton6'),'Value',0);
end
handles.type = type;
handles.output = hObject;
guidata(hObject, handles);

% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
a = get(gco,'Value');
if a == 1;
    type = 5;
    set(findobj('Tag','radiobutton1'),'Value',0);
    set(findobj('Tag','radiobutton2'),'Value',0);
    set(findobj('Tag','radiobutton3'),'Value',0);
    set(findobj('Tag','radiobutton5'),'Value',0);
end
handles.type = type;
handles.output = hObject;
guidata(hObject, handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
varargout{1} = handles.type;
varargout{2} = handles.frbef;
varargout{3} = handles.fraft;
varargout{4} = handles.signoise;
varargout{5} = handles.slope;
handles.output = varargout;
chopstk_mjt(varargout);
guidata(hObject, handles);

function edit1_Callback(hObject, eventdata, handles)
frbef = str2double(get(hObject,'String'));
handles.frbef = frbef;
handles.output = hObject;
guidata(hObject, handles);

function edit2_Callback(hObject, eventdata, handles)
fraft = str2double(get(hObject,'String'));
handles.fraft = fraft;
handles.output = hObject;
guidata(hObject, handles);

function edit3_Callback(hObject, eventdata, handles)
signoise = str2double(get(hObject,'String'));
handles.signoise = signoise;
handles.output = hObject;
guidata(hObject, handles);

function edit5_Callback(hObject, eventdata, handles)
slope = str2double(get(hObject,'String'));
handles.slope = slope;
handles.output = hObject;
guidata(hObject, handles);

% Junk written by guide
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object deletion, before destroying properties.
function pushbutton1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


