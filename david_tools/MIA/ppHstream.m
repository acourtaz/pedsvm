function ppHstream

[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end
M = stkread(stk,stkd);
Mlength = size(M,3);

pause(0.1)
[f,p] = uigetfile('*mask.txt','Choose the mask text file');
if ischar(f)&&ischar(p)
    mask = dlmread([p,f],'\t');
    if ~(size(mask)== size(M(:,:,1)))
       errordlg('Sizes of image and mask do not match')
       return
    end
    fMask = imfill(mask); % filled mask = no black pixels inside the cell
else
    return
end

md = bwdist(~fMask);

nl = 8; % number of layers for estimating diffusion
np = 13.333; %number of pixels for each layer, 2�m for 0.15�m pixels
mdis = zeros(size(md,1),size(md,2),nl);
mask_dist = zeros([size(mask),3]);
area_mdis = zeros(1,nl);

for i=1:nl
    if i < nl
        mdis(:,:,i) = md > round(np*(i-1)) & md <= round(np*i);
    else
        mdis(:,:,i) = md > round(np*(i-1));
    end
    area_mdis(i) = sum(sum(mdis(:,:,i)));
    mask_dist(:,:,2) = mask_dist(:,:,2) + (i/nl)*mdis(:,:,i);
    mask_dist(:,:,3) = mask_dist(:,:,3) + (1-i/nl)*mdis(:,:,i);
    
end

figure
image(mask_dist);
axis image
title('Mask Distance')

fluo = zeros(Mlength,nl);
for i=1:nl
    for j=1:Mlength
        cIm = double(M(:,:,j));
        fluo(j,i) = sum(sum(cIm.*mdis(:,:,i)))/area_mdis(i);
    end
end

% modifs Mo

c = findstr(f,'-');
if isempty(c)
    c = size(f(1:end-4),2);
else c = c(end)+1;
end


[fdist,pdist] = uiputfile([f(1:c),'_maskDist.fig'],'Save quantification');
saveas(gcf,[pdist,fdist]);

%

minFluo = min(fluo);
maxFluo = max(fluo);
Nfluo = zeros(size(fluo));
for i=1:nl
    Nfluo(:,i) = (fluo(:,i)-minFluo(i))./(maxFluo(i)-minFluo(i));
end

fr = 1:Mlength;
figure('name',[f,' stream Fluo'])
hold on
for i=1:nl
    plot(fr,Nfluo(:,i),'color',[0,i/nl,1-i/nl])
end

% modifs Mo

[ffluo,pfluo] = uiputfile([f(1:c),'_DistFluo.fig'],'Save quantification');
saveas(gcf,[pfluo,ffluo]);

%

[fle,pth] = uiputfile([f(1:c),'_maskDF.xlsx'],'File for fluo data');
if ischar(fle) && ischar(pth)
    fluoAll = cell(Mlength+4,2*nl+1);
    fluoAll{2,1} = 'fluo file';
    fluoAll{2,3} = stk;
    fluoAll{3,1} = 'mask file';
    fluoAll{3,3} = f;
    fluoAll{4,1} = 'frame';
    fluoAll{4,2} = 'Normalised fluorescence data';
    fluoAll{4,nl+2} = 'Fluorescence data';
    fluoAll(5:end,1) = num2cell((1:Mlength)');
    fluoAll(5:end,2:nl+1) = num2cell(Nfluo);
    fluoAll(5:end,nl+2:end) = num2cell(fluo);
    xlswrite([pth,fle],fluoAll)
end