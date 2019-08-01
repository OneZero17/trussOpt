function obj = testSimpleLayoutOptimizationExample()
    groundStructure = GeoGroundStructure;
    x=10;y=20;
    groundStructure= groundStructure.createRectangularNodeGrid(x, y);
    loadcase = PhyLoadCase();
    load1NodeIndex = groundStructure.findOrAppendNode(0, 20);
    %load2NodeIndex = groundStructure.findOrAppendNode(2, 2);
    load1 = PhyLoad(load1NodeIndex, 1, 0);
    %load2 = PhyLoad(load2NodeIndex, 1, 0);
    loadcase.loads = {load1};
    loadcases = {loadcase};
    
    support1NodeIndex = groundStructure.findOrAppendNode(0, 0);
    support2NodeIndex = groundStructure.findOrAppendNode(10, 0);
    support1 = PhySupport(support1NodeIndex);
    support2 = PhySupport(support2NodeIndex,1,1);
    supports = {support1; support2};
    groundStructure.createGroundStructureFromNodeGrid();
    solverOptions = OptOptions();
    
    trussProblem = OptProblem();
    trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);
    
    [conNum, varNum, objVarNum] = trussProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    trussProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 1);
    matrix.feedBackResult(result);
    trussProblem.feedBackResult(1);
    groundStructure.plotMembers();
end