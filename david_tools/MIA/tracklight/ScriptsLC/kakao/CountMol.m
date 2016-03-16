function [Nsyn,Nperi,Nextra] = CountMol (file,numextra)
% function [Nsyn,Nperi,Nextra] = CountMol (file,numextra)
% compte les pics trouv� dans les synpases, peri et extra �partir des
% traces non coup�s g���s par affectsynpases
% numextra est le chiffre correspondant aux extra (typ 100 ou 0)



files=sbe(file,1)
savename=[file];
trcdata=[];
Nextra=0;
Nsyn=0;
Nperi=0;
files;
count=0;
   npartial=[];
   
for k=1:length(files)
   str=['trc',filesep,files(k).name,'.syn.trc'];
      if length(dir(str))>0		% is there new peakdata?
      Strcdata =load(str)
      else
      Strcdata=[];
      end
      count=count+1;
   disp(['*  ',num2str(length(Strcdata)),' peaks in file ',files(k).name,sprintf(' (%d/%d)',k,length(files))]);
   %valores parciales
   Ntotpar=size(Strcdata,1);

   npartial(count,1)=count;
   npartialextra=0;
   npartialperi=0;
   npartialsyn=0;
   
for i=1:Ntotpar
    if Strcdata(i, 6)==numextra
        npartialextra=npartialextra+1;
    else 
       if Strcdata(i, 6)>numextra
           npartialsyn=npartialsyn+1;
       else
          npartialperi=npartialperi+1;
      end
  end
end
npartial(count,2)=npartialextra;
npartial(count,3)=npartialsyn;
npartial(count,4)=npartialperi;
npartial(count,5)=Ntotpar;

disp(['On trouve ', num2str(npartialsyn), ' pics dans les synapses, ', num2str(npartialperi), ' peri sur un total de ', num2str(Ntotpar), '.'])

%totales
   trcdata=[trcdata; Strcdata];
end


Ntot=size(trcdata,1);
disp(['Il y a ',num2str(Ntot),' pics au total.']);

for i=1:Ntot
    if trcdata(i, 6)==numextra
       Nextra=Nextra+1;
   else 
       if trcdata(i, 6)>numextra
          Nsyn=Nsyn+1;
      else
          Nperi=Nperi+1;
      end
  end
end
disp(['On trouve ', num2str(Nsyn), ' pics dans les synapses, ', num2str(Nperi), ' peri sur un total de ', num2str(Ntot), '.'])
save (['nropeaks'],'npartial','-ascii')  

end