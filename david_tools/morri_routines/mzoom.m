function out = mzoom(varargin)
%mzoom   mzoom in and out on a 2-D plot.
%   mzoom with no arguments toggles the mzoom state.
%   mzoom(FACTOR) mzooms the current axis by FACTOR.
%       Note that this does not affect the mzoom state.
%   mzoom ON turns mzoom on for the current figure.  
%   mzoom OFF turns mzoom off in the current figure.
%   mzoom OUT returns the plot to its initial (full) mzoom.
%   mzoom XON or mzoom YON turns mzoom on for the x or y axis only.
%   mzoom RESET clears the mzoom out point.
%
%   When mzoom is on, click the left mouse button to mzoom in on the
%   point under the mouse.  Click the right mouse button to mzoom out
%   (shift-click on the Macintosh).  Each time you click, the axes
%   limits will be changed by a factor of 2 (in or out).  You can also
%   click and drag to mzoom into an area.  Double clicking mzooms out to
%   the point at which mzoom was first turned on for this figure.  Note
%   that turning mzoom on, then off does not reset the mzoom point.
%   This may be done explicitly with mzoom RESET.
%   
%   mzoom(FIG,OPTION) applies the mzoom command to the figure specified
%   by FIG. OPTION can be any of the above arguments.

%   mzoom FILL scales a plot such that it is as big as possible
%   within the axis position rectangle for any azimuth and elevation.

%   Clay M. Thompson 1-25-93
%   Revised 11 Jan 94 by Steven L. Eddins
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.42 $  $Date: 1998/09/30 13:43:56 $

%   Note: mzoom uses the figure buttondown and buttonmotion functions
%
%   mzoom XON mzooms x-axis only
%   mzoom YON mzooms y-axis only

switch nargin,
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%
   %%% No Input Arguments %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%
case 0,
   fig=get(0,'currentfigure');
   if isempty(fig), return, end
   mzoomCommand='toggle';
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%
   %%% One Input Argument %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%
