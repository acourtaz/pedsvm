function result = seqfindext (Image, ImagePar, Opts,typefile,waitbarhandle)
% function result = seqfindext (Image, ImagePar, Opts,typefile,waitbarhandle)
% calculate the position of dyes for a sequence of CCD-shots
% Image   -    ASCII-image file
% ImagePar : size of the image
% Opts -(o) see detectpar
% typefile: .spe or .stk
% waitbarhandle: to actualize waitbar
% output: result - # of found peaks
% modify from seqfind.m by MR (mar 06) for gaussiantrack.m
% called by doseq.ext
%--------------------------------------------------------------------------

result = [];
  %load image from file given 
  nX     = ImagePar(3);
  nY     = ImagePar(4);
  ImagePar(5)=1;
  nP     = ImagePar(5);
  Xsize  = ImagePar(1)/nX;
  Ysize  = ImagePar(2)/nY;
  SeqLen = nY;
firstY=1;
lastY=Ysize;
%------------------------------------------------
%loop through the images
%for iX=1:nX
   %for iP=1:nP
      for iY=1:nY

         %NoImage = [iX,iY,iP];
         if exist('waitbarhandle')
            waitbar(iY/nY,waitbarhandle,['Frame # ',num2str(iY)]);
        end
         if typefile ==0
            SubImage  = Image ((firstY:lastY),:);
            firstY=lastY+1;
            lastY=lastY+Ysize;

           % SubImage  = getsub (iX,iY,iP,Image,ImagePar);
        else
            SubImage = (Image(:,:,iY));
        end
         r         = findpeakext (SubImage, Opts);
         if size(r)>0
            %nI     = ((iX-1+iP-1)*nY+iY) * ones(size(r,1),1);
            nI     = iY * ones(size(r,1),1);
            r      = [nI,r];
            result = [result;r];
         end
         %end
      %end
end

%-------------------------------------------------

