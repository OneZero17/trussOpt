for i = 5:5
    for j = 2:2
        load = [1, 5, 10, 50, 100];
        load2 = [10, 15, 50, 100, 110];
        xy = [4, 1; 2, 1; 1, 2];
        runContinuumCase(1, 1, 1, 0.025, -0.003, i, true);
        %runContinuumCase(2, xy(j, 1), xy(j, 2), 0.025, -0.001 * load(i), i, false);
        %runContinuumCase(4, 10, 20, 0.25, 0.25, i, true);
    end
end

function runContinuumCase(caseNum, x, y, spacing, load, figureNum, vonMises)
    matlabMesh = createRectangularMeshMK2(x, y, spacing);
    edges = createMeshEdges(matlabMesh);
    boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
    edges = [edges, boundaryList];
    mesh = Mesh(matlabMesh);
    mesh.createEdges(edges);

    switch caseNum
        case 1
            uniformLoad = PhyUniformLoad([x/2 - 0.03, x/2 + 0.03; 0, 0], 0, load, matlabMesh);
            loadcase.loads = [uniformLoad.loads];
            loadcases = {loadcase};

            uniformSupports1 = PhyUniformSupport([-0.001, 0.06; 0, 0], 1, 1, matlabMesh);
            uniformSupports2 = PhyUniformSupport([x-0.06, x; 0, 0], 1, 1, matlabMesh);
            supports = [uniformSupports1.supports; uniformSupports2.supports];
        case 2
            uniformLoad = PhyUniformLoad([x, x; y/2 - 0.05, y/2 + 0.05], load, 0, matlabMesh);
            loadcase.loads = [uniformLoad.loads];
            loadcases = {loadcase};
            
            uniformSupports1 = PhyUniformSupport([-0.001, 0.001; -0.001, y + 0.001], 1, 1, matlabMesh);
            supports = [uniformSupports1.supports];        
        case 3
            uniformLoad = PhyUniformLoad([x/2 - 0.5, x/2 + 0.5; 0, 0], 0, load, matlabMesh);
            loadcase.loads = [uniformLoad.loads];
            loadcases = {loadcase};
            
            uniformSupports1 = PhyUniformSupport([-0.001, 0.06; -0.001, 0.06], 1, 1, matlabMesh);
            uniformSupports2 = PhyUniformSupport([y-0.06, y+0.06; -0.001, 0.06], 0, 1, matlabMesh);
            supports = [uniformSupports1.supports; uniformSupports2.supports];  
        case 4
            uniformLoad1 = PhyUniformLoad([0, 0.5; y, y], load, 0, matlabMesh);
            uniformLoad2 = PhyUniformLoad([x-0.5, x; y, y], load, 0, matlabMesh);
            loadcase.loads = [uniformLoad1.loads; uniformLoad2.loads];
            loadcases = {loadcase};
            uniformSupports = PhyUniformSupport([-0.001, x+0.001; 0, 0], 1, 1, matlabMesh);
            supports = [uniformSupports.supports];  
    end
    

    solverOptions = OptOptions();
    solverOptions.useVonMises = vonMises;
    continuumProblem = COptProblem();
    continuumProblem.createProblem(mesh, edges, loadcases, supports, solverOptions, 1);

    [conNum, varNum, objVarNum] = continuumProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    continuumProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 1);
    matrix.feedBackResult(result);
    
    continuumProblem.feedBackResult(1);
    volume = mesh.calculateVolume()
    %filename = "x_"+x+"_y_"+y+"_VonMises_"+vonMises+"_Load_" + load+".png";
    
    step = 10;
    title = ['VonMises: ',num2str(vonMises),' Load: ' , num2str(load) , ' volume: ' , num2str(volume)];
    mesh.plotMesh('title', title, 'figureNumber', 1, 'fixedMaximumDensity', false, 'colorBarHorizontal', x>y, 'xLimit', x, 'yLimit', y);
    for i = 2:step
        continuumProblem.updateDensityCoefficient();
        continuumProblem.calcObjectiveCoefficients(matrix);
        result = mosekSolve(matrix, 1);
        matrix.feedBackResult(result);
        continuumProblem.feedBackResult(1);
        volume = mesh.calculateVolume();
        title = ['VonMises: ',num2str(vonMises),' Load: ' , num2str(load) , ' volume: ' , num2str(volume)];
        mesh.plotMesh('title', title, 'figureNumber', i, 'fixedMaximumDensity', false, 'colorBarHorizontal', x>y, 'xLimit', x, 'yLimit', y);
    end
end