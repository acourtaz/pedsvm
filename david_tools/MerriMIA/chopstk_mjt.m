function varargout = chopstk_mjt(varargin);

% designed to excise minis for multiple types of 2 channel analysis
% (departure, arrival, scission, peaks)

clear all;

% type = 1; % departures analysis
% type = 2; % arrivals analysis
  type = 3; % scission analysis
% type = 4; % peak analysis
% type = 5; % other ...

frbef = 20;
fraft = 20;

[f,p] = uigetfile('*.txt','Load track histories');
if ~f,return,end
trks = dlmread([p,f],'\t');
sizetrks = size(trks);

[stk,stkd] = uigetfile('*.stk','Load pH low parent stack');
if ~stk,return,end
movi = stkread(stk,stkd);
movi = double(movi);
sizemovi = size(movi);

[coFile,coDir] = uigetfile('*.txt','Load alignment coefficients');
if ~coFile;
    coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
else coeff = dlmread([coDir,coFile],'\t');
end

shiftup(1:sizetrks(1)) = 0; shiftdown(1:sizetrks(1)) = 0;       % assign matrices to calculate the tags
noshift(1:sizetrks(1)) = trks(:,1);                             % move the id values over to the holding vectors
shiftup(1:sizetrks(1) - 1) = trks(2:sizetrks(1),1);
shiftdn(2:sizetrks(1)) = trks(1:sizetrks(1) - 1);

ffrs(1:sizetrks(1)) = shiftdn - noshift;                        % find first frames, marked by '-1'
ffrs = ffrs .* - 1;                                             % convert to '1' for indexing
ffrs(1) = 1;                                                    % replace the (first) missing value
ffrsind = find(ffrs);                                           % return row indexes for first frame of each history

lfrs(1:sizetrks(1)) = shiftup - noshift;                        % find last frames, marked by '1'
lfrs(sizetrks(1)) = 1;                                          % replace the (last) missing value
lfrsind = find(lfrs);                                           % return row indexes for last frame of each history

tmp = size(ffrsind);                                            % trksumm holds trk id, first and last frame row index
trksumm(1:tmp(2),1) = 1:1:tmp(2);
trksumm(1:tmp(2),2) = ffrsind;
trksumm(1:tmp(2),3) = lfrsind;
trksumm(1:tmp(2),4) = lfrsind - ffrsind + 1;

b = 1;
if type == 1;
trks(:,5) = lfrs;                                                       % append the tag files to the track histories
ffrs = trks(trksumm(:,2),:);                                            % use the indices in trksumm to get the ...
lfrs = trks(trksumm(:,3),:);                                            % actual first and last frame numbers
nfrs = lfrs - ffrs;
goodtrk = trksumm((find(lfrs(:,2) >= frbef & ...                        % get rid of histories too short or close to ends
lfrs(:,2) <= (sizemovi(3) - fraft) & (nfrs(:,2) >= fraft))),:);
for id = 1:size(goodtrk,1);
   ffr = goodtrk(id,2);
   lfr = goodtrk(id,3);
   tmptrk = trks(ffr:lfr,:);                                           % returns full track histories
   ta = find(tmptrk(:,5));
   tmptrk = tmptrk(ta - frbef:ta,:);
   tmptrk = coordstform(tmptrk,coeff);
   ta = find(tmptrk(:,7));
   for a = 1:fraft;                                                    % back fill coords after ta
       tmptrk(ta + a,:) = tmptrk(ta,:);
   end
   tmptrk(ta + 1:ta + fraft,7) = 0;                                    % repair tag column
   tmptrk(ta:ta + fraft,2) = tmptrk(ta,2):1:tmptrk(ta,2) + fraft;      % repair frame column
   check = checkedge(tmptrk,sizemovi);                                 % check coords fit in movi
   if check == 1;                                                      % excise mini
      mini = excisemini(movi,tmptrk,goodtrk,coeff,id);
      mini = uint16(mini);
      stkwrite(mini,[stk(1:4),'e',num2str(b),'.stk'],stkd)             
      b = b + 1;                                                       % would be better to keep original id
   end
end

