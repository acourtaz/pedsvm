%function quantdat

clear all
[f,p] = uigetfile('*.trc','File with tracking data from MIA');          % f is for file, p for path                                             
if ~f,return,end                                                        % 'if ~f' says - if no f, then exit the programme ('return,end')                                                        
dat = dlmread([p,f],'\t');                                              % dlm read requires the path and file, '\t' denotes tab delimiter                                              
dim = size(dat);
n = dim(1);
ids = dat(n,1);                                                         % ids : total number of objects detected (could have ids = dat(size(dat,1),1);)

[coFile,coDir] = uigetfile('*.txt','File with alignment coefficients');
if ~coFile
    c = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
else c = dlmread([coDir,coFile],'\t');
end

frn = 203;                                                              % 'frn' = frame number (will eventually get this from the number of frames in the movi)
trk = zeros(frn,12,ids);                                                % initialize matrix to accept data
trk(3,2:3,:) = 512;                                                     % initialize cells that will take max values of x and y
trk(3,8:9,:) = 512;
id = 1;                                                                 % initialize 'id'
trk(1,1,id) = dat(1,2);                                                 % before the loop starts put 1st track id into matrix

for a = 1:(n - 1);                                                      % because of need for look-ahead, can only run to n-1
    id = dat(a,1);
    r = dat(a,2) + 4;                                                   % row = frame number, plus 4 to accom. header
    trk(1,1,id) = id;
    trk(r,2:3,id) = dat(a,3:4);                                         % transfer the x,y coordinates from the 'dat' to 'trk'
    trk(r,4,id) = dat(a,6);
    x = dat(a,3);
    if x > trk(2,2,id);                                                 % xmax
        trk(2,2,id) = x;
    end
    if x < trk(3,2,id);                                                 % xmin
        trk(3,2,id) = x;
    end
    y = dat(a,4);
    if y > trk(2,3,id);                                                 % ymax
        trk(2,3,id) = y;
    end
    if y < trk(3,3,id);                                                 % ymin
        trk(3,3,id) = y;
    end
    u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 + ...                  % calc x'coordinates for red channel
    c(5).*y + c(6).*y.^2 + c(7).*y.^3 + 256;
    trk(r,8,id) = u;
    v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 + ...                % calc y' coordinates for red channel
    c(12).*y + c(13).*y.^2 + c(14).*y.^3;
    trk(r,9,id) = v;
    if u > trk(2,8,id);                                                 % umin
        trk(2,8,id) = u;
    end
    if u < trk(3,8,id);                                                 % umax
        trk(3,8,id) = u;
    end
    if v > trk(2,9,id);                                                 % vmin
        trk(2,9,id) = v;
    end
    if v < trk(3,9,id);                                                 % vmax
        trk(3,9,id) = v;
    end  
    nid = dat((a + 1),1);                                               % 'nid' = new id (of next row)                                               
    if nid ~= id;                                                       % if the id has changed, tidy up this page before moving onto the next
        r = 4;
        trk(3,1,id) = dat(a,2);                                         % last frame of tracking data
        lfr = trk(3,1,id);
        trk(2,1,id) = dat((a + 1),2);                                   % first frame of tracking data
        ffr = trk(2,1,id);
        trk((4:203),1,id) = 1:200;
        trk(1,2,id) = lfr - ffr + 1;
        trk((4:(ffr + 4)),2,id) = trk((ffr + 4),2,id);                  % all coordinates before first frame = coordinates of first frame
        trk((4:(ffr + 4)),3,id) = trk((ffr + 4),3,id);
        trk((4:(ffr + 4)),8,id) = trk((ffr + 4),8,id);
        trk((4:(ffr + 4)),9,id) = trk((ffr + 4),9,id);
        trk((lfr + 4):203,2,id) = trk((lfr + 4),2,id);                  % all coordinates after last frame = coordinates of last frame
        trk((lfr + 4):203,3,id) = trk((lfr + 4),3,id);
        trk((lfr + 4):203,8,id) = trk((lfr + 4),8,id);
        trk((lfr + 4):203,9,id) = trk((lfr + 4),9,id);
    end
end
clear dat;                                                              % clear dat to free up some memory

b = size(trk);
ntrk = zeros(b);
p = 1;
q = 1;
min = 3;                                                                % 'min' defines the minimal track history

