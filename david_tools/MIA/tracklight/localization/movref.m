function movref
% function movref
% crea archivos trc con posiciones corregidas respecto a una referencia
% movil (movie con clusters)

warning off MATLAB:MKDIR:DirectoryExists
path=cd;
controlf=1;

%files
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
              k=strfind(filename,'clu_MIA.spe');
              if isempty(k)==1
                k=strfind(filename,'gfp.spe');
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
if isempty(st)==1
    d=dir('*SPE*');
    st = {d.name};
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

control=1;
MIAtrue=0;

for cont=1:ultimo   % toda la lista de archivos

        molfile=st{files(cont)};  % con '.spe'
        [file,rem]=strtok(molfile,'.');  %'sin .spe'
       % spelist=dir('*-dom_MIA.spe*');
        currentdir=cd;
        path=[cd,filesep,'trc'];
        
        if isdir(path)
           cd(path);
           trclist=dir('*MIA.con*');
           %trclist=dir('*MIA*');
           if isempty(trclist)==0
            trcfilename=[file,'.MIA.con.trc']
            %trcfilename=[file,'_MIA.trc']
            MIAtrue=1;
           else
            trcfilename=[file,'.con.trc'];
            %trcfilename=[file,'.trc'];
            MIAtrue=0;
           end
           
           if length(dir(trcfilename))>0
              trcfile=load(trcfilename);
              cd(currentdir);
              %pathdom=[cd,'\dom'];
              %cd(pathdom)
              [namefile,rem]=strtok(file,'.');
              MIAfoldertrc=['dom',filesep,namefile,'-clu.MIA',filesep,'tracking',filesep];
              MIAfolder=['dom',filesep,namefile,'-clu.MIA',filesep];
              MIAtrc=[MIAfoldertrc,namefile,'-clu_MIA.trc']
              %spelist=dir('*-clu_MIA.spe*');
              %if isempty(spelist)==1
                 domainfile=[MIAfolder,namefile,'-clu.stk']
                 %else
               %  domainfile=[file,'-clu_MIA.spe'];
               %end
             % cd(currentdir)
              
              if length(dir(domainfile))>0
                 [trcmol,trcdom]=localizemov(molfile,trcfile,domainfile,MIAtrc);                           %localization/cut
                 
                 [namefile,rem]=strtok(file,'.');
                  % guarda trajectorias con localiz con formato para msdturbo
                if MIAtrue==1
                   %MIA
                    filetxt=['trc',filesep,namefile,'.MIA.con.syn.trc']; fi = fopen(filetxt,'w');
                    %filetxt=['trc\',namefile,'.MIA.syn.trc']; fi = fopen(filetxt,'w');
                    if fi<3; error('File not found or readerror.');
                    else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',trcmol');
                    end
                    fclose(fi);
                 else
                    filetxt=['trc',filesep,namefile,'.con.syn.trc']; fi = fopen(filetxt,'w');
                    %filetxt=['trc\',namefile,'.syn.trc']; fi = fopen(filetxt,'w');
                    if fi<3; error('File not found or readerror.');
                    else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',trcmol');
                    end
                    fclose(fi);
                  end
                 % guarda loc domains
                  filetxt=['dom',filesep,'trc',filesep,namefile,'.MIA.con.syn.trc']; fi = fopen(filetxt,'w');
                  %filetxt=['trc\',namefile,'-dom_MIA.syn.trc']; fi = fopen(filetxt,'w');
                  if fi<3; error('File not found or readerror.');
                  else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',trcdom');
                  end
                  fclose(fi);
                  

                  % cutting 
                  %if isdir(['trc\cutnorec']); else mkdir ('trc\cutnorec'); end
                  if isdir(['trc',filesep,'cut']); else mkdir (['trc',filesep,'cut']); end
                     trcmolcut=deconnect(trcmol); %corta trajectorias que cambian de localizacion
                    
                     if MIAtrue==1
                       % filetxt=['trc\cutnorec\',namefile,'.MIA.deco.syn.trc']; fi = fopen(filetxt,'w');
                        filetxt=['trc',filesep,'cut',filesep,namefile,'.MIA.deco.syn.trc']; fi = fopen(filetxt,'w');
                        if fi<3; error('File not found or readerror.');
                        else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',trcmolcut');
                        end
                        fclose(fi);
                    else
                       % filetxt=['trc\cutnorec\',namefile,'.deco.syn.trc']; fi = fopen(filetxt,'w');
                        filetxt=['trc',filesep,'cut',filesep,namefile,'.deco.syn.trc']; fi = fopen(filetxt,'w');
                        if fi<3; error('File not found or readerror.');
                        else; fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',trcmolcut');
                        end
                       fclose(fi);
                   end
                    disp('  '); disp(['New trajectories saved in trc',filesep,'cutnorec']);
                    
                  %reconnection
                  

 
              else
                 disp(['File ',domainfile,' not found']);
                 control=0;
                 trcmol=[];
              end
           else
              disp(['File ',trcfile,' not found']);
              control=0;
              trcmol=[];
          end
       end

