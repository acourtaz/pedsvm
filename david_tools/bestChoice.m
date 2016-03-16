function best = bestChoice(trials,choices)

best = cell(1,2);
happyLists = CalcHappy(choices);
for i=1:trials
    happyLists = cat(1,happyLists,CalcHappy(choices));
end
[u,start] = max(sum(happyLists,2));
best{1} = u;
best{2} = happyLists(start,:);

%to emulate lists from the bestChoice result (bc), use
%ranks = 6 - bc{2};
%for i=1:size(choices,1),binoms(i,1) = choices(i,ranks(i));end