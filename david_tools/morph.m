function M=morph(p,q);
if nargin < 2
   cla
   disp('draw initial polygon')
   p=drawfig('b') 
   hold on
   plot(p,'co') 
   disp('draw final polygon')
   q=drawfig('r')
   end
clf
plot(p);
hold on;
plot(q);
axis(axis);
cla;
hold off;
M=moviein(22);
for j=0:10
    clf
    pj=plot(j/10*p+(1-j/10)*q,'g');
%    set(pj,'Color',[j/10,.8,1-j/10])
    drawnow
    axis('off');
    M(:,j+1)=getframe;
    end;
clf
M(:,12:22)=fliplr(M(:,1:11));
axis('off');
movie(M,33)