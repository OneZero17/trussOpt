thickness = 1;
groundStructure = GeoGroundStructure;
groundStructure.createCustomizedNodeGrid(0, 10, 10, 20, 1, 1);
groundStructure.createNodesFromGrid();
groundStructure.createGroundStructureFromNodeGrid();
loadcase = PhyLoadCase();
load1NodeIndex = groundStructure.findOrAppendNode(5, 20);
load1 = PhyLoad(load1NodeIndex, 0, -1);
loadcase.loads = {load1};
loadcases = {loadcase};
trussProblem = OptProblem();
solverOptions = OptOptions();   
trussProblem.createProblem(groundStructure, loadcases, [], solverOptions);

%% Build continuum problem
xEndMesh = 10; yEndMesh = 10; meshSpacing = 1;
matlabMesh = createRectangularMeshMK2(xEndMesh, yEndMesh, meshSpacing);
edges = createMeshEdges(matlabMesh);
boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, yEndMesh; xEndMesh, yEndMesh, xEndMesh, 0; xEndMesh, 0, 0, 0]);
edges = [edges, boundaryList];
matlabMesh.Edges = edges;
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);
continuumProblem = COptProblem();
continuumLoadcase = PhyLoadCase();  

uniformSupports1 = PhyUniformSupport([-0.001, xEndMesh+0.001; 0, 0], 1, 1, matlabMesh);
supports = [uniformSupports1.supports];
continuumLodacases = {continuumLoadcase};
continuumProblem.createProblem(mesh, edges, continuumLodacases, supports, solverOptions, thickness);

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