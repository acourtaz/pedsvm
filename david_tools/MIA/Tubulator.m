list_file = dir;
broot = cd;

for i = 3:size(list_file,1)
    if list_file(i).isdir
        cd([broot,'\',list_file(i).name])
    
    list2 = dir;
    isanno = 0; isG = 0; isR = 0; isMask = 0; isBack = 0;
    for j = 1:size(list2,1)
        l2n = list2(j).name;
        isanno = ~isempty(strfind(l2n,'annotate'));
        isG = (~isempty(strfind(l2n,'TfR')))&(~isempty(strfind(l2n,'.stk')));
        isR = isempty(strfind(l2n,'TfR'))&(~isempty(strfind(l2n,'.stk')));
        isMask = ~isempty(strfind(l2n,'mask'));
        isBack = ~isempty(strfind(l2n,'rgn'));
        if isanno
            jAnno = j;
        end
        if isG
            jG = j;
        end
        if isR
            jR = j;
        end
        if isMask
            jM = j;
        end
        if isBack
            jB = j;
        end 
    end
    
    fAnno = list2(jAnno).name;
    fG = list2(jG).name;
    fR = list2(jR).name;
    fM = list2(jM).name;
    fB = list2(jB).name;
    
    fluoTubuPool(fAnno,fG,fR,fM,fB)
    cd ..
    end
end