function eventFrequency(varargin)

%Determines the event cumulative and overall frequency 
%from .trc and .txt files

if nargin == 0
    [f1,p1] = uigetfile('*.txt;*.trc','First file with matrix of events');
    if ~f1,return,end
    ev1 = dlmread([p1,f1],'\t');
    prompt = {'Number of frames','Frame interval (in s)',...
        'Frames discarded at the beginning','Frames discarded at the end'};
    [Nf1 F_inter frb1 fra1] = ...
        numinputdlg(prompt,'Parameters for first file',1,[85 4 5 5]);
    p1 = [Nf1 F_inter frb1 fra1];
    %f2 =[];
    [f2,p2] = uigetfile('*.txt;*.trc','Second file with matrix of events');
    if f2 ~= 0
        ev2 = dlmread([p2,f2],'\t');
        [Nf2 F_inter frb2 fra2] = ...
            numinputdlg(prompt,'Parameters for second file',1,[165 4 5 5]);
        p2 = [Nf2 F_inter frb2 fra2];
    end
elseif nargin ==1
    ev1 = dlmread(varargin{1},'\t');
    p1 = [85 4 5 5];
elseif nargin == 5
    f = varargin{1};
    ev1 = dlmread(f,'\t');
    p1 = cell2mat(varargin(2:5));
end
%if strcmp(f(end-3:end),'.txt')
%end

%Recreates an array of events with frame start only, like in annotate.txt files
if strcmp(f1(end-3:end),'.trc')
    firstEvent = round(ev1(2,1));
    lastEvent = round(ev1(end,1));
    evFr1 = [];
    for i=firstEvent:lastEvent
        eventTrack = (ev1(:,1)==i);
        [u,start] = max(eventTrack);
        if u
            evFr1 = [evFr1;ev1(start,1:2)];
        end
    end
elseif strcmp(f1(end-3:end),'.txt')
    evFr1 = ev1(:,1:2);
end

if f2 ~= 0
    if strcmp(f2(end-3:end),'.trc')
    firstEvent = round(ev2(2,1));
    lastEvent = round(ev2(end,1));
    evFr2 = [];
        for i=firstEvent:lastEvent
            eventTrack = (ev2(:,1)==i);
            [u,start] = max(eventTrack);
            if u
                evFr2 = [evFr2;ev2(start,1:2)];
            end
        end
    elseif strcmp(f2(end-3:end),'.txt')
    evFr2 = ev2(:,1:2);
    end
end

TF1 = p1(2)/60;
totalTime1 = (p1(1)-p1(3)-p1(4))*TF1;
freq_min1 = size(evFr1,1)/totalTime1;
disp(['Frequency file 1: ',num2str(freq_min1),' ev/min'])
if f2 ~= 0
    TF2 = p2(2)/60;
    totalTime2 = (p2(1)-p2(3)-p2(4))*TF2;
    freq_min2 = size(evFr2,1)/totalTime2;
    disp(['Frequency file 2: ',num2str(freq_min2),' ev/min'])
end

h_freq = figure('name',['Freq ',f1]);
plot(evFr1(:,2).*TF1,1:size(evFr1,1),'color','r','linewidth',2)
if f2 ~= 0
    hold on
    plot(evFr2(:,2).*TF2,1:size(evFr2,1),'color','b','linewidth',2)
end
xlabel('time (min)')
ylabel('# events')
xo = xlim;
yo = ylim;
text((xo(2)-xo(1))*0.1,(yo(2)-yo(1))*0.9,['f1 = ',num2str(freq_min1),' ev/min'])
if f2 ~= 0
    text((xo(2)-xo(1))*0.1,(yo(2)-yo(1))*0.8,['f2 = ',num2str(freq_min2),' ev/min'])
end

c = strfind(f1,'_');
if isempty(c)
    c = 5;
else c = c(1)-1;
end
cellNum = num2str(f1(1:c));

[ffreq,pfreq] = uiputfile([cellNum,'_freq.fig'],'save figure');
if ischar(ffreq)&& ischar(pfreq)
    saveas(h_freq,[pfreq,ffreq])
end

