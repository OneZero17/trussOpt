clear
x = 5;
y = 10;
supportDomainRadius = 1;
supportingAlpha = 3;
matlabMesh = createRectangularMeshMK2(x, y, 0.2);
nodes = matlabMesh.Nodes';
cornerNodes = [0,0;0,y;x,y;x,0;0,0];
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
cellSinCos= calculateCellEdgeSinCos(cellNodeIndices, voroniNodes);
boundaries = createVoroniCellBoundaries(cellNodeIndices);
boundaryLengths = calculateEdgeLengths(boundaries(:, 1:2), voroniNodes);
boundaries = [boundaries, boundaryLengths];
boundaryNormals = calculateEdgeNormals(boundaries(:, 1:2), voroniNodes);
boundarySinCos = calculateEdgeSinCos(boundaries(:, 1:2), voroniNodes);
voroniNodeNum = size(voroniNodes, 1);
supportDomainMap = cell(voroniNodeNum, 2);

for i = 1:voroniNodeNum
    [supportDomainMap{i, 1}, lengths] = findNodesWithinDistance(nodes', voroniNodes(i, 1), voroniNodes(i, 2), supportDomainRadius);
    minLength = min(lengths);
    if (minLength <1e-9)
        tempDomainMap = lengths;
        tempDomainMap(lengths<1e-9) = 1;
        tempDomainMap(lengths>=1e-9) = 0;
        supportDomainMap{i, 2} = tempDomainMap;
    else
        lengthPowers = lengths.^supportingAlpha;
        supportDomainMapProduct = prod(lengthPowers); 
        tempDomainMap = supportDomainMapProduct./lengthPowers;
        supportDomainMap{i, 2} = tempDomainMap ./sum(tempDomainMap);
    end
end


loadPosX = [0-1e-6, 0+1e-6];
loadPosY = [0+4-1e-6, y-4+1e-6];
loadMagnitude = [0.0, -0.7];
loadNodes = findNodesInBox(voroniNodes', loadPosX, loadPosY);
loadedBoundaries = findBoundariesContainNodes(boundaries, loadNodes);
loadBoundaryNum = sum(loadedBoundaries);
totalLoadedLength = sum(boundaries(loadedBoundaries == 1, 4));
boundaries =[boundaries, zeros(size(boundaries, 1), 2)];
boundaries(loadedBoundaries == 1, 5:6) = repmat(loadMagnitude/totalLoadedLength, loadBoundaryNum, 1);

% fixedPosX = [-1e-6, 1e-6];
% fixedPosY = [0, y];
% fixedCondition = [1 1];
% fixedNodes = findNodesInBox(voroniNodes', fixedPosX, fixedPosY);
% fixedBoundaries = findBoundariesContainNodes(boundaries, fixedNodes);

fixedPosX1 = [-1e-6, 1e-6];
fixedPosY1 = [0-1e-6, 1+1e-6];
fixedPosX2 = [-1e-6, 1e-6];
fixedPosY2 = [y-1e-6, y+1e-6];
fixedCondition = [1 1];
fixedNodes1 = findNodesInBox(voroniNodes', fixedPosX1, fixedPosY1);
fixedBoundaries1 = findBoundariesContainNodes(boundaries, fixedNodes1);
fixedNodes2 = findNodesInBox(voroniNodes', fixedPosX2, fixedPosY2);
fixedBoundaries2 = findBoundariesContainNodes(boundaries, fixedNodes2);
fixedBoundaries = [fixedBoundaries1; fixedBoundaries2];
fixedBoundaryNum = sum(fixedBoundaries);
boundaries =[boundaries, zeros(size(boundaries, 1), 2)];
boundaries(fixedBoundaries == 1, 7:8) = repmat(fixedCondition, fixedBoundaryNum, 1);

meshLessProblem = MLOptProblem();
%meshLessProblem.createProblem(nodes, voroniNodes, cellNodeIndices, supportDomainMap, boundaries, 1);
meshLessProblem.createProblem(nodes, cellNodeIndices, cellLengths, cellNormals, cellAreas, supportDomainMap, boundaries, boundaryNormals, boundarySinCos, 1);

[conNum, varNum, objVarNum] = meshLessProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
meshLessProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
meshLessProblem.feedBackResult(1);
densityList = meshLessProblem.generateDensityList();
stressList = meshLessProblem.generateStressList();
pointStressList = calculatePointStress(stressList, supportDomainMap);

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
% for i = 1:size(vorvx,1)
%     plot(vorvx{i}(:,1),vorvx{i}(:,2),'-b') 
% end

boundaryNode1 = voroniNodes(boundaries(:,1), :);
boundaryNode2 = voroniNodes(boundaries(:,2), :);

% for i = 1:size(boundaries, 1)
%     plot([boundaryNode1(i,1); boundaryNode2(i,1)], [boundaryNode1(i,2); boundaryNode2(i,2)],'-g')
% end
% plot(nodes(:, 1), nodes(:, 2),'r+')

% for i = 1:size(nodes)
%     text(nodes(i, 1), nodes(i, 2), sprintf('%0.2g', densityList(i)), 'FontSize',15, 'Color', [0, 0 ,0]);
% end

% for i = 1:size(nodes)
%     stressText = [num2str(i), '(', sprintf('%0.2g', stressList(i, 1)),',' , sprintf('%0.2g', stressList(i, 2)),',', sprintf('%0.2g', stressList(i, 3)),')'];
%     text(nodes(i, 1), nodes(i, 2), stressText, 'FontSize',15, 'Color', [0, 0 ,0]);
% end
% 
% for i = 1:size(voroniNodes, 1)
%     stressText = ['(' , sprintf('%0.2g', pointStressList(i, 1)),',' , sprintf('%0.2g', pointStressList(i, 2)),',', sprintf('%0.2g', pointStressList(i, 3)),')'];
%     text(voroniNodes(i, 1), voroniNodes(i, 2), stressText, 'FontSize',15, 'Color', [0, 0 ,0]);
% end
