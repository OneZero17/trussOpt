function matlabMesh = createRectangularMesh()
model = createpde;
%Define a circle in a rectangle, place these in one matrix, and create a set formula that subtracts the circle from the rectangle.

R1 = [3,4,0,10,10,0,10,10,0,0]';
gm = [R1];
sf = 'R1';

%Create the geometry.
ns = char('R1');
ns = ns';
g = decsg(gm,sf,ns);
%Include the geometry in the model and plot it.
geometryFromEdges(model,g);

% create mesh
matlabMesh = generateMesh(model,'GeometricOrder','linear', 'Hmax', 0.25);

 %pdeplot(model)
% N_ID = findNodes(matlabMesh,'nearest',[0;-0.75]);
% En = findElements(matlabMesh,'attached',N_ID);
% figure
% pdemesh(model)
% hold on
%plot(matlabMesh.Nodes(1,N_ID), matlabMesh.Nodes(2,N_ID),'or','Color','g', ...
%                                          'MarkerFaceColor','g')
%pdemesh(matlabMesh.Nodes, matlabMesh.Elements(:,En),'EdgeColor','green')
end

