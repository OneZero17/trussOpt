clear
for i = 1:1
    for j = 1:1
    loadMagnitude = [0.05, 0.1, 0.2, 0.3];
    spacing = [1, 0.25; 0.5, 0.25];
    %spacing = [0.5, 0.125; 0.25, 0.125];
    runHybridProblem(0, 10, 10, 20, spacing(j, 1),spacing(j, 2), 1, i, 1, loadMagnitude(i))
    end
end
%runHybridProblem(0, 10, 2.5, 5,0.5,0.25, 2, 1, 1)

function runHybridProblem(xStart, xEnd, yStart, yEnd, discreteSpacing, continuumSpacing, caseNumber, figNumber, thickness, loadMagnitude)
    clearvars -except xStart xEnd yStart yEnd discreteSpacing continuumSpacing caseNumber figNumber thickness loadMagnitude
    %% Build truss problem
    groundStructure = GeoGroundStructure;
    xSpacing = discreteSpacing; ySpacing = discreteSpacing;
    groundStructure.createCustomizedNodeGrid(xStart, yStart, xEnd, yEnd, xSpacing, ySpacing);
    groundStructure.createNodesFromGrid();
    groundStructure.createGroundStructureFromNodeGrid();
    loadcase = PhyLoadCase();
    switch caseNumber
        case 1
            load1NodeIndex = groundStructure.findOrAppendNode(0, yEnd);
            load2NodeIndex = groundStructure.findOrAppendNode(xEnd, yEnd);
            load1 = PhyLoad(load1NodeIndex, loadMagnitude, 0);
            load2 = PhyLoad(load2NodeIndex, loadMagnitude, 0);
            loadcase.loads = {load1; load2};
        case 2
            
    end
    loadcases = {loadcase};
    trussProblem = OptProblem();
    solverOptions = OptOptions();   
    trussProblem.createProblem(groundStructure, loadcases, [], solverOptions);

    %% Build continuum problem
    xEndMesh = xEnd; yEndMesh = yStart; meshSpacing = continuumSpacing;
    matlabMesh = createRectangularMeshMK2(xEndMesh, yEndMesh, meshSpacing);
    edges = createMeshEdges(matlabMesh);
    boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, yEndMesh; xEndMesh, yEndMesh, xEndMesh, 0; xEndMesh, 0, 0, 0]);
    edges = [edges, boundaryList];
    matlabMesh.Edges = edges;
    mesh = Mesh(matlabMesh);
    mesh.createEdges(edges);
    continuumProblem = COptProblem();
    continuumLoadcase = PhyLoadCase();  
    switch caseNumber
        case 1
            uniformSupports1 = PhyUniformSupport([-0.001, xEnd+0.001; 0, 0], 1, 1, matlabMesh);
%             uniformSupports2 = PhyUniformSupport([xEnd-0.5, xEnd+0.001; 0, 0], 1, 1, matlabMesh);
            supports = [uniformSupports1.supports];
        case 2
            uniformLoad =PhyUniformLoad([xEndMesh/2 - 0.5, xEndMesh/2 + 0.5; 0, 0], 0, -loadMagnitude, matlabMesh);
            continuumLoadcase.loads = [uniformLoad.loads];
            uniformSupports1 = PhyUniformSupport([-0.001, 0.5; -0.001, 0.001], 1, 1, matlabMesh);
            uniformSupports2 = PhyUniformSupport([xEnd-0.5, xEnd+0.001; -0.001, 0.001], 0, 1, matlabMesh);
            supports = [uniformSupports1.supports; uniformSupports2.supports];  
    end
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
    title = "Hybrid optimization - Load: " + loadMagnitude + " volume: " + volume;
    groundStructure.plotMembers('title', title, 'figureNumber', figNumber);
    filename = "Case_"+caseNumber+"_Load_" + loadMagnitude+"_ContinuumSpacing_"+continuumSpacing+"_discreteSpacing_"+discreteSpacing + ".png";
    mesh.plotMesh('fixedMaximumDensity', false, 'xLimit', xEndMesh, 'yLimit', yEnd, 'figureNumber', figNumber, 'fileName', filename);
    
end
