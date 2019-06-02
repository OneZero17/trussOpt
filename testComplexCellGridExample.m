clear 
xMax=1; yMax=1; cellSize=1; splitNum = 1;
results = [];
maxArea = inf;
%boundMemberCoefficient = 1/sqrt(1.35);
%boundMemberCoefficient = 0.707;
boundMemberCoefficient = 0.5;
%boundMemberCoefficient = 1;
for xStep = -10:10
    for yStep = -10:10
        xLoad = xStep / 100;
        yLoad = yStep / 100;
        cellGrid = GeoCellGrid(xMax, yMax);

        cellGrid.cells{1, 1}= cellGrid.createPharseOneComplexCell(0, 0, cellSize, splitNum);
        cellGrid.initializeIndices();

        %loads and supports
        loadcase = PhyLoadCase();
        spacing = xMax/splitNum;
        for i = 1:splitNum+1
            loadNodeIndex = cellGrid.findNodeIndex((i-1) * spacing, 0);
            load1 = PhyLoad(loadNodeIndex, 0, yLoad);
            loadNodeIndex = cellGrid.findNodeIndex(xMax, (i-1) * spacing);
            load2 = PhyLoad(loadNodeIndex, -xLoad, 0);
            loadNodeIndex = cellGrid.findNodeIndex((i-1) * spacing, yMax);
            load3 = PhyLoad(loadNodeIndex, 0, -yLoad);
            loadNodeIndex = cellGrid.findNodeIndex(0, (i-1) * spacing);
            load4 = PhyLoad(loadNodeIndex, xLoad, 0);
            loadcase.loads = [loadcase.loads; {load1; load2; load3; load4}];
        end
        loadcases = {loadcase};

        %construct Optimization problem
        solverOptions = OptOptions();
        solverOptions.cellOptimization=1;
        cellProblem = OptProblem();
        cellProblem.createProblem(cellGrid, loadcases, [], solverOptions);
        cellProblem.createComplexCellLinks(cellGrid, maxArea, boundMemberCoefficient);

        %solve the problem
        [conNum, varNum] = cellProblem.getConAndVarNum();
        matrix = ProgMatrix(conNum, varNum);
        cellProblem.initializeProblem(matrix);
        [vars, result] = mosekSolve(matrix, 0);
        results = [results; xLoad, yLoad, result];
    end
end
figure 
axis off
matrix.feedBackResult(vars);
cellProblem.feedBackResult();
cellGrid.plotMembers();
results(:, 1:2) = results(:, 1:2)./results(:, 3);
results(:, 1:2) = results(:, 1:2) /results(1, 1);
figure 
hold on
axis equal
for i = 1:size(results, 1)
    plot(results(i, 1),results(i, 2),'r*');
end

vonMises = results;
for i = 1:size(vonMises, 1)
    vonMises(i, 3) = sqrt(vonMises(i, 1)^2+vonMises(i, 2)^2 - vonMises(i, 1)*vonMises(i, 2));
end
vonMises(:, 1:2) = vonMises(:, 1:2)./vonMises(:, 3);

for i = 1:size(results, 1)
    plot(vonMises(i, 1),vonMises(i, 2),'b*');
end

%matrix.feedBackResult(vars);
%cellProblem.feedBackResult();
%cellGrid.plotMembers();
