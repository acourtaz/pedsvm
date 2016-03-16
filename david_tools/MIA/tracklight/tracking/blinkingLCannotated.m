function res=blinkingLC(file,maxblink,distmax,mintrace, maxiter, handles,waitbarhandle)
% function  res=blinking(file,maxblink,distmax,mintrace,handles,waitbarhandle)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<1, help blinking, return, end

warning off MATLAB:MKDIR:DirectoryExists
controlf=1;
if ~exist('waitbarhandle')
  % % so that I can execute this M-file from the command line - CMT 03/11/2007
  waitbarhandle=waitbar( 0,'Please wait...','Name',['Reconnecting trajectories in ',file]);
end;

%% load file
if length(dir(file))>0		
      TrcInit=load(file);
      disp(['File ' ,file, ' loaded.']);
   else
      disp(['Couldn''t find MIA.trc file ',file]);
      TrcInit = [];
      res=[];
      controlf=0;
end

%%
if controlf==1


%% On va maintenant travailler sur une matrice all?g?e des traces qui ne contient que les d?buts et fins des traces
Points=size(TrcInit(:,1),1);
Ntrace=max(TrcInit(:,1));

TrcShort=[];
TrcShort=[TrcShort;[TrcInit(1,:),1]];
for i=2:Points-1
    if (TrcInit(i,1)-TrcInit(i-1,1)==0 & TrcInit(i+1,1)-TrcInit(i,1)==0)
    else
    TrcShort=[TrcShort;[TrcInit(i,:),i]];
    end
end
TrcShort=[TrcShort;[TrcInit(Points,:),Points]];
%
Trc=TrcShort;
NPoints=size(Trc(:,1),1);
%Trc
%disp(['On travaille sur ' num2str(NPoints), ' points, au lieu de ' num2str(Points), ' en n''utilisant que les d?buts et fins de traces']);

%% d?but de la reconnection
Ntraceinit=max(Trc(:,1));

clear a;
clear b;
Nt(1)=Ntraceinit+1;

%% debut de la boucle sur Nt(h)
if(~exist('maxiter')) maxiter=Ntraceinit; end;
OK=true;
for h=1:maxiter
%% debut de la boucle sur Nt(h)
%   iter=h;
%   disp(['begin iteration: ', num2str(h)])

%   Points=size(Trc(:,1),1)
%   Ntrace=max(Trc(:,1))
%   Nt(h+1)=Ntrace

%% debut du if de la boucle sur Nt(h)
%   if Nt(h+1)~=Nt(h)
  if (OK)
    [Trc, h, Nt, newPoints, Ntrace, OK]=bliterateLC(Trc, h, Nt, distmax, maxblink, mintrace);
    if exist('waitbarhandle')
       waitbar(h/Ntraceinit,waitbarhandle,['Iteration # ',num2str(h)]);
    end;