case 1,
   
   % If the argument is a string, the argument is a mzoom command
   % (i.e. (on, off, down, xdown, etc.).  Otherwise, the argument is
   % assumed to be a figure handle, in which case all we do is
   % toggle the mzoom status.
   
   if ischar(varargin{1}),
      fig=get(0,'currentfigure');
      if isempty(fig), return, end
      
      mzoomCommand=varargin{1};
   else
      scale_factor=varargin{1};
      mzoomCommand='scale';
      fig = gcf;
   end % if
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%% Two Input Arguments %%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%
case 2,
   fig=varargin{1};
   mzoomCommand=varargin{2};
   
otherwise,
   error(nargchk(0, 2, nargin));
   
end % switch nargin

%
% handle 'off' commands first
%
if strcmp(mzoomCommand,'off'),
   %
   % turn off mzoom, and take a hike
   %
   set(findall(fig,'Tag','figToolmzoomIn'),'State','off');
   set(findall(fig,'Tag','figToolmzoomOut'),'State','off');   
   if ~isempty(getappdata(fig,'mzoomFigureMode'))
      rmappdata(fig,'mzoomFigureMode');
   end

   state = getappdata(fig,'mzoomFigureState');
   if ~isempty(state),
      uirestore(state);
      clruprop(fig,'mzoomFigureState');
   end
   return
end % if

ax=get(fig,'currentaxes');

rbbox_mode = 0;
mzoomx = 1; mzoomy = 1; % Assume no constraints

mzoomCommand=lower(mzoomCommand);

if ~isempty(ax) & any(get(ax,'view')~=[0 90]) ...
           & ~(strcmp(mzoomCommand,'scale') | ...
           strcmp(mzoomCommand,'fill')),
   fmzoom3d = 1;
   % set(findall(fig,'Tag','figToolmzoom'),'State','off');   
   % warning('mzoom is only supported for 2D plots.');
   % return % Do nothing
else
   fmzoom3d = 0;
end

if strcmp(mzoomCommand,'toggle'),
   state = getappdata(fig,'mzoomFigureState');
   if isempty(state)
      mzoom(fig,'on');
   else
      mzoom(fig,'off');
   end
   return
end % if

% Catch constrained mzoom
if strcmp(mzoomCommand,'xdown'),
   mzoomy = 0; mzoomCommand = 'down'; % Constrain y
elseif strcmp(mzoomCommand,'ydown')
   mzoomx = 0; mzoomCommand = 'down'; % Constrain x
end


switch mzoomCommand
case 'down',
   % Activate axis that is clicked in
   allAxes = findobj(datachildren(fig),'flat','type','axes');
   mzoom_found = 0;
   
   % this test may be causing failures for 3d axes
   for i=1:length(allAxes),
      ax=allAxes(i);
      mzoom_Pt1 = get(ax,'CurrentPoint');
      xlim = get(ax,'xlim');
      ylim = get(ax,'ylim');
      if (xlim(1) <= mzoom_Pt1(1,1) & mzoom_Pt1(1,1) <= xlim(2) & ...
            ylim(1) <= mzoom_Pt1(1,2) & mzoom_Pt1(1,2) <= ylim(2))
         mzoom_found = 1;
         set(fig,'currentaxes',ax);
         break
      end % if
   end % for

   if mzoom_found==0, return, end
   
   % Check for selection type
   selection_type = get(fig,'SelectionType');
   mzoomMode = getappdata(fig,'mzoomFigureMode');

   axz = get(ax,'ZLabel');
   
      if fmzoom3d

      viewData = getappdata(axz,'mzoomAxesView');
      if isempty(viewData)
         viewProps = { 'CameraTarget'...
                    'CameraTargetMode'...
                    'CameraViewAngle'...
                    'CameraViewAngleMode'};
         setappdata(axz,'mzoomAxesViewProps', viewProps);
         setappdata(axz,'mzoomAxesView', get(ax,viewProps));
      end
      
      if isempty(mzoomMode) | strcmp(mzoomMode,'in');
         mzoomLeftFactor = 1.5;
         mzoomRightFactor = .75;         
      elseif strcmp(mzoomMode,'out');
         mzoomLeftFactor = .75;
         mzoomRightFactor = 1.5;
      end
      
      switch selection_type
         case 'open'
            set(ax,getappdata(axz,'mzoomAxesViewProps'),...
                    getappdata(axz,'mzoomAxesView'));
         case 'normal'
            newTarget = mean(get(ax,'CurrentPoint'),1);
            set(ax,'CameraTarget',newTarget);
            cammzoom(ax,mzoomLeftFactor);
         otherwise
            newTarget = mean(get(ax,'CurrentPoint'),1);
            set(ax,'CameraTarget',newTarget);
            cammzoom(ax,mzoomRightFactor);
      end

      return
   end

   if isempty(mzoomMode) | strcmp(mzoomMode,'in');
      switch selection_type
         case 'normal'
            % mzoom in
            m = 1;
            scale_factor = 2; % the default mzooming factor
         case 'open'
            % mzoom all the way out
            mzoom(fig,'out');
            return;
         otherwise
            % mzoom partially out
            m = -1;
            scale_factor = 2;
      end
   elseif strcmp(mzoomMode,'out')
      switch selection_type
         case 'normal'
            % mzoom partially out
            m = -1;
            scale_factor = 2;
         case 'open'
            % mzoom all the way out
            mzoom(fig,'out');
            return;
         otherwise
            % mzoom in
            m = 1;
            scale_factor = 2; % the default mzooming factor
      end
   else % unrecognized mzoomMode
      return
   end
   
   
   mzoom_Pt1 = get_currentpoint(ax);
   mzoom_Pt2 = mzoom_Pt1;
   center = mzoom_Pt1;
   
   if (m == 1)
      % mzoom in
      units = get(fig,'units'); set(fig,'units','pixels')
      rbbox([get(fig,'currentpoint') 0 0],get(fig,'currentpoint'));
      mzoom_Pt2 = get_currentpoint(ax);
      set(fig,'units',units)
      
      % Note the currentpoint is set by having a non-trivial up function.
      if min(abs(mzoom_Pt1-mzoom_Pt2)) >= ...
            min(.01*[diff(get_xlim(ax)) diff(get_ylim(ax))]),
         % determine axis from rbbox 
         a = [mzoom_Pt1;mzoom_Pt2]; a = [min(a);max(a)];
         
         % Undo the effect of get_currentpoint for log axes
         if strcmp(get(ax,'XScale'),'log'),
            a(1:2) = 10.^a(1:2);
         end
         if strcmp(get(ax,'YScale'),'log'),
            a(3:4) = 10.^a(3:4);
         end
         rbbox_mode = 1;
      end
   end
   limits = mzoom(fig,'getlimits');
   
case 'scale',
   if all(get(ax,'view')==[0 90]), % 2D mzooming with scale_factor
      
      % Activate axis that is clicked in
      mzoom_found = 0;
      ax = gca;
      xlim = get(ax,'xlim');
      ylim = get(ax,'ylim');
      mzoom_Pt1 = [sum(xlim)/2 sum(ylim)/2];
      mzoom_Pt2 = mzoom_Pt1;
      center = mzoom_Pt1;
      
      if (xlim(1) <= mzoom_Pt1(1,1) & mzoom_Pt1(1,1) <= xlim(2) & ...
            ylim(1) <= mzoom_Pt1(1,2) & mzoom_Pt1(1,2) <= ylim(2))
         mzoom_found = 1;
      end % if
      
      if mzoom_found==0, return, end
      
      if (scale_factor >= 1)
         m = 1;
      else
         m = -1;
      end
      
   else % 3D
      old_CameraViewAngle = get(ax,'CameraViewAngle')*pi/360;
      ncva = atan(tan(old_CameraViewAngle)*(1/scale_factor))*360/pi;
      set(ax,'CameraViewAngle',ncva);
      return;
   end
   
   limits = mzoom(fig,'getlimits');

case 'getmode'
   state = getappdata(fig,'mzoomFigureState');
   if isempty(state)
      out = 'off';
   else
      mode = getappdata(fig,'mzoomFigureMode');
      if isempty(mode)
         out = 'on';
      else
         out = mode;
      end
   end
   return

   
case 'on',
   
   set(findall(fig,'Tag','figToolmzoomIn'),'State','on');
   
   state = getappdata(fig,'mzoomFigureState');
   if isempty(state),
      state = uiclearmode(fig,'mzoom',fig,'off');
      setappdata(fig,'mzoomFigureState',state);
   end
   set(fig,'windowbuttondownfcn','mzoom down', ...
      'windowbuttonupfcn','ones;','interruptible','on');
   %,'windowbuttonmotionfcn','','buttondownfcn','');
   set(ax,'interruptible','on')
   return
   
