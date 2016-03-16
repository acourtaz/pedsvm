function [Trc, h, Nt, newPoints, Ntrace, OK]=bliterate(Trc, h, Nt, distmax, maxblink, mintrace)
%% starts here
Points=size(Trc(:,1),1);
Ntrace=max(Trc(:,1));
Nt(h+1)=Ntrace;
%% start if OK
if Nt(h+1)~=Nt(h)
  OK=true;
%% Flag trace boundaries at beginning of each iteration
% %CMT-12/10/2007
% replace the 3 inner `for' loops for dfTrc, debTrc and finTrc in LC's code
% with vectorized code and logical indexing -- this will speed things up
rs=sparse([1; diff(Trc(:,1))]==1);                   % flag the START rows
re=sparse([Trc(2:end,1)-Trc(1:end-1,1);1]==1);       % flag the END rows
rsre=rs|re;

debR=find(rs);  % indices into Trc rows where traces start = trouve les d?buts de trace
finR=find(re);  % indices into Trc rows where traces end = trouve les fins de trace
dfR=find(rsre); % has both of the above = trouve les d?but et fin de trace

Ntrace=size(finR,1);
% disp(['Ntrace = ', num2str(Ntrace)]);
%disp(['Num?ro de la passe : ' num2str(h)]);
% actualizes waitbar
% if exist('waitbarhandle')
%    waitbar(h/Ntraceinit,waitbarhandle,['Iteration # ',num2str(h)]);
% end

% disp('Populating sparse boolean matrix'); tic

%% Instead of LC's `matrice des distances' use a sparse boolean matrix 
% % ROW and COL coordinates of the TRUE elements in this matrix point to 
% % the indices within finR and respectively debR, for those traces that
% % are separated by an Euclidean distance smaller than distmax. That is,
% % point to the trace (say, with number 'n'), for which the Euclidean distance 
% % between its END (pointed to by the indices in finR) and the STARTs of any _SUBSEQUENT_
% % traces (n+1, ... , Ntrace, pointed to by debR) is less than distmax.
% %
% % We do this in two steps, each of which satisfies a given condition, see
% % the code cells `Condition 1' and `Condition 2', below. 
% % Then, the consecutive traces that have extremities (i.e., STARTs and ENDs) closer
% % than max blinking distance (`distmax') or max blinking frames
% % (`maxblink') are collapsed into a single new (and longer) trace
% % (Condition3)

%% Condition1
% % Find out the trace ENDs with trace numbers (given in column 2 of Trc matrix)
% % _SMALLER_ than the trace number of any _SUBSEQUENT_ trace STARTS. 
% % Indices for ENDs are in finR, and indices for STARTs are in debR.
% % We use this condition to create a sparse boolean matrix whose elements 
% % are TRUE `Condition1' is TRUE.
% % Sparse matrices take up less memory, but indexing (linear or not) into them
% % is slow, especially for large matrices: looping nnz(A) times over a 
% % statement like A(i,j)=... takes time proportional to nnz(A)^2 (or even
% % over A(l) where l is a linear index vector). Therefore, we build the
% % sparse matrix `DBool' directly from applying `Condition', which seems 
% % to execute the fastest, even if the `repmat's below may take up some 
% % memory for temporaries

% DBool=sparse(sparse(repmat(Trc(finR(1:Ntrace),2),1,Ntrace)) < sparse(repmat(Trc(debR(:),2)', Ntrace,1)));

% here, DBool is corresponds, element for element, to LC's Dist~=100, see code
% cell `cr?e la matrice des distances' in LC's blinking
% IT TURNS OUT THAT'S ACTUALY NOT TRUE -- MUST REWORK DBOOL !!!:

% should try my previous less vectorized code on full DBool (instead of sparse)
% something like

DBool=false(Ntrace, Ntrace);
for(i=1:Ntrace)
  k=i+1;
  if (i==Ntrace) k=Ntrace; end;
  DBool(i,k:Ntrace)=Trc(finR(i),2)<(Trc(debR(k:Ntrace),2))';
end;

%% Condition2
% % Flag the traces out the trace boundaries separated by Euclidean distance
% % smaller than distmax (see `lespi' in LC's blinking.m); reassign to DBool.
[eyes, jays]=find(DBool); 
kays=sqrt((Trc(finR(eyes),3)-Trc(debR(jays),3)).^2 + (Trc(finR(eyes),4)-Trc(debR(jays),4)).^2) < distmax;
DBool=full(sparse(eyes, jays, kays, Ntrace, Ntrace);

% and here, DBool corresponds element for element to LC's Dist < distmax, see
% code cell `cr?e la matrice des distances' in LC's blinking
% fDBool=full(DBool);
% lcDBool=Dist<distmax;
% all(all(fDBool==lcDBool)) % CHECK!



clear eyes jays kays;
%% Condition3 cr?e la matrice des distances minimum entre traces
% % nx is IdxLesmin(:,1:2)
% % Collapse consecutive traces with extremities closer than distmax into one
% % trace 

nx=[(1:Ntrace)', (1:Ntrace)']; % preallocate (corresponds to LC's IdxLesmin)
% mx=nx;
%% j.o.
if(any(any(DBool)))
%%
%   [deyes, djays]=find(DBool);
%   deyes=sortrows(deyes);
%   deyes=unique(deyes);
%   for (i=1:length(deyes))
%     mx(deyes(i),2)=min(find(DBool(deyes(i),:)));
%   end;

  for (i=1:Ntrace)
    lespi=find(DBool(i,:));
    if(~isempty(lespi)) 
      nx(i,2)=min(lespi); 
    else
      nx(i,2)=i;
    end;
  end;
  
%% test les connections valides. Sinon, connecte la trace avec elle meme  
  mbx=find((Trc(debR(nx(:,2)),2)-Trc(finR(nx(:,1)),2))>maxblink); 
  nx(mbx,2)=nx(mbx,1);                   % there... now they're all reconnected
%% j.o.
else
  % what to do if DBool is all FALSE?
  res=[];
  return;
end;
% clear DBool;

%% Construct a new trace matrix - construit la nouvelle matrice des traces
% "...construit la nouvelle matrice des traces..."
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
% % whatever that means...
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
clear Trc;
Trc(:,1)=nwTrc(:,1);
Trc(:,2)=nwTrc(:,3);
Trc(:,3)=nwTrc(:,4);
Trc(:,4)=nwTrc(:,5);
Trc(:,5)=nwTrc(:,6);
Trc(:,6)=nwTrc(:,7);
Trc(:,7)=nwTrc(:,8);

else
  OK=false;
  Trc=Trc;
  h=h;
  Nt=Nt;
  newPoints=size(Trc(:,1),1);
  Ntrace=Ntrace;
end;
