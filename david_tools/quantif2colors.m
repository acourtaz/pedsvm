function quantif2colors(action)


if nargin == 0
    
    

    
    
    [fileR,pthR] = uigetfile('*.tif','Choose the red image');
     if ~fileR,return,end
    imR = imread([pthR,fileR]);
    
    rBack=dlmread(uigetfile('*rgn.txt', 'Select background region'));
    
    maskcell=dlmread(uigetfile('*mask.txt','Select mask'));

     
    airepix=sum((sum(maskcell)))
    % pixSize = 0.064516; Size pixel spinning +63x, in µm²


    
    Maskred = maskcell .* double(imR);
    fluoback=sum(sum(double(imR(rBack(2):(rBack(2)+rBack(4)),rBack(1):(rBack(1)+rBack(3))))))/(rBack(3)*rBack(4));

    avred=(sum(sum(Maskred))/airepix)-fluoback
    
    
else
    eval(action)
end
    
    
