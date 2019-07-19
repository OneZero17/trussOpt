x1 = [0,2];
y1 = [0,2];
x2 = [1,2,2,1];
y2 = [1,1,2,2];
[x,y]=curveintersect(x1,y1,x2,y2);
plot(x1,y1,'k',x2,y2,'b',x,y,'ro')