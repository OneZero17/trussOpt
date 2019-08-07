clear
x = 10; y = 10; load = -1.5;
thickness = 1; setContinuumLevel = 0.6;
matlabMesh = createRectangularMeshMK2(x, y, 2);
fullNodeGrid = matlabMesh.Nodes';
edges = createMeshEdges(matlabMesh);
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);
boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
edges = [edges, boundaryList];

uniformLoad1 = PhyUniformLoad([x, x; y/2 - 1, y/2+1], 0, load, matlabMesh);
loadcase.loads = [uniformLoad1.loads];
loadcases = {loadcase};
uniformSupports = PhyUniformSupport([0, 0; -0.001, y+0.001], 1, 1, matlabMesh);
supports = [uniformSupports.supports]; 
 
solverOptions = OptOptions();
solverOptions.useVonMises = true;
continuumProblem = COptProblem();
continuumProblem.createProblem(mesh, edges, loadcases, supports, solverOptions, 1);

[conNum, varNum, objVarNum] = continuumProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
continuumProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 1);
matrix.feedBackResult(result);
continuumProblem.feedBackResult(1);

mesh.plotMesh('title', "Test", 'xLimit', x, 'yLimit', y, 'figureNumber', 1);
%% Create mesh
matlabMesh = mesh.createNewMeshWithSetLevel(matlabMesh, setContinuumLevel);
edges = createMeshEdges(matlabMesh);
boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
edges = [edges, boundaryList];
matlabMesh.Edges = edges;
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);

groundStructure = GeoGroundStructure;
groundStructure.nodeGrid = fullNodeGrid;
groundStructure.createMemberListFromNodeGrid();
tic
deleteOverlappingMembers(groundStructure, matlabMesh);
toc
groundStructure.createNodesFromGrid();
groundStructure.createGroundStructureFromMemberList();

 groundStructure.plotMembers('plotGroundStructure', true, 'figureNumber', 2);
 mesh.plotMesh('xLimit', 20, 'yLimit', 10, 'figureNumber', 2, 'plotGroundStructure', true);
loadcase = PhyLoadCase();
loadcases = {loadcase};
trussProblem = OptProblem();

supports = cell(11, 1);
for  i = 0:10
    supportIndex = groundStructure.findNodeIndex(0, i);
    if (supportIndex ~= -1)
        supports{i+1, 1} = PhySupport(supportIndex, 1, 1);
    end
end
supports = supports(~cellfun('isempty', supports));
trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);

%% Create boundary conditions
uniformLoad1 = PhyUniformLoad([x, x; y/2 - 1, y/2+1], 0, load, matlabMesh);
loadcase.loads = [uniformLoad1.loads];
loadcases = {loadcase};
uniformSupports = PhyUniformSupport([0, 0; -0.001, y+0.001], 1, 1, matlabMesh);
supports = [uniformSupports.supports]; 

continuumProblem = COptProblem();
continuumProblem.createProblem(mesh, edges, loadcases, supports, solverOptions, thickness);

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
groundStructure.calculateVolume()
%% Plot results
groundStructure.plotMembers('title', "test", 'figureNumber', 3);
mesh.plotMesh('xLimit', 20, 'yLimit', 10, 'figureNumber', 3);         

