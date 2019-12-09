clear
caseNo = 2;
solverOptions = OptOptions();
switch caseNo
    case 1
    x=50; y=50; z=150;
    startCoordinates = [0, 0, 0];
    endCoordinates = [x, y, z];
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
    solverOptions.nodalSpacing = spacing * 1.75;
    case 2
    z=50;
    startCoordinates = [12.5, 12.5, 0];
    endCoordinates = [37.5, 37.5, z];
    spacing = 6.25;   
    groundStructure = GeoGroundStructure3D;
    groundStructure.createCustomizedNodeGrid(startCoordinates, endCoordinates, [spacing, spacing, spacing]);
    groundStructure.createMembersFromNodes();
    groundStructure.deleteHorizontalMembers();
    loadcase1 = PhyLoadCase();
    load1NodeIndex = groundStructure.findNodeIndex([25, 25, z]);
    load1 = PhyLoad3D(load1NodeIndex, 0.0, 2.0, 0.0);
    loadcase1.loads = {load1};
    
    loadcase2 = PhyLoadCase();
    load2NodeIndex = groundStructure.findNodeIndex([25, 25, z]);
    load2 = PhyLoad3D(load2NodeIndex, 2.0, 0.0, 0.0);
    loadcase2.loads = {load2};    
    
    loadcases = {loadcase1; loadcase2};
    offsetDistance = spacing;
    support1NodeIndex = groundStructure.findNodeIndex([25-offsetDistance, 25-offsetDistance, 0]);
    support2NodeIndex = groundStructure.findNodeIndex([25+offsetDistance, 25+offsetDistance, 0]);
    support3NodeIndex = groundStructure.findNodeIndex([25-offsetDistance, 25+offsetDistance, 0]);
    support4NodeIndex = groundStructure.findNodeIndex([25+offsetDistance, 25-offsetDistance, 0]);
    support1 = PhySupport3D(support1NodeIndex, 1, 1, 1);
    support2 = PhySupport3D(support2NodeIndex, 1, 1, 1);
    support3 = PhySupport3D(support3NodeIndex, 1, 1, 1);
    support4 = PhySupport3D(support4NodeIndex, 1, 1, 1);
    supports = {support1; support2; support3; support4};   
    solverOptions.outputMosek = false;
    solverOptions.nodalSpacing = spacing * 2.5;
    case 3
    x=50; y=150; z=50;
    startCoordinates = [0, 0, 0];
    endCoordinates = [x, y, z];
    spacing = 12.5;   
    groundStructure = GeoGroundStructure3D;
    groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);
    groundStructure.createMembersFromNodes();
    groundStructure.members = deleteCollinearMembers(groundStructure.nodes, groundStructure.members);
    groundStructure.deleteNearHorizontalMembers(0);
%   groundStructure.deleteHorizontalMembers();
    loadcase1 = PhyLoadCase();
    load1NodeIndex = groundStructure.findNodeIndex([x/2, y, 0]);
    load1 = PhyLoad3D(load1NodeIndex, 0.0, 0.0, -5.0);
    loadcase1.loads = {load1};    
    
    loadcases = {loadcase1};
    support1NodeIndex = groundStructure.findNodeIndex([x/2, 0, 0]);
    support2NodeIndex = groundStructure.findNodeIndex([0, 50, 0]);
    support3NodeIndex = groundStructure.findNodeIndex([x, 50, 0]);
    support1 = PhySupport3D(support1NodeIndex, 1, 1, 1);
    support2 = PhySupport3D(support2NodeIndex, 1, 1, 1);
    support3 = PhySupport3D(support3NodeIndex, 1, 1, 1);
    supports = {support1; support2; support3};  
    solverOptions.nodalSpacing = spacing * 1.75;
end

