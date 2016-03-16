function davidtwofit(action)

if nargin == 0
   [m,mp] = uigetfile('*.*','Choose a Movie(.stk)');
   if ~m,return,end
   if strcmp(m(end-2:end),'stk')
      M = stkread(m,mp);
   else,return
   end
   i = 1;
   f = figure;
   big = size(M);
   map = gray(256);
   title(strcat('Frame # =',num2str(i)))
   uicontrol('callback','davidtwofit fullforward','string','Play Forward','position',[125,5,80,20]);
   uicontrol('callback','davidtwofit fullbackward','string','Play Backward','position',[45,5,80,20]);
   high = double(max(max(max(M))));
   low = double(min(min(min(M))));
   
   uicontrol('style','slider',...
      'callback','davidtwofit scale',...
      'min',low,'max',high-3,...
      'value',min(min(min(M))),...
      'sliderstep',[1/(high-3-low),5/(high-3-low)],...
      'position',[240,15,140,10],'tag','scalelow')
   uicontrol('style','text','position',[210,15,30,15],'tag','low_text','fontsize',...
      5)
   
   uicontrol('style','slider',...
      'callback','davidtwofit scale',...
      'min',low+3,'max',high,...
      'value',high,...
      'sliderstep',[1/(high-(low+3)),5/(high-(low+3))],...
      'position',[380,15,140,10],'tag','scalehigh')
   uicontrol('style','text','position',[520,15,30,15],'tag','high_text','fontsize',...
      5)
   
   uicontrol('callback','davidtwofit goto','string','frame#','style','slider',...
      'position',[230,5,300,10],...
      'max',big(3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(big(3)-1),25/(big(3)-1)],'tag','frame#');
   uicontrol('string','Stop','callback','cjtimealign halt','position',[125,25,80,20])

   uicontrol('String','Select Center','callback','davidtwofit activate','style','toggle',...
      'position',[45,25,80,20])
   
   set(gcf,'UserData',M,'keypressfcn','davidtwofit key','doublebuffer','on'...
      ,'colormap',map)
   u = image(M(:,:,i),'cdatamapping','scaled','tag','movi');
   set(gca,'clim',[low,high])
   mzoom on
   axis image
   pixvalm
   scale
   goto
else
   eval(action)
   figure(gcf)
end

function scale
low = round(get(findobj(get(gcf,'children'),'tag','scalelow'),'value'));
high = round(get(findobj(get(gcf,'children'),'tag','scalehigh'),'value'));
minlow = get(findobj(get(gcf,'children'),'tag','scalelow'),'min');
maxhigh = get(findobj(get(gcf,'children'),'tag','scalehigh'),'max');
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end


set(gca,'clim',[low,high])
set(findobj(get(gcf,'children'),'tag','scalelow'),'max',high-1,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
   'value',low)
set(findobj(get(gcf,'children'),'tag','low_text'),'string',num2str(low));
set(findobj(get(gcf,'children'),'tag','scalehigh'),'min',low+1,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
   'value',high)
set(findobj(get(gcf,'children'),'tag','high_text'),'string',num2str(high));


function goto
M = get(gcf,'userdata');
i = round(get(findobj(get(gcf,'children'),'tag','frame#'),'value'));
global stop
stop = 1;
img = M(:,:,i);
set(findobj(get(gcf,'children'),'type','image'),'cdata',img)
title(strcat('Frame # =',num2str(i)))