% conversion trayectorias sin cortar por localizacion
if size(trcmol)>0    

disp('  ');
disp(['Calculating new trajectories...']);
[totfilas, totcolumnas] = size (trcmol);
maxmol=trcmol(totfilas,1);
for mol=1:maxmol
     indice=find(trcmol(:,1)==mol);
     [f c]=size(indice);
     if f>0 
         for j=2:f % a partir del segundo punto
             nroclu=trcmol(indice(j),6);
             if nroclu>0  %loc en cluster
                indiceclu=find(abs(trcdom(:,6))==nroclu);  % archivo con las posiciones en tempclu del clusters correspondiente (incluye peri...)
                [fclu cclu]=size(indiceclu);
                nroframe=trcmol(indice(j),2);
                for t=2:fclu
                    if trcdom(indiceclu(t),2)==nroframe
                        difx= trcdom(indiceclu(t),3)-trcdom(indiceclu(t-1),3); % mov cluster en x
                        dify= trcdom(indiceclu(t),4)-trcdom(indiceclu(t-1),4); % mov cluster en y
                        trcmol(indice(j),3)=trcmol(indice(j),3)-difx;
                        trcmol(indice(j),4)=trcmol(indice(j),4)-dify;
                    end
                end
            end
        end
    end
end

% conversion trayectorias cut
[totfilas, totcolumnas] = size (trcmolcut);
maxmol=trcmolcut(totfilas,1);
for mol=1:maxmol
     indice=find(trcmolcut(:,1)==mol);
     [f c]=size(indice);
     if f>0 
         for j=2:f % a partir del segundo punto
             nroclu=trcmolcut(indice(j),6);
             if nroclu>0  %loc en cluster
                indiceclu=find(abs(trcdom(:,6))==nroclu);  % archivo con las posiciones en tempclu del clusters correspondiente (incluye peri...)
                [fclu cclu]=size(indiceclu);
                nroframe=trcmolcut(indice(j),2);
                for t=2:fclu
                    if trcdom(indiceclu(t),2)==nroframe
                        difx= trcdom(indiceclu(t),3)-trcdom(indiceclu(t-1),3); % mov cluster en x
                        dify= trcdom(indiceclu(t),4)-trcdom(indiceclu(t-1),4); % mov cluster en y
                        trcmolcut(indice(j),3)=trcmolcut(indice(j),3)-difx;
                        trcmolcut(indice(j),4)=trcmolcut(indice(j),4)-dify;
                    end
                end
            end
        end
    end
end
  
%if isdir(['movref\trc\cutnorec']); else mkdir ('movref\trc\cutnorec'); end
if isdir(['movref',filesep,'trc',filesep,'cut']); else mkdir (['movref',filesep,'trc',filesep,'cut']); end

% guarda res en movref
if MIAtrue==0
   filetxt=['movref',filesep,'trc',filesep,file,'.con.syn.trc'];
  % filetxt=['movref\trc\',file,'.syn.trc'];
   fi = fopen(filetxt,'w');
   if fi<3
              error('File not found or readerror.');
   else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',trcmol');
   end
   % close
   fclose(fi);
   %filetxt=['movref\trc\cutnorec\',file,'.deco.syn.trc'];
   filetxt=['movref',filesep,'trc',filesep,file,'.deco.syn.trc'];
     fi = fopen(filetxt,'w');
     if fi<3
       error('File not found or readerror.');
     else
       fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.8f\t %6.8f\r',trcmolcut');
      end
    % close
     fclose(fi);
   
else
   filetxt=['movref',filesep,'trc',filesep,file,'.MIA.con.syn.trc'];
   %filetxt=['movref\trc\',file,'.MIA.syn.trc'];
   fi = fopen(filetxt,'w');
   if fi<3
              error('File not found or readerror.');
   else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',trcmol');
   end
   % close
   fclose(fi);   
   %filetxt=['movref\trc\cutnorec\',file,'.MIA.deco.syn.trc'];
   filetxt=['movref',filesep,'trc',filesep,'cut',filesep,file,'.MIA.deco.syn.trc'];
            fi = fopen(filetxt,'w');
            if fi<3
              error('File not found or readerror.');
            else
              fprintf(fi,'%6.2f\t %6.2f\t %6.8f\t %6.8f\t %6.2f\t %6.2f\t %6.8f\r',trcmolcut');
            end
            % close
            fclose(fi);
end

disp('  ');
disp(['New trajectories saved in movref',filesep]);

end % trc


end %loop cont
