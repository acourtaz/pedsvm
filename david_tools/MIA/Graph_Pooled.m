scrsz = get(0,'ScreenSize');
figure('name','Pooled B2R Wash',...
    'position',[scrsz(3)-1100 scrsz(4)-400 1000 300])
subplot(1,3,1)
errorbar(B2R7_time,B2R7_av,B2R7_sem,'-o','color',[0 0.7 0],'markerfacecolor',[0 0.7 0])
hold on
plot(B2R7_time,high7,'k','linewidth',2)
plot(B2R7_time,median7,'k')
plot(B2R7_time,low7,'k','linewidth',2)
line([0 0],ylim)
hold off

subplot(1,3,2)
errorbar(B2R5_time,B2R5_av,B2R5_sem,'-og','markerfacecolor','g')
hold on
plot(B2R5_time,high5,'k','linewidth',2)
plot(B2R5_time,median5,'k')
plot(B2R5_time,low5,'k','linewidth',2)
line([0 0],ylim)
hold off

subplot(1,3,3)
errorbar(CLC_time,CLC_av,CLC_sem,'-or','markerfacecolor','r')
hold on
plot(CLC_time,highR,'k','linewidth',2)
plot(CLC_time,medianR,'k')
plot(CLC_time,lowR,'k','linewidth',2)
line([0 0],ylim)
hold off

[frand,prand] = uiputfile('Pooled_B2R_Wash2.fig',...
    'save figure');
if ischar(frand)&& ischar(prand)
    saveas(gcf,[prand,frand])
end