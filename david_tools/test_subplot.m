figure('colormap',gray(256))

subplot(1,2,1)
a = magic(11);
image(a,'cdatamapping','scaled','tag','left')
set(gca,'tag','leftAxis')
axis square
line('xdata',5,'ydata',6,'linestyle','none',...
        'marker','+','markerEdgeColor','green')
%set(gca,'clim',[low,high],'tag','moviaxis','userdata',Mini)
b = rand(11);
subplot(1,2,2)
image(b,'cdatamapping','scaled','tag','left')
set(gca,'tag','rightAxis')
axis square
line('xdata',5,'ydata',6,'linestyle','none',...
        'marker','+','markerEdgeColor','red')
axes(findobj('tag','leftAxis'))
line('xdata',2,'ydata',2,'linestyle','none',...
        'marker','+','markerEdgeColor','green')
axes(findobj('tag','rightAxis'))
line('xdata',8,'ydata',5,'linestyle','none',...
        'marker','o','markerEdgeColor','red')