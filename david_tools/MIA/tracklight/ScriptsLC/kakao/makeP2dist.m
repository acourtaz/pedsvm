function OutVec=makeP2dist(filename, syn,time, Maxcalc, sizepixel, prop, meansyn,sdsyn)
% function OutVec=makeP2dist(filename, syn,time, Maxcalc, sizepixel, prop, meansyn,sdsyn)
% si syn=1 -- calcule les P2 des synaptiques, perisynaptiques et extrasynaptiques
%             trouv� dans \trc\cut
% sinon --calcule les P2 trouv� dans \trc
%       --et calcule les P2 avec des fausses synapses de diam�re taillesyn (nm) contenant prop % de
%       mol�ules
% filename ... string describing the SPE data files to be analyzed
%              can contain expandable expressions [see sbe()]
% timing   ...  [till+tlag]
% Maxcalc ... noimbre de timelag calcul�
% sizepixel in nm
% OutVec are not yet implemented
% prop: % of synaptic molecules
% meansyn: mean size of synapses
% sdsyn: SD of synaptic size


global MASCHINE
global BORDER

% check for input parameters

if nargin < 1 % no parameter at all
   help makeP2
   return
end


%trace filename

files=sbe(filename,1);
pkdata=[]; trcdata=[]; inddata=[];
npkdata=[]; ntrcdata=[]; ninddata=[];
maxim=0; maxtrc=0;


if syn==1
    
    
for k=1:length(files)
   str=['pk',filesep,files(k).name,'.pk'];
    
   if length(dir(str))>0		% is there new peakdata?
      Spkdata =load(str);
      SPok=1;
   else
%      disp(['Couldn''t find peak file ',str]);
      Spkdata= [];
      SPok=0;
   end
   