%Makes histogram of frequency per minute
h_isto = figure('name',['Histo freq per min ',f1]);
bin1 = (0.5:(floor((p1(1)-p1(4))*TF1)+0.5));
n_ev1 = ((evFr1(:,2)-p1(3)).*TF1);
hist(n_ev1,bin1)
xlabel('time (min)')
ylabel('events/min')
set(findobj(gca,'type','patch'),'faceColor','r')

if f2 == 0
    [fhisto,phisto] = uiputfile([cellNum,'_histo.fig'],'save figure');
else 
    [fhisto,phisto] = uiputfile([cellNum,'_histo CA.fig'],'save figure');
end
if ischar(fhisto)&& ischar(phisto)
    saveas(h_isto,[phisto,fhisto])
end

if f2 ~= 0
    h_isto2 = figure('name',['Histo freq per min ',f2]);
    bin2 = (0.5:(floor((p2(1)-p2(4))*TF2)+0.5));
    n_ev2 = ((evFr2(:,2)-p2(3)).*TF2);
    hist(n_ev2,bin2)
    xlabel('time (min)')
    ylabel('events/min')
    
    [fhisto2,phisto2] = uiputfile([cellNum,'_histo WCR.fig'],'save figure');
    if ischar(fhisto2)&& ischar(phisto2)
        saveas(h_isto2,[phisto2,fhisto2])
    end
    
end

% gives mean of the last two minutes if recording longer than 10min