[forceList, potentialMemberList, initialVolume] = memberAdding(groundStructure, loadcases, supports, solverOptions);
%groundStructure.plotMembers(forceList);
%
structure = groundStructure.createOptimizedStructureList(forceList);
structure = mergeCollinear(structure);
% plotStructure3D(structure, 1);
%toRhino('rhinoFiles', 'truss', structure);
plotStructure3D(structure, 10);
%
shrinkLength = 0;
structureTools = OptStructureTools;
outputPath = '..\vtkPython\polydatas\';
structureTools.outputStructureFiles(structure, outputPath)
%%
structureTools.outputConnectivity(structure, outputPath);
%structure = structureTools.shrinkTwoEnds(structure, repmat(shrinkLength, size(structure, 1), 1));
%% Building sectors
checkingMaxAngle = 0.977;
floorSpacing = 6.25;
splineSpacing = 1;
floorLineZ = 0:floorSpacing:z;
splintLineX = startCoordinates(1):splineSpacing:endCoordinates(1);
splintLineY = startCoordinates(2):splineSpacing:endCoordinates(2);
[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing);
%%
outputPath = '..\vtkPython\polydatas\';
structureTools.outputSurfaces(cuttingSurfaces, outputPath);
%% Delete violating members in potential member list
step = 1;
while ~printable
    close all
    if step==1
        [newStructure, newGroundStructure] = reoptimization(groundStructure.nodes, potentialMemberList, loadcases, supports, solverOptions, splintLineX, splintLineY, floorLineZ, anglesForEachFloor, initialVolume, checkingMaxAngle);
    else
        [newStructure, newGroundStructure] = reoptimization(newGroundStructure.nodes, newGroundStructure.members, loadcases, supports, solverOptions, splintLineX, splintLineY, floorLineZ, newAnglesForEachFloor, initialVolume, checkingMaxAngle);
    end
    [~, ~, newAnglesForEachFloor, printable] = findPrintingPlan(newStructure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, anglesForEachFloor);
    step = step + 1;
end

%%
%for floorNum = 1 : size(membersInEachFloor, 1)
membersInEachFloor = splitSector3DInZ(structure, floorLineZ);
for floorNum = 1 : size(membersInEachFloor, 1)
    %surfaceCurrent = cuttingSurfaces{floorNum, 1};
    printSpacing = 0.5;
    figure(1)
    view([ 1 1 1]);
    axis equal
    hold on
    [F,V] = stlread(sprintf('SplitedMeshes\\STLExport%i.stl', floorNum));
    testSurface = triangulation(F, V);
    %trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
    %trisurf(surfaceCurrent);
    
    structureSurfaceMin = min(testSurface.Points(:, 3));
    structureSurfaceMax = max(testSurface.Points(:, 3));
    %divideNum = 1;
    %divideSpacing = (floorSpacing + cuttingSurfaceGap) /divideNum;
    currentStructure = membersInEachFloor{floorNum, 1};
    currentZGrid = zGrids{floorNum, 1};
    
    for i = 1:size(currentStructure, 1)
        currentMember = currentStructure(i, :);
        memberZmin = min(currentMember(3), currentMember(6))-2;
        memberZmax = max(currentMember(3), currentMember(6))+4;
        plotStructure3D(currentMember, 10);
        surfaceCurrent = getSurfaceForMember(currentMember, currentZGrid, splintLineX, splintLineY);
        cuttingSurfaceMin = min(surfaceCurrent.Points(:, 3));
        cuttingSurfaceMax = max(surfaceCurrent.Points(:, 3));
        cuttingSurfaceGap = cuttingSurfaceMax - cuttingSurfaceMin;
        divideSpacing = memberZmax - memberZmin+ cuttingSurfaceGap;
        
        figure(2)
        hold on
        axis equal
        view([ 1 1 1]);
        surface1.vertices = V;
        surface1.faces = F;
        memberVector = currentMember([4, 5, 6]) - currentMember([1, 2, 3]);
%         if memberVector(3)<0
%             memberVector = -memberVector;
%         end
%         angle = angleBetweenVectors([0 0 1], memberVector);
%         increasedDistance = divideSpacing / cos(angle);
        memberLength = norm(memberVector);
        increasedSpacingNumber = floor(memberLength/printSpacing);
        tempDivideSpacing = divideSpacing / increasedSpacingNumber;
        
        for printNum = 1:increasedSpacingNumber
            surface2.vertices = surfaceCurrent.Points;
            surface2.vertices(:, 3) = surface2.vertices(:, 3) - (cuttingSurfaceMax - memberZmin) + tempDivideSpacing * (printNum-1);
            surface2.faces = surfaceCurrent.ConnectivityList;
            [intersect12, Surf12] = SurfaceIntersection(surface1, surface2);
            S=Surf12; 
            if isempty(S.faces)
                continue;
            end
            trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
        end
    end
    
