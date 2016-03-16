function foutput = simulRandom(mask);

% Script for generating a simulation of random dots
% Calculates the Ripley K function
% Written by DP 14/9/05
foutput = [];
for h = 1:5
    c = clock;
    rand('state',sum(100*c(6)));
    simul = zeros(size(mask));
    output = [];
    for i=1:1780
        a = round((size(mask,1)-1)*rand)+1;
        b = round((size(mask,2)-1)*rand)+1;
    %c=rand;
        simul(a,b) = simul(a,b)+1;
    end
    simul = mask.*simul;
    [u,v,f]=find(simul);
    [x,y] = meshgrid(1:size(mask,2),1:size(mask,1));
    for i=1:size(u,1)
        line = zeros(1,50);
        for j=1:f(i)
          distance = sqrt((x-v(i)).^2 + (y-u(i)).^2);
          for k=1:50
              circle = distance <= k;
              line(k) = sum(sum(simul.*circle))-1;
          end
          output = cat(1,output,line);
        end
    end
    h
    clear simul
    foutput = cat(1,foutput,mean(output));
end