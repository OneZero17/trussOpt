clear
x = 5;
y = 1;
supportDomainRadius = 1;
matlabMesh = createRectangularMeshMK2(x, y, 0.1);
nodes = matlabMesh.Nodes';
edges = createMeshEdges(matlabMesh);
boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
edges = [edges, boundaryList];

boundaryEdges = edges(edges(:, end)==1, :);
boundaryNodes = unique(reshape(boundaryEdges(:, 1:2), [], 1));
innerNodes = setdiff((1:size(matlabMesh.Nodes, 2))', boundaryNodes);
cornerNodes = [0,0;0,y;x,y;x,0;0,0];
a = setdiff(nodes, cornerNodes, 'rows');
%[vornb,vorvx] = polybnd_voronoi(nodes(innerNodes, :), nodes(boundaryNodes, :));
[vornb,vorvx] = polybnd_voronoi(nodes, cornerNodes);
cellNodeNum = zeros(size(vorvx, 2), 1);
cellAreas = zeros(size(vorvx, 2), 1);
for i = 1:size(vorvx, 2)
    cellNodeNum(i, 1) = size(vorvx{1, i}, 1);
end

for i = 1:size(vorvx, 2)
    cellAreas(i, 1) = polyarea(vorvx{1, i}(:, 1), vorvx{1, i}(:, 2));
end

vorvx = vorvx';
voroniNodesTotal = cell2mat(vorvx);
[voroniNodes, ~, ic] = uniquetol(voroniNodesTotal,1e-6, 'ByRows',true);
cellNodeIndices = mat2cell(ic, cellNodeNum, [1]);

cellLengths = calculateCellEdgeLengths(cellNodeIndices, voroniNodes);
cellNormals = calculateCellEdgeNormals(cellNodeIndices, voroniNodes);
boundaries = createVoroniCellBoundaries(cellNodeIndices);
boundaryLengths = calculateEdgeLengths(boundaries(:, 1:2), voroniNodes);
boundaries = [boundaries, boundaryLengths];
boundaryNormals = calculateEdgeNormals(boundaries(:, 1:2), voroniNodes);
voroniNodeNum = size(voroniNodes, 1);
supportDomainMap = cell(voroniNodeNum, 3);

for i = 1:voroniNodeNum
    [supportDomainMap{i, 1}, supportDomainMap{i, 2}] = findNodesWithinDistance(nodes', voroniNodes(i, 1), voroniNodes(i, 2), supportDomainRadius);
    supportDomainMapProduct = prod(supportDomainMap{i, 2});
    minLength = min(supportDomainMap{i, 2});
    if (minLength <1e-9)
        tempDomainMap = supportDomainMap{i, 2};
        tempDomainMap(supportDomainMap{i, 2}<1e-9) = 1;
        tempDomainMap(supportDomainMap{i, 2}>=1e-9) = 0;
        supportDomainMap{i, 3} = tempDomainMap;
    else
    supportDomainMap{i, 3} = supportDomainMapProduct./supportDomainMap{i, 2};
    supportDomainMap{i, 3} = supportDomainMap{i, 3}/sum(supportDomainMap{i, 3});
    end
end

loadPosX = [x-1e-6, x+1e-6];
loadPosY = [0+0.3-1e-6, y-0.3+1e-6];
loadMagnitude = [-0.1, -0.0];
loadNodes = findNodesInBox(voroniNodes', loadPosX, loadPosY);
loadedBoundaries = findBoundariesContainNodes(boundaries, loadNodes);
loadBoundaryNum = sum(loadedBoundaries);
totalLoadedLength = sum(boundaries(loadedBoundaries == 1, 4));
boundaries =[boundaries, zeros(size(boundaries, 1), 2)];
boundaries(loadedBoundaries == 1, 5:6) = repmat(loadMagnitude/totalLoadedLength, loadBoundaryNum, 1);

fixedPosX = [-1e-6, 1e-6];
fixedPosY = [0, y];
fixedCondition = [1 1];
fixedNodes = findNodesInBox(voroniNodes', fixedPosX, fixedPosY);
fixedBoundaries = findBoundariesContainNodes(boundaries, fixedNodes);
fixedBoundaryNum = sum(fixedBoundaries);
boundaries =[boundaries, zeros(size(boundaries, 1), 2)];
boundaries(fixedBoundaries == 1, 7:8) = repmat(fixedCondition, fixedBoundaryNum, 1);

meshLessProblem = MLOptProblem();
%meshLessProblem.createProblem(nodes, voroniNodes, cellNodeIndices, supportDomainMap, boundaries, 1);
meshLessProblem.createProblem(nodes, cellNodeIndices, cellLengths, cellNormals,  cellAreas, supportDomainMap, boundaries, boundaryNormals, 1);

[conNum, varNum, objVarNum] = meshLessProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
meshLessProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
meshLessProblem.feedBackResult(1);
densityList = meshLessProblem.generateDensityList();

axis equal;
colormap hot;
hold on
cmap = colormap;
for i = 1:size(densityList, 1)
    if (abs(densityList(i)) > 1e-6)
        if densityList(i) > 1
            densityList(i) = 1;
        end
        rgb = interp1( linspace(1, 0, size(cmap, 1)), cmap, densityList(i));  
        fill (vorvx{i, 1}(:, 1), vorvx{i, 1}(:, 2), rgb, 'EdgeColor', rgb);
    end
end

hold on;
for i = 1:size(vorvx,1)
    plot(vorvx{i}(:,1),vorvx{i}(:,2),'-b') 
end

boundaryNode1 = voroniNodes(boundaries(:,1), :);
boundaryNode2 = voroniNodes(boundaries(:,2), :);

for i = 1:size(boundaries, 1)
    plot([boundaryNode1(i,1); boundaryNode2(i,1)], [boundaryNode1(i,2); boundaryNode2(i,2)],'-g')
end
plot(matlabMesh.Nodes(1, :), matlabMesh.Nodes(2, :),'r+')
