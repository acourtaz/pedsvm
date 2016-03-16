function result = compareEvents(Ev1,Ev2)

common = 0;
for i=1:size(Ev1,1)
    A = max(Ev2==Ev1(i));
    if A>0
        common = common+1;
    end
end
only1 = size(Ev1,1)-common;
only2 = size(Ev2,1)-common;
result = [common only1 only2];

