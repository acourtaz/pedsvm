function detecttrack(filename, handles)
%  function detecttrack(filename, handles)
% menu for doseqext.m (gaussiantrack.m)
% reads .spe o .stk movies
%
% MR mar 06 - v1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

path=cd;
controlf=1;
st=[];
[opt,cutoffs]=readdetectionoptions;
D=str2num(handles.diffconst);
cutoffs(1)=str2num(handles.intensityerror);
cutoffs(2)=str2num(handles.maxintensity);
cutoffs(3)=str2num(handles.maxpoints);
disp('  ');
disp('**********Peak detection by Gaussian fitting');
%report
report=get(handles.report,'userdata');
posrep=get(handles.report,'value');
report{posrep+1}=['Peak detection by Gaussian fitting'];
set(handles.report,'userdata',report);
set(handles.report,'value',posrep+1);
disp('  ');
disp(['Reading file ',filename,'...']);
ImagePar=[];
Image=[];

% movie
stktrue=0;
answer=findstr(filename,'.spe'); answerb=findstr(filename,'.SPE');
if isempty(answer)==1 & isempty(answerb)==1
   answer2=findstr(filename,'.stk');
   if isempty(answer2)==1
   else
       % .stk file       
       [stack_info,stackdata] = stkdataread(filename);
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

%report
text=['Image size (pixels): X= ',num2str(ImagePar(1)),'      Y= ',num2str(ImagePar(2)/ImagePar(4)),'        ',num2str(ImagePar(4)),' frames'];
updatereport(handles,text)

[namefile,rem]=strtok(filename,'.'); %sin extension
disp('  ');
disp('Doing detection...');
waitbarhandle=waitbar( 0,'Please wait...','Name',['Peak detection in ',filename]) ;

%recognize peaks 
%Peaks = seqfindext (Image, ImagePar, opt,stktrue,waitbarhandle);            % without doseq... no tracking before cutoffs
Ysize  = ImagePar(2)/ImagePar(4);
firstY=1;
lastY=Ysize;
Peaks=[];

%contr=0
%if contr>0
for iY=1:ImagePar(4)
         if exist('waitbarhandle')
            waitbar(iY/ImagePar(4),waitbarhandle,['Frame # ',num2str(iY)]);
        end
         if stktrue ==0
            SubImage  = Image ((firstY:lastY),:);
            firstY=lastY+1;
            lastY=lastY+Ysize;
        else
            SubImage = stackdata(iY).data;
        end
         r         = findpeakext (SubImage, opt);
         if size(r)>0
            nI     = iY * ones(size(r,1),1);
            r      = [nI,r];
            Peaks = [Peaks;r];
         end
end
%else
%    pkfile= ['pk\',namefile,'.pk'];
%   Peaks=load(pkfile);
%end
close(waitbarhandle);
   
if length(Peaks)>0   
                  [fil col] =size(Peaks) ;          %save peaks in <file>.pk
                 disp('  ');
                 disp(['There are in average ',num2str(fil / ImagePar(4)),' peaks per frame']);
                 % by Cezar M. Tigaret on 23/02/2007
                 save (['pk',filesep,namefile,'.pk'], 'Peaks','-ascii');
                 % save (['pk\',namefile,'.pk'], 'Peaks','-ascii');
                 %report
                 text=['There are in average ',num2str(fil / ImagePar(4)),' peaks per frame.'];
                 updatereport(handles,text)
                 %tracking with 'clean' peaks
                 waitbarhandle=waitbar( 0,'Please wait...','Name',['Initial tracking in ',filename]) ;
                 [TraceData,inddata] = trajectories (filename, ImagePar,D, cutoffs, opt,handles,waitbarhandle);
                 % by Cezar M. Tigaret on 23/02/2007
                 save(['trc',filesep,namefile,'.trc'],'TraceData','-ascii','-tabs'); %save traces in  <file>.trc
                 % save(['trc\',namefile,'.trc'],'TraceData','-ascii','-tabs'); %save traces in  <file>.trc
                 if (length(TraceData)>0) 
                     TraceFound=max(TraceData(:,1));
                 else
                     TraceFound=0;
                 end
                 %index
                 if (length(inddata)>0) 
                 % by Cezar M. Tigaret on 23/02/2007
                     save(['ind',filesep,namefile,'.ind'],'inddata','-ascii'); 
                     % save(['ind\',namefile,'.ind'],'inddata','-ascii'); 
                 end
                 disp(['and the initial tracking constructed ' num2str(TraceFound) ' trajectories.']);
                 disp('  ');
                 %report
                 text=['The initial tracking constructed ' num2str(TraceFound) ' trajectories.'];
                 updatereport(handles,text)
                 close(waitbarhandle);
                 disp('Data saved in .pk, .trc and .ind files...');
end
clear Peaks TraceData inddata;

if stktrue==0
    clear Image;
else
    clear stack;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end of file
