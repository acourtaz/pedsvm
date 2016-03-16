function res=TrcToStep2(file,dlag)

% function res=TrcToStep(file)
% file: fichier des trc
% transforme un fichier trc en steps
% dlag est le time lag (1 2 etc...)

if nargin<1, help TrcToStep, return, end

    
global MASCHINE

disp(['Dans fichier STEP: numtrace, t(numimage), x(t), y(t), NA, x(t+1), y(t+1), step carré.']);
disp([' Ne calcule que les steps entre deux images consécutives.']);

%str=['ana\',file,'.trc'];
str=[file,'.trc']

if length(dir(str))>0		
      Trcdata =load(str);
end

Npoints=size(Trcdata, 1);

Ntrcdata=zeros(Npoints, 11);


for i=1:Npoints-dlag
    if Trcdata(i+dlag,2)-Trcdata(i,2)==dlag
Ntrcdata(i,1:7)=Trcdata(i,1:7);
Ntrcdata(i,8:9)=Trcdata(i+dlag,3:4);
Ntrcdata(i,10)=((Trcdata(i+dlag,3)-Trcdata(i,3))^2+(Trcdata(i+dlag,4)-Trcdata(i,4))^2); 
Ntrcdata(i,11)=(.21^2)*Ntrcdata(i,10); %%% AVEC PASSAGE EN µM
Ntrcdata(i,12)=log10(Ntrcdata(i,11));
    else
    end
end

NNtrcdata=[];
for i=1:Npoints
    if Ntrcdata(i,2)~=0
NNtrcdata=[NNtrcdata; [Ntrcdata(i,:)]];
    else
    end
end

NNtrcdataIN=[];
NNtrcdataOUT=[];
NNpoints=size(NNtrcdata, 1);

for i=1:NNpoints
    if NNtrcdata(i,6)~=0
NNtrcdataIN=[NNtrcdataIN; [NNtrcdata(i,:)]];
    else
        NNtrcdataOUT=[NNtrcdataOUT; [NNtrcdata(i,:)]];
    end
end


res=NNtrcdata;
save([file,num2str(dlag), '.trc.stepALL'],'NNtrcdata','-ascii'); 
save([file,num2str(dlag),'.trc.stepIN'],'NNtrcdataIN','-ascii'); 
save([file,num2str(dlag),'.trc.stepOUT'],'NNtrcdataOUT','-ascii'); 
%save(['ana\',file,'.trc.step'],'NNtrcdata','-ascii'); 

