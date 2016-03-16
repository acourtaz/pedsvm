function scale
children = get(gcf,'children');
scaleLeft = findobj(children,'tag','scaleLeft');
scaleRight = findobj(children,'tag','scaleRight');
leftText = findobj(children,'tag','leftText');
rightText = findobj(children,'tag','rightText');
img = findobj(children,'tag','image');

newR = get(scaleRight,'userdata');
imgL = get(scaleLeft,'userdata');
right = get(scaleRight,'value');
left = get(scaleLeft,'value');
set(leftText,'string',int2str(left))
set(rightText,'string',int2str(right))

red = imgL/left;
red(red>1) = 1;
green = newR/right;
green(green>1) = 1;
blue = zeros(size(red));

rgb = cat(3,red,green,blue);
set(img,'cdata',rgb)

