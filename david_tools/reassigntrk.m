clear all;
[f,p] = uigetfile('*.trc');             % f is for file, p for path                                             
if ~f,return,end                        % 'if ~f' if no f, then exit the programme ('return,end')                                                        
dat = dlmread([p,f],'\t');              % dlm read requires the path and file, '\t' denotes tab delimiter

b = 1;                                  % reorganise data for the tracking algorithm
warning off;
pos = zeros(1,1:3);                    
warning on;
for a = 1:size(dat,1);
    if dat(a,1) ~= 0;                                  
       pos(b,1:2) = dat(a,3:4);
       pos(b,3) = dat(a,2);
       b = b + 1;
    else
    end
end
pos = sortrows(pos,3);                  % resort rows by object id

possize = size(pos);                    % add '1' to all x/y pairs to get rid of '0' coordinates from MM.
warning off;
nonzero = zeros(possize);
nonzero(:,1:2) = 1;
pos = pos + nonzero;
warning on;

param.mem = 2;                          % number of frames a particle can be 'lost'
param.dim = 2;                          % unscramble non coordinate data
param.good = 3;                         % eliminates all tracks < parameter 'good'
param.quiet = 1;                        % switches text on ('0') or off ('1')
maxdisp = 2;                            % maximum displacement

res = track(pos,maxdisp,param);         % reassign tracks

warning off;
temp = zeros(1,1:4);
warning on;
ressize = size(res);                    % identify and fix gaps in the track histories
b = 1;
for a = 1:ressize(1) - 1;
    if res(a,4) == res(a + 1,4) & (res(a + 1,3) - res(a,3)) > 1; % checks the id is the same and whether there is a gap
       gap = (res(a + 1,3) - res(a,3));
       if res(a,1) ~= res(a + 1,1);                              % if the x coords are different either side of the gap, interpolate
        dx = (res(a + 1,1) - res(a,1)) / gap;
        xs = res(a,1):dx:res(a + 1,1); xs = xs(2:gap); xs = xs';
       else
        xs = res(a,1);                                           % if the x coords are the same, fill in the same value
        xs(1:gap - 1) = xs; xs = xs';
       end
       if res(a,2) ~= res(a + 1,2);                              % if the y coords are different either side of the gap, interpolate
        dy = (res(a + 1,2) - res(a,2)) / gap;
        ys = res(a,2):dy:res(a + 1,2); ys = ys(2:gap); ys = ys';
       else
        ys = res(a,2);                                           % if the y coords are the same, fill in the same value
        ys(1:gap - 1) = ys; ys = ys';
       end
       frs = res(a,3):1:res(a + 1,3); frs = frs(2:gap); frs = frs';
       ids = res(a,4); ids(1:gap - 1) = ids; ids = ids';
       bridge(1:gap - 1,1) = xs;                                 % build a tmp matrix called 'bridge' to take all the values
       bridge(1:gap - 1,2) = ys;
       bridge(1:gap - 1,3) = frs;
       bridge(1:gap - 1,4) = ids;
       temp(b,1:4) = res(a,1:4);
       temp(b + 1:b + gap - 1,1:4) = bridge(1:gap - 1,1:4);      % stick the bridge in the gap
       clear bridge;
       b = b + gap;
    else
       temp(b,1:4) = res(a,1:4);                                 % if there isn't a gap, just transfer the row to temp
       b = b + 1;
    end
end

tempsize = size(temp);
warning on;
res = zeros(tempsize);
warning off;
res(:,1) = temp(:,4);
res(:,2) = temp(:,3);
res(:,3:4) = temp(:,1:2);                                        % transfer the final result from 'temp' into the matrix 'res'

[name,path]  = uiputfile('*.txt','Save reassigned tracks histories as');
if ~res,return,end;
dlmwrite([path,name],res,'delimiter','\t','precision',6); %note switched order of [path,name] compared to uiputfile

