groundStructure = GeoGroundStructure;
xStart=0; xEnd = 10; yStart = 15; yEnd=20; xSpacing = 1; ySpacing = 1;
groundStructure.createCustomizedNodeGrid(xStart, yStart, xEnd, yEnd, xSpacing, ySpacing);
groundStructure.createNodesFromGrid();
groundStructure.createGroundStructureFromNodeGrid();

load1NodeIndex = groundStructure.findOrAppendNode(0, yEnd);
load2NodeIndex = groundStructure.findOrAppendNode(xEnd, yEnd);
load1 = PhyLoad(load1NodeIndex, 0.1, 0);
load2 = PhyLoad(load2NodeIndex, 0.1, 0);
loadcase = PhyLoadCase();
loadcase.loads = {load1};
loadcases = {loadcase};
trussProblem = OptProblem();
solverOptions = OptOptions();

%     support1NodeIndex = groundStructure.findOrAppendNode(0, 8);
%     support2NodeIndex = groundStructure.findOrAppendNode(10, 8);
%     support1 = PhySupport(support1NodeIndex);
%     support2 = PhySupport(support2NodeIndex);
%     supports = {support1; support2};
    
trussProblem.createProblem(groundStructure, loadcases, [], solverOptions);

%      [conNum, varNum, objVarNum] = trussProblem.getConAndVarNum();
%      matrix = ProgMatrix(conNum, varNum, objVarNum);
%      trussProblem.initializeProblem(matrix);
%      result = mosekSolve(matrix, 1);
%     matrix.feedBackResult(result);
%     trussProblem.feedBackResult(1);
%     groundStructure.plotMembers('title', "trussTest");

 xEndMesh = 10; yEndMesh = 15; meshSpacing = 0.25;
 matlabMesh = createRectangularMeshMK2(xEndMesh, yEndMesh, meshSpacing);
%  matlabMesh.Nodes = [0,0;1,0;0,1]';
%  matlabMesh.Elements = [1, 2, 3]';
edges = createMeshEdges(matlabMesh);
matlabMesh.Edges = edges;
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);
uniformSupports1 = PhyUniformSupport([-0.001, xEndMesh+0.001; 0, 0], 1, 1, matlabMesh);
supports = [uniformSupports1.supports];
continuumProblem = COptProblem();
% uniformLoad = PhyUniformLoad([0, 0; 1, 1], 0, -0.01, matlabMesh);
continuumLoadcase = PhyLoadCase();
%continuumLoadcase.loads = [uniformLoad.loads];
continuumLodacases = {continuumLoadcase};
continuumProblem.createProblem(mesh, edges, continuumLodacases, supports, solverOptions);

%     [conNum, varNum, objVarNum] = continuumProblem.getConAndVarNum();
%     matrix = ProgMatrix(conNum, varNum, objVarNum);
%     continuumProblem.initializeProblem(matrix);
%     result = mosekSolve(matrix, 1);
%     matrix.feedBackResult(result);
%     continuumProblem.feedBackResult(1);
%     volume = mesh.calculateVolume()
%     mesh.plotMesh( 'fixedMaximumDensity', false);

hybridGeoInfo = GeoHybridMesh(groundStructure, matlabMesh, mesh);
hybridGeoInfo.findOverlappingNodes();

hybridProblem = HybridProblem(hybridGeoInfo, continuumProblem, trussProblem);
hybridProblem.createHybridElements(size(loadcases, 1), 0.1);

[coptConNum, coptVarNum, coptObjVarNum] = continuumProblem.getConAndVarNum();
[trussConNum, trussVarNum, trussObjVarNum] = trussProblem.getConAndVarNum();
matrix = ProgMatrix(coptConNum + trussConNum, coptVarNum + trussVarNum, coptObjVarNum + trussObjVarNum);
hybridProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
trussProblem.feedBackResult(1);
continuumProblem.feedBackResult(1);
mesh.plotMesh('fixedMaximumDensity', false, 'xLimit', xEndMesh, 'yLimit', yEnd);
volume = mesh.calculateVolume()
groundStructure.plotMembers();
