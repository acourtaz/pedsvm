function stepTRC
% function stepTRC
% prepares files for step analysis (tracking.m)
%
% MR - jan 06 - v 1.2                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
control = 1;
start_path=cd;



% path of the data 
dialog_title=['Select data folder for step analysis (trc files)'];
directory_name = uigetdir(start_path,dialog_title);
if directory_name==0
    return
end
path=directory_name;
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
localizar=0;
 k=strfind(path,'cut');
if isempty(k)==0
     option=1  ; % loc
 else
     option=0 ;%no loc
      % dialog box to enter new data
     qstring=['Perform localization of non-reconnected trc files?'];
     button = questdlg(qstring); 
     if strcmp(button,'Yes')
        option=1;
        localizar=1;
     end
end


% ingresar size pixel y cant tlag msd
prompt = {'Pixel size ','Max trajectory length','Max tlags for mean MSD'};
num_lines= 1;
dlg_title = 'Creating subgroup of trajectories';
def = {'190','50','10'}; % default values
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);
if exit(1) == 0;
       %close
       return; 
end
szpx=str2num(answer{1});
maxlength=str2num(answer{2});
maxmsd=str2num(answer{3});
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

% cargar trc 
[f,ultimo]=size(listafiles);
disp(['Sorting trajectories...']);

for cont=1:ultimo
    file=[path,filesep,st{listafiles(cont)}];
    disp (['File ',st{listafiles(cont)}])
     k=strfind(file,'trc');
  if isempty(k)==1
        msgbox(['trc files required!!'],'Select files','error')             % controla tipo de archivo ingresado
      return
  end
  if length(dir(file))>0		
    newtrctemp =load(file);
      control = 1;
   else
      disp(['Couldn''t find trc',filesep,' file ',newtrctemp]);
      control = 0;
  end
  
 if control >0
     if localizar==1
         currentdir=cd;
         cd(path);
        [namefile,rem]=strtok(st{listafiles(cont)},'.');
        cd(currentdir)
        spelist=dir('*-loc_MIA.spe*');
        if isempty(spelist)==1
           domainfile=[namefile,'-loc_MIA.tif'];
        else
           domainfile=[namefile,'-loc_MIA.spe'];
        end
        if length(dir(domainfile))>0
           loctrcstep(namefile,newtrctemp,domainfile);
           newfile=['trc',filesep,'cutnorec',filesep,namefile,'.deco.syn.trc'];
           newtrctemp=load(newfile);
           controls=1;
        else
            disp(['File ',domainfile,' not found']);
            controls=0;
        end
    else
        controls=1;
    end
    
    if isempty(newtrctemp)==1
        controls=0;
    end
    
  if controls>0
        
  newtrc=[];
  if option==1
    nrocol=6;
  else
    nrocol=5;
  end
  for t=1:nrocol
     newtrc(:,t)=newtrctemp(:,t);
  end
  [totfilas, c] = size (newtrc);
  flagsyn=0; 
  
  if option==1
     for fila = 1: totfilas     % archivos con todas las trc
         if newtrc(fila,6) == 0
            trcextra(ex,:)= newtrc (fila, :);
            trcextra(ex,1)= trcextra(ex,1)+ultimaextra;
            ex=ex+1;
         elseif newtrc(fila,6) < 0
           trcperi(ps,:) = newtrc (fila, :) ; 
           trcperi(ps,1)= trcperi(ps,1)+ultimaperi;    % en las peri queda cualquier cosa
           ps=ps+1;
           if fila>1
              if newtrc(fila,1) == newtrc(fila-1,1) 
                 if flagsyn==1           %mol que era sinaptica en el punto anterior
                    trcsyn(s,:) = newtrc (fila, :) ;
                    trcsyn(s,1)= trcsyn(s,1)+ultimasyn;    % la pongo como sinaptica 
                    s=s+1;
                 end
             else
                flagsyn=0;
             end
           else
            flagsyn=0;
           end
         elseif newtrc(fila,6) > 0
         if fila>1
            if newtrc(fila,1) == newtrc(fila-1,1) 
                if flagsyn==1
                    trcsyn(s,:) = newtrc (fila, :) ;
                    trcsyn(s,1)= trcsyn(s,1)+ultimasyn;
                    s=s+1;  
                end
            else
                trcsyn(s,:) = newtrc (fila, :) ;
                trcsyn(s,1)= trcsyn(s,1)+ultimasyn;
                s=s+1;  
                flagsyn=1;
            end
         else
           trcsyn(s,:) = newtrc (fila, :) ;
           trcsyn(s,1)= trcsyn(s,1)+ultimasyn;
           s=s+1;  
           flagsyn=1;
         end
      end
   end;
 
   if ex>1
     ultimaextra=trcextra(ex-1,1);
   end
   if ps>1
     ultimaperi=trcperi(ps-1,1);
   end
   if s>1
     ultimasyn=trcsyn(s-1,1);
   end
  
 else 
   for fila = 1: totfilas      
      trcextra(ex,:)= newtrc (fila, :);
      trcextra(ex,1)= trcextra(ex,1)+ultimaextra;
      ex=ex+1;
   end
   if ex>1
      ultimaextra=trcextra(ex-1,1);
   end

  end  
 end % control
end %control bis
end %loop files

warning off MATLAB:MKDIR:DirectoryExists

if option==1
    extrafolder=['step',filesep,'stepextra',filesep];
    perifolder=['step',filesep,'stepperi',filesep];
    synfolder=['step',filesep,'stepsyn',filesep];
    mkdir (['step',filesep,'stepextra']); mkdir (['step',filesep,'stepperi']); mkdir (['step',filesep,'stepsyn']);
    save (['step',filesep,'stepextra',filesep,'extra.syn.trc'],'trcextra','-ascii');
    %disp('MSD calculation for extrasynaptic trajectories');
    % dist msd
    distmsdtrack('step',filesep,'stepextra',filesep,'extra.syn.trc',szpx,maxmsd, maxlength,extrafolder);

    save (['step',filesep,'stepperi',filesep,'perisyn.syn.trc'],'trcperi','-ascii')  ;
  %  disp('MSD calculation for perisynaptic trajectories');
    % dist msd
   % file=['step\stepperi\perisyn.syn.trc'];
   % if isempty(trcperi)==0
   %   distmsdtrack(file,szpx,maxmsd,maxlength,perifolder);
   %else
  %     disp ('No perisynaptic trajectories');
       % end
  
    save (['step',filesep,'stepsyn',filesep,'synap.syn.trc'],'trcsyn','-ascii');
    disp('MSD calculation for synaptic trajectories');
    % dist msd
    file=['step',filesep,'stepsyn',filesep,'synap.syn.trc'];
    if isempty(trcsyn)==0
       distmsdtrack(file,szpx,maxmsd,maxlength,synfolder);
    else
       disp ('No synaptic trajectories');
    end
  
else
   allfolder=['step',filesep,'all',filesep];
   mkdir (['step',filesep,'all'])
   save (['step',filesep,'all',filesep,'all.syn.trc'],'trcextra','-ascii')
    % dist msd
    msgbox('MSD calculation for all trajectories','Calculating')
   % dist msd
   distmsdtrack('step',filesep,'all',filesep,'all.syn.trc',szpx,maxmsd,maxlength,allfolder);
end

% end of file
