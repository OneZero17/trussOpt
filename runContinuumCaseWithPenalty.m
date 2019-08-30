function runContinuumCaseWithPenalty(caseNum, x, y, spacing, load, figureNum, vonMises)
    matlabMesh = createRectangularMeshMK2(x, y, spacing);
    edges = createMeshEdges(matlabMesh);
    boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
    edges = [edges, boundaryList];
    mesh = Mesh(matlabMesh);
    mesh.createEdges(edges);

    switch caseNum
        case 1
            uniformLoad = PhyUniformLoad([x, x; y/2-0.75, y/2+0.75], 0, load, matlabMesh);
            loadcase.loads = [uniformLoad.loads];
            loadcases = {loadcase};
            uniformSupports1 = PhyUniformSupport([0, 0; -0.001, y+0.001], 1, 1, matlabMesh);
            supports = [uniformSupports1.supports];
    end
    
    solverOptions = OptOptions();
    solverOptions.useVonMises = vonMises;
    continuumProblem = COptProblem();
    continuumProblem.createProblem(mesh, edges, loadcases, supports, solverOptions, 1);
    time = 0;
    [conNum, varNum, objVarNum] = continuumProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    continuumProblem.initializeProblem(matrix);
    tic
    result = mosekSolve(matrix, 1);
    toc
    time = time + toc;
    matrix.feedBackResult(result);
    
    continuumProblem.feedBackResult(1);
    volume = mesh.calculateVolume();
    %filename = "x_"+x+"_y_"+y+"_VonMises_"+vonMises+"_Load_" + load+".png";
    oldVolume = volume;
    step = 50;
    for i = 2:step
        continuumProblem.updateDensityCoefficient();
        continuumProblem.calcObjectiveCoefficients(matrix);
        tic
        result = mosekSolve(matrix, 1);
        toc
        time = time + toc;
        matrix.feedBackResult(result);
        continuumProblem.feedBackResult(1);
        volume = mesh.calculateVolume();
        if abs(volume - oldVolume) / oldVolume < 0.01
            break
        else
            oldVolume = volume;
        end
    end
    filename = ['x_',num2str(x),'_y_',num2str(y),'_VonMises_',num2str(vonMises),'_Load_' , num2str(load), '.png'];
    title = ['VonMises: ',num2str(vonMises),' Load: ' , num2str(load) , ' volume: ' , num2str(volume), ' time: ', num2str(time), ' iterationNum:', num2str(i)];
    mesh.plotMesh('title', title, 'figureNumber', figureNum, 'fixedMaximumDensity', false, 'colorBarHorizontal', x>y, 'xLimit', x, 'yLimit', y, 'fileName', filename);
end
