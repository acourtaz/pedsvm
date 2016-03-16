function chooseBeads2(action)

if nargin == 0
   %close all
   [file,direc] = uigetfile('*.tif','Choose an Alignment Image');
   if ~file,return,end
   img = imread([direc,file]);
      
   %classimage(img)
   width = size(img,2);
   button = questdlg('Is the Green channel on the left side of the image?');
   isLeft = strcmp(button,'Yes');
   % left image = green channel
   offset = floor(width/2);
   left = img(:,1+offset*(~isLeft):offset*(1+~isLeft)); %should be called green but David is lazy :)
   right = img(:,1+offset*(isLeft):offset*(1+isLeft));  %should be called red but David is lazy :)
   
   %set(0,'DefaultLineCreateFcn','choosebeads modify')
   %the previous line is a leftover of first version for Matlab 5
   scr = get(0,'ScreenSize');
   figure('position',[scr(3)/4 scr(4)/4 scr(3)/2 scr(4)/2])
   set(gcf,'doublebuffer','on','keypressfcn','chooseBeads2 zoomToggle')
   map = gray(256);
   set(gcf,'colormap',map,'name',['Bead Selection   ',file])
   
   subplot(1,2,1)
   image(left,'cdatamapping','scaled','tag','leftImage')
   axis image
   title('Green channel')
   set(gca,'tag','leftAxis')
   highLeft = double(max(max(left(:,:))));
   lowLeft = double(min(min(left(:,:))));
   
   subplot(1,2,2) %subdivides the figure in two panes with its own axes%
   image(right,'cdatamapping','scaled','tag','rightImage')
   axis image
   title('Red channel')
   set(gca,'tag','rightAxis')
   highRight = double(max(max(right(:,:))));
   lowRight = double(min(min(right(:,:))));
   
   uicontrol('position',[50,35,80,20],'string',...
      'Zoom','callback','chooseBeads2 zoomOn',...
      'style','togglebutton','value',1,'tag','zoomOn')
   
   uicontrol('position',[50,10,80,20],'string',...
      'Transfer Zoom','callback','chooseBeads2 zoomTransfer')
   
   uicontrol('position',[170,35,100,20],'string',...
      'Save Coordinates','callback','chooseBeads2 saveCoord')
  
   uicontrol('position',[170,10,100,20],'string',...
       'Fit & Save','tag','FS','callback','chooseBeads2 saveFit','UserData',isLeft)
   
   uicontrol('position',[300,35,100,20],'string',...
      'Load Coordinates','callback','chooseBeads2 loadCoord')
  
   uicontrol('position',[300,10,150,20],'string',...
       'Calculate coeff transform','callback','chooseBeads2 calcCoeff')
   
   %Controls inherited from play
   %Level controls for the left image
   uicontrol('style','slider','callback','chooseBeads2 scaleLeft',...
      'min',lowLeft,'max',highLeft-3,'value',lowLeft,...
      'position',[80,60,180,15],'tag','scalelowLeft')
   
   uicontrol('style','text','position',[50,60,30,15],'tag','lowLeft_text')
      %'fontsize',5)
   
   uicontrol('style','text','position',[15,60,35,15],'string','Low')
   
   uicontrol('style','slider','callback','chooseBeads2 scaleLeft',...
      'min',lowLeft+3,'max',highLeft,'value',highLeft,...
      'position',[80,75,180,15],'tag','scalehighLeft')
   
   uicontrol('style','text','position',[50,75,30,15],'tag','highLeft_text')
      %'fontsize',5)
   
   uicontrol('style','text','position',[15,75,35,15],'string','High')
   
   %Level controls for the right image
   uicontrol('style','slider','callback','chooseBeads2 scaleRight',...
      'min',lowRight,'max',highRight-3,'value',lowRight,...
      'position',[350,60,180,15],'tag','scalelowRight')
   
   uicontrol('style','text','position',[320,60,30,15],'tag','lowRight_text')
      %'fontsize',5)
   
   uicontrol('style','text','position',[285,60,35,15],'string','Low')
   
   uicontrol('style','slider','callback','chooseBeads2 scaleRight',...
      'min',lowRight+3,'max',highRight,'value',highRight,...
      'position',[350,75,180,15],'tag','scalehighRight')
   
   uicontrol('style','text','position',[320,75,30,15],'tag','highRight_text')
      %'fontsize',5)
   
   uicontrol('style','text','position',[285,75,35,15],'string','High')
   
   
   chooseBeads2 scaleLeft
   chooseBeads2 scaleRight
   chooseBeads2 zoomOn
   
