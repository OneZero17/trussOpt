clear
thickness = 1;
groundStructure = GeoGroundStructure;

groundStructure.createCustomizedNodeGrid(0, 0.5, 1, 2, 0.5, 0.5);
groundStructure.createNodesFromGrid();
groundStructure.createGroundStructureFromNodeGrid();
loadcase = PhyLoadCase();
loadcases = {loadcase};
% load1NodeIndex = groundStructure.findOrAppendNode(5, 20);
% load1 = PhyLoad(load1NodeIndex, 0, -1);
% loadcase.loads = {load1};
% loadcases = {loadcase};
supports = cell(3, 1);
for  i = 0:2
    supportIndex = groundStructure.findNodeIndex(i*0.5, 2);
    if (supportIndex ~= -1)
        supports{i+1, 1} = PhySupport(supportIndex, 1, 1);
    end
end
trussProblem = OptProblem();
solverOptions = OptOptions();   
trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);

%% Build continuum problem
xEndMesh = 1; yEndMesh = 0.5; meshSpacing = 0.5;
matlabMesh = createRectangularMeshMK2(xEndMesh, yEndMesh, meshSpacing);
edges = createMeshEdges(matlabMesh);
boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, yEndMesh; xEndMesh, yEndMesh, xEndMesh, 0; xEndMesh, 0, 0, 0]);
edges = [edges, boundaryList];
matlabMesh.Edges = edges;
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);
continuumProblem = COptProblem();
continuumLoadcase = PhyLoadCase();  

uniformLoad1 = PhyUniformLoad([0.5, 0.5; 0, 0], 0, 0.5, matlabMesh);
loadcase.loads = [uniformLoad1.loads];
loadcases = {loadcase};

uniformSupports1 = PhyUniformSupport([-0.001, xEndMesh+0.001; 0, 0], 1, 1, matlabMesh);
supports = [uniformSupports1.supports];
continuumLodacases = {continuumLoadcase};
continuumProblem.createProblem(mesh, edges, loadcases, [], solverOptions, thickness);

%% Build hybrid elements
hybridGeoInfo = GeoHybridMesh(groundStructure, matlabMesh, mesh);
hybridGeoInfo.findOverlappingNodes();
hybridProblem = HybridProblem(hybridGeoInfo, continuumProblem, trussProblem);
hybridProblem.createHybridElements(size(loadcases, 1));

%% Build conic programming matrix and solve
[coptConNum, coptVarNum, coptObjVarNum] = continuumProblem.getConAndVarNum();
[trussConNum, trussVarNum, trussObjVarNum] = trussProblem.getConAndVarNum();
matrix = ProgMatrix(coptConNum + trussConNum, coptVarNum + trussVarNum, coptObjVarNum + trussObjVarNum);
hybridProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
trussProblem.feedBackResult(1);
continuumProblem.feedBackResult(1);
volume = mesh.calculateVolume(thickness) + groundStructure.calculateVolume();
%% Plot results
title = "Hybrid optimization - Load: " + 1 + " volume: " + volume;
groundStructure.plotMembers('title', title, 'figureNumber', 1);
mesh.plotMesh('fixedMaximumDensity', false, 'xLimit', 10, 'yLimit', 20, 'figureNumber', 1);