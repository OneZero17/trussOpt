for stepNum = 5:5
    xMax=10; yMax=10; cellSize=1; splitNum = 1;

    maxArea = inf;
    boundMemberCoefficient = stepNum * 0.1;

    cellGrid = GeoCellGrid(xMax, yMax);

    % create the first cell
    cellGrid.cells{1, 1}= cellGrid.createPharseOneComplexCell(0,0,cellSize, splitNum);

    % create first row
    for i = 2:xMax
        cellGrid.cells{i, 1} = cellGrid.createPharseTwoComplexCell(cellGrid.cells{i - 1, 1});
    end

    %create the rest
    for i= 1:xMax
        for j = 2:yMax
            if (i == 1)
                cellGrid.cells{i, j} = cellGrid.createPharseThreeComplexCell(cellGrid.cells{i, j - 1});
            else
                cellGrid.cells{i, j} = cellGrid.createPharseFourComplexCell(cellGrid.cells{i, j - 1}, cellGrid.cells{i - 1, j});
            end
        end
    end
    cellGrid.initializeIndices();

    %loads and supports
    loadcase = PhyLoadCase();
    loadNodeIndex = cellGrid.findNodeIndex(xMax, 0);
    load = PhyLoad(loadNodeIndex, -1, 0);
    load2NodeIndex = cellGrid.findNodeIndex(xMax, cellSize);
    load2 = PhyLoad(load2NodeIndex, -1, 0);
    loadcase.loads = {load, load2};
    loadcases = {loadcase};

    support1NodeIndex = cellGrid.findNodeIndex(0, 0);
    support2NodeIndex = cellGrid.findNodeIndex(0, yMax);
    support3NodeIndex = cellGrid.findNodeIndex(0, cellSize);
    support1 = PhySupport(support1NodeIndex);
    support2 = PhySupport(support2NodeIndex, 1, 0);
    support3 = PhySupport(support3NodeIndex);
    supports = {support1; support3};

    %construct Optimization problem
    solverOptions = OptOptions();
    solverOptions.cellOptimization=1;
    cellProblem = OptProblem();
    cellProblem.createProblem(cellGrid, loadcases, supports, solverOptions);
    cellProblem.createComplexCellLinks(cellGrid, maxArea, boundMemberCoefficient);

    %solve the problem
    [conNum, varNum] = cellProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum);
    cellProblem.initializeProblem(matrix);
    [vars, result] = mosekSolve(matrix, 0);
    matrix.feedBackResult(vars);
    cellProblem.feedBackResult(1);

    cellGrid.plotMembers(1, ['CellRatio = ', num2str(boundMemberCoefficient), ' Result = ', num2str(result)]);          
end
