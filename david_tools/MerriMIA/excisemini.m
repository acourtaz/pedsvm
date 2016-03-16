function [mini] = excisemini(movi,tmptrk,goodtrk,coeff,id);

% cuts out a ministack using track coords in 'tmptrk' (columns: id, frame
% number, x, y, u, v, tag for alignment frame)

frs = tmptrk(:,2);
x = round(tmptrk(:,3));
y = round(tmptrk(:,4));
u = round(tmptrk(:,5));
v = round(tmptrk(:,6));

minigrn = zeros(25);
minired = zeros(25);

for a = 1:size(tmptrk,1);
    fr = tmptrk(a,2);
    minigrn(:,:,a) = movi((y(a) - 12):(y(a) + 12),(x(a) - 12):(x(a) + 12),fr);
    minired(:,:,a) = movi((v(a) - 12):(v(a) + 12),(u(a) - 12):(u(a) + 12),fr);
end

mini(1:25,1:50,1:size(tmptrk,1)) = 0;
mini(1:25,1:25,1:size(tmptrk,1)) = minigrn;
mini(1:25,26:50,1:size(tmptrk,1)) = minired;

