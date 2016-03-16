function CCPtoPax

%Written by DP to analyse the colocalisation CCPs Paxilin in cells treated
%with nocodazole. Data obtained on confocal, thresholded with MIA. For each
%cell, there are three images:
%1. Paxilin clusters (MIA image)
%2. CCPs (MIA image)
%3. mask (painted image, after Metamorph thresholding, value 65000)

list_file = dir;
broot = cd;

for i = 3:size(list_file,1)
    if list_file(i).isdir
        cd([broot,'\',list_file(i).name]) %Goes to the daughter folder
        l2 = dir;
        
    end
end