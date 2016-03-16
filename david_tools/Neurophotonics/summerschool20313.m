clear all

[StreamName,dirname] = uigetfile('Stream_GluA1-SEP_001.stk','tif');
cd(dirname)


% Get I (Stream.tif)
% info = imfinfo(StreamName);
% h = waitbar(0,'Please wait reading Stream...');
% for i=1:numel(info)
%     I(i).data = imread(StreamName,i);
%     waitbar(i/numel(info))
% end
% close(h)

I1 = tiffread(StreamName,1);
I(1).data = I1(1).data;
imwrite(I(1).data,'I_align.tif','tif','Compression','None')
% %
h = waitbar(0,'Please wait...');
for i=2:750
    
    I2 = tiffread(StreamName,i);
    [I_Align.data] = f_Image_Alignment (I(1).data,I2.data);
    imwrite(I_Align.data,'I_align.tif','tif','WriteMode','append','Compression','None')
waitbar(i / 750)
end
close(h)

%%
figure(10)
% hold on
for i=1:numel(I_Align)
   imshow(I_Align(i).data,[])
   text(10,10,['Frame' num2str(i)],'color','w','fontsize',12)
   pause(0.01)
   
    
end