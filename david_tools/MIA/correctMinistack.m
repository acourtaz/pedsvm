function correctMinistack

%Interleaves red5 and red7 ministacks and corrects for bleedthrough from
%TfR5 and TfR7 ministacks

[stkR5,stkd] = uigetfile('*.stk','Choose the red ministack (pH 5)');
if ~stkR5,return,end
Red5 = stkread(stkR5,stkd);

ev = max(strfind(stkR5,'_'));

stkR7 = [stkR5(1:ev-2),'7',stkR5(ev:end)];
%[stkR7,stkdR7] = uigetfile('*.stk','Choose the red ministack (pH 7)');
%if ~stkR7,return,end
Red7 = stkread(stkR7,stkd);

stkG5 = [stkR5(1:ev-5),'TfR5',stkR5(ev:end)];
%[stkG5,stkdG5] = uigetfile('*.stk','Choose the TfR (green) ministack (pH 5)');
%if ~stkG5,return,end
TfR5 = stkread(stkG5,stkd);

stkG7 = [stkR5(1:ev-5),'TfR7',stkR5(ev:end)];
%[stkG7,stkdG7] = uigetfile('*.stk','Choose the TfR (green) ministack (pH 7)');
%if ~stkG7,return,end
TfR7 = stkread(stkG7,stkd);

if (~isequal(size(Red5),size(TfR5)))||(~isequal(size(Red7),size(TfR7)))
    error('ministacks must have the same size and frame number')
end

first_pH = 7;
bleed = 0.032;

defaults = {first_pH,bleed};
prompt = {'pH of the first frame (7 or 5)','bleed-through coefficient'};
[first_pH,bleed] = numinputdlg(prompt,'',1,defaults);

if first_pH ~= 5 && first_pH ~= 7
    error('first pH value has to be 7 or 5')
end

Red5 = double(Red5);
Red7 = double(Red7);
TfR5 = double(TfR5);
TfR7 = double(TfR7);

frameRed = size(Red5,3) + size(Red7,3);
Red = zeros(size(Red5,1),size(Red5,2),frameRed);

if first_pH == 7
    Red(:,:,1:2:end) = Red7 - bleed.*TfR7;
    Red(:,:,2:2:end) = Red5 - bleed.*TfR5;
elseif first_pH == 5
    Red(:,:,1:2:end) = Red5 - bleed.*TfR5;
    Red(:,:,2:2:end) = Red7 - bleed.*TfR7;
end

Red = uint16(Red);

[stkR,stkd] = uiputfile([stkR5(1:ev-2),'Corr',stkR5(ev:end)],...
    'name of the corrected ministack');

if ischar(stkR)&&ischar(stkd)
    stkwrite(Red,stkR,stkd);
end