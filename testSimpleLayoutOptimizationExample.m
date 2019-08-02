function obj = testSimpleLayoutOptimizationExample()
    groundStructure = GeoGroundStructure;
    x=10;y=20;
    groundStructure.createCustomizedNodeGrid(0, 0, x, y, 1, 1);
    groundStructure.createNodesFromGrid();
    loadcase = PhyLoadCase();
    load1NodeIndex = groundStructure.findOrAppendNode(0, y);
    load2NodeIndex = groundStructure.findOrAppendNode(x, y);
    load1 = PhyLoad(load1NodeIndex, 0.1, 0);
    load2 = PhyLoad(load2NodeIndex, 0.1, 0);
    loadcase.loads = {load1; load2};
    loadcases = {loadcase};
    
    supports = cell(11, 1);
    for i = 1:11
        supportNodeIndex = groundStructure.findOrAppendNode((i-1)*1, 0);
        support = PhySupport(supportNodeIndex);
        supports{i, 1} = support;
    end
%    support1NodeIndex = groundStructure.findOrAppendNode(0, 0);
%     support2NodeIndex = groundStructure.findOrAppendNode(9, 0);
%     support1 = PhySupport(support1NodeIndex);
%     support2 = PhySupport(support2NodeIndex,0,1);
%     supports = {support1; support2};
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