for a = 1:b(3);                                                         % short for loop to transfer filtered 'trk' data into 'ntrk' matrix
    if trk(1,2,a) > min & trk(2,1,a) > 20 & trk(2,1,a) < 180;             
        ntrk(:,:,p) = trk(:,:,a);
        p = p + 1;
    else
        q = q + 1;
    end
end

[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end
movi = stkread(stk,stkd);
movi = double(movi);

circ = zeros(25,25);
midx = (0.5*(size(circ,1))) + 0.5;
midy = (0.5*(size(circ,2))) + 0.5;
x = 1;
y = 1;

for y = 1:25;
    for x = 1:25;
        dist = (((y - midy)^2 + (x - midx)^2) ^ 0.5);
        if dist <= 4.5;
            circ(y,x) = 1;
        end
    x = x + 1;
    end
    y = y + 1;
end
circpix = sum(sum(circ));

ann = zeros(25,25);
midx = (0.5*(size(ann,1))) + 0.5;
midy = (0.5*(size(ann,2))) + 0.5;
x = 1;
y = 1;

for y = 1:25;
    for x = 1:25;
        dist = (((y - midy)^2 + (x - midx)^2) ^ 0.5);
        if  6 <= dist & dist <= 12;
            ann(y,x) = 1;
        end
    x = x + 1;
    end
    y = y + 1;
end
annpix = sum(sum(ann));

n_events = p;
id = 0;
fr = 1;
count = 0;
s = size(movi);
sntrk = size(ntrk);
mini = zeros(25,50,(s(3)));
quantdat = zeros((sntrk(1).*2),5,p);

for a = 1:sntrk(3);
    id = id + 1;
    r = 1;
    grnxmin = round(ntrk(3,2,id));
    grnxmax = round(ntrk(2,2,id));
    grnymin = round(ntrk(3,3,id));
    grnymax = round(ntrk(2,3,id));
    redxmin = round(ntrk(3,8,id));
    redxmax = round(ntrk(2,8,id));
    redymin = round(ntrk(3,9,id));
    redymax = round(ntrk(2,9,id));
    for fr = 1:200;
        grnxy(1:2) = round(ntrk((r + 3),2:3,id));
        redxy(1:2) = round(ntrk((r + 3),8:9,id));
        if grnxmin > 13 & grnxmax < 243 & grnymin > 13 & grnymax < 287 ...
            redymin > 269 & redxmax < 499 & redymin > 13 & redymax < 287;
            minigrn = movi((grnxy(1,2) - 11):(grnxy(1,2) + 13),(grnxy(1,1) - 11):(grnxy(1,1) + 13),r);
            minired = movi((redxy(1,2) - 11):(redxy(1,2) + 13),(redxy(1,1) - 11):(redxy(1,1) + 13),r);
            grnroi = sum(sum(circ.*minigrn))/circpix;
            grnann = sum(sum(ann.*minigrn))/annpix;
            redroi = sum(sum(circ.*minired))/circpix;
            redann = sum(sum(ann.*minired))/annpix;
            ntrk((r + 3),4,id) = grnroi;
            ntrk((r + 3),5,id) = grnann;
            ntrk((r + 3),6,id) = grnroi - grnann;
            ntrk((r + 3),10,id) = redroi;
            ntrk((r + 3),11,id) = redann;
            ntrk((r + 3),12,id) = redroi - redann;
        
            quantdat(1,1,id) = id;
            ffr = ntrk(2,1,id);                                             % 1st frame of tracking data
            quantdat(1,2,id) = ffr;
            quantdat((2:408),1,id) = -203:203;
            quantdat((203 - ffr + r),2,id) = grnroi - grnann;
            quantdat((203 - ffr + r),3,id) = redroi - redann;
    
            mini(1:25,1:25,r) = minigrn(1:25,1:25,1);
            mini(1:25,26:50,r) = minired(1:25,1:25,1);
            mini = uint16(mini);
            if fr == 199;
                count = count + 1;
            end
        end
        fr = fr + 1;
        r = r + 1;
    end
    % stkwrite(mini,['test','_',num2str(count(1,1)),'.stk'],stkd)
end

av = (sum(quantdat,3))/p;
plot(av(178:228,2),'-og')
hold all;
plot(av(178:225,3),'-or')
