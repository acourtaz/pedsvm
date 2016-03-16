function [ labels ] = loadLabels( action )
%LOADLABELS Summary of this function goes here
%   Detailed explanation goes here

if nargin == 0
[all, alld] = uigetfile('*.trc','Load all events matrix');
 if ~all,return,end
 allEvents = dlmread([alld,all],'\t');

[cln, clnd] = uigetfile('*.trc','Load clean events matrix');
 if ~cln,return,end
 clnEvents = dlmread([clnd,cln],'\t');

allID = unique(allEvents(:,1));
clnID = unique(clnEvents(:,1));

labels = ismember(allID, clnID);
 
end


end

