clear
caseNo = 1;
switch caseNo
    case 1
    x=50; y=50; z=150;
    spacing = 12.5;
    groundStructure = GeoGroundStructure3D;
    groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);
    groundStructure.createMembersFromNodes(); 
    
    groundStructure.members = deleteCollinearMembers(groundStructure.nodes, groundStructure.members);
    loadcase1 = PhyLoadCase();
    load1NodeIndex = groundStructure.findNodeIndex([x/2, 0, z]);
    load1 = PhyLoad3D(load1NodeIndex, 0.0, 5.0, 0.0);
    loadcase1.loads = {load1};

    loadcase2 = PhyLoadCase();
    load2NodeIndex = groundStructure.findNodeIndex([x/2, y/2, z]);
    load2 = PhyLoad3D(load1NodeIndex, 5.0, 0.0, 0.0);
    loadcase2.loads = {load2};
    loadcases = {loadcase1};

    %support1NodeIndex = groundStructure.findNodeIndex([0, 0, 0]);
    support2NodeIndex = groundStructure.findNodeIndex([x/2, 0, 0]);
    support3NodeIndex = groundStructure.findNodeIndex([0, 0, 75]);
    support4NodeIndex = groundStructure.findNodeIndex([x, 0, 75]);
    %support1 = PhySupport3D(support1NodeIndex, 1, 1, 1);
    support2 = PhySupport3D(support2NodeIndex, 1, 1, 1);
    support3 = PhySupport3D(support3NodeIndex, 1, 1, 1);
    support4 = PhySupport3D(support4NodeIndex, 1, 1, 1);
    supports = {support2; support3; support4};
    case 2
    x=50; y=50; z=50;
    spacing = 12.5;   
    groundStructure = GeoGroundStructure3D;
    groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);
    groundStructure.createMembersFromNodes();
    loadcase1 = PhyLoadCase();
    load1NodeIndex = groundStructure.findNodeIndex([x/2, y/2, z]);
    load1 = PhyLoad3D(load1NodeIndex, 0.0, 5.0, 0.00);
    loadcase1.loads = {load1};
    
    loadcase2 = PhyLoadCase();
    load2NodeIndex = groundStructure.findNodeIndex([x/2, y/2, z]);
    load2 = PhyLoad3D(load2NodeIndex, 5.0, 0.0, 0.00);
    loadcase2.loads = {load2};    
    
    loadcases = {loadcase1; loadcase2};
    support1NodeIndex = groundStructure.findNodeIndex([12.5, 12.5, 0]);
    support2NodeIndex = groundStructure.findNodeIndex([37.5, 12.5, 0]);
    support3NodeIndex = groundStructure.findNodeIndex([37.5, 37.5, 0]);
    support4NodeIndex = groundStructure.findNodeIndex([12.5, 37.5, 0]);
    support1 = PhySupport3D(support1NodeIndex, 1, 1, 1);
    support2 = PhySupport3D(support2NodeIndex, 1, 1, 1);
    support3 = PhySupport3D(support3NodeIndex, 1, 1, 1);
    support4 = PhySupport3D(support4NodeIndex, 1, 1, 1);
    supports = {support1; support2; support3; support4};   
    case 3
    x=50; y=150; z=50;
    spacing = 12.5;   
    groundStructure = GeoGroundStructure3D;
    groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);
    groundStructure.createMembersFromNodes();
    loadcase1 = PhyLoadCase();
    load1NodeIndex = groundStructure.findNodeIndex([x/2, y, 0]);
    load1 = PhyLoad3D(load1NodeIndex, 0.0, 0.0, -5.0);
    loadcase1.loads = {load1};    
    
    loadcases = {loadcase1};
    support1NodeIndex = groundStructure.findNodeIndex([x/2, 0, 0]);
    support2NodeIndex = groundStructure.findNodeIndex([0, 75, 0]);
    support3NodeIndex = groundStructure.findNodeIndex([x, 75, 0]);
    support1 = PhySupport3D(support1NodeIndex, 1, 1, 1);
    support2 = PhySupport3D(support2NodeIndex, 1, 1, 1);
    support3 = PhySupport3D(support3NodeIndex, 1, 1, 1);
    supports = {support1; support2; support3};   
end

solverOptions = OptOptions();
solverOptions.nodalSpacing = spacing * 1.75;

[forceList, potentialMemberList, initialVolume] = memberAdding(groundStructure, loadcases, supports, solverOptions);
%groundStructure.plotMembers(forceList);
%
structure = groundStructure.createOptimizedStructureList(forceList);
structure = mergeCollinear(structure);
plotStructure3D(structure, 1);
toRhino('rhinoFiles', 'truss', structure);