else
   switch action
      
   case 'scaleLeft'
      children = get(gcf,'children');
      low = round(get(findobj(children,'tag','scalelowLeft'),'value'));
      high = round(get(findobj(children,'tag','scalehighLeft'),'value'));
      minlow = get(findobj(children,'tag','scalelowLeft'),'min');
      maxhigh = get(findobj(children,'tag','scalehighLeft'),'max');
      if high == minlow+1
         high = high +1;
      end
      if low == maxhigh-1
         low = low-1;
      end
      
      set(findobj('tag','leftAxis'),'clim',[low,high])
      set(findobj(children,'tag','scalelowLeft'),'max',high-1,...
         'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
         'value',low)
      set(findobj(children,'tag','lowLeft_text'),'string',num2str(low));
      set(findobj(children,'tag','scalehighLeft'),'min',low+1,...
         'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
         'value',high)
      set(findobj(children,'tag','highLeft_text'),'string',num2str(high));
      
   case 'scaleRight'
      children = get(gcf,'children');
      low = round(get(findobj(children,'tag','scalelowRight'),'value'));
      high = round(get(findobj(children,'tag','scalehighRight'),'value'));
      minlow = get(findobj(children,'tag','scalelowRight'),'min');
      maxhigh = get(findobj(children,'tag','scalehighRight'),'max');
      if high == minlow+1
         high = high +1;
      end
      if low == maxhigh-1
         low = low-1;
      end
      
      set(findobj('tag','rightAxis'),'clim',[low,high])
      set(findobj(children,'tag','scalelowRight'),'max',high-1,...
         'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
         'value',low)
      set(findobj(children,'tag','lowRight_text'),'string',num2str(low));
      set(findobj(children,'tag','scalehighRight'),'min',low+1,...
         'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
         'value',high)
      set(findobj(children,'tag','highRight_text'),'string',num2str(high));
      
   case 'zoomToggle'
     if get(gcf,'currentcharacter')=='z'
         children = get(gcf,'children');
         zoomOn = findobj(children,'tag','zoomOn');
         zoomStatus = get(zoomOn,'value');
         set(zoomOn,'value',~zoomStatus);
         chooseBeads2('zoomOn')
      end
            
   case 'zoomOn'
      
      children = get(gcf,'children');
      axes(findobj(children,'tag','leftAxis'))
      zoomStatus = get(findobj(children,'tag','zoomOn'),'value');  
      
      if zoomStatus
         zoom on
         lastPoint = get(findobj(children,'tag','leftAxis'),'userdata');
         child2 = get(findobj(children,'tag','leftAxis'),'children');
         if ~isempty(lastPoint)
            delete(findobj(child2,'xdata',lastPoint(1),'ydata',lastPoint(2)))
         end
      else
         zoom off
         set(findobj(children,'tag','leftImage'),'ButtonDownFcn','chooseBeads2 pickLeft')
         chooseBeads2 zoomTransfer
      end
      
   case 'zoomTransfer'
      children = get(gcf,'children');
      xlim = get(findobj(children,'tag','leftAxis'),'xlim');
      ylim = get(findobj(children,'tag','leftAxis'),'ylim');
      set(findobj(children,'tag','rightAxis'),'xlim',xlim,'ylim',ylim);
      
   case 'pickLeft'
      if strcmp(get(gcf,'selectiontype'),'normal')
         leftBead = get(gca,'currentpoint');
         leftBead = leftBead(1,1:2);
         children = get(gcf,'children');
         set(gca,'userdata',leftBead);
         set(findobj(children,'tag','leftImage'),'ButtonDownFcn','');
         set(findobj(children,'tag','rightImage'),'ButtonDownFcn','chooseBeads2 pickRight')
         drawline(leftBead) 
      end
      
   case 'pickRight'
      if strcmp(get(gcf,'selectiontype'),'normal')
         rightBead = get(gca,'currentpoint');
         children = get(gcf,'children');
         rightBead = rightBead(1,1:2);
         leftBead = get(findobj(children,'tag','leftAxis'),'userdata');
         set(findobj(children,'tag','leftAxis'),'userdata',[])
         set(gca,'userdata',[get(gca,'userdata');leftBead,rightBead]);
         set(findobj(children,'tag','rightImage'),'ButtonDownFcn','');
         set(findobj(children,'tag','leftImage'),'ButtonDownFcn','chooseBeads2 pickLeft')
         drawline(rightBead)
      end
  
   case 'saveCoord'
      [beadFile,beadDir]  = uiputfile('*.txt','Save coordinates as');
      if ~beadFile,return,end
      children = get(gcf,'children');
      beadPairs = get(findobj(children,'tag','rightAxis'),'userdata');
      dlmwrite([beadDir,beadFile],beadPairs,'\t')
      
   case 'saveFit'
      children = get(gcf,'children');
      isL = get(findobj(children,'tag','FS'),'userdata');
      %isL = isL{1};
      if isL
         [beadFile,beadDir]  = uiputfile('fit(gL).txt','Save coordinates as');
      else
         [beadFile,beadDir]  = uiputfile('fit(gR).txt','Save coordinates as');
      end
      if ~beadFile,return,end
      beadPairs = get(findobj(children,'tag','rightAxis'),'userdata');
      left = double(get(findobj(children,'tag','leftImage'),'cdata'));
      right = double(get(findobj(children,'tag','rightImage'),'cdata'));
      [X,Y] = meshgrid(1:size(left,2),1:size(left,1));
      %lowRight = get(findobj('tag','rightAxis'),'clim');
      %lowLeft = get(findobj('tag','leftAxis'),'clim');
      %left = left-min(min(left));
      %right = right-min(min(right));
      errorCenters = ones(size(beadPairs,1),4);
      while max(max(errorCenters)) > 0.05
         oldBeads = beadPairs;
         
         for i = 1:size(beadPairs,1)
            
            distLeftBead = sqrt((X-beadPairs(i,1)).^2+(Y-beadPairs(i,2)).^2);
            circleLeftBead = distLeftBead < 4;
            leftBead = circleLeftBead.*left;
            leftBead = leftBead-min(leftBead(leftBead>0));
            leftBead(leftBead<0)=0;
            totalLeft = sum(sum(leftBead));
            beadPairs(i,1)=sum(sum(X.*leftBead))/totalLeft;
            beadPairs(i,2)=sum(sum(Y.*leftBead))/totalLeft;
            
            distRightBead = sqrt((X-beadPairs(i,3)).^2+(Y-beadPairs(i,4)).^2);
            circleRightBead = distRightBead < 4;
            rightBead = circleRightBead.*right;
            rightBead = rightBead - min(rightBead(rightBead>0));
            rightBead(rightBead<0)=0;
            totalRight = sum(sum(rightBead));
            beadPairs(i,3)=sum(sum(X.*rightBead))/totalRight;
            beadPairs(i,4)=sum(sum(Y.*rightBead))/totalRight;
         end
         
         errorCenters = (beadPairs-oldBeads).^2;
      end
      
      %save([beadDir,beadFile],'beadPairs','-ASCII')
      dlmwrite([beadDir,beadFile],beadPairs,'\t')

   case 'loadCoord'
      [beadFile,beadDir]  = uigetfile('*.txt','Open coordinates file');
      if ~beadFile,return,end
      children = get(gcf,'children');
      delete(findobj(children,'type','line'))
      beadPairs = load([beadDir,beadFile]);
      set(findobj(children,'tag','rightAxis'),'userdata',beadPairs);
      set(0,'DefaultLineCreateFcn','')
      drawnow 
      axes(findobj(children,'tag','leftAxis'));
      for i=1:size(beadPairs,1)
         drawline(beadPairs(i,1:2));
      end
      axes(findobj(children,'tag','rightAxis'));
      for i=1:size(beadPairs,1)
         drawline(beadPairs(i,3:4));
      end
      %set(0,'DefaultLineCreateFcn','chooseBeads2 modify') 
      %the previous line is a leftover of first version for Matlab 5
      
   case 'calcCoeff'
      %calculates the coefficients of the 3rd order polynomial
      %interpolating the bead coordinates selected
      %there are 14 coefficients
      %therefore, for a unique interpolation, at least 7 beads are needed
      children = get(gcf,'children');
      beads = get(findobj(children,'tag','rightAxis'),'userdata');
      isL = get(findobj(children,'tag','FS'),'userdata');
      %isL = isL{1};
      if size(beads,1) < 7
         errordlg('There are not enough beads for a unique interpolation')
         return
      end
      if isL
          [coFile,p] = uiputfile('coeffs(gL).txt','Save transformation coefficients');
          pause(0.1)
          [rcoFile,pr] = uiputfile([coFile(1:end-8),'(gR).txt'],'Save reverse transformation coefficients');
      else
          [coFile,p] = uiputfile('coeffs(gR).txt','Save transformation coefficients');
          pause(0.1)
          [rcoFile,pr] = uiputfile([coFile(1:end-8),'(gL).txt'],'Save reverse transformation coefficients');
      end
      if ~coFile,return,end
      xLeft = beads(:,1);
      yLeft = beads(:,2);
      xRight= beads(:,3);
      yRight= beads(:,4);
      %The function chosen is a third order polynomial function
      E1 = [ones(size(xLeft)) xLeft xLeft.^2 xLeft.^3 yLeft yLeft.^2 yLeft.^3];
      E = [E1 zeros(size(xLeft,1),7);zeros(size(xLeft,1),7) E1];
      %Second order polynomial
      %E1 = [ones(size(xLeft)) xLeft xLeft.^2 yLeft yLeft.^2];
      %E = [E1 zeros(size(xLeft,1),5);zeros(size(xLeft,1),5) E1];
      cRight = [xRight;yRight];
      coeff = E\cRight;  
      if ischar(rcoFile)&&ischar(pr)
          Er1 = [ones(size(xRight)) xRight xRight.^2 xRight.^3 yRight yRight.^2 yRight.^3];
          Er = [Er1 zeros(size(xRight,1),7);zeros(size(xRight,1),7) Er1];
          cLeft = [xLeft;yLeft];
          rcoeff = Er\cLeft;
          dlmwrite([pr,rcoFile],rcoeff,'\t')
      end
      if ischar(coFile)&&ischar(p)
         dlmwrite([p,coFile],coeff,'\t')
      end
 
   case 'modify'
      xy = [get(gcbo,'xdata'),get(gcbo,'ydata')];
      children = get(gcf,'children');
      beadPairs = get(findobj(children,'tag','rightAxis'),'userdata');
      currentAxis = get(gca,'tag');
      if strcmp(currentAxis,'leftAxis') 
         coll = 1; otherColl = 3;
         if ~isempty(get(gca,'userdata'))
            if get(gca,'userdata') == xy
               set(findobj(children,'tag','rightImage'),'ButtonDownFcn','');
               set(findobj(children,'tag','leftImage'),'ButtonDownFcn','chooseBeads2 pickLeft')
               if strcmp(get(gcf,'SelectionType'),'alt')
                  delete(gcbo)
               elseif strcmp(get(gcf,'SelectionType'),'normal')
                  set(gcf,'userdata',gcbo,'windowButtonMotionFcn','chooseBeads2 move',...
                     'windowButtonUpFcn','chooseBeads2 up') 
               end
               return
            end
         end
      else
         coll = 3; otherColl = 1;
         children = get(findobj('tag','leftAxis'),'children');   
      end
      row = find(xy(1)==beadPairs(:,coll)...
         &xy(2)==beadPairs(:,coll+1));
      
      if strcmp(get(gcf,'SelectionType'),'alt')
         delete(gcbo)
         delete(findobj(children,'xdata',beadPairs(row,otherColl),...
            'ydata',beadPairs(row,otherColl+1)))
         beadPairs(row,:) = [];
         set(findobj(children,'tag','rightAxis'),'userdata',beadPairs);      
      end
      
      if strcmp(get(gcf,'SelectionType'),'normal')
         set(gcbo,'userdata',row)
         set(gcf,'userdata',gcbo,'windowButtonMotionFcn','chooseBeads2 move',...
            'windowButtonUpFcn','chooseBeads2 up')
      end
      
   case 'move'
      circle = get(gcf,'userdata');    
      currentPoint = get(gca,'currentpoint');      
      set(circle,'xdata',currentPoint(1,1),'ydata',currentPoint(1,2));
      
   case 'up'
      set(gcf,'windowButtonMotionFcn','','windowButtonUpFcn','')
      circle = get(gcf,'userdata');
      children = get(findobj('tag','leftAxis'),'children');   
      xy = [get(circle,'xdata'),get(circle,'ydata')];
      beadPairs = get(findobj(children,'tag','rightAxis'),'userdata');
      currentAxis = get(gca,'tag');
      if strcmp(currentAxis,'leftAxis') 
         coll = 1;
         if ~isempty(get(gca,'userdata'))
            set(gca,'userdata',xy);
            set(findobj(children,'tag','leftImage'),'ButtonDownFcn','');
            set(findobj(children,'tag','rightImage'),'ButtonDownFcn','chooseBeads2 pickRight')
            return
         end
      else
         coll = 3;
      end
      beadPairs(get(circle,'userdata'),(0:1)+coll) = xy;
      set(findobj(children,'tag','rightAxis'),'userdata',beadPairs);
   end
end

function drawline(coord)
line('xdata',coord(1),'ydata',coord(2),'lineStyle','none',...
   'marker','o','markerEdgeColor','red','buttonDownFcn','chooseBeads2 modify')
