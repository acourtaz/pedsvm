function newdavidfit(action)
if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose a Stack');
   if ~stk,return,end
   frame = 1;
   M = stkread(stk,stkd);
   figure
   map = gray(256);
   %controls specific to davidfit
   cd(stkd)
   uicontrol('String','Select Center','callback','newdavidfit activate','style','toggle',...
      'position',[67,15,80,15])
   uicontrol('String','Use Old Background','callback','newdavidfit gofit',...
      'position',[52,0,110,15],'tag','use_old')
   
   uicontrol('style','checkbox','position',[5,285,15,15],'tag','distract')
   uicontrol('style','text','string',{'Distracting','Granule?'},'position',[20,270,50,30])
   uicontrol('style','checkbox','position',[5,255,15,15],'tag','psf')
   uicontrol('style','text','string','Fit Psf','position',[20,255,50,15])
   
   uicontrol('style','text','string','Outputs:','position',[15,225 50,20],...
      'fontweight','bold')
   uicontrol('style','checkbox','position',[5,210,15,15],'tag','sbacksub','value',1)
   uicontrol('style','text','string',{'Background','Subtracted','Stack?'},'position',...
      [20,180,60,45])
   uicontrol('style','checkbox','position',[5,165,15,15],'tag','sbackground')
   uicontrol('style','text','string',{'Reusable','Background?'},'position',[20,150,65,30])
   uicontrol('style','checkbox','position',[5,135,15,15],'tag','sfits','value',1,...
      'callback','newdavidfit toggle_linescans')
   uicontrol('style','text','string','Fits?','position',[20,135,25,15])
   uicontrol('style','checkbox','position',[5,120,15,15],'tag','slinescans','value',1)
   uicontrol('style','text','string','Linescans?','position',[20,120,55,15])
   
   %controls inherited from play
   uicontrol('string','Stop','callback','newdavidfit goto','position',[40,30,45,15])
   %defines the stop button
   uicontrol('callback','newdavidfit fullforward','string',...
      'Play -->','position',[130,30,45,15])
   uicontrol('callback','newdavidfit fullbackward','string',...
      '<-- Play','position',[85,30,45,15])
   high = double(max(max(max(M(:,:,1:end-1)))));
   low = double(min(min(min(M(:,:,1:end-1)))));
   uicontrol('style','slider',...
      'callback','newdavidfit scale',...
      'min',low,'max',high-3,...
      'value',low,...
      'position',[240,15,315,15],'tag','scalelow')
   uicontrol('style','text','position',[210,15,30,15],'tag','low_text','fontsize',...
      5)
   uicontrol('style','text','position',[175,15,35,15],'string','Low')
   uicontrol('style','slider',...
      'callback','newdavidfit scale',...
      'min',low+3,'max',high,...
      'value',high,...
      'position',[240,30,315,15],'tag','scalehigh')
   uicontrol('style','text','position',[210,30,30,15],'tag','high_text','fontsize',...
      5)
   uicontrol('style','text','position',[175,30,35,15],'string','High')
   uicontrol('callback','newdavidfit goto','string','frame#','style','slider',...
      'position',[275,0,280,15],...
      'max',size(M,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(M,3)-1),25/(size(M,3)-1)],'tag','frame#');
   uicontrol('style','text','position',[240,0,35,15],'string','Frame')
   set(gcf,'UserData',M,'keypressfcn','newdavidfit key','doublebuffer','on'...
      ,'colormap',map)
   u = image(M(:,:,frame),'cdatamapping','scaled','tag','movi');
   set(gca,'clim',[low,high],'tag','moviaxis')
   h = title([stk,' Frame # = ',num2str(frame)],...
      'interpreter','none');
   set(h,'userdata',stk)
   mzoom on
   axis image
   pixvalm
   scale
   goto
else
   eval(action)
end

%functions from play
function scale
%evaluated on line 75
children = get(gcf,'children');
low = round(get(findobj(children,'tag','scalelow'),'value'));
high = round(get(findobj(children,'tag','scalehigh'),'value'));
minlow = get(findobj(children,'tag','scalelow'),'min');
maxhigh = get(findobj(children,'tag','scalehigh'),'max');
if high == minlow+1
  	high = high +1;
