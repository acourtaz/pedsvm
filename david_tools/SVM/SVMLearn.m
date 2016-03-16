function [] = SVMLearn()
%SVMLEARN Summary of this function goes here
%   Detailed explanation goes here
    [labels, datas] = loadDatas();
    datas = single(datas);
    SVMModel = fitcsvm(datas, labels);
    uisave('SVMModel');


end

