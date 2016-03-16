function happy = CalcBIC(choices)

%Calculates a possibility of BIC demo choices for EScube students
%choices is the NxC matrix of N students with their C choices
%To be used by bestBIC.m

seed = randperm(24);
TP1 = zeros(5,5);
TP2 = zeros(5,5);
happy = zeros(2,24);
for i=1:24
    j=1;
    while j<6
        p = choices(seed(i),j);
        if TP1(p,1)==0
            TP1(p,1)=seed(i);break
        elseif TP1(p,2)==0
            TP1(p,2)=seed(i);break
        elseif TP1(p,3)==0
            TP1(p,3)=seed(i);break
        elseif TP1(p,4)==0
            TP1(p,4)=seed(i);break
        elseif TP1(p,5)==0
            TP1(p,5)=seed(i);break
        end
        j=j+1;
    end
    happy(1,seed(i))=6-j;
end
for i=24:-1:1 %Reverses the order of priority for students in TP2
    j=1;
    while j<6
        p = choices(seed(i),j);
        uhu = ~max(TP1(p,:)==seed(i)); 
        %Tests if already given in TP1: 0 if not yet, 1 if yes
        if TP2(p,1)==0 && uhu
            TP2(p,1)=seed(i);break
        elseif TP2(p,2)==0 && uhu
            TP2(p,2)=seed(i);break
        elseif TP2(p,3)==0 && uhu
            TP2(p,3)=seed(i);break
        elseif TP2(p,4)==0 && uhu
            TP2(p,4)=seed(i);break
        elseif TP2(p,5)==0 && uhu
            TP2(p,5)=seed(i);break
        end
        j=j+1;
    end
    happy(2,seed(i))=6-j;
    end
%TP1
%TP2
%sum(sum(happy))