elseif type == 2;
trks(:,5) = ffrs;                                                      % append the tag files to the track histories
ffrs = trks(trksumm(:,2),:);                                           % use the indices in trksumm to get the ...
lfrs = trks(trksumm(:,3),:);                                           % actual first and last frame numbers
nfrs = lfrs - ffrs;
goodtrk = trksumm((find(ffrs(:,2) >= frbef + 1 & ...                   % get rid of histories too short or close to ends
ffrs(:,2) <= (sizemovi(3) - fraft) & (nfrs(:,2) >= fraft))),:);
for id = 1:size(goodtrk,1);
   ffr = goodtrk(id,2);
   lfr = goodtrk(id,3);
   tmptrk = trks(ffr:lfr,:);                                           % returns full track histories
   ta = find(tmptrk(:,5));
   tmptrk = tmptrk(ta:ta + fraft,:);
   tmptrk = coordstform(tmptrk,coeff);
   ta = find(tmptrk(:,7));
   tmptrk(frbef + 1:fraft + frbef + 1,:) = tmptrk(1:fraft + 1,:);      % back fill coords before ta
   for a = 1:frbef;
      tmptrk(a,:) = tmptrk(frbef + 1,:);
   end
   tmptrk(1:frbef,7) = 0;                                              % repair tag column
   tmptrk(1:frbef + 1,2) = ...
   (tmptrk(frbef + 1,2) - frbef):1:tmptrk(frbef + 1,2);                % repair frame column
   check = checkedge(tmptrk,sizemovi);                                 % check coords fit in movi
   if check == 1;
      mini = excisemini(movi,tmptrk,goodtrk,coeff,id);                 % excise mini
      mini = uint16(mini);
      stkwrite(mini,[stk(1:4),'e',num2str(b),'.stk'],stkd)             
      b = b + 1;                                                       % would be better to keep original id
   end
end

elseif type == 3;
trks(:,5) = ffrs;                                                      % append the tag files to the track histories
ffrs = trks(trksumm(:,2),:);
goodtrk = trksumm((find(ffrs(:,2) >= frbef + 1 & ...
ffrs(:,2) <= (sizemovi(3) - fraft - 1))),:);                           % get rid of histories too close to ends
tmp(1:frbef + fraft + 1,1:5) = 0;
miniscut(1,1:7) = 0;
for id = 1:size(goodtrk,1);
    ffr = goodtrk(id,2);
    lfr = goodtrk(id,3);
    tmptrk = trks(ffr:lfr,:);
    if lfr - ffr <= fraft + 1;
       tmp(frbef + 1:frbef + (lfr - ffr) + 1,1:5) = tmptrk(:,:);
       for a = 1:frbef;
           tmp(a,1:4) = tmp(frbef + 1,1:4);                            % backfill frames before            
       end
       tmp(1:frbef + 1,2) = ...
       (tmp(frbef + 1,2) - frbef):1:tmp(frbef + 1,2);                  % repair frame numbers
       for a = (frbef + (lfr - ffr) + 1):(frbef + fraft + 1);
           tmp(a,1:4) = tmp(frbef + lfr - ffr + 1,1:4);
       end
       tmp(frbef + lfr - ffr:frbef + fraft + 1,2) = ...                % backfill frames after
       tmp(frbef + (lfr - ffr),2):1:(tmp(frbef + (lfr - ffr),2)) + ...
       fraft - (lfr - ffr) + 1;
    else
       tmp(frbef + 1:frbef + fraft + 1,1:5) = tmptrk(1:fraft + 1,:);
       for a = 1:frbef;
           tmp(a,1:4) = tmp(frbef + 1,1:4);                            % backfill frames after            
       end
       tmp(1:frbef + 1,2) = ...
       (tmp(frbef + 1,2) - frbef):1:tmp(frbef + 1,2);                  % repair frame numbers
    end
    tmptrk = coordstform(tmp,coeff);
    chk = chkbnd(tmptrk,sizemovi);                                     % check coords fit in movi
    if chk == 1;
       mini = excisemini(movi,tmptrk,goodtrk,coeff,id);                % excise mini
       ta = find(tmptrk(:,7));
       chk = chksig(mini,ta);
       if chk ==1;
            mini = uint16(mini);
            stkwrite(mini,[stk(1:4),'e',num2str(b),'.stk'],stkd)             
            miniscut(b,:) = tmptrk(ta,:);                              % details to locate parent objs.
            b = b + 1;                                                 % would be better to keep original id                
       end
    end
end

clear movi;                                                            % free up some memory
        
[stk,stkd] = uigetfile('*.stk','Load pH high Tfnr stack');             % build stack of 'parent objects'
if ~stk,return,end
movi = stkread(stk,stkd);
movi = double(movi);
sizemovi = size(movi);

parents(1:25,1:25) = 0;

for a = 1:size(miniscut,1);                                             % use 'miniscut' to get x,y and fr
    fr = miniscut(a,2);
    x = round(miniscut(a,3));
    y = round(miniscut(a,4));
    tmp = movi(y - 12:y + 12,x - 12: x + 12,fr - 3:fr);
    tmp = mean(tmp,3);
    parents(:,:,a) = tmp;
end

%parents = uint16(parents);
%stkwrite(parents,[stk(1:4),'_par_objs','.stk'],stkd);

%parents = double(parents);
parents = trkedit_mjt(parents);

elseif type == 4;
    
elseif type == 5;
    
end