clear
close all
caseNo = 1;
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
    case 4
    x=100; y=100; z=62.5;
    startCoordinates = [0, 0, 0];
    endCoordinates = [x, y, z];
    spacing = 12.5;
    groundStructure = GeoGroundStructure3D;
    groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);
    groundStructure.createMembersFromNodes(); 
    %groundStructure.deleteNearHorizontalMembers(0);
    groundStructure.members = deleteCollinearMembers(groundStructure.nodes, groundStructure.members);
    loadcase1 = PhyLoadCase();
    load1NodeIndex = groundStructure.findNodeIndex([x/2, y/2, 0]);
    load1 = PhyLoad3D(load1NodeIndex, 0.0, 0.0, -20.0);
    loadcase1.loads = {load1};

    loadcase2 = PhyLoadCase();
    load2NodeIndex = groundStructure.findNodeIndex([x/2, y/2, z]);
    load2 = PhyLoad3D(load1NodeIndex, 5.0, 0.0, 0.0);
    loadcase2.loads = {load2};
    loadcases = {loadcase1};

    support1NodeIndex = groundStructure.findNodeIndex([0, 0, 0]);
    support2NodeIndex = groundStructure.findNodeIndex([x, y, 0]);
    support3NodeIndex = groundStructure.findNodeIndex([x, 0, 0]);
    support4NodeIndex = groundStructure.findNodeIndex([0, y, 0]);
    support1 = PhySupport3D(support1NodeIndex, 1, 1, 1);
    support2 = PhySupport3D(support2NodeIndex, 0, 0, 1);
    support3 = PhySupport3D(support3NodeIndex, 0, 0, 1);
    support4 = PhySupport3D(support4NodeIndex, 0, 0, 1);
    supports = {support1; support2; support3; support4};
    solverOptions.nodalSpacing = spacing * 1.75;    
end

[forceList, potentialMemberList, initialVolume] = memberAdding(groundStructure, loadcases, supports, solverOptions);
%groundStructure.plotMembers(forceList);
%
structure = groundStructure.createOptimizedStructureList(forceList);
structure = mergeCollinear(structure);
plotStructure3D(structure, 1);
toRhino('rhinoFiles', 'truss', structure);
plotStructure3D(structure, 10);
%
shrinkLength = 0;
structureTools = OptStructureTools;
%% Building sectors
checkingMaxAngle = 0.977;
floorSpacing = z/10;
splineSpacing = 10;
boxStart = startCoordinates;
boxStart(1) = boxStart(1) - 5;
boxStart(2) = boxStart(2) - 5;
boxEnd = endCoordinates;
boxEnd(1) = boxEnd(1) + 5;
boxEnd(2) = boxEnd(2) + 5;
floorLineZ = outputBoxForEachFloor(startCoordinates, endCoordinates, structure, false); % splitted floors in Z direction
%%
splintLineX = startCoordinates(1):splineSpacing:endCoordinates(1);
splintLineY = startCoordinates(2):splineSpacing:endCoordinates(2);
[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing, 0.5);
%% Reoptimization
[newStructure, newGroundStructure] = reoptimization(groundStructure.nodes, potentialMemberList, loadcases, supports, solverOptions, splintLineX, splintLineY, floorLineZ, anglesForEachFloor, initialVolume, checkingMaxAngle);

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

function floorLineZ = outputBoxForEachFloor(startCoordinates, endCoordinates, structure, outputFlag)
    structureTools = OptStructureTools;
    floorLineZ = unique([structure(:, 3); structure(:, 6)])';
    boxStart = startCoordinates;
    boxStart(1) = boxStart(1) - 40;
    boxStart(2) = boxStart(2) - 40;
    boxEnd = endCoordinates;
    boxEnd(1) = boxEnd(1) + 40;
    boxEnd(2) = boxEnd(2) + 40;
    tempStructure = structure;
    tempStructure(:, end) = abs(tempStructure(:, end) * 50);
    if outputFlag
        structureTools.outputLevelBoxes(tempStructure, floorLineZ, boxStart, boxEnd, '..\vtkPython\levelBoxes\');
    end
end
