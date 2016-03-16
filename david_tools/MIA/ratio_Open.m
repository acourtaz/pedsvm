function ratio = ratio_Open(events)

nEvents = size(events,2);
ratio = zeros(1,nEvents);
N = 22; %time of opening
for i = 1:nEvents
    oTime = events(1,i)-1;
    if oTime > 8
        s = 4;
        
        while mod(N+oTime,4) ~= mod(N+s,4)
            s = s+1;
        end
ratio(i) = sum(events(N+oTime-3:N+oTime,i))/sum(events(N+s-3:N+s,i));
        X = (1:size(events,1)-1)-N+1;
        figure
        plot(X,events(2:end,i))
        hold on
        plot(s-3:s,events(N+s-3:N+s,i),...
            'linestyle','none','marker','o')
        plot(oTime-3:oTime,events(N+oTime-3:N+oTime,i),...
            'linestyle','none','marker','o')
        text(50,50,num2str(ratio(i)))
        hold off
        
    end
end