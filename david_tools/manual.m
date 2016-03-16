functone = reshape(gauss3dfree([back_fit(1:5),back_fit(10:11)],xs,ys),size(small_average));
functtwo = reshape(gauss3dfree([back_fit(1),back_fit(6:11)],xs,ys),size(small_average));
twofunct = reshape(twogauss3dfree(back_fit,xs,ys),size(small_average));
res = sum(sum((twofunct - small_average).^2))/(prod(size(twofunct))-1)
small_background = small_average - functone +back_fit(1);

figure
surf(small_average)
title(['Average Image from frames ',num2str(firstframe),' to ',num2str(lastframe)])
clim = get(gca,'clim');
zlim = get(gca,'zlim');
set(gca,'ydir','reverse','zlimmode','manual')
rotate3d on

figure
surf(twofunct)
title('Two Functions Fit to Average Image')
set(gca,'clim',clim,'ydir','reverse','zlim',zlim)
rotate3d on

figure
surf(functone)
title('Function Fit to the Important Granule')
set(gca,'clim',clim,'ydir','reverse','zlim',zlim)
rotate3d on

figure
surf(functtwo)
title('Function Fit the the Distracting Granule')
set(gca,'clim',clim,'ydir','reverse','zlim',zlim)
rotate3d on

figure
surf(small_background)
title('Background')
set(gca,'clim',clim,'ydir','reverse','zlim',zlim)
rotate3d on
back_fit