h1 = hist(n_ev1,bin1);
h1 = [bin1+1;h1];
S1 = size (h1,2);
if S1<3 
    disp('File 1 too short for histogramm analysis')
    m1_23 = -1;
    m1_89 = -1;
    m1_end = -1;
    h1(1,:) = h1(1,:)-0.5;
    h1 = num2cell(h1');
else
    m1_23 = (h1(2,2)+h1(2,3))/2; % mean of the 2nd and 3rd minutes
    if S1 > 6
        m1_end = (h1(2,(S1-2))+h1(2,(S1-1)))/2; % mean of the 2 last minutes
    else m1_end = -1;
    end
    
    if S1 > 9
        m1_89 = (h1(2,8)+h1(2,9))/2; % mean of the 8th and 9th minutes
    else m1_89 = -1;
    end
    h1(1,:) = h1(1,:)-0.5;
    h1 = num2cell(h1');
end


if f2 ~= 0
    h2 = hist(n_ev2,bin2);
    h2 = [bin2+1;h2];
    S2 = size(h2,2);
    if S2<3
        disp('File 2 too short for histogeamm analysis')
        m2_23 = -1;
        m2_89 = -1;
        m2_end = -1;
        h2(1,:) = h2(1,:)-0.5;
        h2 = num2cell(h2');
    else
        m2_23 = (h2(2,2)+h2(2,3))/2; % mean of the 2nd and 3rd minutes
        
        if S2 > 6
            m2_end = (h2(2,(S2-2))+h2(2,S2-1))/2; % mean of the 2 last minutes
        else m2_end = -1;
        end
        
        if S2 > 9
            m2_89 = (h2(2,8)+h2(2,9))/2; % mean of the 9th and 10th minutes
        else m2_89 = -1;
        end
        h2(1,:) = h2(1,:)-0.5;
        h2 = num2cell(h2');
    end
end

%%%

% Writes the cumulated frequency data  histogramm data in Excel file
evFr1 = [evFr1,n_ev1,(1:size(evFr1,1))'];
evFr1 = num2cell(evFr1);
Sev = max(size(h1,1),size(evFr1,1));
if size(h1,1) < Sev
    h1 = cat(1,h1,cell(Sev - size(h1,1),size(h1,2)));
elseif size(evFr1,1) < Sev
    evFr1 = cat(1,evFr1,cell(Sev - size(evFr1,1),size(evFr1,2)));
end
evFr1 = cat(2,evFr1, h1);

Header1 = cell(7,6);
Header1{1,1} = 'Frequency data';
Header1{1,5} = 'Frequency histo data';
Header1{2,1} = f1;
Header2 = Header1;
Header1{1,3} = date;
Header1(3,:) = {'# frames','interval (s)','fr_bef','fr_aft','',''};
Header1(4,:) = cat(2,num2cell(p1),cell(1,2));
Header1{5,1} = 'Mean frequency';
Header1{5,3} = freq_min1;
Header1(7,:) = {'# Event','frame','Rel time','cumulFreq','minute','ev/min'};
if m1_23 >= 0
    Header1{3,5} = '2-3 min';
    Header1{3,6} = m1_23;
else Header1{3,5} = 'recording too short';
end
if m1_end >= 0
    Header1{5,5} = [num2str(S1-2),'-',num2str(S1-1),' min'];
    Header1{5,6} = m1_end;
    if m1_89 >= 0
         Header1{4,5} = '8-9 min';
         Header1{4,6} = m1_89;
    end
end


totEv1 = cat(1,Header1,evFr1);

if f2~=0
    Header2{2,1} = f2;
    evFr2 = [evFr2,n_ev2,(1:size(evFr2,1))'];
    evFr2 = num2cell(evFr2);
    Sev = max(size(h2,1),size(evFr2,1));
    if size(h2,1) < Sev
        h2 = cat(1,h2,cell(Sev - size(h2,1),size(h2,2)));
    elseif size(evFr2,1) < Sev
       evFr2 = cat(1,evFr2,cell(Sev - size(evFr2,1),size(evFr2,2)));
    end
    evFr2 = cat(2,evFr2,h2);
    
    Header2(3,:) = {'# frames','interval (s)','fr_bef','fr_aft','',''};
    Header2(4,:) = cat(2,num2cell(p2),cell(1,2));
    Header2{5,1} = 'Mean frequency';
    Header2{5,3} = freq_min2;
    Header2(7,:) = {'# Event','frame','Rel time','cumulFreq','minute','ev/min'};
    if m2_23 >= 0
        Header2{3,5} = '2-3 min';
        Header2{3,6} = m2_23;
    else Header2{3,5} = 'recording too short';
    end
    if m2_end >= 0
       Header2{5,5} = [num2str(S2-2),'-', num2str(S2-1),' min'];
       Header2{5,6} = m2_end;
       if m2_89 >= 0
         Header2{4,5} = '8-9 min';
         Header2{4,6} = m2_89;
       end
    elseif m2_89 >= 0
       Header2{5,5} = '8-9 min';
       Header2{5,6} = m2_89;
    end
            
    totEv2 = cat(1,Header2,evFr2);
       
    Sev = max(size(totEv1,1),size(totEv2,1));
    if size(totEv1,1) < Sev
        totEv1 = cat(1,totEv1,cell(Sev - size(totEv1,1),size(totEv1,2)));
    elseif size(totEv2,1) < Sev
        totEv2 = cat(1,totEv2,cell(Sev - size(totEv2,1),size(totEv2,2)));
    end
    
    totEv = cat(2, totEv1, cell(Sev,1), totEv2);
    
else
    totEv = totEv1;
end

disp(['File 1: eventcount = ', num2str(size(evFr1,1))])
if m1_23 >= 0
        disp(['File 1, 2-3 min: ',num2str(m1_23),' ev/min'])
    if m1_89 >= 0
        disp(['File 1, 8-9 min: ', num2str(m1_89),' ev/min'])
    end
    if m1_end >= 0
        disp(['File 1, ', num2str(S1-2),'-', num2str(S1-1),' min: ',...
            num2str(m1_end),' ev/min'])
    end
end
disp(' ')

if f2~=0
    disp(['File 2: eventcount = ', num2str(size(evFr2,1))])
    if m2_23 >= 0
        disp(['File 2, 2-3 min: ',num2str(m2_23),' ev/min'])
    end
    if m2_89 >= 0
        disp(['File 2, 8-9 min: ', num2str(m2_89),' ev/min'])
    end
    if m2_end >= 0
        disp(['File 2, ', num2str(S2-2),'-', num2str(S2-1),' min: ',...
        num2str(m2_end),' ev/min'])
    end 
   
end

[fle,p1] = uiputfile([cellNum,'_freq.xlsx'],...
      'Where to put the frequency data file');

if ischar(fle) && ischar(p1)
   warning off MATLAB:xlswrite:AddSheet
   xlswrite([p1,fle],totEv,'Freq')
end
