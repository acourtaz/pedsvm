function MSDtrack(file,handles)
%function MSDtrack(file,handles)
% calculates MSD from .trc files
%
% MR mar 06 - v1.0  for gaussiantrack.m and MIAtrack.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize variables
till=str2num(handles.till);
sizepixel=str2num(handles.sizepixel);
mintrace=str2num(handles.mintrace);
longFIT=str2num(handles.longfit);
deco=get(handles.dolocalize,'value'); % localization & deconnection
[namefile,rem]=strtok(file,'.');

%MSD
disp('  ');
disp([' MSD calculation of reconnected trajectories...' ]);
waitbarhandle=waitbar( 0,'Please wait...','Name',['Calculating MSD in ',file]);
trccut=load(['trc',filesep,namefile,'.con.trc']); % trayectorias mol con loc

if (length(trccut)>0) 
  [msddata, fullmsddata]=newMSDTL(trccut,150,waitbarhandle); %%%%%%%%%%% !!! MSD de 150 points au max
  save(['msd',filesep,namefile,'.con.msd'],'msddata','-ascii'); 
  close(waitbarhandle);
  % extrait les traces des fichiers .msd
  Maxtrace=max(msddata(:,1));
  for i=1:Maxtrace
    temp=[];
    lesfits=[];
    p=1;
    for j=1:size(msddata(:,1))
        if  msddata(j,1)==i
            temp(p,:)=[msddata(j,1),msddata(j,2)*till,msddata(j,3),msddata(j,4)];%  
            p=p+1;
        else        
        end
    end
    if p>4 % min for fit ATENTION!!!!!!!!!!!!!!!!!!!!!!
       if isdir(['msd',filesep,'molecules']);else;mkdir(['msd',filesep,'molecules']);end;
       save(['msd',filesep,'molecules',filesep,namefile,'.con.molecule.',num2str(i),'.msd.dat'],'temp','-ascii'); % individual msd
    end
  end
else
  temp=[];
  if isdir(['msd',filesep,'molecules']);else;mkdir(['msd',filesep,'molecules']);end;
  save(['msd',filesep,'molecules',filesep,namefile,'.con.molecule.',Num2str(i),'.msd.dat'],'temp','-ascii'); 
end

% with localization
if deco>0
   if isdir(['msd',filesep,'cut']);else; mkdir (['msd',filesep,'cut']);end;
   if isdir(['msd',filesep,'cut',filesep,'fits']);else; mkdir (['msd',filesep,'cut',filesep,'fits']);end;
   % checks existence
   trccutfile=['trc',filesep,'cut',filesep,namefile,'.deco.syn.trc']; % trayectorias mol con loc
   if length(dir(trccutfile))>0
      trccut=load(trccutfile); % trayectorias mol con loc
      disp('  ');
      disp([' MSD calculation of cut trajectories...' ]);
      waitbarhandle=waitbar( 0,'Please wait...','Name',['Calculating MSD of cut trajectories in ',file]);
      [msddata, fullmsddata]=newMSDTL(trccut,150,waitbarhandle); %%%%%%%%%%% !!! MSD de 150 points au max
      save(['msd',filesep,'cut',filesep,namefile,'.deco.syn.msd'],'msddata','-ascii'); 
      close(waitbarhandle);
      % fits of cut trajectories
      waitbarhandle=waitbar( 0,'Please wait...','Name',['Fitting MSD in ',file]);
      touslesfits=fitMSD(till,sizepixel,longFIT,mintrace,msddata,trccut,deco,waitbarhandle);
      if isempty(touslesfits)==0
         touslesfits=sortrows(touslesfits,5);
         disp('  ');
         disp(['MSD and fits of cut trajectories saved in msd',filesep,'cut']);
         %report
         text=['MSD and fits of cut trajectories saved in msd',filesep,'cut'];
         updatereport(handles,text)
      else  % no fits left
         disp('  ');
         disp(['MSD cut trajectories saved in msd',filesep,'cut, fit not done']);
         %report
         text=['MSD cut trajectories saved in msd',filesep,'cut, fit not done'];
         updatereport(handles,text,1)
     end
     close(waitbarhandle)
   else
      disp('  ');
      disp(['File ',trccutfile,' not found']);
      touslesfits=[];
      %report
      text=['MSD and fits not done'];
      updatereport(handles,text)
   end
   save(['msd',filesep,'cut',filesep,'fits',filesep,namefile,'.deco.fit.msd'],'touslesfits','-ascii'); 
else
   % fits
   if length(trccut)>0  % sin loc
      waitbarhandle=waitbar( 0,'Please wait...','Name',['Fitting MSD in ',file]);
      if isdir(['msd',filesep,'fits']);else; mkdir (['msd',filesep,'fits']);end
      touslesfits=fitMSD(till,sizepixel,longFIT,mintrace,msddata,trccut,deco,waitbarhandle);
      touslesfits=sortrows(touslesfits,4);
      disp('  ');
      disp(['MSD and fits saved in msd',filesep]);
      %report
      text=['MSD and fits saved in msd',filesep];
      updatereport(handles,text)
      close(waitbarhandle)
   else
      touslefits=[];
      %report
      text=['MSD and fits not done'];
      updatereport(handles,text)
   end
   save(['msd',filesep,'fits',filesep,namefile,'.fit.msd'],'touslesfits','-ascii'); 
end

% end of file