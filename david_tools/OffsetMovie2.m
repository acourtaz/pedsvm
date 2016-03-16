function OffsetMovie2

% aligns movie according to next image
% (see OffsetMovie for alignment to first image)

[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end
M = stkread(stk,stkd);
stk = stk(1:end-4);

a = 100;
imOffset = zeros(size(M,3),2);
%refIm = M(:,:,1);
for i = 1:size(M,3)-1
    currIm = M(:,:,i);
    imTemplate = M(1+a:end-a,1+a:end-a,i+1);
    C = normxcorr2(imTemplate,currIm);
    [maxIm,imaxIm] = max(C(:));
    [yPim,xPim] = ind2sub(size(C),imaxIm(1));
    yoff = (yPim-size(imTemplate,1)-a);
    xoff = (xPim-size(imTemplate,2)-a);
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
    %if i==1
        imOffset(i,1) = yoff;
        imOffset(i,2) = xoff;
    %else
    %    imOffset(i,1) = yoff+imOffset(i-1,1);
    %    imOffset(i,2) = xoff+imOffset(i-1,2);
    %end
end

stkwrite(M,[stk,'_offset2'],stkd);

figure
plot(imOffset(:,1),imOffset(:,2))