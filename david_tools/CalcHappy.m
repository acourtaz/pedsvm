function happy = CalcHappy(choices)

%Calculates a possibility of project choices for EScube students
%choices is the NxC matrix of N students with their C choices
%To be used by bestChoice.m

seed = randperm(24);
project = zeros(12,2);
happy = zeros(1,24);
for i=1:24
    j=1;
    while j<6
        p = choices(seed(i),j);
        if project(p,1)==0
            project(p,1)=seed(i);break
        elseif project(p,2)==0
            project(p,2)=seed(i);break
        end
        j=j+1;
    end
    happy(seed(i))=6-j;
end

