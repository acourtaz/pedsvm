function shape_index(threshold)

[stk,stkd] = uigetfile('*.stk','Choose a growth cone movie');
if ~stk,return,end
Movi = stkread(stk,stkd);

%Need to make a 'play' like interface to choose the value for threshold
length = size(Movi,3);
binMovi = Movi > threshold;
filledCone = zeros(size(Movi));
boundCone = zeros(size(Movi));
areaCone = zeros(size(Movi,3),1);
areaCone = squeeze(areaCone);
perimCone = zeros(size(Movi,3),1);
perimCone = squeeze(perimCone);
for i=1:length
    binImFill = imfill(binMovi(:,:,i),'holes');
    binLabel = bwlabel(binImFill);
    S = regionprops(binLabel,'Area');
    [cone,numCone] = max([S.Area]);
    coneIm = (binLabel == numCone);
    filledCone(:,:,i) = coneIm;
    areaCone(i) = bwarea(coneIm);
    conePerim = bwperim(coneIm);
    boundCone(:,:,i) = conePerim;
    perimCone(i) = sum(sum(conePerim));
end
areaCone = double(areaCone);
perimCone = double(perimCone);
filledCone = uint8(filledCone);
stkwrite(filledCone,'areatry.stk',stkd);
boundCone = uint8(boundCone);
stkwrite(boundCone,'boundtry.stk',stkd);

dlmwrite('areaCone.txt', areaCone, 'delimiter','\t','precision',5);
dlmwrite('perimCone.txt', perimCone, 'delimiter','\t','precision',5);
shape = perimCone.^2./(4*pi.*areaCone);
dlmwrite('shape.txt', shape, 'delimiter','\t','precision',5);



