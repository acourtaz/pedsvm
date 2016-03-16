function paxiClath

%To quantify the number of adhesion zones (paxillin spots) and CCPs in
%cells treated with nocodazole + washout

pax = 'CSU 635';
clc = 'CSU 473';
list_files = dir;
file_done = zeros(size(list_files,1));
for i = 1:size(list_files,1)
    f = list_files(i).name;
    
end