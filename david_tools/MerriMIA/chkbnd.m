function [chk] = chkbnd(tmptrk,sizemovi);

% checks that coordinates within 'tmptrk' are within the bounds of the
% parent stack (columns: id, frame number, x, y, u, v, tag for alignment
% frame)

minx = min(tmptrk(:,3));
maxx = max(tmptrk(:,3));
miny = min(tmptrk(:,4));
maxy = max(tmptrk(:,4));
minu = min(tmptrk(:,5));
maxu = max(tmptrk(:,5));
minv = min(tmptrk(:,6));
maxv = max(tmptrk(:,6));

if minx > 13 & maxx < 243 & miny > 13 & maxy < 287 ...
   minu > 269 & maxu < 499 & minv > 13 & maxv < 287;
    chk = 1;
    else
    chk = 0;
end