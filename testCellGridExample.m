clear
xMax=40; yMax=40; cellSize=1; splitNum = 1;

maxArea = inf;
%boundMemberCoefficient = 0.5;
%boundMemberCoefficient = 1/sqrt(1.35);
%boundMemberCoefficient = 1/sqrt(1.35);
boundMemberCoefficient = 0.3;
%boundMemberCoefficient = 0.707;
%boundMemberCoefficient = 1;

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
load = PhyLoad(loadNodeIndex, 0, -1);
loadcase.loads = {load};
loadcases = {loadcase};

support1NodeIndex = cellGrid.findNodeIndex(0, 0);
support2NodeIndex = cellGrid.findNodeIndex(0, yMax);
support1 = PhySupport(support1NodeIndex);
support2 = PhySupport(support2NodeIndex);
supports = {support1; support2};

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
result = mosekSolve(matrix, 0);
matrix.feedBackResult(result);
cellProblem.feedBackResult();
cellGrid.plotMembers();