%% Building sectors
% tempStructure = [0 0 0 0 50 0 10];
% structure = tempStructure;
floorSpacing = 12.5;
splineSpacing = 2.5;
maximumTurnAngle = 0.5;
nozzleMaxAngle = 0.809;
checkingMaxAngle = 0.977;
reRunTurnedOn = false;
floorLineZ = 0:floorSpacing:z;
membersInEachFloor = splitSector3DInZ(structure, floorLineZ);

anglesForEachFloor = cell(size(membersInEachFloor, 1), 1);
splintLineX = -5:splineSpacing:x + 5;
splintLineY = -5:splineSpacing:y + 5;
[floorSurfaceX, floorSurfaceY] = meshgrid(splintLineX, splintLineY);

floorGap = 0; 
figure(1)
hold on
%tiledlayout(2,2);
%figure(2)
% t = tiledlayout(3, 4, 'TileSpacing','compact');
cuttingSurfaces = cell(size(membersInEachFloor, 1), 1);
%: size(membersInEachFloor, 1)
for floorNum = 1 
    reRun = true;
    while reRun
        if floorNum==1
            figure(1)
            floorSurfaceZ=zeros(size(floorSurfaceX, 1), size(floorSurfaceX, 2))+ (floorNum - 1) * floorGap + floorGap/2;
            s = surf(floorSurfaceX,floorSurfaceY,floorSurfaceZ, 'FaceAlpha',0.2) ;
            s.EdgeColor = 'none';
            s.FaceColor = [0.6 0.6 0.6];
        end
        currentFloor = membersInEachFloor{floorNum, 1};
        currentFloor(:, 3) = currentFloor(:, 3) + (floorNum - 1) * floorGap;
        currentFloor(:, 6) = currentFloor(:, 6) + (floorNum - 1) * floorGap;
        floorSurfaceZ=floorLineZ(floorNum + 1)*ones(size(floorSurfaceX, 1), size(floorSurfaceX, 2))+ (floorNum - 1) * floorGap + floorGap/2;
        figure(1)
        s = surf(floorSurfaceX,floorSurfaceY,floorSurfaceZ, 'FaceAlpha',0.2) ;
        s.EdgeColor = 'none';
        s.FaceColor = [0.6 0.6 0.6];
        view([1 1 1])
        textheight = floorLineZ(floorNum + 1) + (floorNum - 1) * floorGap - floorSpacing/2;
        text(0, y, textheight, sprintf('Level %i', floorNum),'Rotation',+15);
        plotStructure3D(currentFloor, 1);
        %figure(2)
        %nexttile
        title(sprintf('Level %i', floorNum));
        hold on
        plotStructure3D(currentFloor, floorNum+1);
        members = splitSector3DInX(membersInEachFloor{floorNum, 1}, splintLineX);
        splitedStructures = cell(x/splineSpacing, 1);
        for i = 1:size(members, 1)
            splitedStructures{i, 1} = splitSector3DInY(members{i, 1}, splintLineY);
        end
        printPlanProblem = PPOptProblem3D;
        printPlanProblem.createProblem(splitedStructures, nozzleMaxAngle, maximumTurnAngle);
        [conNum, varNum, objVarNum] = printPlanProblem.getConAndVarNum();
        matrix = ProgMatrix(conNum, varNum, objVarNum);
        printPlanProblem.initializeProblem(matrix);
        result = mosekSolve(matrix, 0);
        matrix.feedBackResult(result);
        angles = printPlanProblem.outputPrintingAngles(splitedStructures);
        anglesForEachFloor{floorNum, 1} = angles;
        [printPlanGrid, normalVectors, surface] = plotPrintingSurface(angles, splintLineX, splintLineY, (floorNum-1) * floorSpacing, floorNum+1);
        view([1 1 1])
        cuttingSurfaces{floorNum, 1} = surface;
        % check printability
        if reRunTurnedOn
            membersToBeChecked = [zeros(size(membersInEachFloor{floorNum, 1}, 1), 2), membersInEachFloor{floorNum, 1}]; 
            memberExist = deleteMembersViolatePrintingPlan3D(membersToBeChecked, splintLineX, splintLineY, angles, checkingMaxAngle);
            reRun = ~all(memberExist == 1);  
            deletedMember = membersInEachFloor{floorNum, 1}(memberExist==0, :);
            plotStructure3D(deletedMember, floorNum+1, [1 0 0])
            membersInEachFloor{floorNum, 1} = membersInEachFloor{floorNum, 1}(memberExist==1, :);
        else
