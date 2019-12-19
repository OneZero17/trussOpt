%% Create Some Data
[xq,yq] = meshgrid(1:1:10);
zq = xq.^2-4*yq.^3;
% Primary Shape
primary = reshape([xq,yq],size(xq,1)*size(xq,2),2);
xq = reshape(xq,size(primary,1),1);
yq = reshape(yq,size(primary,1),1);
zq = reshape(zq,size(primary,1),1);
primary = reshape([xq,yq,zq],size(xq,1)*size(xq,2),3);
% Outer Boarder
secondary{1} = [1,1;10,1;10,10;1,10];
% Inner Border 1
% secondary{2} = [2.5,2.5;8.5,2.5;8.5,4.5;7.5,4.5;7.5,7.5;2.5,7.5];
secondary{2} = [9 8; 10 8; 10 9; 9 9];
% Inner Border 2
secondary{3} = [8,8;9,8;9,9;8,9];
%% Run delaunayConstrained Function
clf
[DT,xyz,ind] = delaunayConstrained(primary,secondary,'borders');
%%
hold on
trisurf(DT.ConnectivityList(isInterior(DT),:),...
        xyz(:,1),...
        xyz(:,2),...
        xyz(:,3));
h = plot3(primary(:,1),primary(:,2),primary(:,3),'r.','MarkerSize',12);
hold off