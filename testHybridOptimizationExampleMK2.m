clear
x = 30; y = 10; load = -0.5;
thickness = 1; setContinuumLevel = 0.2;
matlabMesh = createRectangularMeshMK2(x, y, 0.5);
fullNodeGrid = matlabMesh.Nodes';
edges = createMeshEdges(matlabMesh);
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);
boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
edges = [edges, boundaryList];

loadRange = [x, x; y/2-0.5, y/2+0.5];
uniformLoad1 = PhyUniformLoad(loadRange, 0, load, matlabMesh);
loadcase.loads = [uniformLoad1.loads];
loadcases = {loadcase};
supportRange = [0, 0; -0.001, y+0.001];
uniformSupports = PhyUniformSupport(supportRange, 1, 1, matlabMesh);
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
volume = mesh.calculateVolume(thickness);
mesh.plotMesh('title', "Test", 'xLimit', x, 'yLimit', y, 'figureNumber', 1);
mesh.plotMesh('title', "Test", 'xLimit', x, 'yLimit', y, 'figureNumber', 2, 'setLevel', setContinuumLevel);
%% Create mesh
matlabMesh = mesh.createNewMeshWithSetLevel(matlabMesh, setContinuumLevel);
edges = createMeshEdges(matlabMesh);
boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
edges = [edges, boundaryList];
matlabMesh.Edges = edges;
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);

groundStructure = GeoGroundStructure;
groundStructure.createCustomizedNodeGrid(0, 0, x, y, 1, 1);

groundStructure.appendNodes(matlabMesh.Nodes');
groundStructure.createMemberListFromNodeGrid();
tic
deleteOverlappingMembers(groundStructure, matlabMesh);
toc
groundStructure.createNodesFromGrid();
groundStructure.createGroundStructureFromMemberList();

groundStructure.plotMembers('plotGroundStructure', true, 'figureNumber', 3);
mesh.plotMesh('xLimit', 20, 'yLimit', 10, 'figureNumber', 3, 'plotGroundStructure', true);
loadcase = PhyLoadCase();
loadcases = {loadcase};
trussProblem = OptProblem();

supports = cell(11, 1);
for  i = 0:20
    supportIndex = groundStructure.findNodeIndex(0, i*0.5);
    if (supportIndex ~= -1)
        supports{i+1, 1} = PhySupport(supportIndex, 1, 1);
    end
end
supports = supports(~cellfun('isempty', supports));
trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);

%% Create boundary conditions
uniformLoad1 = PhyUniformLoad(loadRange, 0, load, matlabMesh);
loadcase.loads = [uniformLoad1.loads];
loadcases = {loadcase};
uniformSupports = PhyUniformSupport(supportRange, 1, 1, matlabMesh);
supports = [uniformSupports.supports]; 
continuumProblem = COptProblem();
continuumProblem.createProblem(mesh, edges, loadcases, supports, solverOptions, thickness);

hybridGeoInfo = GeoHybridMesh(groundStructure, matlabMesh, mesh);
hybridGeoInfo.findOverlappingNodes();
hybridProblem = HybridProblem(hybridGeoInfo, continuumProblem, trussProblem);
hybridProblem.createHybridElements(size(loadcases, 1));

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
groundStructure.plotMembers('title', "test:"+"Volume: " + volume, 'figureNumber', 4);
mesh.plotMesh('xLimit', x, 'yLimit', y, 'figureNumber', 4); 