% % 
% % Points;
% % Ntrace;
% % 
% % %% trouve les d?but et fin de trace
% % dfTrc=[];
% % dfTrc=[dfTrc;[1,Trc(1,:)]];
% % for i=2:Points-1
% %     if Trc(i,1)-Trc(i-1,1)==1
% %     dfTrc=[dfTrc;[i,Trc(i,:)]];
% %     else
% %         if Trc(i+1,1)-Trc(i,1)==1
% %         dfTrc=[dfTrc;[i,Trc(i,:)]];
% %         end
% %     end
% % end
% % dfTrc=[dfTrc;[Points,Trc(Points,:)]];
% % 
% % %% trouve les d?buts de trace
% % debTrc=[];
% % debTrc=[debTrc;Trc(1,:)];
% % for i=2:Points
% %     if Trc(i,1)-Trc(i-1,1)==1
% %     debTrc=[debTrc;Trc(i,:)];
% %     else
% %     end
% % end
% % 
% % %% trouve les fins de trace
% % finTrc=[];
% % for i=1:Points-1
% %     if Trc(i+1,1)-Trc(i,1)==1
% %        finTrc=[finTrc;Trc(i,:)];
% %     end
% % end
% % finTrc=[finTrc;Trc(Points,:)];
% % Ntrace=size(finTrc(:,1),1)
% % %disp(['Num?ro de la passe : ' num2str(h)]);
% % % actualizes waitbar
% % if exist('waitbarhandle')
% %    waitbar(h/Ntraceinit,waitbarhandle,['Iteration # ',num2str(h)]);
% % end
% % 
% % %% cr?e la matrice des distances
% % Dist=zeros(Ntrace,Ntrace);
% % Dist=Dist+100;
% % for i=1:Ntrace
% %     for j=1:Ntrace
% %        if (j>i & finTrc(i,2)<debTrc(j,2))
% %            Dist(i,j)=sqrt((finTrc(i,3)-debTrc(j,3))^2+(finTrc(i,4)-debTrc(j,4))^2);
% %        else
% %        end
% %     end
% % end
% % 
% % %% cr?e la matrice des distances minimum entre traces: IdxLesmin contient les indices des traces et les valeurs des distances
% % Lesmin=zeros(Ntrace,1);
% % IdxLesmin=[];
% % % % 
% % % % Below, Lesmin is a column
% % % % vector of Euclidean distances which are smaller than distmax AND represent
% % % % the distance between a trace END and its NEAREST trace START (hence the need
% % % % for `lepi'. All other values in Lesmin that do not satisfy the conditions
% % % % just described are assigned the value 100, so that Lesmin length is the same
% % % % as the number of traces we're working on -- unfortunately, not only this is
% % % % a useless memory filler, but is also implemented with for loops -- utterly
% % % % inefficient!
% % % % 
% % % % To replace Lesmin with just a vector of indices, one could call:
% % % % 
% % % % DBoolLC=sparse(Dist<distmax);    % get a matrix of `lespi's in one breath;
% % % %                                  % in fact, DBoolLC is the same as my DBool
% % % %                                  % after Condition2, as shown by the
% % % %                                  % following condition, which verifies:
% % % %                                  % all(all(DBoolLC == DBool)) 
% % % % 
% % % % [eyes, jays]=find(DBool);        % eyes & jays are ROW, resp. COL indices.
% % % %                                  % To find out which of these has the
% % % %                                  % minimum index (row-wise) we call: 
% % % % eyes=sortrows(eyes);             % sort the ROW indices (i.e., the eyes)
% % % % eyes=unique(eyes);               % then get the UNIQUE ROW number
% % % % 
% % % % mylesmin=sparse(Ntrace,1);       % preallocate index matrix for min. COL
% % % %                                  % indices (see above)
% % % % 
% % % % for i=1:length(eyes)                              % can't bypass a for loop
% % % %   mylesmin(eyes(i))=min(find(DBool(eyes(i),:)));  % here; vectorizing yields
% % % % end;                                              % accumulation
% % % % 
% % % % Now, for mylesmin the following three tests verify:
% % % % 
% % % % a) size(find(mylesmin~=0)) == size(find(Lesmin~=100));
% % % % 
% % % % b) all(find(mylesmin~=0) == find(Lesmin~=100));
% % % % 
% % % % c) verify that indeed mylesmin points to the appropriate columns into Dist:
% % % % 
% % % %    test=zeros(Ntrace,1);
% % % %    for (i=1:Ntrace)
% % % %      if (mylesmin(i)~=0) test(i)=Dist(i,mylesmin(i)); end;
% % % %    end;
% % % %    test(find(test==0))=100;
% % % %    all(test==Lesmin);              % <- VERIFIES !!!
% % % % 
% % % % 
% % for i=1:Ntrace-1
% %     lespi=find((Dist(i,:)<distmax)); % find COL indices for Dist<distmax in each ROW
% %     if ~isempty(lespi)
% %         lepi=min(lespi); % get the minimum COL index for Dist<distmax in each ROW
% %         Lesmin(i)=Dist(i,lepi); % copy THAT particular Dist element into Lesmin
% %         clear lepi;
% %         clear lespi;
% %     else 
% %         Lesmin(i)=100;
% %     end
% % end
% % 
% % Lesmin(Ntrace)=100;
% % %Lesmin
% % 
% % %% populate IdxLesmin
% % % % Here, LC verifies (again!) Euclidean distances in Dist against the values in
% % % % Lesmin, making sure they are valid (i.e., < 100); if the tests verify, then
% % % % he passes the ROW and COL indices and THE value of Lesmin at ROW into yet
% % % % another matrix `IdxLesmin' (by the way, how many times do we store the same
% % % % values in this code???), EXCEPT that when ROW==COL he writes a `100' into
% % % % IdxLesmin, and passes (ROW, ROW) as coordinates!
% % % % 
% % % % In fact, the column coordinates are contained in mylesmin~=0 so if I define:
% % % % 
% % % % myidxlesmin=[eyes, mylesmin(find(mylesmin~=0))];
% % % % 
% % % % I actually get an abbreviated version of IdxLesmin i.e., without the
% % % % coordinates for which Euclidean distance is 100, and only half the
% % % % column-size. 
% % % % 
% % % % By the way, it turns out that LC's IdxLesmin contains TWICE the same data:
% % % % 
% % % % testa=IdxLesmin(1:Ntrace,:);
% % % % testb=IdxLesmin(Ntrace+1:end,:);
% % % % all(all(testa==testb))            % <- VERIFIES (!!!) which means that
% % % % IdxLesmin really has unnecessary data duplication (row/column and distances
% % % % are listed twice)
% % % % 
% % % %  So, why is all this necessary?
% % % % 
% % % % Furthermore, given:
% % % % 
% % % % testd=testa(find(testa(:,3)~=100), 1:2);
% % % % 
% % % % all(all(myidxlesmin==testd))      % <- also VERIFIES !!!
% % % % 
% % % % which means that myidxlesmin contains THE SAME row/column indices into LC's
% % % % Dist (and my DBool) for every trace END-START pair separated by less than
% % % % distmax (and smaller than 100, whatever the reason for chosing this value !!!)
% % % % 
% % for i=1:Ntrace
% %     for j=1:Ntrace
% %         if (Dist(i,j)==Lesmin(i) & Dist(i,j)<100) 
% %             IdxLesmin=[IdxLesmin;[i,j,Lesmin(i)]]; 
% %         else
% %             if (Dist(i,j)==Lesmin(i) & i==j & Dist(i,j)==100)
% %                IdxLesmin=[IdxLesmin;[i,i,100]]; 
% %             else
% %             end
% %         end
% %     end
% % end
% % 
% % IdxLesmin;
% % temp=Trc;
% % 
% % %Ntrace=size(IdxLesmin(:,1),1)
% % nwTrc=[];
% % 
% % %% test les connections valides. Sinon, connecte la trace avec elle meme
% % % % here, LC applies a third condition: that the distance between consecutive
% % % % trace boundaries is not larger than maxblink, or that the Eucildean
% % % % distance is larger than distmax; if it is, then assign ROW 
% % % % coord to COL coord in IdxLesmin (for COL and ROW coord see previous
% % % % code cell).
% % % % I think it's obvious that the test w.r.t distmax is futile, since we have
% % % % already filtered against this...
% % % % 
% % % % In fact, he is working here only on the FIRST Ntrace rows of IdxLesmin, and
% % % % doesn't even touch the second half (see comments in the previous cell code
% % % % for data duplication in IdxLesmin).
% % % % 
% % % % Applying the same condition w.r.t maxblink to myidxlesmin, I make use of the
% % % % index vectors debR and finR to index into Trc; for this, I use the columns
% % % % of myidxlesmin to actually index into debR and finR, thus indirectly
% % % % retrieveing the indices into Trc (kind of `pointer to pointer' if you wish):
% % % % 
% % % % mb=find((Trc(debR(myidxlesmin(:,2)),2)-Trc(finR(myidxlesmin(:,1)),2))>maxblink);
% % % % myidxlesmin(mb,2)=myidxlesmin(mb,1);
% % % % 
% % % % Now, myidxlesmin is identical to first half (rows 1:Ntrace) of IdxLesmin
% % % % columns 1 and 2, but without those rows for which column 3 (Euclidean
% % % % distance) is 100:
% % % % 
% % % % I you run LC's loop below the you'll see that, given:
% % % % 
% % % % testa=IdxLesmin(1:Ntrace,:);          
% % % % 
% % % % we obtain:
% % % % 
% % % % all(myidxlesmin==testa(find(testa(:,3)~=100),1:2))   % <- VERIFIES !!!
% % % % 
% % for i=1:Ntrace
% %     if ((debTrc(IdxLesmin(i,2),2)-finTrc(IdxLesmin(i,1),2))>maxblink | IdxLesmin(i,3)>distmax)
% %         IdxLesmin(i,2)=IdxLesmin(i,1);
% %     else
% %     end
% % end    
% % IdxLesmin;
% % 
% % %% construit la nouvelle matrice des traces 
% % % % As in the previous code cell, LC is only iterating through the first Ntrace
% % % % rows of IdxLesmin, which enforces my belief in the myidxlesmin approach
% % % % outlined above. Oh, and temp is none other than Trc... yet another 
% % % % data copy!!! Oh, boy...
% % for i=1:Ntrace%-1
% %     nwIdx(i,1)=i;
% %     if IdxLesmin(i,2)~=IdxLesmin(i,1)
% %         debuttrace1=dfTrc(2*IdxLesmin(i,1)-1,1); %
% %         fintrace1=dfTrc(2*IdxLesmin(i,1),1);
% %         debuttrace2=dfTrc(2*IdxLesmin(i,2)-1,1);
% %         fintrace2=dfTrc(2*IdxLesmin(i,2),1);
% %         for k=debuttrace1:fintrace1
% %             if temp(k,1)==0
% %             else
% %                 nwTrc=[nwTrc;[i,temp(k,:)]];
% %                 temp(k,1)=0;
% %             end
% %         end
% %         for k=debuttrace2:fintrace2
% %             if temp(k,1)==0
% %             else
% %                 nwTrc=[nwTrc;[i,temp(k,:)]];
% %                 temp(k,1)=0;
% %             end
% %         end
% %     else
% %         debuttrace1=dfTrc(2*IdxLesmin(i,1)-1,1); %
% %         fintrace1=dfTrc(2*IdxLesmin(i,1),1);
% %         for k=debuttrace1:fintrace1
% %             if temp(k,1)==0
% %             else
% %                 nwTrc=[nwTrc;[i,temp(k,:)]];
% %                 temp(k,1)=0;
% %             end
% %         end    
% %     end
% % end
% % 
% % %% renum?rote les nouvelles traces sans chiffre manquant
% % newPoints=size(nwTrc(:,1),1);
% % tmp=[];
% % tmp(1)=nwTrc(1,1);
% % for i=2:newPoints
% %     if (nwTrc(i,1)-nwTrc(i-1,1))>0
% %        tmp(i)=tmp(i-1)+1;
% %     else
% %         tmp(i)=tmp(i-1);
% %     end
% % end
% % for i=2:newPoints
% %     nwTrc(i,1)=tmp(i);
% % end
% % 
% % %% s?pare r?initialise la trace
% % clear Trc;
% % Trc(:,1)=nwTrc(:,1);
% % Trc(:,2)=nwTrc(:,3);
% % Trc(:,3)=nwTrc(:,4);
% % Trc(:,4)=nwTrc(:,5);
% % Trc(:,5)=nwTrc(:,6);
% % Trc(:,6)=nwTrc(:,7);
% % Trc(:,7)=nwTrc(:,8);
% % 
% % % clear nwTrc


  end; %fin du if dans de la boucle sur Nt(h)

end; % fin de la boucle sur Nt(h)
if exist('waitbarhandle')
      % % so that I can execute this M-file from the command line - CMT 03/11/2007
    close(waitbarhandle);
end

%disp(['Patience ! Avancement de l''?criture de la matrice finale de traces ... ']);

%% s?lectionne les traces de longueur sup?rieure ? minTrace
Ntracereconnect=max(Trc(:,1));
Np=newPoints/2;
numTrace=1;
longTrc=0;
tempoTrc=[];
tempo=[];

%% generate longTrc
longTrc=zeros(Ntrace,2); % va contenir le num?ro de la trace et la longueur de la trace

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
%longTrc : matrice de la longueur des traces

%% consolidate longTrc
for i=1:newPoints
   if longTrc(Trc(i,1),2)>mintrace
       tempoTrc=[tempoTrc;[Trc(i,:)]];
   end
end
Trc=tempoTrc;

if size(Trc)>0    
%% renum?rote les nouvelles traces sans chiffre manquant
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

%% refabrique la matrice compl?te des traces ? partir de trace
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
  if exist('handles')
    % % so that I can execute this M-file from the command line - CMT 03/11/2007
    text=[num2str(Ntracereconnect) ' trajectories after reconnection and ',num2str(Ntracefin) ' trajectories after filtering the short ones (less than ' num2str(mintrace) ' points).'];
    updatereport(handles,text)
  end;

else
    disp('No trajectory left with enough number of points.');
    if exist('handles')
      % % so that I can execute this M-file from the command line - CMT 03/11/2007
      text=['No trajectory left with enough number of points.'];
      updatereport(handles,text,1)
    end;
    res=[];
end

end


% end of file