end
if low == maxhigh-1
  	low = low-1;
end

set(gca,'clim',[low,high])
set(findobj(children,'tag','scalelow'),'max',high-1,...
  	'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
  	'value',low)
set(findobj(children,'tag','low_text'),'string',num2str(low));
set(findobj(children,'tag','scalehigh'),'min',low+1,...
  	'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
  	'value',high)
set(findobj(children,'tag','high_text'),'string',num2str(high));

function goto
M = get(gcf,'userdata');
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 1;
img = M(:,:,frame);
set(findobj(children,'tag','movi'),'cdata',img)
tit = get(gca,'title');
stk = get(tit,'userdata');
title([stk,' Frame # = ',num2str(frame)]);


function fullbackward
M = get(gcf,'userdata');
children = get(gcf,'children');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(M,3);
for frame = current_frame:-1:1
   if stop
      break
   end
   set(findobj(children,'type','image'),'cdata',M(:,:,frame))
   set(findobj(children,'tag','frame#'),'value',frame)
   drawnow
end
goto

function fullforward
M = get(gcf,'userdata');
children = get(gcf,'children');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(M,3);
for frame = current_frame:nframes
   if stop
      break
   end
   set(findobj(children,'type','image'),'cdata',M(:,:,frame))
   set(findobj(children,'tag','frame#'),'value',frame)
   drawnow
end
goto

function key
M = get(gcf,'userdata');
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 1;
if get(gcf,'currentcharacter') == '.'
   if frame < size(M,3)
      frame = frame+1;
   end
end
if get(gcf,'currentcharacter') == ','
   if frame>1
      frame = frame-1;
   end
end
set(findobj(children,'tag','frame#'),'value',frame)
goto

%functions specific to davidfit
function activate
if ~get(gcbo,'value')
   mzoom on
   pixvalm on
end
if get(gcbo,'value')
   pixvalm off
   mzoom off
   set(findobj('tag','movi'),'buttondownfcn','newdavidfit gofit')
end


function gofit
large_dim = 25;
small_dim = 15;
options = optimset(optimset('lsqnonlin'),'largescale','off',...
   'linesearchtype','cubicpoly','display','off','derivativecheck','off',...
   'maxiter',150,'tolfun',.1,'tolx',1e-3,'jacobian','on','diagnostics','off');
