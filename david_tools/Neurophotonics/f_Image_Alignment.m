function [I_Align,shiftx,shifty] = f_Image_Alignment (I1,I2)
% [RegIm,RegIm2] = StackAlignment (inStack,inStack2,inSave)

% STACKALIGNMENT aligns all images of a stack with the second one as a
% reference.
    %STACKALIGNMENT(inStack,inSave) uses DFTREGISTRATION (see Manuel Guizar-Sicairos, Samuel T. Thurman, and James R. Fienup, 
    % "Efficient subpixel image registration algorithms," Opt. Lett. 33,
    % 156-158 (2008)) to align the image stack inStack.

%     nbImages = numel(inStack);
    for k = 1%:nbImages
    %     [shifts(k,:),Greg(k).data] = dftregistration(fft2(double(inStack(2).data)),fft2(double(inStack(k).data)));
    %     RegIm(k).data = uint16(abs(ifft2(Greg(k).data)));
        [shifts(k,:)] = dftregistration(fft2(double(I1)),fft2(double(I2)));
        img = I2; 
%         img2 = I; 
        shiftx = -1*shifts(k,4);
        shifty = -1*shifts(k,3);   

        %%%%%% shift routine
        s = size(img);
        %Left/right
        img = img(:,mod((1:s(2))+s(2)+shiftx,s(2))+1);
%         img2 = img2(:,mod((1:s(2))+s(2)+shiftx,s(2))+1);
        %Up/Down
        I_Align= img(mod((1:s(1))+s(1)+shifty,s(1))+1,:);
%         RegIm2(k).data = img2(mod((1:s(1))+s(1)+shifty,s(1))+1,:);
        %%%%%%
    end
    
end