case 'inmode'
   mzoom(fig,'on');
   set(findall(fig,'Tag','figToolmzoomIn'),'State','on');   
   set(findall(fig,'Tag','figToolmzoomOut'),'State','off');      
   setappdata(fig,'mzoomFigureMode','in');
   return   
   
case 'outmode'
   mzoom(fig,'on');
   set(findall(fig,'Tag','figToolmzoomIn'),'State','off');   
   set(findall(fig,'Tag','figToolmzoomOut'),'State','on');      
   setappdata(fig,'mzoomFigureMode','out');
   return
   
case 'reset',
   axz = get(ax,'ZLabel');
   if isappdata(axz,'mzoomAxesData')
     rmappdata(axz,'mzoomAxesData');
   end
   return
   
case 'xon',
   mzoom(fig,'on') % Set up userprop
   set(fig,'windowbuttondownfcn','mzoom xdown', ...
      'windowbuttonupfcn','ones;', ...
      ...
      'interruptible','on');
   set(ax,'interruptible','on')
   return
   
case 'yon',
   mzoom(fig,'on') % Set up userprop
   set(fig,'windowbuttondownfcn','mzoom ydown', ...
      'windowbuttonupfcn','ones;', ...
      'windowbuttonmotionfcn','','buttondownfcn','',...
      'interruptible','on');
   set(ax,'interruptible','on')
   return
   
