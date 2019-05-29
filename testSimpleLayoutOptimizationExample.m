function obj = testSimpleLayoutOptimizationExample()
    groundStructure = GeoGroundStructure;
    x=5;y=5;
    groundStructure= groundStructure.createRectangularNodeGrid(x, y);
    loadcase = PhyLoadCase();
    [groundStructure, loadNodeIndex] = groundStructure.findOrAppendNode(x, 0);
    load = PhyLoad(loadNodeIndex, 0, -1);
    loadcase.loads = {load};
    loadcases = {loadcase};
    
    [groundStructure, support1NodeIndex] = groundStructure.findOrAppendNode(0, 0);
    [groundStructure, support2NodeIndex] = groundStructure.findOrAppendNode(0, y);
    support1 = PhySupport(support1NodeIndex);
    support2 = PhySupport(support2NodeIndex);
    supports = {support1; support2};
    groundStructure = groundStructure.createGroundStructureFromNodeGrid();
    
    solverOptions = OptOptions();
    
    trussProblem = OptProblem();
    trussProblem = trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);
    
    [conNum, varNum] = trussProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum)
    [trussProblem, matrix] = trussProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 0);
    answer = result.sol.bas.xx;
end