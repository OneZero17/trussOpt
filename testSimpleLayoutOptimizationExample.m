function obj = testSimpleLayoutOptimizationExample()
    groundStructure = GeoGroundStructure;
    x=10;y=10;
    groundStructure= groundStructure.createRectangularNodeGrid(x, y);
    loadcase = PhyLoadCase();
    [groundStructure, loadNodeIndex] = groundStructure.findOrAppendNode(x, 0);
    load = PhyLoad(loadNodeIndex, 0, -1);
    loadcase.loads = {load};
    loadcases = {loadcase};
    
    [groundStructure, support1NodeIndex] = groundStructure.findOrAppendNode(0, 0);
    [groundStructure, support2NodeIndex] = groundStructure.findOrAppendNode(0, y);
    support1 = PhySupport(support1NodeIndex);
    support2 = PhySupport(support2NodeIndex,1,0);
    supports = {support1; support2};
    groundStructure = groundStructure.createGroundStructureFromNodeGrid();
    solverOptions = OptOptions();
    
    trussProblem = OptProblem();
    trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);
    
    [conNum, varNum] = trussProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum);
    trussProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 0);
    matrix.feedBackResult(result);
    trussProblem.feedBackResult(1);
    groundStructure.plotMembers(0);
end