%             membersToBeChecked = [zeros(size(membersInEachFloor{floorNum, 1}, 1), 2), membersInEachFloor{floorNum, 1}]; 
%             memberExist = deleteMembersViolatePrintingPlan3D(membersToBeChecked, splintLineX, splintLineY, angles, checkingMaxAngle);
%             reRun = ~all(memberExist == 1);  
%             deletedMember = membersInEachFloor{floorNum, 1}(memberExist==0, :);
%             plotStructure3D(deletedMember, floorNum+1, [1 0 0])
            reRun = false;
        end
    end
end
%groundStructure.plotMembers(forceList);

%%
%for floorNum = 1 : size(membersInEachFloor, 1)
for floorNum = 1 : size(membersInEachFloor, 1)
    surfaceCurrent = cuttingSurfaces{floorNum, 1};
    figure(1)
    view([ 1 1 1]);
    axis equal
    hold on
    [F,V] = stlread(sprintf('SplitedMeshes\\STLExport%i.stl', floorNum));
    testSurface = triangulation(F, V);
    trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
    trisurf(surfaceCurrent);
    
    cuttingSurfaceMin = min(surfaceCurrent.Points(:, 3));
    cuttingSurfaceMax = max(surfaceCurrent.Points(:, 3));
    structureSurfaceMin = min(testSurface.Points(:, 3));
    structureSurfaceMax = max(testSurface.Points(:, 3));
    cuttingSurfaceGap = cuttingSurfaceMax - cuttingSurfaceMin;
    divideNum = 40;
    divideSpacing = (floorSpacing + cuttingSurfaceGap) /divideNum;
    figure(2)
    hold on
    axis equal
    axis off
    surface1.vertices = V;
    surface1.faces = F;
    for i = 1:divideNum+2
        surface2.vertices = surfaceCurrent.Points;
        surface2.vertices(:, 3) = surface2.vertices(:, 3) - (cuttingSurfaceMax - structureSurfaceMin) + divideSpacing * (i-1);
        surface2.faces = surfaceCurrent.ConnectivityList;
        [intersect12, Surf12] = SurfaceIntersection(surface1, surface2);
        S=Surf12; 
        if isempty(S.faces)
            continue;
        end
        trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
    end
    view([ 1 1 1]);
end
%% Delete violating members in potential member list
newGroundStructure = GeoGroundStructure3D;
% newGroundStructure.nodes = groundStructure.nodes;
% newGroundStructure.members = newMembers;

newGroundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing / 2, spacing / 2, spacing / 2]);
newGroundStructure.createMembersFromNodes();
newGroundStructure.members = deleteCollinearMembers(newGroundStructure.nodes, newGroundStructure.members);

%%
potentialMemberList = newGroundStructure.members;
totalMemberList = [potentialMemberList(:, 3:9), potentialMemberList(:, 1:2), (1:size(potentialMemberList, 1))'];
totalMembersInEachFloor = splitSector3DInZ(totalMemberList, floorLineZ);
memberExistList = ones(size(potentialMemberList, 1), 1);
memberNumList = (1:size(potentialMemberList, 1))';
for floorNum = 1:size(membersInEachFloor, 1)
    currentAngle = anglesForEachFloor{floorNum, 1};
    currentList = totalMembersInEachFloor{floorNum, 1}(:, end);
    tempList = zeros(size(potentialMemberList, 1), 1);
    tempList(currentList, :) = 1;
    checkList = memberExistList==1 & tempList==1;
    tempMemberNumList = memberNumList(checkList);
    memberExist = deleteMembersViolatePrintingPlan3D(potentialMemberList(checkList, :), splintLineX, splintLineY, currentAngle, checkingMaxAngle);
    memberExistList(tempMemberNumList(memberExist == 0)) = 0;
end
    newMembers = potentialMemberList(memberExistList == 1, :); 
    
% Re-optimize structure with known printing curve
newGroundStructure.members = newMembers;
[newForceList, finalVolume] = memberAdding(newGroundStructure, loadcases, supports, solverOptions);
newStructure = newGroundStructure.createOptimizedStructureList(newForceList);
plotStructure3D(newStructure, size(membersInEachFloor, 1)+2);
view([1 1 1])
fprintf("Volume Increase is %.2f%% \n", 100*(finalVolume - initialVolume) / initialVolume);
%newGroundStructure.plotMembers(newForceList, 'figureNumber', size(membersInEachFloor, 1)+2);
