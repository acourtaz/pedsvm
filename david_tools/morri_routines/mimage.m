function varargout = mimage(img,varargin)
map = gray(256);
figure
set(gcf,'colormap',map);
handle = image(img,'cdatamapping','scaled',varargin{:});
mzoom on
axis image
pixvalm
if nargout == 1
   varargout{1} = handle;
end