case 'out',
   limits = mzoom(fig,'getlimits');
   center = [sum(get_xlim(ax))/2 sum(get_ylim(ax))/2];
   m = -inf; % mzoom totally out
   
case 'getlimits', % Get axis limits
   axz = get(ax,'ZLabel');
   limits = getappdata(axz,'mzoomAxesData');
   % Do simple checking of userdata
   if size(limits,2)==4 & size(limits,1)<=2, 
      if all(limits(1,[1 3])<limits(1,[2 4])), 
         getlimits = 0; out = limits(1,:); return   % Quick return
      else
         getlimits = -1; % Don't munge data
      end
   else
      if isempty(limits), getlimits = 1; else getlimits = -1; end
   end
   
   % If I've made it to here, we need to compute appropriate axis
   % limits.
   
   if isempty(getappdata(axz,'mzoomAxesData')),
      % Use quick method if possible
      xlim = get_xlim(ax); xmin = xlim(1); xmax = xlim(2); 
      ylim = get_ylim(ax); ymin = ylim(1); ymax = ylim(2); 
      
   elseif strcmp(get(ax,'xLimMode'),'auto') & ...
         strcmp(get(ax,'yLimMode'),'auto'),
      % Use automatic limits if possible
      xlim = get_xlim(ax); xmin = xlim(1); xmax = xlim(2); 
      ylim = get_ylim(ax); ymin = ylim(1); ymax = ylim(2); 
      
   else
      % Use slow method only if someone else is using the userdata
      h = get(ax,'Children');
      xmin = inf; xmax = -inf; ymin = inf; ymax = -inf;
      for i=1:length(h),
         t = get(h(i),'Type');
         if ~strcmp(t,'text'),
            if strcmp(t,'image'), % Determine axis limits for image
               x = get(h(i),'Xdata'); y = get(h(i),'Ydata');
               x = [min(min(x)) max(max(x))];
               y = [min(min(y)) max(max(y))];
               [ma,na] = size(get(h(i),'Cdata'));
               if na>1, dx = diff(x)/(na-1); else dx = 1; end
               if ma>1, dy = diff(y)/(ma-1); else dy = 1; end
               x = x + [-dx dx]/2; y = y + [-dy dy]/2;
            end
            xmin = min(xmin,min(min(x)));
            xmax = max(xmax,max(max(x)));
            ymin = min(ymin,min(min(y)));
            ymax = max(ymax,max(max(y)));
         end
      end
      
      % Use automatic limits if in use (override previous calculation)
      if strcmp(get(ax,'xLimMode'),'auto'),
         xlim = get_xlim(ax); xmin = xlim(1); xmax = xlim(2); 
      end
      if strcmp(get(ax,'yLimMode'),'auto'),
         ylim = get_ylim(ax); ymin = ylim(1); ymax = ylim(2); 
      end
   end
   
   limits = [xmin xmax ymin ymax];
   if getlimits~=-1, % Don't munge existing data.
      % Store limits mzoomAxesData
      % store it with the ZLabel, so that it's cleared if the 
      % user plots again into this axis.  If that happens, this
      % state is cleared
      axz = get(ax,'ZLabel');
      setappdata(axz,'mzoomAxesData',limits);
   end
   
   out = limits;
   return
   
case 'getconnect', % Get connected axes
   axz = get(ax,'ZLabel');
   limits = getappdata(axz,'mzoomAxesData');
   if all(size(limits)==[2 4]), % Do simple checking
      out = limits(2,[1 2]);
   else
      out = [ax ax];
   end
   return
   