function fullbackward
M = get(gcf,'userdata');
i = round(get(findobj(get(gcf,'children'),'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(M,3);
for j = i:-1:1
   if stop
      j = get(findobj(get(gcf,'children'),'tag','frame#'),'value');
      break
   end
   set(findobj(get(gcf,'children'),'type','image'),'cdata',M(:,:,j))
   set(findobj(get(gcf,'children'),'tag','frame#'),'value',j)
   drawnow
end
goto

function fullforward
M = get(gcf,'userdata');
i = round(get(findobj(get(gcf,'children'),'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(M,3);
for j = i:nframes
   if stop
      j = get(findobj(get(gcf,'children'),'tag','frame#'),'value');
      break
   end
   set(findobj(get(gcf,'children'),'type','image'),'cdata',M(:,:,j))
   set(findobj(get(gcf,'children'),'tag','frame#'),'value',j)
   drawnow
end
goto

function key
M = get(gcf,'userdata');
i = round(get(findobj(get(gcf,'children'),'tag','frame#'),'value'));
global stop
stop = 1;
if get(gcf,'currentcharacter') == '.'
   if i < size(M,3)
      i = i+1;
   end
end
if get(gcf,'currentcharacter') == ','
   if i>1
      i = i-1;
   end
end
goto

function halt
goto

function activate

if ~get(gcbo,'value')
   mzoom on
   pixvalm on
end

if get(gcbo,'value')
   pixvalm off
   mzoom off
   set(findobj('tag','movi'),'buttondownfcn','davidtwofit gofit')
end

function gofit
small_dim = 15;
large_dim = 25;
options = optimset(optimset('lsqnonlin'),'largescale','off',...
   'linesearchtype','cubicpoly','display','off','derivativecheck','off',...
   'maxiter',150,'tolfun',.1,'tolx',1e-3,'jacobian','on','diagnostics','off');

M = get(gcf,'userdata');
nframes = size(M,3);

current_point = round(get(gca,'currentpoint')');
[x,y] = deal(current_point(1),current_point(2));
backsub_file = 0;
background_file = 0;
small_background = zeros(2*small_dim+1,2*small_dim+1);
large_background = zeros(2*large_dim+1,2*large_dim+1);
[xl,xld] = uiputfile('*.xls','Save an Excell file output?');
sub_back = 1 == menu('Subtract Background?','Yes','No');
scan = 1 == menu('Compute Linescans','Yes','No');
if sub_back
   [backsub_file,backsub_dir] = uiputfile('*.stk','Save the Background Subtracted Movie?');
   from_file = 1 == menu('What Background?','Use an old one',...
      'Create a new one');
   if from_file
      [backfile,backfiled] = uigetfile('*.mat','Where is the old Background');
      temp = load([backfiled,backfile]);
      small_background = temp.small_background;
      large_background = temp.large_background;
      x = temp.x;
      y = temp.y;
   else
      [background_file,background_dir] = uiputfile('*.mat','Save the background for Matlab to use latter?');
      prompt = {'First Frame','Last Frame'};
      answer = inputdlg(prompt,'Compute Background From Which Frames');
      [firstframe,lastframe] = deal(answer{:});
      firstframe = str2num(firstframe);
      lastframe = str2num(lastframe);
      small_average = zeros(2*small_dim+1,2*small_dim+1);
      large_average = zeros(2*large_dim+1,2*large_dim+1);
      for i = firstframe:lastframe
         small = double(M(y-small_dim:y+small_dim,x-small_dim:x+small_dim,i));
         large = double(M(y-large_dim:y+large_dim,x-large_dim:x+large_dim,i));
         small_average = small_average + small;
         large_average = large_average + large;
      end
      small_average = small_average/length(firstframe:lastframe);
      large_average = large_average/length(firstframe:lastframe);
      
      figure('colormap',gray(256))
      im = imagesc(small_average);
      axis image
      pixvalm
      set(im,'buttondownfcn','uiresume')
      title('Click on the center of the distracting granule')
      uiwait
      center = floor((size(small_background,1)+1)/2);
      current_point = round(get(gca,'currentpoint')');
      [center2x,center2y] = deal(current_point(1),current_point(2));
      
      X0 = [min(min(small_average)),small_average(center,center)-min(min(small_average)),center,center,1.5,...
            small_average(center2y,center2x)-min(min(small_average)),center2x,center2y,1.5,0,0];
      [xs,ys] = meshgrid(1:size(small_background,1));
      back_fit = lsqnonlin('twogauss3dfree',X0,[],[],options,xs,ys,small_average);
      functone = reshape(gauss3dfree([back_fit(1:5),back_fit(10:11)],xs,ys),size(small_average));
      functtwo = reshape(gauss3dfree([back_fit(1),back_fit(6:11)],xs,ys),size(small_average));
      twofunct = reshape(twogauss3dfree(back_fit,xs,ys),size(small_average));
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
      
      if menu('Continue?','Yes','No')==2,return,end
      
      [xs,ys] = meshgrid(1:size(large_average,1));
      dif = large_dim-small_dim;
      funct = reshape(gauss3dfree([back_fit(1:5),back_fit(10:11)]+[0 0 dif dif 0 0 0],xs,ys),size(large_average));
      large_background = large_average-funct+back_fit(1);
      
   end
end
small_backsub = zeros(2*small_dim+1,2*small_dim+1);
large_backsub = zeros(2*large_dim+1,2*large_dim+1);
for i = 1:size(M,3)
   small = double(M(y-small_dim:y+small_dim,x-small_dim:x+small_dim,i));
   small_backsub(:,:,i) = small-small_background;
   large = double(M(y-large_dim:y+large_dim,x-large_dim:x+large_dim,i));
   large_backsub(:,:,i) = large-large_background;
end
fits = zeros(nframes,7);
disp('Fitting...')
for i = 1:nframes
   disp(['Frame ',num2str(i)])
   fits(i,:) = fit(small_backsub(:,:,i),options);
end
if xl&scan
   disp('Computing Linescans')
   scans = zeros(nframes,16);
   stdscans = scans;
   for i = 1:nframes
      disp(['Frame ',num2str(i)])
      if fits(i,3:4)+10-small_dim>=0&fits(i,3:4)+10+small_dim<=2*large_dim+1
         [scans(i,:),stdscans(i,:)] = linescan(large_backsub(:,:,i),fits(i,3:4)+10,small_dim);
      end
   end
   scan_result = cell(nframes+1,small_dim+2);
   stdscan_result = cell(nframes+1,small_dim+2);
   scans = num2cell(scans);
   stdscans = num2cell(stdscans);
   title2 = {'Frame','Radius 0','Radius 1', '2','3','4','5','6','7','8','9',...
         '10','11','12','13','14','15'};
   [scan_result{1,:}] = deal(title2{:});
   [stdscan_result{1,:}] = deal(title2{:});
   [scan_result{2:end,1}] = deal(frames{:});
   [scan_result{2:end,1}] = deal(frames{:});
   [scan_result{2:end,1}] = deal(frames{:});
   [stdscan_result{2:end,1}] = deal(frames{:});
   [scan_result{2:end,2:end}] = deal(scans{:});
   [stdscan_result{2:end,2:end}] = deal(stdscans{:});
end

   
fits(:,3) = x+fits(:,3)-small_dim+1;
fits(:,4) = y+fits(:,4)-small_dim+1;
title = {'Frame','Base','Amplitude','Center x','Center y','Width','xslope','yslope','FWHM'};
result = cell(nframes+1,9);
[result{1,:}] = deal(title{:});
frames = num2cell(1:nframes);
[result{2:end,1}] = deal(frames{:});
FWHM = num2cell(2*sqrt(2*log(2))*fits(:,5));
fits = num2cell(fits);
[result{2:end,2:8}] = deal(fits{:});
[result{2:end,9}] = deal(FWHM{:});

if xl&scan
   hsheet = get(hworkbook.worksheets,'item',2);
   topleft = get(hsheet,'cells',1,1);
   bottomright = get(hsheet,'cells',size(scan_result,1),size(scan_result,2));
   hrange = get(hsheet,'range',topleft,bottomright);
   hrange.value = scan_result;
   hcols = get(hsheet,'columns');
   invoke(hcols,'autofit');
   hsheet.name = 'Linescans';
   
   hsheet = get(hworkbook.worksheets,'item',3);
   topleft = get(hsheet,'cells',1,1);
   bottomright = get(hsheet,'cells',size(stdscan_result,1),size(stdscan_result,2));
   hrange = get(hsheet,'range',topleft,bottomright);
   hrange.value = stdscan_result;
   hcols = get(hsheet,'columns');
   invoke(hcols,'autofit');
   hsheet.name = 'Std Error';
end

if xl
   
   if size(xl,2)<=4
      xl = [xl,'.xls'];
   end
   if ~strcmp(xl(end-3),'.')
      xl = [xl,'.xls'];
   end
   fid = fopen([xld,xl]);
   if fid~=-1
      fclose(fid);
      delete([xld,xl]);
   end
   
   hexcel = actxserver('Excel.Application');
   hworkbook = hexcel.workbooks.add;
   
   hsheet = get(hworkbook.worksheets,'item',1);
   topleft = get(hsheet,'cells',1,1);
   bottomright = get(hsheet,'cells',size(result,1),size(result,2));
   hrange = get(hsheet,'range',topleft,bottomright);
   hrange.value = result;
   hcols = get(hsheet,'columns');
   invoke(hcols,'autofit');
   hsheet.name = 'Fits';
   
      
   invoke(hworkbook,'saveas',[xld,xl]);
   invoke(hworkbook,'close');
   invoke(hexcel,'quit');
   delete(hexcel);
end

if background_file
   save([background_dir,background_file],'x','y','small_background','large_background');
end
if backsub_file
   stkwrite(uint16(cat(3,large_backsub,large_background)),backsub_file,backsub_dir);
end
disp('Done')

function [param,res] = fit(img,options)
center = floor((size(img,1)+1)/2);
X0 = [min(min(img)),max(max(img))-min(min(img)),center,center,1.5,0,0];
[x,y] = meshgrid(1:size(img,1));
[param,res] = lsqnonlin('gauss3dfree',X0,[],[],options,x,y,img);