%     figure(2)
%     hold on
%     axis equal
%     axis off
%     surface1.vertices = V;
%     surface1.faces = F;
%     for i = 1:divideNum+2
%         surface2.vertices = surfaceCurrent.Points;
%         surface2.vertices(:, 3) = surface2.vertices(:, 3) - (cuttingSurfaceMax - structureSurfaceMin) + divideSpacing * (i-1);
%         surface2.faces = surfaceCurrent.ConnectivityList;
%         [intersect12, Surf12] = SurfaceIntersection(surface1, surface2);
%         %test = splitFV(Surf12.faces, Surf12.vertices);
%         S=Surf12; 
%         if isempty(S.faces)
%             continue;
%         end
%         trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
%     end
%     view([ 1 1 1]);
end
%% 
function [newStructure, newGroundStructure] = reoptimization(nodes, members, loadcases, supports, solverOptions, splintLineX, splintLineY, floorLineZ, anglesForEachFloor, initialVolume, checkingMaxAngle)
    newGroundStructure = GeoGroundStructure3D;
    newGroundStructure.nodes = nodes;
    newGroundStructure.members = members;
    newGroundStructure.members = deleteCollinearMembers(newGroundStructure.nodes, newGroundStructure.members);

    potentialMemberList = newGroundStructure.members;
    totalMemberList = [potentialMemberList(:, 3:9), potentialMemberList(:, 1:2), (1:size(potentialMemberList, 1))'];
    totalMembersInEachFloor = splitSector3DInZ(totalMemberList, floorLineZ);
    memberExistList = ones(size(potentialMemberList, 1), 1);
    totalPenaltyList = zeros(size(potentialMemberList, 1), 1);
    memberNumList = (1:size(potentialMemberList, 1))';
    for floorNum = 1:size(floorLineZ, 2)-1
        currentAngle = anglesForEachFloor{floorNum, 1};
        currentList = totalMembersInEachFloor{floorNum, 1}(:, end);
        tempList = zeros(size(potentialMemberList, 1), 1);
        tempList(currentList, :) = 1;
        checkList = memberExistList==1 & tempList==1;
        tempMemberNumList = memberNumList(checkList);
        [memberExist, penaltyValue] = deleteMembersViolatePrintingPlan3D(potentialMemberList(checkList, :), splintLineX, splintLineY, currentAngle, checkingMaxAngle);
        memberExistList(tempMemberNumList(memberExist == 0)) = 0;
        totalPenaltyList(tempMemberNumList(memberExist == 0)) = penaltyValue(penaltyValue~=0);
    end
        newMembers = potentialMemberList(memberExistList == 1, :); 
        
    penaltyFactor = 0;
    newGroundStructure.members = newMembers;
    [newForceList, finalVolume] = fullGroundStructure(newGroundStructure, loadcases, supports, solverOptions, penaltyFactor*totalPenaltyList);
    newStructure = newGroundStructure.createOptimizedStructureList(newForceList);
    plotStructure3D(newStructure, size(floorLineZ, 2)+1);
    view([1 1 1])
    fprintf("Volume Increase is %.2f%% \n", 100*(finalVolume - initialVolume) / initialVolume);
end


function [cuttingSurfaces,  splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, reRunTurnedOn, knownAngleValue,floorSpacing)
    clf
    maximumTurnAngle = 0.4;
    nozzleMaxAngle = 0.809;
    symmetryInX = true;
    solverOptions.useCosAngleValue = false;
    solverOptions.useAngleTurnConstraint = true;
    printable = true;
    membersInEachFloor = splitSector3DInZ(structure, floorLineZ);

    anglesForEachFloor = cell(size(membersInEachFloor, 1), 1);

    [floorSurfaceX, floorSurfaceY] = meshgrid(splintLineX, splintLineY);

    floorGap = 0; 
    figure(1)
    hold on
    %tiledlayout(2,2);
    figure(2)
    t = tiledlayout(3, 3, 'TileSpacing','compact');
    cuttingSurfaces = cell(size(membersInEachFloor, 1), 1);
    splitedStructureEachFloor = cell(size(membersInEachFloor, 1), 1);
    zGrids = cell(size(membersInEachFloor, 1), 1);
    %
    for floorNum = 1 : size(membersInEachFloor, 1)  
        reRun = true;
        while reRun
            if floorNum==1
                figure(1)
                view([1 1 1])
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
            view([1 0.5 0.5])
            textheight = floorLineZ(floorNum + 1) + (floorNum - 1) * floorGap - floorSpacing/2;
            %text(0, 150, textheight, sprintf('Level %i', floorNum),'Rotation',+15);
            plotStructure3D(currentFloor, 1);
%             figure(2)
%             nexttile(t)
            
            hold on
            
            plotStructure3D(currentFloor, floorNum+1);
            axis off
            %title(sprintf('Level %i', floorNum));
            members = splitSector3DInX(membersInEachFloor{floorNum, 1}, splintLineX);
            splitedStructures = cell(size(splintLineX, 2) - 1, 1);
            for i = 1:size(members, 1)
                splitedStructures{i, 1} = splitSector3DInY(members{i, 1}, splintLineY);
            end
            splitedStructureEachFloor{floorNum, 1} = splitedStructures;
            printPlanProblem = PPOptProblem3D;
            
            if ~isempty(knownAngleValue)
                printPlanProblem.createProblem(splitedStructures, nozzleMaxAngle, maximumTurnAngle, solverOptions, knownAngleValue{floorNum, 1});
            else
                printPlanProblem.createProblem(splitedStructures, nozzleMaxAngle, maximumTurnAngle, solverOptions, []);
            end
            [conNum, varNum, objVarNum] = printPlanProblem.getConAndVarNum();
            matrix = ProgMatrix(conNum, varNum, objVarNum);
            printPlanProblem.initializeProblem(matrix);
            result = mosekSolve(matrix, 0);
            matrix.feedBackResult(result);
            angles = printPlanProblem.outputPrintingAngles(splitedStructures, solverOptions);
            
            if symmetryInX
                angles = adjustAnglesToBeSymmetryInX(angles);
            end
            if ~isempty(knownAngleValue)
                anglesForEachFloor{floorNum, 1} = getAnglesForFilledFacets(angles, splitedStructures, knownAngleValue{floorNum, 1});
            else
                anglesForEachFloor{floorNum, 1} = getAnglesForFilledFacets(angles, splitedStructures, []);
            end
            [printPlanGrid, normalVectors, surface] = plotPrintingSurface(angles, splintLineX, splintLineY, floorLineZ(floorNum), splitedStructures, floorNum+1);
            zGrids{floorNum, 1} = printPlanGrid;
            view([1 1 1])
            cuttingSurfaces{floorNum, 1} = surface;
            % check printability
            
            membersToBeChecked = [zeros(size(membersInEachFloor{floorNum, 1}, 1), 2), membersInEachFloor{floorNum, 1}]; 
            memberExist = deleteMembersViolatePrintingPlan3D(membersToBeChecked, splintLineX, splintLineY, angles, checkingMaxAngle);
            reRun = ~all(memberExist == 1); 

            unprintableMember = membersInEachFloor{floorNum, 1}(memberExist==0, :);
            if ~isempty(unprintableMember)
                printable = false;
            end
%             plotStructure3D(unprintableMember, 1, [1 0 0])
            if reRunTurnedOn
                membersInEachFloor{floorNum, 1} = membersInEachFloor{floorNum, 1}(memberExist==1, :);
            else
                reRun = false;
            end
        end
    end 
end

function newAngles = getAnglesForFilledFacets(angles, structures, knownAngleValue)
    newAngles = angles;
    for i = 1:size(angles, 1)
        for j = 1:size(angles, 2)
            if ~isempty(knownAngleValue) && ~isempty(knownAngleValue{i, j})
                continue;
            end
            
            if isempty(structures{i, 1}{j, 1})
                newAngles{i, j} = [];
            end
        end
    end
end