case 'fill',
   old_view = get(ax,'view');
   view(45,45);
   set(ax,'CameraViewAngleMode','auto');
   set(ax,'CameraViewAngle',get(ax,'CameraViewAngle'));
   view(old_view);
   return
   
otherwise
   error(['Unknown option: ',mzoomCommand,'.']);
end

%
% Actual mzoom operation
%

if ~rbbox_mode,
   xmin = limits(1); xmax = limits(2); 
   ymin = limits(3); ymax = limits(4);
   
   if m==(-inf),
      dx = xmax-xmin;
      dy = ymax-ymin;
   else
      dx = diff(get_xlim(ax))*(scale_factor.^(-m-1)); dx = min(dx,xmax-xmin);
      dy = diff(get_ylim(ax))*(scale_factor.^(-m-1)); dy = min(dy,ymax-ymin);
   end
   
   % Limit mzoom.
   center = max(center,[xmin ymin] + [dx dy]);
   center = min(center,[xmax ymax] - [dx dy]);
   a = [max(xmin,center(1)-dx) min(xmax,center(1)+dx) ...
         max(ymin,center(2)-dy) min(ymax,center(2)+dy)];
   
   % Check for log axes and return to linear values.
   if strcmp(get(ax,'XScale'),'log'),
      a(1:2) = 10.^a(1:2);
   end
   if strcmp(get(ax,'YScale'),'log'),
      a(3:4) = 10.^a(3:4);
   end
   
end

% Check for axis equal and update a as necessary
if strcmp(get(ax,'plotboxaspectratiomode'),'manual') & ...
   strcmp(get(ax,'dataaspectratiomode'),'manual')
   ratio = get(ax,'plotboxaspectratio')./get(ax,'dataaspectratio');
   dx = a(2)-a(1);
   dy = a(4)-a(3);
   [kmax,k] = max([dx dy]./ratio(1:2));
   if k==1
      dy = kmax*ratio(2);
      a(3:4) = mean(a(3:4))+[-dy dy]/2;
   else
     dx = kmax*ratio(1);
     a(1:2) = mean(a(1:2))+[-dx dx]/2;
   end
end

% Update circular list of connected axes
list = mzoom(fig,'getconnect'); % Circular list of connected axes.
if mzoomx,
   if a(1)==a(2), return, end % Short circuit if mzoom is moot.
   set(ax,'xlim',a(1:2))
   h = list(1);
   while h ~= ax,
      set(h,'xlim',a(1:2))
      % Get next axes in the list
      hz = get(h,'ZLabel');
      next = getappdata(hz,'mzoomAxesData');
      if all(size(next)==[2 4]), h = next(2,1); else h = ax; end
   end
end
if mzoomy,
   if a(3)==a(4), return, end % Short circuit if mzoom is moot.
   set(ax,'ylim',a(3:4))
   h = list(2);
   while h ~= ax,
      set(h,'ylim',a(3:4))
      % Get next axes in the list
      hz = get(h,'ZLabel');
      next = getappdata(hz,'mzoomAxesData');
      if all(size(next)==[2 4]), h = next(2,2); else h = ax; end
   end
end


function p = get_currentpoint(ax)
%GET_CURRENTPOINT Return equivalent linear scale current point
p = get(ax,'currentpoint'); p = p(1,1:2);
if strcmp(get(ax,'XScale'),'log'),
   p(1) = log10(p(1));
end
if strcmp(get(ax,'YScale'),'log'),
   p(2) = log10(p(2));
end

function xlim = get_xlim(ax)
%GET_XLIM Return equivalent linear scale xlim
xlim = get(ax,'xlim');
if strcmp(get(ax,'XScale'),'log'),
   xlim = log10(xlim);
end

function ylim = get_ylim(ax)
%GET_YLIM Return equivalent linear scale ylim
ylim = get(ax,'ylim');
if strcmp(get(ax,'YScale'),'log'),
   ylim = log10(ylim);
end
