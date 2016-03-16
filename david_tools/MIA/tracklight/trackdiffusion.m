function varargout = trackdiffusion(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRACKDIFFUSION M-file for trackdiffusion.fig
%
% menu to launch gaussiantrack.m or MItrack.m
% analysis of diffusion results
% movies
%
% MR - mar 06 - v 1.0                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off','MATLAB:dispatcher:InexactMatch')
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackdiffusion_OpeningFcn, ...
                   'gui_OutputFcn',  @trackdiffusion_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trackdiffusion_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
warning off MATLAB:m_warning_end_without_block

% --- Outputs from this function are returned to the command line.
function varargout = trackdiffusion_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


%msgbox('New versions! for the cleaning of trajectories and the creation of movies!!!')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% results
function results_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function diffconst_Callback(hObject, eventdata, handles)
% diffusion constant
disp('  ');
disp ('********** Diffusion coefficient results')
disp('  ');
resultsdif
% --------------------------------------------------------------------
function step_Callback(hObject, eventdata, handles)
% makes the files for step analysis
% folder step
disp('  ');
disp ('********** Step analysis')
disp('  ');
stepTRC
% --------------------------------------------------------------------
function distribution_Callback(hObject, eventdata, handles)
% counts molecules and measures their distance to the domain centroid
disp('  ');
disp ('********** Distribution of molecules in domains')
disp('  ');
distri
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tests for the analysis parameters

% --------------------------------------------------------------------
function test_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function peakintensity_Callback(hObject, eventdata, handles)
disp('  ');
disp ('********** Frequency histograms of peaks intensity, width or offset')
disp('  ');
testspeak
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualizations
%
% --------------------------------------------------------------------
function images_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function movie_Callback(hObject, eventdata, handles)
% movie with trajectories over .spe files or .tif files
movtrack;
% --------------------------------------------------------------------
function domain_Callback(hObject, eventdata, handles)
disp('  ');
disp ('********** Display of detected domains')
disp('  ');
visudomains(handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tools_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function subgroup_Callback(hObject, eventdata, handles)
disp('  ');
disp ('********** Selection of trajectories by their D')
disp('  ');
partialTRCTL
%--------------------------------------------------------------------
function clean_Callback(hObject, eventdata, handles)
disp('  ');
disp ('********** Clean trajectories')
disp('  ');
cleanTRCTL
% --------------------------------------------------------------------
function doubleloc_Callback(hObject, eventdata, handles)
% edge detection by sobel and sorting of trajectories for a second
% localization
disp('  ');
disp ('********** Localization in domains of two images')
disp('  ');
doublelocalize
%------------------------------------------------------------------------
function movingref_Callback(hObject, eventdata, handles)
% recalculates positions for molecules that colocalize with a moving domain
% remakes trajectories and calculates msd and D
disp('  ');
disp ('********** Recalculation of trajectories localized in a moving domain')
disp('  ');
movref
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% help me with the help!!!!
% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
helptracklight

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%quit
function quitpushbutton3_Callback(hObject, eventdata, handles)
    qstring=['Do you want to quit?'];
    button = questdlg(qstring); 
    if strcmp(button,'Yes')
        disp('  ');
        close
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extras
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function visudomains(handles)
%llama synapses para ver marcacion dominios

% loads and reads -loc_MIA file 
[file,path] = uigetfile('*loc_MIA*','Load domain image');
filename = [path,file];
if filename==0
    return
end
% movie
stktrue=0;
answer=findstr(filename,'.spe'); answerb=findstr(filename,'.SPE');
if isempty(answer)==1 & isempty(answerb)==1
            answer2=findstr(filename,'.tif');
            if isempty(answer2)==1
                msgbox('Wrong type of file','Error','error');
                return
            else
                    % .tif file       
                    [stack_info,datamatrix] = tifdataread(filename);
                    Xdim=stack_info.x;
                    Ydim=stack_info.y;
                    stktrue=2;
                    [fil,col]=size(datamatrix);     
                    datamatrix=double(datamatrix);
                    if col/Xdim==3  %rgb
                        msgbox('Wrong type of file','Error','error');
                        return
                    end
                    nfram=1;
             end
else
     % .spe file
     [datamatrix p]= spedataread (filename);
     Xdim=p(1);
     Ydim=p(2)/p(4);
     nfram=p(4);
end

% num?rote les synapses (ici, il s'agit de l'image mia seuill?e)
level = graythresh(datamatrix);
bw = im2bw(datamatrix,level); %binarise avec le seuil level
figure
imshow(bw);

[labeled,numObjects] = bwlabel(bw,4); 
disp(['********* On num?rote ' num2str(numObjects) ' synapses']);
%cr?? les zones perisynaptiques : d'abord avec valeur -1
% taille de la zone = (expand-1)/2
expand=5;
zone=(expand-1)/2;
disp(['la taille de la zone p?risynaptique: ' num2str(zone) ' pixels']);
M=zeros(expand,expand);
M=M+1;
BW2= conv2(labeled,M);
s=size(BW2);
BW2=BW2(zone+1:s(1)-zone,zone+1:s(2)-zone); %rescale l'image convolu?e pour qu'elle ait la meme taille que labeled
BW2=sign(BW2);
datamatrix=sign(datamatrix);
BW2=imsubtract(BW2,datamatrix); % matrice des zones perisynaptiques
labeled=imsubtract(labeled, BW2);

figure
RGB_label = label2rgb(abs(BW2), 'gray');
imshow(RGB_label);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in gaussian.
function gaussian_Callback(hObject, eventdata, handles)
setdetectionoptions; %default detection options
gaussiantrack

% --- Executes on button press in miatracking.
function miatracking_Callback(hObject, eventdata, handles)
miatrack
% end of file

