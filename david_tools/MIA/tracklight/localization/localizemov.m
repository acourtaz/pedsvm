function [nwtrcsyn,newtrcdatadomain]=localizemov(movie,Trc,domainfile,MIAtrc)
% function [nwtrcsyn,newtrcdatadomain]=localizemov(movie,Trc,domainfile)
%
% modified from affectsynapses.m by MR (mar 06) for movref.m
% author LC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reads files

nframmol=max(Trc(:,2)); % max number of images

% MIA
nrocol=5;

% movie domains
       [stack_info,framematrix] = stkdataread(domainfile);
       ImagePar(1)=stack_info.x;
       ImagePar(2)=stack_info.y * stack_info.frames;
       ImagePar(3)= 1;
       ImagePar(4)= stack_info.frames;
       ImagePar(5)= 1;
       stktrue=1;
Xdim=ImagePar(1);
Ydim=ImagePar(2)/ImagePar(4);
nframdom=ImagePar(4);

% control nfram
if nframmol>nframdom
    nfram=nframdom
else
    nfram=nframmol
end       

disp('  ');
disp(['Performing localization of trajectories of molecules...']);

nwtrcsyn=[];

for nroimagen=1:nfram
    disp('  ');
     disp(['Image # ',num2str(nroimagen)]);

   if nroimagen==1
      firsty=nroimagen;
      lasty=Ydim;
   else
      firsty=(nroimagen-1)*Ydim;
      lasty=firsty+Ydim;
   end
   if stktrue==0
        datamatrix=framematrix(firsty:lasty,:);
    else
        datamatrix = framematrix(nroimagen).data;
        %datamatrix=framematrix(:,:,nroimagen);
   end
   
  % numerotacion synapses
  [maximas, numsynapse]=domains(datamatrix,ImagePar);   
  
  % localizacion archivo trc de dominios
  [namefile,rem]=strtok(domainfile,'_');
  %trcdomain=namefile(1:(size(namefile,1)-4))
  currentdir=cd;
 % path=[cd,'\dom\trc'];
  %cd(path)
 % str=[MIAfoldertrc,namefile,'.MIA.con.trc'];  % siempre reconnectados!
  if length(dir(MIAtrc))>0		
      trcdatadomain =load(MIAtrc);
      SPok=1;
      disp(['File ' ,MIAtrc, ' loaded.']);
  else
      disp(['Couldn''t find con.trc file for domains ',MIAtrc]);
      trcdata= [];
      SPok=0;
  end
  %cd(currentdir);
  
 if SPok>0
     newtrcdatadomain=[];
     for i=1:size(trcdatadomain(:,1),1)
         newtrcdatadomain=[newtrcdatadomain;[trcdatadomain(i,1:5),numsynapse(max(min(round(trcdatadomain(i,4)+1),Ydim),1),max(min(round(trcdatadomain(i,3)+1),Xdim),1)),trcdatadomain(i,6)]];
         %newtrcdatadomain=[trcdatadomain,numsynapse(max(min(round(trcdatad
         %omain(i,4)+1),Ydim),1),max(min(round(trcdatadomain(i,3)+1),Xdim),1))];
     end
     disp('Localization of domains done')
 end
 
  % loc trajectories
  if (length(Trc)>0) 
     [Points,col]=size(Trc);
     temp=[];
     if nroimagen==1    
          % inicializa nuevo file trc
         for i=1:Points
            if col>nrocol
               %MIA
              %if Trc(i,2)==nroimagen
                 temp=[temp;[Trc(i,1:5),numsynapse(max(min(round(Trc(i,4)+1),Ydim),1),max(min(round(Trc(i,3)+1),Xdim),1)),Trc(i,6)]] ;% ! x et y sont inversé dans numsynapse par rapport à Trc
                 %end     
            else
              %if Trc(i,2)==nroimagen
                 temp=[temp;[Trc(i,:),numsynapse(max(min(round(Trc(i,4)+1),Ydim),1),max(min(round(Trc(i,3)+1),Xdim),1))]]; % ! x et y sont inversé dans numsynapse par rapport à Trc
                 %end
            end
         end
         nwtrcsyn=temp;
     else
         for i=1:Points
                 if Trc(i,2)==nroimagen
                    nwtrcsyn(i,6)==numsynapse(max(min(round(Trc(i,4)+1),Ydim),1),max(min(round(Trc(i,3)+1),Xdim),1)) ;% ! x et y sont inversé dans numsynapse par rapport à Trc
                 end     
         end
     end
          disp('Localization of trajectories done')

 else
     disp('Empty .trc file');
end
     
end %loop frames

% end of file