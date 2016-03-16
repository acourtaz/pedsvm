function pixvalm(action)
if nargin <1
   if strcmp(get(gcf,'WindowButtonMotionFcn'),'pixvalm motion')
      off   
   else
      on  
   end
elseif isnumeric(action)
   on
   set(findobj(get(gcf,'children'),'tag','pixvalm'),'userdata',action)  
elseif strcmp(action,'motion')&strcmp(get(gcf,'WindowButtonMotionFcn'),'pixvalm motion')
   p = round(get(gca,'currentpoint'))';
   p = p(1:2);
   img = get(findobj(get(gca,'children'),'type','image'),'cdata');
   xlim = get(gca,'xlim');
   ylim = get(gca,'ylim');
   if p(2)>=ylim(1) & p(1)>=xlim(1) & p(2)<=ylim(2) & p(1)<=xlim(2)
      val = double(img(p(2),p(1)));
      if ndims(img) ==3
         m = 255;
         if ~isempty(get(findobj(get(gcf,'children'),'tag','pixvalm'),'userdata'))
            m = double(get(findobj(get(gcf,'children'),'tag','pixvalm'),'userdata'));
         end
         val = val*m;
      end
      set(findobj(get(gcf,'children'),'tag','pixvalm'),'string',...
         ['(',num2str(p(1)),',',num2str(p(2)),') -->',num2str(val,5)])
   else 
      set(findobj(get(gcf,'children'),'tag','pixvalm'),'string',...
         {''})
   end
elseif strcmp(action,'beginmove')
   if strcmp(get(gcf,'selectiontype'),'normal')
      m = get(findobj(get(gcf,'children'),'tag','pixvalm'),'userdata');
      set(findobj(get(gcf,'children'),'tag','pixvalm'),'userdata',...
         {get(gcf,'currentpoint'),get(findobj(get(gcf,'children'),'tag','pixvalm'),'position'),...
            get(gcf,'windowbuttonupfcn'),m});
      set(gcf,'windowbuttonmotionfcn','pixvalm move')
      set(gcf,'windowbuttonupfcn','pixvalm endmove')
   else off
   end
elseif strcmp(action,'move')
   originalpt = get(findobj(get(gcf,'children'),'tag','pixvalm'),'userdata');
   originalpos = originalpt{2};
   originalpt = originalpt{1};
   newpt = get(gcf,'currentpoint');
   moved = newpt-originalpt;
   newpos = originalpos + [moved(1:2),0 0];
   set(findobj(get(gcf,'children'),'tag','pixvalm'),'position',newpos)
elseif strcmp(action,'endmove')
   set(gcf,'windowbuttonmotionfcn','pixvalm motion')   
   orig = get(findobj(get(gcf,'children'),'tag','pixvalm'),'userdata');
   origfcn = orig{3};
   origuser = orig{4};
   set(gcf,'windowbuttonupfcn',origfcn)
   set(findobj(get(gcf,'children'),'tag','pixvalm'),'userdata',origuser)
elseif strcmp(action,'on')
   on
elseif strcmp(action,'off')
   off   
end
function on
if ~strcmp(get(gcf,'WindowButtonMotionFcn'),'pixvalm motion')
   set(gcf,'WindowButtonMotionFcn','pixvalm motion','busyaction','cancel')
   uicontrol('style','text','enable','inactive','tag','pixvalm',...
      'buttondownfcn','pixvalm beginmove','position',[5 330 120 13],...
      'horizontalalignment','left','backgroundcolor',[0.85 0.9 0.9]);
end
function off
set(gcf,'WindowButtonMotionFcn','')
delete(findobj(get(gcf,'children'),'tag','pixvalm'))    
