%To pool all the randomized dataset for distance to synapse
%Put all the 'XXX_dist.trc' and 'XXX_rnd.txt' files in a single folder
%and run the script from this folder

cSyn = 2;
list_files = dir;
poolRnd = [];
poolDist = [];
for i = 1:size(list_files,1)
    f = list_files(i).name;
    isrnd = ~isempty(strfind(f,'rnd'));
    isdist = ~isempty(strfind(f,'dist'));
    if isrnd
        valRnd = dlmread(f,'\t');
        poolRnd = cat(1,valRnd,poolRnd);
    end
    if isdist
        valDist = dlmread(f,'\t');
        poolDist = cat(1,valDist(:,end),poolDist);
    end
end
nEv = size(poolRnd,1);
poolRnd = sort(poolRnd,1);
pRnd = prctile(valRnd,[5,50,95],2);
meanRnd = mean(valRnd,2);
Xval = 1/nEv:1/nEv:1;

h2 = figure('name','pooled cells Rnd DistSyn');
    hold on
    plot(pRnd(:,1),Xval,'k')
    hl50 = plot(pRnd(:,2),Xval,'k');
    plot(pRnd(:,3),Xval,'k')
    line([cSyn cSyn],ylim)    
    hlav = plot(meanRnd,Xval,'b');
    %hlmsk = plot(sDistSyn,1/pixMask:1/pixMask:1,'c');
    hlev = plot(poolDist,Xval,'r','linewidth',2);
    %legend([hl50,hlav,hlmsk,hlev],'95confid','average','mask','events')
    legend([hl50,hlav,hlev],'95confid','average','events')
    xlabel('distance from synapse')
    ylabel('fraction events')
    hold off
    cumulPool = cat(2,Xval',poolDist,meanRnd,pRnd);
    
    dlmwrite(cumulPool,'PooledRnd.txt')
    
    
    
    