function varargout = resultsdif(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESULTSDIF M-file for resultsdif.fig
%
% Makes txt file/s to join results from several fit files after batch analysis
% In case of localization analysis, separates molecules into three
% categories: synaptic, perisynaptic or extrasynaptic.
% Calculates median D
%
% Called by tracking
%
%
% MR - fev 06 - v 1.2                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Last Modified by GUIDE v2.5 02-Mar-2006 12:55:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @resultsdif_OpeningFcn, ...
                   'gui_OutputFcn',  @resultsdif_OutputFcn, ...
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

% --- Executes just before resultsdif is made visible.
function resultsdif_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for resultsdif
handles.output = hObject;

 set(handles.savefolder,'string','Folder name');
 set(handles.savefolder,'Value',1);
handles.selection=get(handles.savefolder,'Value');
guidata(gcbo,handles) ;

%set(gcf,'name','Diffusion coefficient');

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = resultsdif_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% --- Executes on button press in loadfilepushbutton1.
function loadfilepushbutton1_Callback(hObject, eventdata, handles)

warning off MATLAB:MKDIR:DirectoryExists

% inicializacion campos resultados
set(handles.linea1,'string',' ');
set(handles.linea2,'string',' ');
set(handles.linea3,'string',' ');
set(handles.edit5,'string',' ');
set(handles.edit8,'string',' ');
set(handles.edit11,'string',' ');
set(handles.edit12,'string',' ');
set(handles.edit13,'string',' ');
set(handles.edit14,'string',' ');
set(handles.save,'string','Save results in folder');
name=get(handles.savefolder,'string');
guidata(gcbo,handles) ;
saveopt=1;

k=strfind(name,'Folder name');
if isempty(k)==0
    saveopt=0;
else
    mkdir(name)
    saveopt=1;
end
start_path=[cd,'\msd'];
dialog_title=['Select data folder for D calculation (fits folder)'];
directory_name = uigetdir(start_path,dialog_title);
if directory_name==0
    return
end
path=directory_name;
k=strfind(path,'cut');
if isempty(k)==0
     option=1 ; % loc
 else
     option=0 ;%no loc
end
%choose data
d = dir(path);
st = {d.name};
if isempty(st)==1
   msgbox(['No files!!'],'Select files','error')
   return
end
[listafiles,v] = listdlg('PromptString','Select files:','SelectionMode','multiple','ListString',st);
if v==0
   return
end
  
% data
firstenter=1;
nroexp=1;
ex = 1;
ps = 1;
sy=1;
control=1;
extra=[];
perisyn=[];
synaptic=[];
total=[];
[f,ultimo]=size(listafiles);

for cont=1:ultimo
    file=[path,'\',st{listafiles(cont)}];
     k=strfind(file,'fit');
  if isempty(k)==1
        msgbox(['Fit files required!!'],'Select files','error')    % controla tipo de archivo ingresado
      return
  end
    x =load(file);
    disp(['File ' ,st{listafiles(cont)}, ' loaded.']);
    analizados{nroexp}=file;
    nroexp=nroexp+1;

 if option==1        
     todoloc=1;
    [synmol, totcolumnas] = size (x);  
    for fila = 1: synmol
      if x(fila,5) == 0
          if x(fila,4)==0
          else
           extra (ex,:) = x (fila, :); 
           ex=ex+1;
          end
       else
          if x(fila,5) < 0
                 perisyn (ps,:) = x (fila, :);  % archivo indice con molec perisyn
                 ps=ps+1;
             else
                 synaptic (sy,:) = x (fila, :) ; % archivo indice con molec syn
                 sy=sy+1;
          end
       end
    end;
   else
    %sin distinguir localizacion
   [mol, totcolumnas] = size (x);  
    for fila = 1: mol
           total (ex,:) = x (fila, :) ;
           ex=ex+1;
    end
 end
end % for con
m1=0;m2=0;m3=0;n1=0;n2=0;n3=0;mje=(' ');

if option==1

  switch handles.selection
      
      case 1                      % no junta nada
           resextra = [name,'\extra.dat']; resperi = [name,'\peri.dat']; ressynap = [name,'\synap.dat'];
           if isempty(extra)==0
              if saveopt==1
                 save(resextra,'extra','-ascii') 
              end
              [n1,m] = size (extra);
              m1 = median ( extra (:,2));
           end
           if isempty(perisyn)==0
             if saveopt==1
                save(resperi,'perisyn','-ascii') 
             end
             [n2,m] = size (perisyn);
             m2 = median ( perisyn (:,2));
           end
           if isempty(synaptic)==0
             if saveopt==1
               save(ressynap,'synaptic','-ascii') 
             end
             [n3,m] = size (synaptic);
             m3 = median ( synaptic (:,2));
         end
           if saveopt==1
              mje=(['Results saved in \',name]);
              else
              mje=('No data saved');
           end
        set(handles.linea1,'string','Extrasynaptic'); set(handles.linea2,'string','Perisynaptic');
        set(handles.linea3,'string','Synaptic');
        set(handles.edit5,'string',num2str(m1));
        set(handles.edit8,'string',num2str(n1));
        set(handles.edit11,'string',num2str(m2));
        set(handles.edit12,'string',num2str(n2));
        set(handles.edit13,'string',num2str(m3));
        set(handles.edit14,'string',num2str(n3));
        set(handles.mensaje,'string',mje);
        
    case 2            % junta peri y extra
            periandextra=[extra',perisyn']; periandextra=periandextra';
            resperiextra = [name,'\peri+extra.dat'];  ressynap = [name,'\synap.dat'];
           if isempty(periandextra)==0
             if saveopt==1
                save(resperiextra,'periandextra','-ascii') 
             end
             [n1,m] = size (periandextra);
             m1 = median ( periandextra (:,2));
           end
           if isempty(synaptic)==0
             if saveopt==1
               save(ressynap,'synaptic','-ascii') 
             end
             [n2,m] = size (synaptic);
             m2 = median ( synaptic (:,2));
           end
           if saveopt==1
              mje=(['Results saved in \',name]);
              else
              mje=('No data saved');
           end
        set(handles.linea1,'string','Peri+extrasynaptic'); set(handles.linea2,'string','Synaptic');
        set(handles.linea3,'string',' ');
        set(handles.edit5,'string',num2str(m1));
        set(handles.edit8,'string',num2str(n1));
        set(handles.edit11,'string',num2str(m2));
        set(handles.edit12,'string',num2str(n2));
        set(handles.edit13,'string','');
        set(handles.edit14,'string','');
        set(handles.mensaje,'string',mje);

  case 3             % junta peri y syn
            periandsynaptic=[perisyn',synaptic']; periandsynaptic=periandsynaptic';
            resextra = [name,'\extra.dat']; resperisyn = [name,'\peri+syn.dat'];
             if isempty(extra)==0
               if saveopt==1
                 save(resextra,'extra','-ascii') 
               end
               [n1,m] = size (extra);
               m1 = median ( extra (:,2));
             end
             if saveopt==1
                save(resperisyn,'periandsynaptic','-ascii') 
             end
             [n2,m] = size (periandsynaptic);
             m2 = median ( periandsynaptic (:,2));
             if saveopt==1
              mje=(['Results saved in \',name]);
              else
              mje=('No data saved');
             end
        set(handles.linea1,'string','Extrasynaptic'); set(handles.linea2,'string','Peri+synaptic');
        set(handles.linea3,'string',' ');
        set(handles.edit5,'string',num2str(m1));
        set(handles.edit8,'string',num2str(n1));
        set(handles.edit11,'string',num2str(m2));
        set(handles.edit12,'string',num2str(n2));
        set(handles.edit13,'string','');
        set(handles.edit14,'string','');
        set(handles.mensaje,'string',mje);

   end    %case selection 
   
else    %option sin loc
    
   if isempty(total)==0
       res = [name,'\total.dat'];
       if saveopt==1
          save(res,'total','-ascii') ;
          mje=(['Results saved in \',name]);
       else
          mje=('No data saved');
       end
       [n,m] = size (total);
       m = median ( total (:,2));
        set(handles.linea1,'string','All trajectories'); set(handles.linea2,'string',' ');
        set(handles.linea3,'string',' ');
        set(handles.edit5,'string',num2str(m));
        set(handles.edit8,'string',num2str(n));
        set(handles.edit11,'string','');
        set(handles.edit12,'string','');
        set(handles.edit13,'string','');
        set(handles.edit14,'string','');
        set(handles.mensaje,'string',mje);
end

guidata(hObject, handles);

end

disp(' ');
disp(['Done']);
disp(' ');


set(handles.savefolder,'string','Folder name');
   guidata(hObject, handles);


%--------------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function savefolder_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function savefolder_Callback(hObject, eventdata, handles)

savefolder=get(hObject,'String');

guidata(hObject, handles);

%--------------------------------------------------------------------------
% campos resultados
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
function edit5_Callback(hObject, eventdata, handles)

function edit8_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
function edit8_Callback(hObject, eventdata, handles)

function edit11_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
function edit11_Callback(hObject, eventdata, handles)

function edit12_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
function edit12_Callback(hObject, eventdata, handles)

function edit13_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
function edit13_Callback(hObject, eventdata, handles)

function edit14_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
function edit14_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%selection
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function popupmenu1_Callback(hObject, eventdata, handles)

handles.selection=get(hObject,'Value');
        set(handles.linea1,'string',' ');
        set(handles.linea2,'string',' ');
        set(handles.linea3,'string',' ');
        set(handles.edit5,'string',' ');
        set(handles.edit8,'string',' ');
        set(handles.edit11,'string',' ');
        set(handles.edit12,'string',' ');
        set(handles.edit13,'string',' ');
        set(handles.edit14,'string',' ');
        set(handles.mensaje,'string',' ');

guidata(hObject, handles);

% end of file