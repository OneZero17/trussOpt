clf
matlabMesh = createRectangularMesh();
edges = createMeshEdges(matlabMesh);
edges(edges(:,1)==0, :) =[];
mesh = Mesh(matlabMesh);
mesh.createEdges(edges);

%%outPutEdges = findNearestEdgesToPoint(matlabMesh, edges, 0, -0.75);
x=10;y=10;
nodeID = findNodes(matlabMesh, 'nearest', [x/2; 0]);
load = PhyLoad(nodeID, 0, -0.8);
loadcase.loads = {load};
loadcases = {loadcase};

support1NodeIndex = findNodes(matlabMesh, 'nearest', [0; 0]);
support2NodeIndex = findNodes(matlabMesh, 'nearest', [x; 0]);
support1 = PhySupport(support1NodeIndex);
support2 = PhySupport(support2NodeIndex);
supports = {support1; support2};
solverOptions = OptOptions();
continuumProblem = COptProblem();
continuumProblem.createProblem(mesh, edges, loadcases, supports, solverOptions);

[conNum, varNum, objVarNum] = continuumProblem.getConAndVarNum();
matrix = ProgMatrix(conNum, varNum, objVarNum);
continuumProblem.initializeProblem(matrix);
result = mosekSolve(matrix, 0);
matrix.feedBackResult(result);
continuumProblem.feedBackResult(1);
mesh.plotMesh();
xx = 0.0;