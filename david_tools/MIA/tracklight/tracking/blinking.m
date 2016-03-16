function res=blinking(file,maxblink,distmax,mintrace,handles, waitbarhandle)
% function  res=blinking(file,maxblink,distmax,mintrace, handles,waitbarhandle)
%  connecte les traces entre elles.
% path: data folder
% file: .trc file made by MIA
% maxblink=dur?e maximale entre la derni?re image et la premi?re des deux traces connect?es
% distmax : distance maximale des mol?cules (pxl) entre la derni?re image et la premi?re 
% des deux traces connect?es
% minTrace : dur?e minimum des traces que l'on conserve
% waitbarhandle: to actualize wait bar
%
% from connectraceMIA.m, modified by MR (mar 06) for gaussiantrack.m 
% author: LC
% optimized by: Cezar M. Tigaret (CMT), fall 2007: vectorization and logical
%               indexing; extended documentation on the algorithm (as far as I could understand it)
%               and on the modifications brought by CMT (as well as their
%               justification and checkpoints for compilance with LC's
%               algorithm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % CMT - 01/11/2007 Most of the execution time and memory are consumed by the
% outer iteration loop. This is about trying to optimize that. 
if nargin<1, help blinking, return, end

warning off MATLAB:MKDIR:DirectoryExists
controlf=1;
if ~exist('waitbarhandle')
  % % so that I can execute this M-file from the command line - CMT 03/11/2007
  waitbarhandle=waitbar( 0,'Please wait...','Name',['Reconnecting trajectories in ',file]);
end;

TrcInit = [];
res=[];
controlf=1;

%% load file
if ~isempty(dir(file))		
%       TrcInit=load(file);
      TrcInit=loadMIATrc(file);
      disp(['File ' ,file, ' loaded.']);
   else
      disp(['Couldn''t find MIA.trc file ',file]);
      TrcInit = [];
      res=[];
      controlf=0;
end

%%
if controlf==1

% %On va maintenant travailler sur une matrice all?g?e des traces qui ne contient que les d?buts et fins des traces
%% preamble
if(isempty(TrcInit))
  return;
end;
Points=size(TrcInit(:,1),1);
Ntrace=max(TrcInit(:,1));

% 
% % CMT-12/10/2007
% % Minimze the use of `for' loops, `if/else' statements, and the use of
% % temporary matrices (especially those of `double' elements), which
% % alltogether render the code inefficient and a memory hog.
% % Instead, use vectorizing and logical indexing, both techniques being
% % much faster in Matlab, and with a smaller memory footprint.
% % 
% % Oh, and by the way, sparse boolean matrices are well suited for the purpose,
% % except that indexing into sparse booleans is DOG SLOW... So, use with care!
% % 

% % vectorization and logical indexing - CMT-05/11/2007
%% Initial extraction of trace boundaries
% % (i.e., STARTS and ENDS)
rs=sparse([1; diff(TrcInit(:,1))]==1);                 % flag rows for trace STARTs
re=sparse([TrcInit(2:end,1)-TrcInit(1:end-1,1);1]==1); % flag rows trace ENDs
rsre=rs|re;                                            % merge flags

Trc=[TrcInit(rsre,:), find(rsre)];  % apply flags to filter, append their indices
NPoints=size(Trc(:,1),1);
% % here, Trc is equal with the one in LC's routine, element for element.
%% d?but de la reconnection
Ntraceinit=max(Trc(:,1));
% Nt=zeros(Ntraceinit+1,1);
clear a;
clear b;
Nt(1)=Ntraceinit+1;

%% debut de la boucle sur Nt(h) -- the REAL KILLER
for h=1:Ntraceinit
  Points=size(Trc(:,1),1);
  Ntrace=max(Trc(:,1));
  Nt(h+1)=Ntrace;

  if Nt(h+1)~=Nt(h)
%% Flag trace boundaries at beginning of each iteration
    % %CMT-12/10/2007
    % replace the 3 inner `for' loops for dfTrc, debTrc and finTrc in LC's code
    % with vectorized code and logical indexing -- this will speed things up
    rs=sparse([1; diff(Trc(:,1))]==1);                   % flag the START rows
    re=sparse([Trc(2:end,1)-Trc(1:end-1,1);1]==1);       % flag the END rows
    rsre=rs|re;

    debR=find(rs);  % indices into Trc rows where traces start <-> LC's debTrc
    finR=find(re);  % indices into Trc rows where traces end <-> LC's finTrc
    dfR=find(rsre); % has both of the above <-> LC's dfTrc

    Ntrace=size(finR,1);

    % actualizes waitbar
    if exist('waitbarhandle')
       waitbar(h/Ntraceinit,waitbarhandle,['Iteration # ',num2str(h)]);
    end;

    % % Instead of the `matrice des distances Dist' use a boolean matrix `DBool'
    % % ROW and COL coordinates of the TRUE elements in this matrix point to 
    % % the indices within finR and, respectively debR, for those traces that
    % % are separated by an Euclidean distance smaller than distmax.
    % %
    % % We do this in two steps, each of which satisfies the Condition1 and
    % % Condition2, below.

%% Condition1
    % % Find out the trace ENDs with trace numbers (given in column 2 of Trc
    % % matrix) SMALLER than the trace number of any SUBSEQUENT trace STARTS.
    % % Indices for ENDs are in finR, and indices for STARTs are in debR.
    % % We use this condition to create a boolean matrix whose elements are
    % % are TRUE wherever `Condition1' is TRUE.
    % %     
    % % Although sparse matrices take up less memory, indexing (linear or
    % % logical) into them is slow, especially for large matrices: looping
    % % nnz(A) times over a statement like A(i,j)=... takes time proportional to
    % % nnz(A)^2, where nnz = the number of non-zero elements in the sparse
    % % matrix.
    % %
    % % I could build the sparse matrix `DBool' directly from applying
    % % `Condition1', which seems to execute the fastest, even if the `repmat's
    % % below may take up some memory for temporaries. 
    % % Unfortunately the repmat solution (commented-out one-liner below)
    % % does not yield the correct ORDERING of the finR and debR indices into
    % % DBool. 
    % %
    % % Therefore I decided to risk taking up more memory and construct a full 
    % % (as opposed to sparse) DBool and iterate over its rows (with vectorized
    % % column indexing) which seems to run slightly faster.
   
    DBool=false(Ntrace, Ntrace);
    for(i=1:Ntrace)
      k=i+1;
      if (i==Ntrace) k=Ntrace; end; % AHA !!
      DBool(i,k:Ntrace)=Trc(finR(i),2)<(Trc(debR(k:Ntrace),2))';
    end;
    
    % % This one-liner might have been elegant, but was incorrect
    % 
    % DBool=sparse(sparse(repmat(Trc(finR(1:Ntrace),2),1,Ntrace)) < sparse(repmat(Trc(debR(:),2)', Ntrace,1)));
    % 
    % % keep it commented so that I can revisit this

%% Condition2
    % % Flag the traces out the trace boundaries separated by Euclidean distance
    % % smaller than distmax (see `lespi' in LC's blinking.m); reassign to DBool.
    [eyes, jays]=find(DBool); 
    kays=sqrt((Trc(finR(eyes),3)-Trc(debR(jays),3)).^2 + (Trc(finR(eyes),4)-Trc(debR(jays),4)).^2) < distmax;
    DBool=full(sparse(eyes, jays, kays, Ntrace, Ntrace));

    % % Now, DBool corresponds, element for element, to LC's conditions that
    % % Dist ~= 100 AND Dist < distmax
    % % see the code snippet `cr?e la matrice des distances' in LC's blinking.
    % % To verify it is correct, run the following code (alternatively replacing
    % % `distmax' with 100):
    %
    % % for sparse matrix:
    %
    % fDBool=full(DBool);
    % lcDBool=Dist<distmax;
    % all(all(fDBool==lcDBool)) % CHECK!
    %
    % % for full matrix:
    % all(all(DBool==Dist<distmax) % CHECK!

    clear eyes jays kays; % give up some memory
%% Condition3 cr?e la matrice des distances minimum entre traces
    % % Actually, here I do away with (what I believe to be) unnecessary data
    % % duplication. In fact, what we're all after is a matrix of indices that
    % % point to the closest trace boundaries. We then use it to collapse those
    % % traces that are separated by less than maxblink.
 
    % % I use a 2-column matrix that holds these indices into DBool's rows and
    % % column, respectively and it will be identical to LC's IdxLesmin 1st 2
    % % columns
    %

    nx=[(1:Ntrace)', (1:Ntrace)']; % preallocate (corresponds to LC's IdxLesmin)
    if(any(any(DBool)))
      
    % % another bit of code that, albeit elegant, didn't yield correct result
    %   [deyes, djays]=find(DBool);
    %   deyes=sortrows(deyes);
    %   deyes=unique(deyes);
    %   for (i=1:length(deyes))
    %     mx(deyes(i),2)=min(find(DBool(deyes(i),:)));
    %   end;
    % % keep it for reference
    
      for (i=1:Ntrace)
        lespi=find(DBool(i,:)); % same name as in LC's code for didactical scope
        if(~isempty(lespi)) 
          nx(i,2)=min(lespi); 
        else
          nx(i,2)=i; % AHA!!
        end;
      end;

%% test les connections valides. Sinon, connecte la trace avec elle meme   
      % % collapse trace indices w.r.t maxblink
      mbx=find((Trc(debR(nx(:,2)),2)-Trc(finR(nx(:,1)),2))>maxblink); 
      nx(mbx,2)=nx(mbx,1);                   % there... now they're all reconnected
    else
      % what to do if DBool is all FALSE?
%       res=[];
%       return;
    end;
    clear DBool; % give up memory

%% Construct a new trace matrix - construit la nouvelle matrice des traces
    % must find a way to optimize this expensive algorithm
    nwTrc=[];
    temp=Trc; 

    for (i=1:Ntrace)
      if (nx(i,2)~=nx(i,1))
        deb1=dfR(2*nx(i,1)-1);
        fin1=dfR(2*nx(i,1));
        deb2=dfR(2*nx(i,2)-1);
        fin2=dfR(2*nx(i,2));
        for(k=deb1:fin1)
          if (temp(k,1)==0) ;
          else
            nwTrc=[nwTrc;[i,temp(k,:)]];
            temp(k,1)=0;
          end;
        end;
        for (k=deb2:fin2)
          if (temp(k,1)==0) ;
          else
            nwTrc=[nwTrc;[i,temp(k,:)]];
            temp(k,1)=0;
          end;
        end;
      else
        deb1=dfR(2*nx(i,1)-1);
        fin1=dfR(2*nx(i,1));
        for (k=deb1:fin1)
          if (temp(k,1)==0) ;
          else
            nwTrc=[nwTrc;[i,temp(k,:)]];
            temp(k,1)=0;
          end;
        end;
      end;
    end;

%% Renumerote les nouvelles traces sans chiffre manquant
    % % whatever that means... LC's code untouched
    newPoints=size(nwTrc(:,1),1);
    tmp=[];
    tmp(1)=nwTrc(1,1);
    for i=2:newPoints
        if (nwTrc(i,1)-nwTrc(i-1,1))>0
           tmp(i)=tmp(i-1)+1;
        else
           tmp(i)=tmp(i-1);
        end
    end
    for i=2:newPoints
        nwTrc(i,1)=tmp(i);
    end

%% Separe reinitialise la trace
% LC's code untouched
    clear Trc;
    Trc(:,1)=nwTrc(:,1);
    Trc(:,2)=nwTrc(:,3);
    Trc(:,3)=nwTrc(:,4);
    Trc(:,4)=nwTrc(:,5);
    Trc(:,5)=nwTrc(:,6);
    Trc(:,6)=nwTrc(:,7);
    Trc(:,7)=nwTrc(:,8);
    
    clear nwTrc;
  else
    break; % no need for carrying on...
  end; %fin du if dans de la boucle sur Nt(h)

end; % fin de la boucle sur Nt(h)

%disp(['Patience ! Avancement de l''?criture de la matrice finale de traces ... ']);


%% Selectionne les traces de longueur superieure a minTrace
% % LC's code untouched
% if exist('waitbarhandle')
%       % % so that I can execute this M-file from the command line - CMT 03/11/2007
%     close(waitbarhandle);
% end

Ntracereconnect=max(Trc(:,1));
Np=newPoints/2;
numTrace=1;
longTrc=0;
tempoTrc=[];
tempo=[];
longTrc=zeros(Ntrace,2); %%% va contenir le num?ro de la trace et la longueur de la trace

for i=1:Np
longTrc(numTrace,1)=numTrace;
    if Trc(2*i,1)==numTrace
    longTrc(numTrace,2)=longTrc(numTrace,2)+Trc(2*i,7)-Trc(2*i-1,7)+1;
    else
    numTrace=numTrace+1;
    longTrc(numTrace,2)=longTrc(numTrace,2)+Trc(2*i,7)-Trc(2*i-1,7)+1;
    
    end
end
longTrc(Ntrace,1)=Ntrace;
%% longTrc : matrice de la longueur des traces
% % LC's code untouched
for i=1:newPoints
   if longTrc(Trc(i,1),2)>mintrace
       tempoTrc=[tempoTrc;[Trc(i,:)]];
   end
end
Trc=tempoTrc;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if size(Trc)>0    
%% Renumerote les nouvelles traces sans chiffre manquant
Points=size(Trc(:,1),1);
tmp=[];
tmp(1)=Trc(1,1);
for i=2:Points
    if (Trc(i,1)-Trc(i-1,1))>0
       tmp(i)=tmp(i-1)+1;
    else
       tmp(i)=tmp(i-1);
    end
end
for i=1:Points
    Trc(i,1)=tmp(i)-tmp(1)+1;
end

%% Refabrique la matrice complete des traces a partir de trace
NPoints=size(Trc(:,1),1);
Np=NPoints/2;
fullTrc=[];
for i=1:Np
    debut=Trc(2*i-1,7);
    fin=Trc(2*i,7);
    for j=debut:fin
        fullTrc=[fullTrc;[Trc(2*i-1,1),TrcInit(j,2:6)]];
    end
end
%disp(['On r?cup?re ' num2str(size(fullTrc(:,1),1)), ' points qui constituent les traces de d?part, apr?s filtrage des traces trops courtes.']);

%resindx=nwIdx;
res=fullTrc;

Ntracefin=max(fullTrc(:,1));
%disp([num2str(Ntraceinit) ' traces au d?part.']);
%disp([num2str(Ntracereconnect) ' traces apr?s reconnection.']);
%disp(['Finalement, ' num2str(Ntracefin) ' traces apr?s filtrage des traces trop courtes (inf?rieures ? ' num2str(minTrace) ' points).']);
disp([num2str(Ntraceinit) ' trajectories at the beginning.']);
disp([num2str(Ntracereconnect) ' trajectories after reconnection.']);
disp([num2str(Ntracefin) ' trajectories after filtering the short ones (less than ' num2str(mintrace) ' points).']);
disp(' ');
  %report
%   if exist('handles')
    % % so that I can execute this M-file from the command line - CMT 03/11/2007
  text=[num2str(Ntracereconnect) ' trajectories after reconnection and ',num2str(Ntracefin) ' trajectories after filtering the short ones (less than ' num2str(mintrace) ' points).'];
  updatereport(handles,text)
%   end;

else
    disp('No trajectory left with enough number of points.');
%     if exist('handles')
      % % so that I can execute this M-file from the command line - CMT 03/11/2007
    text=['No trajectory left with enough number of points.'];
    updatereport(handles,text,1)
%     end;
    res=[];
end

end

% end of file
