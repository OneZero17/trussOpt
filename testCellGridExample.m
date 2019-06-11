clear;
caseNum = 3;
%case 0 single bar
%case 1 single bar
%case 2 quarter bicycle wheel
%case 3 fan shape
%case 4 michell cantilever
%case 5 constained michell cantilever

%for stepNum = 10:10
xMax=30; yMax=30; cellSize=1; splitNum = 2;

if (caseNum == 5)
    xMax = 60;
    yMax = 30;
end

maxArea = 1;
switch splitNum
    case 1
        boundMemberCoefficient = 1;
    case 2
        boundMemberCoefficient = 1/sqrt(1.35);
    case 3
        boundMemberCoefficient = 0.707;
    case 4
        boundMemberCoefficient = 0.607;
end
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
cellGrid.initializeCellNodesAndMembers();
cellGrid.initializeIndices();

%loads and supports
switch caseNum
     case 0
        loadcase = PhyLoadCase();
        loadNodeIndex = cellGrid.findNodeIndex(xMax, yMax/2);
        load = PhyLoad(loadNodeIndex, -1, 0);
        loadcase.loads = {load};
        loadcases = {loadcase};
        spacing = 1/splitNum;
        nodeNum = splitNum*yMax + 1;
        supports = cell(nodeNum, 1);
        for i = 1:nodeNum+1
            supportNodeIndex = cellGrid.findNodeIndex(0, (i-1) * spacing); 
            support = PhySupport(supportNodeIndex);
            supports{i, 1} = support;
        end
    case 1
        loadcase = PhyLoadCase();
        loadNodeIndex = cellGrid.findNodeIndex(xMax, 0);
        load = PhyLoad(loadNodeIndex, -1, 0);
        load2NodeIndex = cellGrid.findNodeIndex(xMax, cellSize);
        load2 = PhyLoad(load2NodeIndex, -1, 0);
        loadcase.loads = {load2};
        loadcases = {loadcase};

        support1NodeIndex = cellGrid.findNodeIndex(0, 0);
        support2NodeIndex = cellGrid.findNodeIndex(0, yMax);
        support3NodeIndex = cellGrid.findNodeIndex(0, cellSize);
        support1 = PhySupport(support1NodeIndex);
        support2 = PhySupport(support2NodeIndex, 1, 0);
        support3 = PhySupport(support3NodeIndex);
        supports = {support1; support3};
    case 2
        loadcase = PhyLoadCase();
        loadNodeIndex = cellGrid.findNodeIndex(xMax, 0);
        load = PhyLoad(loadNodeIndex, 0, -1);
        loadcase.loads = {load};
        loadcases = {loadcase};

        support1NodeIndex = cellGrid.findNodeIndex(0, 0);
        support2NodeIndex = cellGrid.findNodeIndex(0, yMax);
        support1 = PhySupport(support1NodeIndex);
        support2 = PhySupport(support2NodeIndex, 1, 0);
        supports = {support1; support2};
     case 3
        loadcase = PhyLoadCase();
        loadNodeIndex = cellGrid.findNodeIndex(xMax/2, 0);
        load = PhyLoad(loadNodeIndex, 0, -1);
        loadcase.loads = {load};
        loadcases = {loadcase};

        support1NodeIndex = cellGrid.findNodeIndex(0, 0);
        support2NodeIndex = cellGrid.findNodeIndex(xMax, 0);
        support1 = PhySupport(support1NodeIndex);
        support2 = PhySupport(support2NodeIndex, 1, 1);
        supports = {support1; support2};
     case 4
        loadcase = PhyLoadCase();
        loadNodeIndex = cellGrid.findNodeIndex(xMax,yMax/2);
        load = PhyLoad(loadNodeIndex, 0, -1);
        loadcase.loads = {load};
        loadcases = {loadcase};
        nodeNum = splitNum*yMax + 1;
        spacing = 1/splitNum;
        supports = cell(nodeNum, 1);
        for i = 1:nodeNum+1
            if (i-1) * spacing > yMax/3 && (i-1) * spacing < 2*yMax/3
                supportNodeIndex = cellGrid.findNodeIndex(0, (i-1) * spacing); 
                support = PhySupport(supportNodeIndex);
                supports{i, 1} = support;
            end
        end
        supports = supports(~cellfun('isempty',supports));
    case 5
        loadcase = PhyLoadCase();
        loadNodeIndex = cellGrid.findNodeIndex(xMax,yMax/2);
        load = PhyLoad(loadNodeIndex, 0, -1);
        loadcase.loads = {load};
        loadcases = {loadcase};
        nodeNum = splitNum*yMax + 1;
        spacing = 1/splitNum;
        supports = cell(nodeNum, 1);
        for i = 1:nodeNum+1
            if (i-1) * spacing > yMax/3 && (i-1) * spacing < 2*yMax/3
                supportNodeIndex = cellGrid.findNodeIndex(0, (i-1) * spacing); 
                support = PhySupport(supportNodeIndex);
                supports{i, 1} = support;
            end
        end
        supports = supports(~cellfun('isempty',supports));
 end

    %construct Optimization problem
    solverOptions = OptOptions();
    solverOptions.cellOptimization=1;
    cellProblem = OptProblem();
    cellProblem.createProblem(cellGrid, loadcases, supports, solverOptions);
    cellProblem.createComplexCellLinks(cellGrid, maxArea, boundMemberCoefficient);

    %solve the problem
    [conNum, varNum, objVarNum] = cellProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    cellProblem.initializeProblem(matrix);
    [vars, result] = mosekSolve(matrix, 0);
    matrix.feedBackResult(vars);
    cellProblem.feedBackResult(1);
    %cellGrid.plotMembers();
    firstRowVolumePercentage = calcCellsVolume(cellGrid.cells(:,1))/result;
    title = "CellRatio = "+num2str(boundMemberCoefficient)+" Result = "+num2str(result);
    cellGrid.plotMembers('title', title, 'nodalForce', true);          
%end
