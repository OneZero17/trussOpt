function circle(x,y,r, figureNum, inDegree, outDegree)
if (nargin <5)
    inDegree = 0;
    outDegree = 2*pi;
end
figure(figureNum)
hold on
ang=inDegree:0.01:outDegree; 
xp=r*cos(ang);
yp=r*sin(ang);
plot(x+xp,y+yp,':', 'LineWidth', 2, 'color', [0.7, 0.7, 0.7]);
end
