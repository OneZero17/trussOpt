for i = 1:5
    for j = 1:3
        load = [1, 5, 10, 50, 100];
        load2 = [10, 15, 50, 100, 110];
        xy = [4, 1; 2, 1; 1, 2];
        runContinuumCase(2, xy(j, 1), xy(j, 2), 0.025, -0.001 * load(i), i, true);
        %runContinuumCase(2, xy(j, 1), xy(j, 2), 0.025, -0.001 * load(i), i, false);
    end
end

function runContinuumCase(caseNum, x, y, spacing, load, figureNum, vonMises)
    matlabMesh = createRectangularMeshMK2(x, y, spacing);
    edges = createMeshEdges(matlabMesh);
    edges(edges(:,1)==0, :) =[];
    mesh = Mesh(matlabMesh);
    mesh.createEdges(edges);

    switch caseNum
        case 1
            uniformLoad = PhyUniformLoad([x/2 - 0.03, x/2 + 0.03; 0, 0], 0, load, matlabMesh);
            loadcase.loads = [uniformLoad.loads];
            loadcases = {loadcase};

            uniformSupports1 = PhyUniformSupport([-0.001, 0.06; -0.001, 0.06], 1, 1, matlabMesh);
            uniformSupports2 = PhyUniformSupport([1.94, 2.001; -0.001, 0.06], 1, 1, matlabMesh);
            supports = [uniformSupports1.supports; uniformSupports2.supports];
        case 2
            uniformLoad = PhyUniformLoad([x, x; y/2 - 0.05, y/2 + 0.05], 0, load, matlabMesh);
            loadcase.loads = [uniformLoad.loads];
            loadcases = {loadcase};
            
            uniformSupports1 = PhyUniformSupport([-0.001, 0.001; -0.001, y + 0.001], 1, 1, matlabMesh);
            supports = [uniformSupports1.supports];        
        case 3
            uniformLoad = PhyUniformLoad([x/2 - 0.03, x/2 + 0.03; 0, 0], 0, load, matlabMesh);
            loadcase.loads = [uniformLoad.loads];
            loadcases = {loadcase};
            
            uniformSupports1 = PhyUniformSupport([-0.001, 0.06; -0.001, 0.06], 1, 1, matlabMesh);
            uniformSupports2 = PhyUniformSupport([1.94, 2.001; -0.001, 0.06], 0, 1, matlabMesh);
            supports = [uniformSupports1.supports; uniformSupports2.supports];  
    end
    

    solverOptions = OptOptions();
    solverOptions.useVonMises = vonMises;
    continuumProblem = COptProblem();
    continuumProblem.createProblem(mesh, edges, loadcases, supports, solverOptions);

    [conNum, varNum, objVarNum] = continuumProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    continuumProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 0);
    matrix.feedBackResult(result);
    continuumProblem.feedBackResult(1);
    volume = mesh.calculateVolume()
    title = "VonMises: "+vonMises+" Load: " + load + " volume: " + volume;
    filename = "x_"+x+"_y_"+y+"_VonMises_"+vonMises+"_Load_" + load+".png";
    mesh.plotMesh('title', title, 'figureNumber', figureNum, 'fileName', filename, 'fixedMaximumDensity', false, 'colorBarHorizontal', x>y, 'xLimit', x, 'yLimit', y);
end