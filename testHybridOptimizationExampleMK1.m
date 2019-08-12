clear
x = 1; y = 10; load = 0.3;
thickness = 1; setContinuumLevel = 0.6;
matlabMesh = createRectangularMeshMK2(x, y, 0.5);
fullNodeGrid = matlabMesh.Nodes';
edges = createMeshEdges(matlabMesh);
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);
boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
edges = [edges, boundaryList];

loadRange = [0.5, 0.5; 0, 0];
uniformLoad1 = PhyUniformLoad(loadRange, 0, load, matlabMesh);
loadcase.loads = [uniformLoad1.loads];
loadcases = {loadcase};
supportRange = [-0.001, x+0.001; y, y];
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
groundStructureTemp1 = GeoGroundStructure;
groundStructureTemp1.createCustomizedNodeGrid(0, 0.5, 0, 1, 0.5, 0.5);
groundStructureTemp1.createMemberListFromNodeGrid();
groundStructureTemp2 = GeoGroundStructure;
groundStructureTemp2.createCustomizedNodeGrid(0.5, 0.5, 0.5, 1, 0.5, 0.5);
groundStructureTemp2.createMemberListFromNodeGrid();
groundStructureTemp2.memberList(:, 1:2) = groundStructureTemp2.memberList(:, 1:2) + 2;
groundStructureTemp3 = GeoGroundStructure;
groundStructureTemp3.createCustomizedNodeGrid(1, 0.5, 1, 1, 0.5, 0.5);
groundStructureTemp3.createMemberListFromNodeGrid();
groundStructureTemp3.memberList(:, 1:2) = groundStructureTemp3.memberList(:, 1:2) + 4;

%groundStructure.createCustomizedNodeGrid(0, 0, x-1, y, 1, 1);

%groundStructure.appendNodes([9.5, 5.5; 9.5, 5; 9.5, 4.5]);
groundStructure.nodeGrid = [groundStructureTemp1.nodeGrid; groundStructureTemp2.nodeGrid; groundStructureTemp3.nodeGrid];
%groundStructure.appendNodes(matlabMesh.Nodes');
groundStructure.memberList = [groundStructureTemp1.memberList; groundStructureTemp2.memberList; groundStructureTemp3.memberList];
%groundStructure.createMemberListFromNodeGrid();
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
    supportIndex = groundStructure.findNodeIndex(i*0.5, 1);
    if (supportIndex ~= -1)
        supports{i+1, 1} = PhySupport(supportIndex, 1, 1);
    end
end
supports = supports(~cellfun('isempty', supports));
trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);

%% Create boundary conditions
uniformLoad1 = PhyUniformLoad(loadRange, 0, -0.5, matlabMesh);
loadcase.loads = [uniformLoad1.loads];
loadcases = {loadcase};
uniformSupports = PhyUniformSupport(supportRange, 1, 1, matlabMesh);
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
groundStructure.plotMembers('title', "test", 'figureNumber', 4);
mesh.plotMesh('xLimit', x, 'yLimit', y, 'figureNumber', 4);         

