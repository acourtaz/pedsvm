function distmsdtrack(file,sizepixel,totaltlag,maxlength,savefolder)
% distmsdtrack(file,sizepixel,totaltlag,maxlength,savefolder)
% totaltlag: nro de puntos de mean MSD a calcular 
% calcula distribuciones de r2 a partir de archivo (file) preparado por stepTRC
% (o immotrc)
% crea grafico y archivo para graficar msd (10 primeros tlag)
%
% pone limite de maxlength tlags para que no haya problemas de falta de memoria
% en caso de QD (jan 06)
%
% dentro de tracking.m
%
% MR - jan 06 - v 1.2                                           MatLab6p5p1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1 
   help distmsdtrack
   return
end
if nargin < 3 
   totaltlag=10;
   disp(['Calculating 10 points mean MSD ...']);
else
   disp(['Calculating ',num2str(totaltlag),' points mean MSD...']);
end
if nargin<4
    savefolder=cd;
end
disp(['Calculating over the first ',num2str(maxlength),' points of the trajectories']);

i=1;
traces=load(file);
fullpdf=[];
grafmsd=[];
[msddata, fmsddata] = msdshortlim(traces,totaltlag,maxlength);
fmsddata=fmsddata*(sizepixel/1000)^2; % go from pxl => um^2
disp (['Saving file ']);

for step=1:size(fmsddata,2)
  	OnzeVector = sort(fmsddata(find(fmsddata(:,step)~=0), step))';
   	if ~isempty(OnzeVector)
       AantalVector = linspace(0,1,length(OnzeVector));
       OnzeData = [OnzeVector', AantalVector'];
	   filename = sprintf('dist%02.0f.dat', step);
       save([savefolder,filename],'OnzeData', '-ascii');
       disp (filename);
       fullpdf=[fullpdf;OnzeData];
       filename = sprintf('fullDist.dat', step);
       save ([savefolder,filename],'fullpdf','-ascii');
    end 
end 
      
%linear MSD-plot
ntrc=size(fmsddata,2);
tdat=[];
for noz=1:ntrc
      val=fmsddata(:,noz); val=val(val>0);
      if length(val)>0
         tdat=[tdat;[mean(val), std(val)/sqrt(length(val))]];
      else
         tdat=[tdat;[0 0]];
      end
end
[fil,col]=size(tdat);
%colecta datos para grafico MSD pero solo los 10 primeros puntos  
for cont=1:10
       if cont<fil+1
          grafmsd(cont,1)=cont;
          grafmsd(cont,2)=tdat(cont,1);
          grafmsd(cont,3)=tdat(cont,2);
       end
end
savename= sprintf('fullmsd.dat', step);
save ([savefolder,filename],'grafmsd','-ascii');
   
figure;
[fil,col]=size(tdat);
if fil>9
      maxy=(tdat(9,1)+tdat(9,1)/6);
else
      maxy=(tdat(fil,1)+tdat(fil,1)/6);
end
plot(1:ntrc,tdat(:,1),'b*',1:ntrc,tdat(:,1)+tdat(:,2),'b^',1:ntrc,tdat(:,1)-tdat(:,2),'bv');
axis ([0 10 0 maxy]);
xlabel ('time lag'), ylabel('MSD (pixel^2)');

clear all

%end of file






