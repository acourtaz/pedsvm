function OffsetMovie

%Written by DP, updated July 21st 2015
% aligns movie according to first image
% (see OffsetMovie2 for alignment to next image)

[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end
M = stkread(stk,stkd);
stk = stk(1:end-4);
[coFile,coDir] = uigetfile('*.txt','File with offset coefficients');
if ~coFile
    imOffset = zeros(size(M,3),2);
    ld = 0;
else
    imOffset = dlmread([coDir,coFile],'\t');
    ld = 1;
end

a = 100;
refIm = M(:,:,1);
for i = 1:size(M,3)-1
    if ld
        xoff = imOffset(i+1,1);
        yoff = imOffset(i+1,2);
    else
        imTemplate = M(1+a:end-a,1+a:end-a,i+1);
        C = normxcorr2(imTemplate,refIm);
        [maxIm,imaxIm] = max(C(:));
        [yPim,xPim] = ind2sub(size(C),imaxIm(1));
        yoff = (yPim-size(imTemplate,1)-a);
        xoff = (xPim-size(imTemplate,2)-a);
    end
    newIm = M(:,:,i+1);
    if yoff<0
        newIm = newIm(1-yoff:end,:);
        for j = 1:abs(yoff)
            newIm = cat(1,newIm,newIm(end,:));
        end
    elseif yoff>0
        newIm = newIm(1:end-yoff,:);
        for j = 1:abs(yoff)
            newIm = cat(1,newIm(1,:),newIm);
        end        
    end
    if xoff<0
        newIm = newIm(:,1-xoff:end);
        for j = 1:abs(xoff)
            newIm = cat(2,newIm,newIm(:,end));
        end
    elseif xoff>0
        newIm = newIm(:,1:end-xoff);
        for j = 1:abs(xoff)
            newIm = cat(2,newIm(:,1),newIm);
        end        
    end
    M(:,:,i+1) = newIm; 
    if ~ld
        imOffset(i+1,1) = xoff;
        imOffset(i+1,2) = yoff;
    end
end

stkwrite(M,[stk,'_offset'],stkd);

figure
plot(imOffset(:,1),imOffset(:,2))
if ~ld
    dlmwrite([stk,'_offset.txt'],imOffset,'\t')
end