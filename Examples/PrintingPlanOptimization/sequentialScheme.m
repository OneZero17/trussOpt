clear
caseNo = 1;
switch caseNo
    case 1
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
    case 2
    z=50;
    startCoordinates = [12.5, 12.5, 0];
    endCoordinates = [37.5, 37.5, z];
    spacing = 3.125;   
    groundStructure = GeoGroundStructure3D;
    groundStructure.createCustomizedNodeGrid(startCoordinates, endCoordinates, [spacing, spacing, spacing]);
    groundStructure.createMembersFromNodes();
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
    support2NodeIndex = groundStructure.findNodeIndex([0, 25, 0]);
    support3NodeIndex = groundStructure.findNodeIndex([x, 25, 0]);
    support1 = PhySupport3D(support1NodeIndex, 1, 1, 1);
    support2 = PhySupport3D(support2NodeIndex, 1, 1, 1);
    support3 = PhySupport3D(support3NodeIndex, 1, 1, 1);
    supports = {support1; support2; support3};  
    solverOptions.nodalSpacing = spacing * 1.75;
end
solverOptions = OptOptions();
solverOptions.nodalSpacing = spacing * 1.75;    
[forceList, potentialMemberList, initialVolume] = memberAdding(groundStructure, loadcases, supports, solverOptions);

structure = groundStructure.createOptimizedStructureList(forceList);
structure = mergeCollinear(structure);
plotStructure3D(structure, 1);


%% Find print plan
checkingMaxAngle = 0.977;
floorSpacing = 12.5;
splineSpacing = 10;
floorLineZ = 0:floorSpacing:z;
splintLineX = startCoordinates(1):splineSpacing:endCoordinates(1);
splintLineY = startCoordinates(2):splineSpacing:endCoordinates(2);
[cuttingSurfaces, splitedStructureEachFloor, initialAnglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing);

%% Re-optimization
for step = 1:100
    % Calculate delta for every members
    close all
    potentialMemberList = groundStructure.members;
    totalMemberList = [potentialMemberList(:, 3:9), potentialMemberList(:, 1:2), (1:size(potentialMemberList, 1))'];
    totalMembersInEachFloor = splitSector3DInZ(totalMemberList, floorLineZ);
    if step == 1
        oldPenaltyList = zeros(size(potentialMemberList, 1), 1);
        anglesForEachFloor = initialAnglesForEachFloor;
    else
        oldPenaltyList = totalPenaltyList;
    end
    totalPenaltyList = zeros(size(potentialMemberList, 1), 2);
    scalingFactor = 1.1;
    for floorNum = 1:size(floorLineZ, 2)-1
        deltaValues = calculateDeltaForMembers(totalMembersInEachFloor{floorNum, 1}, splintLineX, splintLineY, anglesForEachFloor{floorNum, 1}, checkingMaxAngle, scalingFactor);
        totalPenaltyList(totalMembersInEachFloor{floorNum, 1}(:, end), :) = totalPenaltyList(totalMembersInEachFloor{floorNum, 1}(:, end), :) + deltaValues;
    end
    check = (totalPenaltyList(:, 1)./totalPenaltyList(:, 2) - 1);
    totalPenaltyList = (totalPenaltyList(:, 1)./totalPenaltyList(:, 2) - 1) .* potentialMemberList(:, end);
%     totalPenaltyList = totalPenaltyList*0.4 + oldPenaltyList*0.6;
    
    [newForceList, finalVolume] = fullGroundStructure(groundStructure, loadcases, supports, solverOptions, totalPenaltyList);
    fprintf("Volume Increase is %.2f%% \n", 100*(finalVolume - initialVolume) / initialVolume);
    newStructure = groundStructure.createOptimizedStructureList(newForceList);

    [cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(newStructure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing);
    if printable
        break
    end
end













