function doublelocalize
% function doublelocalize
% performs double localization of trajectories over two images of domains
% gives 0 to extra-domain localization
% positive number for points inside domains of image1
% negative number for points inside domains of image2 or in both
% needs .con.trc files, saves .con.syn.trc files in double\trc
% calls deconnect and saves deco.syn.trc in double\trc\cut
%
% MR 04-06
% mod 06/06: allows MIA trc files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%lista movies
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
if isdir(['double',filesep,'trc',filesep,'cut']); else; mkdir(['double',filesep,'trc',filesep,'cut']); end

% sets identifiers for image files
prompt = {'Image 1 (positive values)','Image 2 (negative values)'};
num_lines= 1;
dlg_title = 'Identifiers for domains files';
def = {'-red.tif','-green.tif'}; % default values
answer  = inputdlg(prompt,dlg_title,num_lines,def);
exit=size(answer);
if exit(1) == 0;
   return; 
end
identif1=answer{1};
identif2=answer{2};
   
for nromovie=1:ultimo
    control=0;
    file=st{files(nromovie)}
    [namefile,rem]=strtok(file,'.');
    Image1name=[namefile,identif1]
    Image2name=[namefile,identif2]
    trcfile=['trc',filesep,namefile,'.con.trc'];
    if length(dir(Image1name))>0
        if length(dir(Image2name))>0
            if length(dir(trcfile))>0
               control=1;                      % trc file by Gaussian fitting
               MIAcontrol=0
           else
               trcfile=['trc',filesep,namefile,'.MIA.con.trc'];
               if length(dir(trcfile))>0
                   control=1;
                   MIAcontrol=1                % trc file by MIA tracking
               else
                   disp(['File ',trcfile,' not found']);
               end
           end
        else
            disp(['File ',Image2name,' not found']);
        end
    else
        disp(['File ',Image1name,' not found']);
    end            
    
    if control==1
        
       % reads trc file
       Trc=load(trcfile);
       % reads files
       [Image1,ImagePar1]=readimages(Image1name);
       [Image2,ImagePar2]=readimages(Image2name);
       %dimension des images
       Xdim1=ImagePar1(1);
       Ydim1=ImagePar1(2)/ImagePar1(4);
       Xdim2=ImagePar2(1);
       Ydim2=ImagePar2(2)/ImagePar2(4);
       control2=0;
       if Xdim1==Xdim2
          if Ydim1==Ydim2
             control2=1;
          else
             disp(['Images must have the same size'])
          end
       else
          disp(['Images must have the same size'])
       end
       
       if control2==1
           mergesynapse=zeros(Ydim1,Xdim1);
          % binarization & numeration
          disp('  ');
          disp(['Numbering domains...']);
          % Image 1
          level1 = graythresh(Image1);
          bwimage1 = im2bw(Image1,level1); %binarise avec le seuil level
          [numsynapse1,numObjects1] = bwlabel(bwimage1,4); 
          disp([ num2str(numObjects1) ' domains numbered in image 1']);
          % Image 2
          level2 = graythresh(Image2);
          bwimage2 = im2bw(Image2,level2); %binarise avec le seuil level
          [numsynapse2,numObjects2] = bwlabel(bwimage2,4); 
          disp([ num2str(numObjects2) ' domains numbered in image 2']);
          % re-numbering and negative values
          for i=1:Ydim1
              for j=1:Xdim1
                  if numsynapse1(i,j)>0 & numsynapse2(i,j)>0                   %loc on domain of image1 and domain of image2 that co-localize
                         mergesynapse(i,j)=-(numsynapse1(i,j));                 %takes the negative value of the domain 1
                     elseif numsynapse1(i,j)>0 & numsynapse2(i,j)==0 
                         mergesynapse(i,j)=numsynapse1(i,j);                    %loc on domain of image1
                     elseif numsynapse1(i,j)==0 & numsynapse2(i,j)>0 
                         mergesynapse(i,j)=-(numsynapse2(i,j)+numObjects1);     %loc on domain of image2
                  end
              end
          end
          %disp(size(mergesynapse))
          %disp(Ydim1)
          %disp(Xdim1)
          disp('  ');
          disp(['Performing localization of trajectories of molecules...']);
          Points=size(Trc(:,1),1);
          temp=[];
          for i=1:Points
              if MIAcontrol==0
                  temp=[temp;[Trc(i,:),mergesynapse(max(min(round(Trc(i,4)+1),Ydim1),1),max(min(round(Trc(i,3)+1),Xdim1),1))]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
              else
                  temp=[temp;[Trc(i,1:5),mergesynapse(max(min(round(Trc(i,4)+1),Ydim1),1),max(min(round(Trc(i,3)+1),Xdim1),1)),Trc(i,6)]]; % ! x et y sont invers�dans numsynapse par rapport �Trc
              end
          end
          nwtrcsyn=temp;
 
         % guarda trajectorias con localiz con formato para msdturbo
         if MIAcontrol==0
            filetxt=['double',filesep,'trc',filesep,namefile,'.con.syn.trc']; fi = fopen(filetxt,'w'); 
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',nwtrcsyn');
            end; fclose(fi);
        else
            filetxt=['double',filesep,'trc',filesep,namefile,'.MIA.con.syn.trc']; fi = fopen(filetxt,'w'); 
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',nwtrcsyn');
            end; fclose(fi);
        end

         % cutting
         nwtrccut=deconnect(nwtrcsyn); %corta trajectorias que cambian de localizacion
         if MIAcontrol==0
            filetxt=['double',filesep,'trc',filesep,'cut',filesep,namefile,'.deco.syn.trc']; fi = fopen(filetxt,'w');
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',nwtrccut');
            end; fclose(fi);
        else
            filetxt=['double',filesep,'trc',filesep,'cut',filesep,namefile,'.MIA.deco.syn.trc']; fi = fopen(filetxt,'w');
            if fi<3; error('File not found or readerror.');
            else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',nwtrccut');
            end; fclose(fi);
        end
         %save(['double\trc\cut\',namefile,'.deco.syn.trc'],'nwtrccut','-ascii','-tabs'); % trayectorias mol con loc
         disp('  ');
         disp(['New trajectories saved in double',filesep,'trc',filesep]);
     end % control2
     
 end  %control 1
 
end % loop

%--------------------------------------------------------------------------
function [Image,ImagePar]=readimages(Imagename)

stktrue=0;
k=strfind(Imagename,'spe');
if isempty(k)==1                             %tif
   stktrue=1;
   info=imfinfo(Imagename);
   ImagePar(1)=info.Width;
   ImagePar(2)=info.Height;
   ImagePar(3)= 1;
   ImagePar(4)= 1;
   ImagePar(5)= 1;
   Image=imread(Imagename);
   Image=double(Image);
else
   [Image ImagePar]=spedataread(Imagename); %.spe
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%