%   str=['trc\',files(k).name,'.syn.trc'];
   str=['trc',filesep,'cut',filesep,files(k).name,'.deco.syn.trc'];
   if length(dir(str))>0     % is there new trcdata?
      Strcdata=load(str);
      STok=1;
   else
 %     disp(['Couldn''t find trace file ',str]);
      Strcdata=[];
      STok=0;
   end
   
   str=['ind',filesep,files(k).name,'.ind'];
   if length(dir(str))>0		% is there new indexdata? 
      Sinddata=load(str);
      SIok=1;
	else
 %     disp(['Couldn''t find index file ',str]);
      Sinddata=[];
      SIok=0;
   end
   % msddata=load(['msd\',filename,'.msd']);
   
   disp([' * found ', num2str(max(Strcdata(:,1))),' traces in file ',files(k).name]);
   if SPok>0
      Spkdata(:,1)=Spkdata(:,1)+maxim;		% new imagenumber
   end
   
   if STok>0
      Strcdata(:,2)=Strcdata(:,2)+maxim;	% -"-
      Strcdata(:,1)=Strcdata(:,1)+maxtrc; % new tracenumber
   end
   
   if SIok>0
      Sinddata(:,1)=Sinddata(:,1)+maxtrc; % -"-
      validind=logical([zeros(size(Sinddata,1),1),Sinddata(:,2:end)>0]);
      Sinddata(validind)=Sinddata(validind)+size(pkdata,1);
      												% new index in pkdata
   end
     
   if ~isempty(inddata)		% indexdata can have different length (max. length of trace)
      maxind=size(inddata,2);
      newind=size(Sinddata,2);
      if maxind>newind
         Sinddata=[Sinddata, zeros(size(Sinddata,1),maxind-newind)];
      elseif maxind<newind
         inddata=[inddata, zeros(size(inddata,1),newind-maxind)];
      end
   end
   
   pkdata=[pkdata; Spkdata];
   trcdata=[trcdata;Strcdata];
   inddata=[inddata;Sinddata];
   
   if ~isempty(pkdata)
      maxim=max(pkdata(:,1));
   end
   if ~isempty(trcdata)
      maxtrc=max(trcdata(:,1));
   end
end

npkdata=pkdata;
ntrcdata=trcdata;
ninddata=inddata;

long=size(ntrcdata);
% synaptiques
ntrcdataSYN=[];
for i=1:long(1)
    if  ntrcdata(i,6)>0
        ntrcdataSYN=[ntrcdataSYN; ntrcdata(i,:)];
    else
    end
end

% perisynaptiques
ntrcdataPERI=[];
for i=1:long(1)
    if  ntrcdata(i,6)<0
        ntrcdataPERI=[ntrcdataPERI; ntrcdata(i,:)];
    else
    end
end

% extrasynaptiques
ntrcdataEXTRA=[];
for i=1:long(1)
    if  ntrcdata(i,6)==0
        ntrcdataEXTRA=[ntrcdataEXTRA; ntrcdata(i,:)];
    else
    end
end

ntrcdataSYN;
ntrcdataPERI;
ntrcdataEXTRA;

% calcul des matrices des msd
if size(ntrcdataSYN)==0
    nmsddataSYN=[];
    fmsddataSYN=[];
else
    [nmsddataSYN, fmsddataSYN] = ct2_msdshort(ntrcdataSYN,Maxcalc);	% calculate mean square displacement
    MeanDSYN = mean(nmsddataSYN(:,3)./nmsddataSYN(:,2))/4;
end

if size(ntrcdataPERI)==0
    nmsddataPERI=[];
    fmsddataPERI=[];
else
    [nmsddataPERI, fmsddataPERI] = ct2_msdshort(ntrcdataPERI,Maxcalc);	% calculate mean square displacement
    MeanDPERI = mean(nmsddataPERI(:,3)./nmsddataPERI(:,2))/4;
end

if size(ntrcdataEXTRA)==0
    nmsddataEXTRA=[];
    fmsddataEXTRA=[];
else
    [nmsddataEXTRA, fmsddataEXTRA] = ct2_msdshort(ntrcdataEXTRA,Maxcalc);	% calculate mean square displacement
    MeanDEXTRA = mean(nmsddataEXTRA(:,3)./nmsddataEXTRA(:,2))/4;
end


%calcul des P2

subplot(3,1,1);
hold on;
fullpdfSYN=[];
fmsddataSYN=fmsddataSYN*(sizepixel/1000)^2; % go from pxl => um^2
save ('fmsddataSYN', 'fmsddataSYN', '-ascii');
	      for step=1:min(size(fmsddataSYN,2),Maxcalc)
  				OnzeVector = sort(fmsddataSYN(find(fmsddataSYN(:,step)~=0), step))';    
   	      if ~isempty(OnzeVector)
               AantalVector = linspace(0,1,length(OnzeVector));
               % timing now in [ms]
                 OnzeData = [OnzeVector', AantalVector'];
%           	 filename = '';
			     filename = sprintf('syn%02.0f.dist.dat', step);
                 doit = ['save ', filename, ' OnzeData -ascii'];
                 eval(doit);
               fullpdfSYN=[fullpdfSYN;OnzeData];
               filename = sprintf('fullDist.syn.dat', step);
               doit = ['save ', filename, ' fullpdfSYN -ascii'];
               eval(doit);
               plot(OnzeVector, AantalVector);               
              if step==1
                 xlabel('r^2 [{\mu}m^2]'), ylabel('P(r^2, t [ms]) SYNAPTIQUE')
	   	         text(0.5,0.5,sprintf(' N_{1 step} = %4.0f',length(OnzeVector)),'Units','normalized')
   	   	         text(0.5,0.35,sprintf(' on n''en calcule que %4.0f',Maxcalc),'Units','normalized')
                 text(0.5,0.2,sprintf(' t_{lag} = %4.0f ms',step*time),'Units','normalized')
      	      end % if step==1
          end % if ~isempty(OnzeVector)
          end % for step
          

subplot(3,1,2);
hold on;
fullpdfPERI=[];
fmsddataPERI=fmsddataPERI*(sizepixel/1000)^2; % go from pxl => um^2
save ('fmsddataPERI', 'fmsddataPERI', '-ascii');
	      for step=1:min(size(fmsddataPERI,2),Maxcalc)
  				OnzeVector = sort(fmsddataPERI(find(fmsddataPERI(:,step)~=0), step))';    
   	      if ~isempty(OnzeVector)
               AantalVector = linspace(0,1,length(OnzeVector));
               % timing now in [ms]
                 OnzeData = [OnzeVector', AantalVector'];
%           	 filename = '';
			     filename = sprintf('per%02.0f.dist.dat', step);
                 doit = ['save ', filename, ' OnzeData -ascii'];
                 eval(doit);
               fullpdfPERI=[fullpdfPERI;OnzeData];
               filename = sprintf('fullDist.peri.dat', step);
               doit = ['save ', filename, ' fullpdfPERI -ascii'];
               eval(doit);
               plot(OnzeVector, AantalVector);
              if step==1
                 xlabel('r^2 [{\mu}m^2]'), ylabel('P(r^2, t [ms]) PERISYNAPTIQUE')
	   	         text(0.5,0.5,sprintf(' N_{1 step} = %4.0f',length(OnzeVector)),'Units','normalized')
   	   	         text(0.5,0.35,sprintf(' on n''en calcule que %4.0f',Maxcalc),'Units','normalized')
                 text(0.5,0.2,sprintf(' t_{lag} = %4.0f ms',step*time),'Units','normalized')
      	      end % if step==1
          end % if ~isempty(OnzeVector)
          end % for step
          
 
subplot(3,1,3);
hold on;         
fullpdfEXTRA=[];
fmsddataEXTRA=fmsddataEXTRA*(sizepixel/1000)^2; % go from pxl => um^2
OutVec=fmsddataEXTRA;
save ('fmsddataEXTRA', 'fmsddataEXTRA', '-ascii');
	      for step=1:min(size(fmsddataEXTRA,2),Maxcalc)
  				OnzeVector = sort(fmsddataEXTRA(find(fmsddataEXTRA(:,step)~=0), step))';    
   	      if ~isempty(OnzeVector)
               AantalVector = linspace(0,1,length(OnzeVector));
               % timing now in [ms]
                 OnzeData = [OnzeVector', AantalVector'];
%           	 filename = '';
			     filename = sprintf('ext%02.0f.dist.dat', step);
                 doit = ['save ', filename, ' OnzeData -ascii'];
                 eval(doit);
               fullpdfEXTRA=[fullpdfEXTRA;OnzeData];
               filename = sprintf('fullDist.extra.dat', step);
               doit = ['save ', filename, ' fullpdfEXTRA -ascii'];
               eval(doit);
               plot(OnzeVector, AantalVector);
              if step==1
                 xlabel('r^2 [{\mu}m^2]'), ylabel('P(r^2, t [ms]) EXTRASYNAPTIQUE')
	   	         text(0.5,0.5,sprintf(' N_{1 step} = %4.0f',length(OnzeVector)),'Units','normalized')
   	   	         text(0.5,0.35,sprintf(' on n''en calcule que %4.0f',Maxcalc),'Units','normalized')
                 text(0.5,0.2,sprintf(' t_{lag} = %4.0f ms',step*time),'Units','normalized')
      	      end % if step==1
          end % if ~isempty(OnzeVector)
          end % for step
          
          
          
else  %if syn==1
% random synapses

    
for k=1:length(files)
    
control=1;

   str=['pk',filesep,files(k).name,'.pk'];
   if length(dir(str))>0		% is there new peakdata?
      Spkdata =load(str);
      SPok=1;
   else
%      disp(['Couldn''t find peak file ',str]);
      Spkdata= [];
      SPok=0;
      control=0;
   end
   
   str=['trc',filesep,files(k).name,'.con.trc'];

   if length(dir(str))>0     % is there new trcdata?
      Strcdata=load(str);
      STok=1;
   else
 %     disp(['Couldn''t find trace file ',str]);
      Strcdata=[];
      STok=0;
            control=0;

   end
   
   str=['ind',filesep,files(k).name,'.ind'];
   if length(dir(str))>0		% is there new indexdata? 
      Sinddata=load(str);
      SIok=1;
	else
 %     disp(['Couldn''t find index file ',str]);
      Sinddata=[];
      SIok=0;
            control=0;

   end
   % msddata=load(['msd\',filename,'.msd']);
   
   if control>0
   
   disp([' * found ', num2str(max(Strcdata(:,1))),' traces in file ',files(k).name]);
   if SPok>0
      Spkdata(:,1)=Spkdata(:,1)+maxim;		% new imagenumber
   end
   
   if STok>0
      Strcdata(:,2)=Strcdata(:,2)+maxim;	% -"-
      Strcdata(:,1)=Strcdata(:,1)+maxtrc; % new tracenumber
   end
   
   if SIok>0
      Sinddata(:,1)=Sinddata(:,1)+maxtrc; % -"-
      validind=logical([zeros(size(Sinddata,1),1),Sinddata(:,2:end)>0]);
      Sinddata(validind)=Sinddata(validind)+size(pkdata,1);
      												% new index in pkdata
   end
     
   if ~isempty(inddata)		% indexdata can have different length (max. length of trace)
      maxind=size(inddata,2);
      newind=size(Sinddata,2);
      if maxind>newind
         Sinddata=[Sinddata, zeros(size(Sinddata,1),maxind-newind)];
      elseif maxind<newind
         inddata=[inddata, zeros(size(inddata,1),newind-maxind)];
      end
   end
   
   pkdata=[pkdata; Spkdata];
   trcdata=[trcdata;Strcdata];
   inddata=[inddata;Sinddata];
   
   if ~isempty(pkdata)
      maxim=max(pkdata(:,1));
   end
   if ~isempty(trcdata)
      maxtrc=max(trcdata(:,1));
   end
   
end %control

end

npkdata=pkdata;
ntrcdata=trcdata;
ninddata=inddata;
long=size(ntrcdata);

% calcul de la matrice des msd pour toutes les trajectoires
if size(ntrcdata)==0
    nmsddata=[];
    fmsddata=[];
else
    [nmsddata, fmsddata] = ct2_msdshort(ntrcdata,Maxcalc);	% calculate mean square displacement
    MeanD = mean(nmsddata(:,3)./nmsddata(:,2))/4;
end

%calcul des P2
% pour toutes les trajectoires

subplot(2,1,1);
hold on;
fullpdf=[];
fmsddata=fmsddata*(sizepixel/1000)^2; % go from pxl => um^2
save ('fmsddata', 'fmsddata', '-ascii');
	      for step=1:min(size(fmsddata,2),Maxcalc)
  				OnzeVector = sort(fmsddata(find(fmsddata(:,step)~=0), step))';    
   	      if ~isempty(OnzeVector)
               AantalVector = linspace(0,1,length(OnzeVector));
               % timing now in [ms]
                 OnzeData = [OnzeVector', AantalVector'];
%           	 filename = '';
			     filename = sprintf('dist%02.0f.dist.dat', step);
                 doit = ['save ', filename, ' OnzeData -ascii'];
                 eval(doit);
               fullpdf=[fullpdf;OnzeData];
               filename = sprintf('fullDist.dist.dat', step);
               doit = ['save ', filename, ' fullpdf -ascii'];
               eval(doit);
               plot(OnzeVector, AantalVector);               
              if step==1
                 xlabel('r^2 [{\mu}m^2]'), ylabel('P(r^2, t [ms]) ALL')
	   	         text(0.5,0.5,sprintf(' N_{1 step} = %4.0f',length(OnzeVector)),'Units','normalized')
   	   	         text(0.5,0.35,sprintf(' on n''en calcule que %4.0f',Maxcalc),'Units','normalized')
                 text(0.5,0.2,sprintf(' t_{lag} = %4.0f ms',step*time),'Units','normalized')
      	      end % if step==1
          end % if ~isempty(OnzeVector)
          end % for step

          
          
% pour des synapses g���s         
subplot(2,1,2);
hold on;
fullpdfFSYN=[];

disp([num2str(prop), ' % des pas sont simul� ']);
    %comme �ant dans des synapses de di��re ' num2str(taillesyn) 'nm.
prop=prop/100; %proportion estim� des synaptiques

taille=size(fmsddata);
FSYNfmsddata=zeros(taille(1), taille(2));
counter=0;
counterout=0;
for i=1:min(size(fmsddata,2),Maxcalc)
    tempo=fmsddata(find(fmsddata(:,i)),i); %vecteur contenant les steps non-nuls pour le timelag i
    Ntempo=size(tempo); % nombre de steps non nul pour le timelag i
    NPropTempo=round(Ntempo(1)*prop); % nombre de steps que l'on simule etre synaptiques
    counter=counter+NPropTempo;
    elus=sort(round(rand(NPropTempo,1)*Ntempo(1))); % tire al�toirement NpropTempo entiers entre 1 et Ntempo(1)
    for j=1:NPropTempo
        
         % calculates taillesyn
         factor=normrnd(meansyn,sdsyn);
         taillesyn=factor*sizepixel;
         taillesyn=1/3*(taillesyn/1000)^2; %taille maximale des synapses (m2);

        if elus(j)>0
           if tempo(elus(j))<taillesyn
            FSYNfmsddata(elus(j),i)=tempo(elus(j));
           else 
            if i==min(size(fmsddata,2),Maxcalc)
                counterout=counterout+1;    
            else
            end
           end
        else
        end
    end
end
clear fmsddata;
disp([num2str(counter), ' steps s�ectionn� simul� comme synaptiques, ' num2str(NPropTempo) ' pour le dernier timelag']);
disp([num2str(counterout/NPropTempo*100), ' % (' num2str(counterout) ') des steps s�ectionn� pour le dernier timelag ont ��rejet� car trops grands par rapport �la taille des synapses']);
save ('FSYNfmsddata', 'FSYNfmsddata', '-ascii');
	      for step=1:min(size(FSYNfmsddata,2),Maxcalc)
  				OnzeVector = sort(FSYNfmsddata(find(FSYNfmsddata(:,step)~=0), step))';    
   	      if ~isempty(OnzeVector)
               AantalVector = linspace(0,1,length(OnzeVector));
               % timing now in [ms]
                 OnzeData = [OnzeVector', AantalVector'];
%           	 filename = '';
			     filename = sprintf('Fsyn%02.0f.dist.dat', step);
                 doit = ['save ', filename, ' OnzeData -ascii'];
                 eval(doit);
               fullpdfFSYN=[fullpdfFSYN;OnzeData];
               filename = sprintf('fullDist.FSYN.dat', step);
               doit = ['save ', filename, ' fullpdfFSYN -ascii'];
               eval(doit);
               plot(OnzeVector, AantalVector);               
              if step==1
                 xlabel('r^2 [{\mu}m^2]'), ylabel('P(r^2, t [ms]) faux synaptiques')
	   	         text(0.5,0.5,sprintf(' N_{1 step} = %4.0f',length(OnzeVector)),'Units','normalized')
   	   	         text(0.5,0.35,sprintf(' on n''en calcule que %4.0f',Maxcalc),'Units','normalized')
                 text(0.5,0.2,sprintf(' t_{lag} = %4.0f ms',step*time),'Units','normalized')
      	      end % if step==1
          end % if ~isempty(OnzeVector)
          end % for step
  
OutVec=[];    
end %if syn==1