children = get(gcf,'children');
M = get(gcf,'userdata');
tit = get(gca,'title');
stk = get(tit,'userdata');
nframes = size(M,3);
current_point = round(get(gca,'currentpoint')');
[x,y] = deal(current_point(1),current_point(2));
[xl,xld] = uiputfile([stk(1:end-4),'.xls'],'Save an Excel File Output?');

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
end

sbacksub = get(findobj(children,'tag','sbacksub'),'value');
sfits = get(findobj(children,'tag','sfits'),'value');
slinescans = get(findobj(children,'tag','slinescans'),'value');
sbackground = get(findobj(children,'tag','sbackground'),'value');
distract = get(findobj(children,'tag','distract'),'value');
use_old = strcmp(get(gcbo,'tag'),'use_old');
use_psf = get(findobj(children,'tag','psf'),'value');

if use_old
   [backfile,backfiled] = uigetfile('*.mat','Where is the old Background');
   temp = load([backfiled,backfile]);
   small_background = temp.small_background;
   large_background = temp.large_background;
   x = temp.x;
   y = temp.y;
   if isfield(temp,'back_fit')
      back_fit = temp.back_fit;
   else
      back_fit = 500;
   end
   sbackground = 0;
end

if sbackground
   [background_file,background_dir] = uiputfile([xld,stk(1:end-4),'_background','.mat'],...
      'Save the Background');
   if ~background_file,sbackground = 0;end
end

if sbacksub 
   [backsub_file,backsub_dir] = uiputfile([xld,stk(1:end-4),'_backsub','.stk'],...
      'Save the Background Subtracted Movie');
   if ~backsub_file,sbacksub = 0;end
end

if ~use_old
   prompt = {'First Frame','Last Frame'};
   defaults = [2,10];
   [firstframe,lastframe] = numinputdlg(prompt,'Compute Background From Which Frames',1,defaults);
   if use_psf
      %for now no distracting granules with psf fitting :(
      where = what('david_tools');
      [fc,dc] = uigetfile([where.path,'\psf.txt'],'Where is the psf for davidfit');
      if fc
         %C = load([dc,fc]);
         %psf = C.psf;
         %C = C.C;
         psf = load([dc,fc]);
         k = .8;
         psf_rad = floor((size(psf,1)-1)/2);
      else
         use_psf = 0;
      end
   end
   small_average = zeros(2*small_dim+1);
   large_average = zeros(2*large_dim+1);
   for frame = firstframe:lastframe
      small = double(M(y-small_dim:y+small_dim,x-small_dim:x+small_dim,frame));
      large = double(M(y-large_dim:y+large_dim,x-large_dim:x+large_dim,frame));
      small_average = small_average + small;
      large_average = large_average + large;
   end
   avframes = length(firstframe:lastframe);
   small_average = small_average/avframes;
   large_average = large_average/avframes;
   if distract
      figure('colormap',gray(256))
      im = imagesc(small_average);
      axis image
      pixvalm
      set(im,'buttondownfcn','uiresume')
      title('Click on the center of the distracting granule')
      uiwait
      center = floor((size(small_average,1)+1)/2);
      current_point = round(get(gca,'currentpoint')');
      [center2x,center2y] = deal(current_point(1),current_point(2));
      
      if use_psf
         
         back_fit = fittwopsf(small_average,psf,k,center2x,center2y);
         [xs,ys] = meshgrid(-small_dim-psf_rad:small_dim+psf_rad);
         
         %show w/offset & slope
         functone = reshape(fcnpsf(back_fit([1:5,10,11]),xs,ys,psf,k,'noshow'),size(small_average));
         functtwo = reshape(fcnpsf(back_fit([1,6:9,10,11]),xs,ys,psf,k,'noshow'),size(small_average));
         twofunct = reshape(fcntwopsf(back_fit,xs,ys,psf,k,'noshow'),size(small_average));
         
         %show w/o offset | slope
         %functone = reshape(fcnpsf(back_fit(1:5),xs,ys,psf,k),size(small_average))-back_fit(1);
         %functtwo = reshape(fcnpsf(back_fit([1,6:9]),xs,ys,psf,k),size(small_average))-...
         %back_fit(1);
         %twofunct = reshape(fcntwopsf(back_fit(1:9),xs,ys,psf,k),size(small_average))-back_fit(1);
         
         small_background = -reshape(fcnpsf(back_fit(1:5),xs,ys,psf,k,'noshow',small_average),...
            size(small_average))+back_fit(1);
         
         [xs,ys] = meshgrid(-large_dim-psf_rad:large_dim+psf_rad);
         large_background = -reshape(fcnpsf(back_fit(1:5),xs,ys,psf,k,'noshow',large_average),...
            size(large_average))+back_fit(1);
         
         back_fit_excel = {'Offset' back_fit(1) 'Amplitude 1' back_fit(2) ...
               'X 1' back_fit(3)+x,'Y 1', back_fit(4)+y,...
               'Radius 1',back_fit(5),'Amplitude 2' back_fit(6) ...
               'X 2' back_fit(7)+x,'Y 2', back_fit(8)+y,'Radius 2',back_fit(9),...
               'xslope',back_fit(10),...
               'yslope',back_fit(11)}'
         
      else
         
         back_fit = twofit(small_average,options,center2x,center2y);
         [xs,ys] = meshgrid(-small_dim:small_dim);
         
         %show w/offset & slope
         functone = reshape(gauss3dfree(back_fit([1:5,10,11]),xs,ys),size(small_average));
         functtwo = reshape(gauss3dfree(back_fit([1,6:9,10,11]),xs,ys),size(small_average));
         twofunct = reshape(twogauss3dfree(back_fit,xs,ys),size(small_average));
         
         %show w/o offset | slope
         %functone = reshape(gauss3dfree(back_fit(1:5),xs,ys),size(small_average))-back_fit(1);
         %functtwo = reshape(gauss3dfree(back_fit([1,6:9]),xs,ys),size(small_average))-...
         %   back_fit(1);
         %twofunct = reshape(twogauss3dfree(back_fit(1:9),xs,ys),size(small_average))-back_fit(1);
         
         small_background = -reshape(gauss3dfree(back_fit(1:5),xs,ys,small_average),...
            size(small_average))+back_fit(1);
         back_fit_excel = {'Offset' back_fit(1) 'Amplitude 1' back_fit(2) ...
               'X 1' back_fit(3)+x,'Y 1', back_fit(4)+y,...
               'Sigma 1',back_fit(5),'Amplitude 2' back_fit(6) ...
               'X 2' back_fit(7)+x,'Y 2', back_fit(8)+y,'Sigma 2',back_fit(9),...
               'xslope',back_fit(10),...
               'yslope',back_fit(11)}'
         
         [xs,ys] = meshgrid(-large_dim:large_dim);
         large_background = -reshape(gauss3dfree(back_fit(1:5),xs,ys,large_average),...
            size(large_average))+back_fit(1);
      end
      
      msurf(small_average)
      title(['Average Image from Frames ',num2str(firstframe),' to ',num2str(lastframe)])
      clim = get(gca,'clim');
      zlim = get(gca,'zlim');
      
      msurf(twofunct)
      title('Two Functions Fit to Average Image')
      set(gca,'clim',clim,'zlim',zlim)
            
      msurf(functone)
      title('Function Fit to the Important Granule')
      set(gca,'clim',clim,'zlim',zlim)
            
      msurf(functtwo)
      title('Function Fit the the Distracting Granule')
      set(gca,'clim',clim,'zlim',zlim)
            
      msurf(small_background)
      title('Background')
      set(gca,'clim',clim,'zlim',zlim)
                 
   else
      if use_psf
         back_fit = fitpsf(small_average,psf,k);
         [xs,ys] = meshgrid(-small_dim-psf_rad:small_dim+psf_rad);
         funct = reshape(fcnpsf(back_fit,xs,ys,psf,k,'noshow'),size(small_average));
         small_background = -reshape(fcnpsf(back_fit(1:5),xs,ys,psf,k,'noshow',small_average),...
            size(small_average))+back_fit(1);
         [xs,ys] = meshgrid(-large_dim-psf_rad:large_dim+psf_rad);
         large_background = -reshape(fcnpsf(back_fit(1:5),xs,ys,psf,k,'noshow',large_average),...
            size(large_average))+back_fit(1);
         back_fit_excel = {'Offset' back_fit(1) 'Amplitude' back_fit(2) ...
               'X' back_fit(3)+x,'Y', back_fit(4)+y,'Radius',back_fit(5),'xslope',back_fit(6),...
               'yslope',back_fit(7)}'
      else
         back_fit = fit(small_average,options);
         [xs,ys] = meshgrid(-small_dim:small_dim);
         funct = reshape(gauss3dfree(back_fit,xs,ys),size(small_average));%-back_fit(1);
         small_background = -reshape(gauss3dfree(back_fit(1:5),xs,ys,small_average),...
            size(small_average))+back_fit(1);
         [xs,ys] = meshgrid(-large_dim:large_dim);
         large_background = -reshape(gauss3dfree(back_fit(1:5),xs,ys,large_average),...
            size(large_average))+back_fit(1);
         back_fit_excel = {'Offset' back_fit(1) 'Amplitude' back_fit(2) ...
               'X' back_fit(3)+x,'Y', back_fit(4)+y,'Sigma',back_fit(5),'xslope',back_fit(6),...
               'yslope',back_fit(7)}'
      end
      
      msurf(small_average)
      title(['Average Image from Frames ',num2str(firstframe),' to ',num2str(lastframe)])
      clim = get(gca,'clim');
      zlim = get(gca,'zlim');
            
      msurf(funct)
      title('Fit to Average Image')
      set(gca,'clim',clim,'zlim',zlim)
           
      msurf(small_background)
      title('Background')
      set(gca,'clim',clim,'zlim',zlim)
            
   end
   if menu('Continue?','Yes','No')==2,return,end
end

small_backsub = zeros(2*small_dim+1,2*small_dim+1);
large_backsub = zeros(2*large_dim+1,2*large_dim+1);
for frame = 1:nframes
   small = double(M(y-small_dim:y+small_dim,x-small_dim:x+small_dim,frame));
   small_backsub(:,:,frame) = small-small_background;
   large = double(M(y-large_dim:y+large_dim,x-large_dim:x+large_dim,frame));
   large_backsub(:,:,frame) = large-large_background;
end

if xl
   hexcel = actxserver('Excel.Application');
   smalltotal = sum(sum(small_backsub));
   largetotal = sum(sum(large_backsub));
   title = {[num2str(size(small_background,1),2),'X',num2str(size(small_background,1),2),...
            ' Total'],[num2str(size(large_background,1),2),'X',num2str(size(large_background,1),2),...
            ' Total']};
   total = cell(nframes+1,2);
   total(1,1:2) = title;
   total(2:end,1) = num2cell(smalltotal);
   total(2:end,2) = num2cell(largetotal);
   hworkbook = hexcel.workbooks.add;
   hsheet = get(hworkbook.worksheets,'item',1);
   topleft = get(hsheet,'cells',1,10);
   bottomright = get(hsheet,'cells',size(total,1),11);
   hrange = get(hsheet,'range',topleft,bottomright);
   hrange.value = total;
   if ~use_old
      topleft = get(hsheet,'cells',1,12);
      bottomright = get(hsheet,'cells',size(back_fit_excel,1),12);
      hrange = get(hsheet,'range',topleft,bottomright);
      hrange.value = back_fit_excel;
      topleft = get(hsheet,'cells',24,12);
      bottomright = get(hsheet,'cells',35,12);
      hrange = get(hsheet,'range',topleft,bottomright);
      hrange.value = {[num2str(size(small_background,1),2),'X',num2str(size(small_background,1),2),...
               ' Background Total'],sum(sum(small_background)),[num2str(size(large_background,1),2),...
               'X',num2str(size(large_background,1),2),...
               ' Background Total'],sum(sum(large_background)),...
            [num2str(size(small_background,1),2),'X',num2str(size(small_background,1),2),...
               ' Background Average'],mean(mean(small_background)),[num2str(size(large_background,1),2),...
               'X',num2str(size(large_background,1),2),...
               ' Background Average'],mean(mean(large_background)),...
            'First Frame',firstframe,'Last Frame',lastframe}';
      hcols = get(hsheet,'columns');
      invoke(hcols,'autofit');
      hsheet.name = 'Fits';
   end
end
if sfits&xl
   fits = zeros(nframes,7);
   h = waitbar(0,'Fitting');
   for frame = 1:nframes
      waitbar(frame/nframes,h)
      fits(frame,:) = fit(small_backsub(:,:,frame),options);
   end
   close(h)
   adjfits = fits;
   adjfits(:,3) = x+fits(:,3);
   adjfits(:,4) = y+fits(:,4);
   title = {'Frame','Offset','Amplitude','Center x','Center y','Sigma','xslope','yslope','FWHM'};
   result = cell(nframes+1,9);
   result(1,:) = title;
   frames = num2cell(1:nframes);
   result(2:end,1) = frames;
   FWHM = num2cell(2*sqrt(2*log(2))*fits(:,5));
   result(2:end,2:8) = num2cell(adjfits);
   result(2:end,9) = FWHM;
   topleft = get(hsheet,'cells',1,1);
   bottomright = get(hsheet,'cells',size(result,1),size(result,2));
   hrange = get(hsheet,'range',topleft,bottomright);
   hrange.value = result;
   hcols = get(hsheet,'columns');
   invoke(hcols,'autofit');
   hsheet.name = 'Fits';
end
if slinescans&xl
   h = waitbar(0,'Computing Linescans')
   scans = zeros(nframes,16);
   stdscans = scans;
   for frame = 1:nframes
      waitbar(frame/nframes,h)
      if fits(frame,3:4)-small_dim>=-large_dim&fits(frame,3:4)+small_dim<=large_dim
         [scans(frame,:),stdscans(frame,:)] = ...
            linescan(large_backsub(:,:,frame),fits(frame,3:4)+large_dim+1,small_dim);
      end
   end
   close(h)
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
   invoke(hworkbook,'saveas',[xld,xl]);
   invoke(hworkbook,'close');
   invoke(hexcel,'quit');
   delete(hexcel);
end

if sbackground
   save([background_dir,background_file],'x','y','small_background','large_background','back_fit');
end

if sbacksub
   stkwrite(uint16(cat(3,large_backsub+back_fit(1),large_background)),backsub_file,backsub_dir);
end
msgbox('Done')

function toggle_linescans
children = get(gcf,'children');
if ~get(findobj(children,'tag','sfits'),'value')
   set(findobj(children,'tag','slinescans'),'value',0,'enable','off')
else
   set(findobj(children,'tag','slinescans'),'enable','on')
end


function [param,res] = fit(img,options)
center = floor((size(img,1)+1)/2);
radius = center-1;
X0 = [min(min(img)),max(max(img))-min(min(img)),0,0,1.5,0,0];
[x,y] = meshgrid(-radius:radius);
[param,res] = lsqnonlin('gauss3dfree',X0,[],[],options,x,y,img);

function [param,res] = twofit(img,options,center2x,center2y)
center = floor((size(img,1)+1)/2);
radius = center-1;
X0 = [min(min(img)),img(center,center)-min(min(img)),0,0,1.5,...
      img(center2y,center2x)-min(min(img)),center2x-radius-1,...
      center2y-radius-1,1.5,0,0];
[x,y] = meshgrid(-radius:radius);
[param,res] = lsqnonlin('twogauss3dfree',X0,[],[],options,x,y,img);


function param = fitpsfmtx(img,C,k)
options = optimset(optimset('lsqnonlin'),'largescale','off',...
   'linesearchtype','cubicpoly','display','off','derivativecheck','off',...
   'maxiter',150,'tolfun',.1,'tolx',1e-3,'jacobian','on','diagnostics','off');
large_rad = floor((sqrt(size(C,2))-1)/2);
[x,y] = meshgrid(-large_rad:large_rad);
X0 = [min(min(img)),max(max(img))-min(min(img)),...
      0,0,1.5,0,0];
param = lsqnonlin('fcnpsfmtx',X0,[],[],options,x(:),y(:),C,k,img);

function param = fitpsf(img,psf,k)

options = optimset(optimset('lsqnonlin'),'largescale','off',...
   'display','final','diagnostics','off','jacobian','off',...
   'derivativecheck','off','linesearchtype','cubicpoly',...
   'tolfun',1e1,'tolx',1e-2,...
   'maxfunevals','100*numberOfVariables',...
   'DiffMaxChange',0.1,'MaxIter',400);

outputsiz = size(img,1);
psfsiz = size(psf,1);
inputsiz = outputsiz+psfsiz-1;
input_radius = floor((inputsiz-1)/2);
output_radius = floor((outputsiz-1)/2);
output_center = output_radius+1;

[x,y] = meshgrid(-input_radius:input_radius);

offset = min(min(img));
amp = 5*(img(output_center,output_center)-min(min(img)));
xcenter = 0;
ycenter = 0;
R = 2;
xslope = 0;
yslope = 0;

newdefaults = [offset,amp,xcenter,ycenter,R,xslope,yslope];
newdefaults = str2num(num2str(newdefaults));
olddefaults = zeros(size(newdefaults));

range = output_center + (-output_radius:output_radius);
msurf(img(range,range))
title('Original Image')
clim = get(gca,'clim');
zlim = get(gca,'zlim');


ftrial = reshape(fcnpsf(newdefaults,x,y,psf,k,'noshow'),size(img(range,range)));
trial = msurf(ftrial);
title('First Guess at Fuction')
set(gca,'clim',clim,'zlim',zlim)

while ~strcmp(num2str(olddefaults),num2str(newdefaults))
   ftrial = reshape(fcnpsf(newdefaults,x,y,psf,k,'noshow'),size(img(range,range)));
   olddefaults = newdefaults;
   set(trial,'zdata',ftrial,'cdata',ftrial)
   tit = 'These initial guess values may here be adjusted manually';
   prompt = {'Offset','Amplitude','X-Coord (rel. to 0 at center of frame)',...
         'Y-Coord (rel. to 0 at center of frame)','Radius',...
         'X-Slope','Y-Slope'};
   [offset,amp,xcenter,ycenter,R,xslope,yslope]=...
      numinputdlg(prompt,tit,1,olddefaults);
   newdefaults = [offset,amp,xcenter,ycenter,R,xslope,yslope];
end

range = output_center + (-output_radius:output_radius);
msurf(img(range,range))
title('Image minus Fit')
view(20,-78)

param = lsqnonlin('fcnpsf',newdefaults,[],[],options,x,y,psf,k,'show',img);

function param = fittwopsf(img,psf,k,center2x,center2y)
options = optimset(optimset('lsqnonlin'),'largescale','off',...
   'display','final','diagnostics','off','jacobian','off',...
   'derivativecheck','off','linesearchtype','cubicpoly',...
   'tolfun',1e1,'tolx',1e-2,'LevenbergMarquardt','on',...
   'maxfunevals','100*numberOfVariables',...
   'DiffMaxChange',0.1,'MaxIter',400);

outputsiz = size(img,1);
psfsiz = size(psf,1);
inputsiz = outputsiz+psfsiz-1;
input_radius = floor((inputsiz-1)/2);
output_radius = floor((outputsiz-1)/2);
output_center = output_radius+1;

[x,y] = meshgrid(-input_radius:input_radius);

offset = min(min(img));
amp1 = 5*(img(output_center,output_center)-min(min(img)));
xcenter1 = 0;
ycenter1 = 0;
R1 = 2;
amp2 = 5*(img(center2y,center2x)-min(min(img)));
xcenter2 = center2x-output_radius-1;
ycenter2 = center2y-output_radius-1;
R2 = 2;
xslope = 0;
yslope = 0;
newdefaults = [offset,amp1,xcenter1,ycenter1,R1,amp2,xcenter2,ycenter2,R2,xslope,yslope];
newdefaults = str2num(num2str(newdefaults));
olddefaults = zeros(size(newdefaults));

range = output_center + (-output_radius:output_radius);
msurf(img(range,range))
title('Original Image')
clim = get(gca,'clim');
zlim = get(gca,'zlim');


ftrial = reshape(fcntwopsf(newdefaults,x,y,psf,k,'noshow'),size(img(range,range)));
trial = msurf(ftrial);
title('First Guess at Function')
set(gca,'clim',clim,'zlim',zlim)

while ~strcmp(num2str(olddefaults),num2str(newdefaults))
   ftrial = reshape(fcntwopsf(newdefaults,x,y,psf,k,'noshow'),size(img(range,range)));
   olddefaults = newdefaults;
   set(trial,'zdata',ftrial,'cdata',ftrial)
   tit = 'These initial guess values may here be adjusted manually';
   prompt = {'Offset','Amplitude 1','X-Coord 1 (rel. to 0 at center of frame)',...
         'Y-Coord 1 (rel. to 0 at center of frame)','Radius 1','Amplitude 2',...
         'X-Coord 2 (rel. to 0 at center of frame)',...
         'Y-Coord 2 (rel. to 0 at center of frame)','Radius 2','X-Slope','Y-Slope'};
   [offset,amp1,xcenter1,ycenter1,R1,amp2,xcenter2,ycenter2,R2,xslope,yslope]=...
      numinputdlg(prompt,tit,1,olddefaults);
   newdefaults = [offset,amp1,xcenter1,ycenter1,R1,amp2,xcenter2,ycenter2,R2,xslope,yslope];
end

range = output_center + (-output_radius:output_radius);
msurf(img(range,range))
title('Image minus Fit')
view(20,-78)
param = lsqnonlin('fcntwopsf',newdefaults,[],[],options,x,y,psf,k,'show',img);




