clear
warning('off','all')
for i = 4:9
    clearvars -except i
    casenum = 2;
    switch casenum  
        case 1
            x = 20; y = 10; thickness = 1; setContinuumLevel = 0.3;
            continuumSpacing = 0.5; discreteSpacing = 2;
            loads = [x, x, y/2-0.75, y/2+0.75, -0.1 * i];
            supports = [0, 0, -0.001, y+0.001, 1, 1];
            %runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.5, 0.05);
            %runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.8, 0.05);
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 1.0, 0.0);
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 1.0, 0.1);
        case 2
            x = 10; y = 5; thickness = 1; setContinuumLevel = 0.3;
            continuumSpacing = 0.5; discreteSpacing = 1;
            loads = [x/2-0.3, x/2+0.3, 0, 0, -0.1*i];
            supports = [0, 0.6, 0, 0.0, 1, 1; x-0.6, x, 0, 0.0, 1, 1];
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.4, 0);
        case 3
            x = 10; y = 5; thickness = 1; setContinuumLevel = 0.3;
            continuumSpacing = 0.125; discreteSpacing = 1.0;
            loads = [x/2-0.3, x/2+0.3, 0, 0, -0.1*i];
            supports = [0, 0.6, 0, 0.0, 1, 1; x-0.6, x, 0, 0.0, 0, 1];
            runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 0.5, 0.1);
            %runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, setContinuumLevel, loads, supports, casenum, 1.0, 0.1);
    end
end


function [outputLoads, outputSupports] = addLoadsAndSupports(matlabMesh, loads, supports)
    outputLoads = [];
    for i = 1:size(loads, 1)
        load = loads(i, end);
        loadRange = [loads(i, 1:2); loads(i, 3:4)];
        uniformLoad = PhyUniformLoad(loadRange, 0, load, matlabMesh);
        outputLoads = [outputLoads; uniformLoad.loads];
    end
    
    outputSupports = [];
    for i = 1:size(supports, 1)
        supportRange = [supports(i, 1:2); supports(i, 3:4)];
        uniformSupports = PhyUniformSupport(supportRange, supports(i, end-1), supports(i, end), matlabMesh);
        outputSupports = [outputSupports; uniformSupports.supports];
    end
end

