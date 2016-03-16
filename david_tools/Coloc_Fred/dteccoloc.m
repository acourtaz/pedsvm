function out=dteccoloc(n);
if nargin==0
    disp('entrer n');
end  
% For Backroung and Roi selection Images are displayed using rainbow LUT to
% enhance signal to noise ratio.

%Open Image A (red channel) 
[imgA,pathA] = uigetfile('*.tif;*.tiff','Open red Channel');
A = imread([pathA,imgA]); 
figure
colormap rainbow
imshow(A)
title('Select background then ROI');
%background selection
[xa,ya,Bga,rect1] = imcrop(A,jet(256));
[Backa,Ta]= edge(Bga, 'sobel');
%ROI selection
[x,y,Ia,rect] = imcrop(A,jet);
%Find edges in ROI, the constant to multiply Ta (e.s 5)can be adapted
%from 2 to 10 depending on the experimental conditions and the selectivity
%requiered.
BWsa = edge(Ia, 'sobel',6.*Ta);
% dilate lines
se90 = strel('line', 2, 90);
se0 = strel('line', 2, 0);
BWsdila = imdilate(BWsa, [se90 se0]);
% fill holes
BWdfilla = imfill(BWsdila,'holes');
% exclude non linked objects (optionnal, not activated, requiers imclearborder fonction)
BWnoborda = (BWdfilla);

%Open Image B (green channel) 
[imgB,pathB] = uigetfile('*.tif;*.tiff','Open green channel');
B = imread([pathB,imgB]); 
figure
imshow(B,jet(256))
title('Select background then ROI');
%background selection
[xb,yb,Bgb,rect3] = imcrop(B,jet(256));
[Backb,Tb]= edge(Bgb, 'sobel');
%ROI selection
Ib = imcrop(x,y,B,rect);
%Find edges in ROI,the constant to multiply Tb (e.s 5) can be adapted
%from 2 to 10 depending on the experimental conditions and the selectivity
%requiered. 
BWsb = edge(Ib, 'sobel',6.*Tb);
% dilate lines
se90 = strel('line',2, 90);
se0 = strel('line', 2, 0);
BWsdilb = imdilate(BWsb, [se90 se0]);
% fill holes
BWdfillb = imfill(BWsdilb,'holes');
% exclude non linked objects (optionnal, not activated, requiers imclearborder fonction)
BWnobordb = (BWdfillb);

% Boolean Operations
% Inter is "and", Mask is "or"
Inter=(BWnoborda&BWnobordb);
Mask=(BWnoborda|BWnobordb);
%Calculation of Overlaping surfaces in per cent
[s,d,Int]=find(Inter);[In q]=size(Int);
[s,d,Mas]=find(Mask);[Ma q]=size(Mas);
Overlaping=(In/Ma).*100;display(Overlaping);

%Show Original Images outlined
BWoutlinea = bwperim(BWnoborda);
Segouta = Ia; 
Segouta(BWoutlinea) = 255; 
figure, imshow(Segouta), title('outlined Red Channel');
BWoutlineb = bwperim(BWnobordb);
Segoutb = Ib; 
Segoutb(BWoutlineb) = 255; 
figure, imshow(Segoutb), title('outlined Green Channel');

% nMDP Calculation
% Convert from unit8 arrays to double floating arrays
A=double(Ia);
B=double(Ib);
% Exclude non ROI pixels
A=(A.*Mask);
B=(B.*Mask);
%Calculate means
[i,j,v]=find(A);
Ma=mean2(v);
[k,l,w]=find(B);
Mb=mean2(w);
% nMDP
AM=(A)-(Ma);
BM=(B)-(Mb);
PEM=((AM).*(BM))/(max(AM(:)).*max(BM(:)));
%Mean and zero traces
x1=[-1,1];
x2=[0,255];
t=0.*x2;
ma=0.*x1+Ma; 
mb=0.*x1+Mb;
%Prepare Images
IM=PEM;
IMA=A;
IMB=B;
IMROI=Mask;
IM=IM.*IMROI;

% Icorr Calculation. Here comes the famous n !!!
[m,o,p]=find(IM);
[n,xout] = hist(p,[min(p):0.01:max(p)]);
pno=p;
i = find(pno>0);
pno(i) = 0;
PEMnO=find(pno);
[ano pno]=size(PEMnO);
pso=p;
i = find(pso<0);
pso(i) = 0;
PEMpO=find(pso);
[aso pso]=size(PEMpO);
Icorr=((aso)/((aso)+(ano)));
display(Icorr);

%Merging
Aa=adapthisteq(Ia);
Ba=adapthisteq(Ib);
Bleu=zeros([size(Ia)]);
RGB = cat(3,Aa,Ba,Bleu);


  % Display results in figures
 figure;
subplot(2,2,1);plot(IM(:),IMA(:),x1,ma,t,x2);title('Red Ch vs nMDP');
axis([-1 1 0 255]);
subplot(2,2,2);plot(IM(:),IMB(:),x1,mb,t,x2);title('Green Ch vs nMDP');
axis([-1 1 0 255]);
subplot(2,2,3); plotmatrix(IMA(:),IMB(:));title('Red Ch vs Green Ch');
axis([0 255 0 255]);
subplot(2,2,4); 
bar(xout,n);
text((max(xout)/2),mean(n),['Overlaping=',(num2str(Overlaping))]),text((max(xout)/2),max(n),['Icorr=',(num2str(Icorr))]);
title('Distribution of nMDP');
figure
imshow(medfilt2(IM,[3 3]))
colormap mapcorr
title('nMDP Image');
CLim =[-0.5, 0.5]; 
set(gca,'CLim',CLim);
colorbar;
figure
imshow(RGB);
title('Merge');
