clear
groundStructure = GeoGroundStructure3D;
x=50; y=50; z=150;
spacing = 12.5;
%nozzleMaxAngle = 0.9773884;
solverOptions = OptOptions();
solverOptions.nodalSpacing = spacing * 1.75;
groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);

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
 
groundStructure.createMembersFromNodes();

[forceList, potentialMemberList, initialVolume] = memberAdding(groundStructure, loadcases, supports, solverOptions);
%groundStructure.plotMembers(forceList);
structure = groundStructure.createOptimizedStructureList(forceList);
plotStructure3D(structure, 1);

%% Building sectors
floorSpacing = 12.5;
splineSpacing = 2.5;
maximumTurnAngle = 0.5;
nozzleMaxAngle = 0.809;
checkingMaxAngle = 0.977;
reRunTurnedOn = false;

floorLineZ = 0:floorSpacing:z;
membersInEachFloor = splitSector3DInZ(structure, floorLineZ);
anglesForEachFloor = cell(size(membersInEachFloor, 1), 1);
splintLineX = 0:splineSpacing:x;
splintLineY = 0:splineSpacing:y;
[floorSurfaceX, floorSurfaceY] = meshgrid(splintLineX, splintLineY);

floorGap = 0; 
figure(1)
hold on
%tiledlayout(2,2);
figure(2)
t = tiledlayout(3, 4, 'TileSpacing','compact');
for floorNum = 1 : size(membersInEachFloor, 1)
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
        figure(2)
        nexttile(t)
        title(sprintf('Level %i', floorNum));
        hold on
        plotStructure3D(currentFloor, 2);
        members = splitSector3DInX(membersInEachFloor{floorNum, 1}, splintLineX);
        splitedStructures = cell(x/splineSpacing, 1);
        for i = 1:(x / splineSpacing)
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
        [printPlanGrid, normalVectors] = plotPrintingSurface(angles, splintLineX, splintLineY, (floorNum-1) * floorSpacing, 2);
        hold off
        view([1 1 1])

        % check printability
        if reRunTurnedOn
            membersToBeChecked = [zeros(size(membersInEachFloor{floorNum, 1}, 1), 2), membersInEachFloor{floorNum, 1}]; 
            memberExist = deleteMembersViolatePrintingPlan3D(membersToBeChecked, splintLineX, splintLineY, angles, checkingMaxAngle);
            reRun = ~all(memberExist == 1);  
            deletedMember = membersInEachFloor{floorNum, 1}(memberExist==0, :);
            %plotStructure3D(deletedMember, floorNum+1, [1 0 0])
            membersInEachFloor{floorNum, 1} = membersInEachFloor{floorNum, 1}(memberExist==1, :);
        else
            reRun = false;
        end
    end
end
%groundStructure.plotMembers(forceList);

%% Delete violating members in potential member list
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
newGroundStructure = GeoGroundStructure3D;
newGroundStructure.nodes = groundStructure.nodes;
newGroundStructure.members = newMembers;
[newForceList, finalVolume] = fullGroundStructure(newGroundStructure, loadcases, supports, solverOptions);
newStructure = newGroundStructure.createOptimizedStructureList(newForceList);
plotStructure3D(newStructure, size(membersInEachFloor, 1)+2);
view([1 1 1])
fprintf("Volume Increase is %.2f%% \n", 100*(finalVolume - initialVolume) / initialVolume);
%newGroundStructure.plotMembers(newForceList, 'figureNumber', size(membersInEachFloor, 1)+2);
