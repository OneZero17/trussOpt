function matlabMesh = createRectangularMesh(x, y, spacing)
    model = createpde;
    R1 = [3,4,0,x,x,0,y,y,0,0]';
    gm = [R1];
    sf = 'R1';

    %Create the geometry.
    ns = char('R1');
    ns = ns';
    g = decsg(gm,sf,ns);
    %Include the geometry in the model and plot it.
    geometryFromEdges(model,g);

    % create mesh
     matlabMesh = generateMesh(model,'GeometricOrder','linear', 'Hmax', spacing);
%     Nb = findNodes(matlabMesh,'box',[x, x],[y/2 - 0.05, y/2 + 0.05]);
%     figure
%     pdemesh(model)
%     hold on
%     plot(matlabMesh.Nodes(1,Nb),matlabMesh.Nodes(2,Nb),'or','MarkerFaceColor','g')
end

