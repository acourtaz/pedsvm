function [tmptrk] = coordstform(tmptrk,coeff);

% calculates transform coefficients and appends coordinates to matrix
% 'tmptrk' (columns: id, frame number, x, y, u, v, tag for alignment frame)

x = tmptrk(:,3);
y = tmptrk(:,4);
tag = tmptrk(:,5);
c = coeff;

u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 + ...              % calc x'coordinates for red channel
c(5).*y + c(6).*y.^2 + c(7).*y.^3 + 256;
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 + ...            % calc y' coordinates for red channel
c(12).*y + c(13).*y.^2 + c(14).*y.^3;

tmptrk(:,5) = u;
tmptrk(:,6) = v;
tmptrk(:,7) = tag;