function runHybridOptimizationCase(x, y, continuumSpacing, discreteSpacing, filterLevel, InputLoads, InputSupports, caseNo, radius, jointLength)
    thickness = 1; setContinuumLevel = filterLevel;
    matlabMesh = createRectangularMeshMK2(x, y, continuumSpacing);
    edges = createMeshEdges(matlabMesh);
    mesh = Mesh(matlabMesh);
    mesh.createEdges(edges);
    boundaryList = determineExternalBoundaryList(matlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
    edges = [edges, boundaryList];

    [meshLoads, meshSupports] = addLoadsAndSupports(matlabMesh, InputLoads, InputSupports);
    loadcase.loads = meshLoads;
    loadcases = {loadcase};

    solverOptions = OptOptions();
    continuumProblem = COptProblem();
    continuumProblem.createProblem(mesh, edges, loadcases, meshSupports, solverOptions, 1);

    [conNum, varNum, objVarNum] = continuumProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    continuumProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 1);
    matrix.feedBackResult(result);
    continuumProblem.feedBackResult(1);
    volume = mesh.calculateVolume(thickness);
    title1 = "Hybrid_optimization_MK3_Case_"+ caseNo+ "_Stage_1_Load_" + InputLoads(1, end) + ".png" ;
    mesh.plotMesh('title', "Test, Volume: " + volume, 'xLimit', x, 'yLimit', y, 'figureNumber', 1, 'fileName', title1);
    title2 = "Hybrid_optimization_MK3_Case_"+ caseNo+ "_Stage_2_Load_" + InputLoads(1, end) + ".png" ;
    mesh.plotMesh('title', "Test", 'xLimit', x, 'yLimit', y, 'figureNumber', 2, 'setLevel', setContinuumLevel, 'fileName', title2);
       
    %% Create continuum problem for Hybrid Optimization
    clearvars -except mesh matlabMesh meshLoads meshSupports setContinuumLevel x y discreteSpacing caseNo InputLoads InputSupports solverOptions thickness continuumSpacing radius jointLength
    newMatlabMesh = mesh.createNewMeshWithSetLevel(matlabMesh, setContinuumLevel);
    edges = createMeshEdges(newMatlabMesh);
    boundaryList = determineExternalBoundaryList(newMatlabMesh.Nodes', edges, [0, 0, 0, y; 0, y, x, y; x, y, x, 0; x, 0, 0, 0]);
    edges = [edges, boundaryList];
    newMatlabMesh.Edges = edges;
    mesh = Mesh(newMatlabMesh);
    mesh.createEdges(edges);
    
    boundaryNodes = unique(reshape(edges(edges(:, 4)==0, 1:2), 1, []));
    
    mesh.plotMesh('title', "Test", 'xLimit', x, 'yLimit', y, 'figureNumber', 5,'plotGroundStructure', true);
    
    [newMeshLoads, newMeshSupports] = addLoadsAndSupports(newMatlabMesh, InputLoads, InputSupports);
    unloadedPoints=[]; unLoadedPointIndices=[]; unSupportedPoints=[]; unSupportedIndices=[];
    
    loadedAndSupportedNodes = zeros(size(newMeshLoads, 1) + size(newMeshSupports, 1), 1);
    for i = 1:size(newMeshLoads, 1)
        loadedAndSupportedNodes(i, 1) = newMeshLoads{i, 1}.nodeIndex;
    end
    
    for i = 1:size(newMeshSupports, 1)
        loadedAndSupportedNodes(size(newMeshLoads, 1)+i, 1) = newMeshSupports{i, 1}.node;
    end
     
    if size(newMeshLoads, 1) ~= size(meshLoads, 1)
        loadX = meshLoads{1, 1}.loadX;
        loadY = meshLoads{1, 1}.loadY;
        oldLoadPoints = zeros(size(meshLoads, 1), 2);
        for i = 1:size(meshLoads, 1)
            oldLoadPoints(i, :) = matlabMesh.Nodes(:, meshLoads{i, 1}.nodeIndex)';
        end
        
        newLoadPoints = zeros(size(newMeshLoads, 1), 2);
        for i = 1:size(newLoadPoints)
            newLoadPoints(i, :) = newMatlabMesh.Nodes(:, newMeshLoads{i, 1}.nodeIndex)';
            newMeshLoads{i, 1}.loadX = loadX;
            newMeshLoads{i, 1}.loadY = loadY;
        end
        [unloadedPoints, unLoadedPointIndices] = setdiff(oldLoadPoints, newLoadPoints, 'rows');
    end
    
    
    if size(newMeshSupports, 1) ~= size(meshSupports, 1)
        oldSupportPoints = zeros(size(meshSupports, 1), 2);
        for i = 1:size(meshSupports, 1)
            oldSupportPoints(i, :) = matlabMesh.Nodes(:, meshSupports{i, 1}.node)';
        end
        
        newSupportPoints = zeros(size(newMeshSupports, 1), 2);
        for i = 1:size(newMeshSupports)
            newSupportPoints(i, :) = newMatlabMesh.Nodes(:, newMeshSupports{i, 1}.node)';
        end
        [unSupportedPoints, unSupportedIndices] = setdiff(oldSupportPoints, newSupportPoints, 'rows');
    end
    
    loadcase.loads = newMeshLoads;
    loadcases = {loadcase};

    continuumProblem = COptProblem();
    continuumProblem.createProblem(mesh, edges, loadcases, newMeshSupports, solverOptions, thickness);

    %% Create discrete problem for Hybrid Optimization
    groundStructure = GeoGroundStructure;
    groundStructure.createCustomizedNodeGrid(0, 0, x, y, discreteSpacing, discreteSpacing);
    
    groundStructure.appendNodes([unloadedPoints; unSupportedPoints]);
    groundStructure.appendNodes(newMatlabMesh.Nodes(:, boundaryNodes)');
    groundStructure.continuumNodeNum = 0;
    
    groundStructure.createMemberListFromNodeGrid();
    tic
    deleteOverlappingMembers(groundStructure, newMatlabMesh, continuumSpacing);
    toc
    groundStructure.createNodesFromGrid();
    groundStructure.createGroundStructureFromMemberList();

    title3 = "Hybrid_optimization_MK3_Case_"+ caseNo+ "_Stage_3_Load_" + InputLoads(1, end) + ".png" ;
    groundStructure.plotMembers('plotGroundStructure', true, 'figureNumber', 3);
    mesh.plotMesh('xLimit', 20, 'yLimit', 10, 'figureNumber', 3, 'plotGroundStructure', true, 'fileName', title3);
    loadcase = PhyLoadCase();
    if ~isempty(unloadedPoints)
        loads = cell(size(unloadedPoints, 1), 1);
        for i = 1:size(unloadedPoints, 1)
            loadX = meshLoads{unLoadedPointIndices(i, 1), 1}.loadX;
            loadY = meshLoads{unLoadedPointIndices(i, 1), 1}.loadY;
            loadIndex = groundStructure.findNodeIndex(unloadedPoints(i, 1), unloadedPoints(i, 2));
            loads{i, 1} = PhyLoad(loadIndex, loadX, loadY);
        end
        loadcase.loads = loads;
    end
    loadcases = {loadcase};
    
    supports = [];
    if ~isempty(unSupportedPoints)
        supports = cell(size(unSupportedPoints, 1), 1);
        for i = 1:size(unSupportedPoints, 1)
            fixedX = meshSupports{unSupportedIndices(i, 1), 1}.fixedX;
            fixedY = meshSupports{unSupportedIndices(i, 1), 1}.fixedY;
            supportIndex = groundStructure.findNodeIndex(unSupportedPoints(i, 1), unSupportedPoints(i, 2));
            supports{i, 1} = PhySupport(supportIndex, fixedX, fixedY);
        end
    end 
    
    trussProblem = OptProblem();
    trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions, 0);

    hybridGeoInfo = GeoHybridMesh(groundStructure, newMatlabMesh, mesh);
    hybridGeoInfo.findOverlappingNodes();
    hybridGeoInfo.findNodesWithinRadius(radius, loadedAndSupportedNodes);
    hybridProblem = HybridProblem(hybridGeoInfo, continuumProblem, trussProblem);
    hybridProblem.createHybridElementsWithinRadius(size(loadcases, 1));
    hybridProblem.addJointLengthToHybridNodes(jointLength);

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
    title4 = "Hybrid_optimization_MK3_Case_"+ caseNo+ "_Stage_4_Load_" + InputLoads(1, end)+"_Radius_" + +radius + "_JointLength_" + jointLength + ".png" ;
    groundStructure.plotMembers('title', "test:"+"Volume: " + volume, 'figureNumber', 4);
    mesh.plotMesh('xLimit', x, 'yLimit', y, 'figureNumber', 4, 'fileName', title4); 
end