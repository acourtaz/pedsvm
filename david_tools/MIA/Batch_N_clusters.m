for i = 1:20
    name = '036-2';
    f1 = [name,num2str(i),'.tif'];
    f2 = [name,num2str(i),'.rgn'];
    N_clusters(f1,f2)
end