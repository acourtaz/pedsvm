function partialQuench(action)

[stk5,stkd5] = uigetfile('*.stk','Stack of events (TfR5)');
if ~stk5,return,end
[stk7,stkd7] = uigetfile('*.stk','Stack of clusters (TfR7)');
if ~stk7,return,end
q = numinputdlg('coefficient for partial quenching (0 full quench, 1 no quench)',...
    'Quenching coefficient',1,0.1);

m5 = stkread(stk5,stkd5);
m7 = stkread(stk7,stkd7);

mo = zeros(size(m5));

mo(:,:,1) = m5(:,:,1)-q*m7(:,:,1);
for i = 2:size(m5,3)
    mo(:,:,i) = m5(:,:,i) - (q/2)*(m7(:,:,i-1)+m7(:,:,i));
end

mo = uint16(mo);
pause(0.1)
[f,p] = uiputfile([stk5(1:end-4),'q',num2str(q*10),'.stk'],'new pH5 file');
if ischar(f) && ischar(p)
    stkwrite(mo,f,p)
end