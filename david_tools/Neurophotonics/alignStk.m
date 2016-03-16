function alignStk

[StreamName,dirname] = uigetfile('*.stk');
stk = stkread(StreamName, dirname);
cd(dirname)


% Get I (Stream.tif)
% info = imfinfo(StreamName);
% h = waitbar(0,'Please wait reading Stream...');
% for i=1:numel(info)
%     I(i).data = imread(StreamName,i);
%     waitbar(i/numel(info))
% end
% close(h)

I1 = stk(:,:,1);
imwrite(I1,'I_align.tif','tif','Compression','None')
% %
h = waitbar(0,'Please wait...');
stkAlign = zeros(size(stk));
stkAlign(:,:,1) = I1;
for i=2:size(stk,3)
    I2 = stk(:,:,i);
    [I_Align.data] = f_Image_Alignment (I1,I2);
    stkAlign(:,:,i) = I_Align.data;
    waitbar(i / size(stk,3))
end
stkAlign = uint16(stkAlign);
stkwrite(stkAlign,[StreamName(1:end-4),'_Align.stk'],dirname);
close(h)
