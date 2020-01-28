clear
groundStructure = GeoGroundStructure3D;
x=100; y=100; z=250;
spacing = 25;
%nozzleMaxAngle = 0.9773884;
solverOptions = OptOptions();
solverOptions.nodalSpacing = spacing * 1.75;
groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);
groundStructure.createMembersFromNodes();
groundStructure.members = deleteCollinearMembers(groundStructure.nodes, groundStructure.members);
%groundStructure.deleteNearHorizontalMembers(0);

loadcase = PhyLoadCase();
load1NodeIndex = groundStructure.findNodeIndex([x/2, y, z]);
load1 = PhyLoad3D(load1NodeIndex, 0.0, 5.0, 0.0);
% %load2 = PhyLoad(load2NodeIndex, 0.1, 0);
loadcase.loads = {load1};
loadcases = {loadcase};
 
support1NodeIndex = groundStructure.findNodeIndex([0, 0, 0]);
support2NodeIndex = groundStructure.findNodeIndex([x, y, 0]);
support3NodeIndex = groundStructure.findNodeIndex([x, 0, 0]);
support4NodeIndex = groundStructure.findNodeIndex([0, y, 0]);
support1 = PhySupport3D(support1NodeIndex);
support2 = PhySupport3D(support2NodeIndex);
support3 = PhySupport3D(support3NodeIndex);
support4 = PhySupport3D(support4NodeIndex);
supports = {support1; support2; support3; support4};
 
[forceList, potentialMemberList, initialVolume] = memberAdding(groundStructure, loadcases, supports, solverOptions);
structure = groundStructure.createOptimizedStructureList(forceList);
plotStructure3D(structure, 10);
%groundStructure.plotMembers(forceList);

%% Building sectors
startCoordinates = [0, 0, 0];
endCoordinates = [x, y, z];
checkingMaxAngle = 0.977;
floorSpacing = 6.25;
splineSpacing = 5;
%floorLineZ = 0:floorSpacing:z;
%floorLineZ = unique([structure(:, 3); structure(:, 6)])';
floorLineZ = [0,250]
boxStart = startCoordinates;
boxStart(1) = boxStart(1) - 5;
boxStart(2) = boxStart(2) - 5;
boxEnd = endCoordinates;
boxEnd(1) = boxEnd(1) + 5;
boxEnd(2) = boxEnd(2) + 5;
%structureTools.outputLevelBoxes(structure, floorLineZ, boxStart, boxEnd, '..\vtkPython\levelBoxes\');

[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing);

%% Delete violating members in potential member list
checkingMaxAngle = 0.977;
[newStructure, newGroundStructure] = reoptimization(groundStructure.nodes, potentialMemberList, loadcases, supports, solverOptions, splintLineX, splintLineY, floorLineZ, anglesForEachFloor, initialVolume, checkingMaxAngle);

%%
structureTools = OptStructureTools;
floorLineZ = unique([newStructure(:, 3); newStructure(:, 6)])';
boxStart = startCoordinates;
boxStart(1) = boxStart(1) - 20;
boxStart(2) = boxStart(2) - 20;
boxEnd = endCoordinates;
boxEnd(1) = boxEnd(1) + 20;
boxEnd(2) = boxEnd(2) + 20;
tempStructure = newStructure;
tempStructure(:, end) = abs(tempStructure(:, end) * 50);
structureTools.outputLevelBoxes(tempStructure, floorLineZ, boxStart, boxEnd, '..\vtkPython\levelBoxes\');

%% floorLineZ = [0,200/3,100,125,225,250]
splintLineX = startCoordinates(1)-10:splineSpacing:endCoordinates(1)+20;
splintLineY = startCoordinates(2)-10:splineSpacing:endCoordinates(2)+20;
[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(newStructure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing);

%%
newStructure(4, end) = newStructure(4, end) * 20;
newStructure(8, end) = newStructure(8, end) * 20;
outputPath = '..\vtkPython\polydatas\';
structureTools = OptStructureTools;
outputStructure = newStructure;
outputStructure(:, end) = abs(newStructure(:, end) * 50);
structureTools.outputStructureFiles(outputStructure, outputPath);
structureTools.outputConnectivity(outputStructure, outputPath);
%%
tempStructure = [newStructure, (1:size(newStructure, 1))'];
membersInEachFloor = splitSector3DInZ(tempStructure, floorLineZ);
printSpacing = 1.3;
levelSpacing = 2.5;
maximumOverhangAngle = 0.262;
totalPieces = cell(1, 1);
addedPieceNum = 1;
maximumOverhang = 0;
maximumB = 45;
% for floorNum = 1:size(membersInEachFloor, 1)
for floorNum = 1
    %surfaceCurrent = cuttingSurfaces{floorNum, 1};
    currentZStart = floorLineZ(floorNum);
    stlFileFolder = sprintf('..\\vtkPython\\booleanResults\\level%i\\', floorNum);
    figure(1)
    view([ 1 1 1]);
    axis equal
    hold on
    currentStructure = membersInEachFloor{floorNum, 1};
    currentZGrid = zGrids{floorNum, 1};
    memberStartingLevel = zeros(size(currentStructure, 1), 1);
    zGridColumnNum = size(currentZGrid, 2);
    currentZGrid = reshape(currentZGrid, [], 1);
    tempZGrid = cell2mat(currentZGrid);
    tempzmax = max(tempZGrid(:, 3));
    tempZGrid(:, 3) = tempZGrid(:, 3) - (tempzmax - currentZStart);
    tempZGrid = mat2cell(tempZGrid, ones(size(tempZGrid, 1), 1));
    currentZGrid = reshape(tempZGrid, [], zGridColumnNum);
    floorFinished = true;
    currentLevel = 0;
    finishedCutting = false(size(currentStructure, 1), 1);
    memberstarted = false(size(currentStructure, 1), 1);
    
    while floorFinished    
        currentLevel = currentLevel + levelSpacing;
        currentStructure(:, 7) = abs(currentStructure(:, 7));
        currentStructure = sortrows(currentStructure, 7, 'descend');
       for i = 1:size(currentStructure, 1)
       %for i = 2
%      if floorNum==1 && i==6
%          continue;
%      end
        memberFileName = [stlFileFolder, sprintf('cutCylinder%i.stl', currentStructure(i, end)-1)];
        if isfile(memberFileName)
            [F,V] = stlread(memberFileName);
        else 
            finishedCutting(i, 1) = true;
            continue;
        end
            if ~isempty(V) 
            memberBoundingBox = boundingBox3d(V);
%           figure(2)
%           hold on
%           axis equal
           testSurface = triangulation(F, V);
%            trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
%            aa=0.0;
            currentMember = currentStructure(i, :);
%             plotStructure3D(currentMember, 10);
            [surfaceCurrent, surfaceCoordinates, calibrationPoint, surfaceAngles] = getCustomizedZGridForMember(currentMember, memberBoundingBox, splintLineX, splintLineY, anglesForEachFloor{floorNum, 1});
            calibrationLevel = structureTools.getZCoordinateOnSurface(calibrationPoint(1), calibrationPoint(2), currentZGrid) + currentLevel;
            currentCalibrationLevel = structureTools.getZCoordinateOnSurface(calibrationPoint(1), calibrationPoint(2), surfaceCoordinates);
            %[surfaceCurrent, surfaceCoordinates] = getSurfaceForMember(memberBoundingBox, currentZGrid, splintLineX, splintLineY);
            %trisurf(surfaceCurrent, 'EdgeColor', 'none', 'FaceAlpha',0.2);
            
            if currentMember(1) > currentMember(4)
                point1X = 2;
                point2X = 1;
            else
                point1X = 1;
                point2X = 2;
            end
            
            if currentMember(2) > currentMember(5)
                point1Y = 4;
                point2Y = 3;
            else
                point1Y = 3;
                point2Y = 4;                
            end
            
            cuttingSurfaceMin = structureTools.getZCoordinateOnSurface(memberBoundingBox(point1X), memberBoundingBox(point1Y), surfaceCoordinates);
            cuttingSurfaceMax = structureTools.getZCoordinateOnSurface(memberBoundingBox(point2X), memberBoundingBox(point2Y), surfaceCoordinates);
            
            %[cuttingSurfaceMin, cuttingSurfaceMax] = getHeightBoundPointsInSurface(memberBoundingBox, currentZGrid, splintLineX, splintLineY);
            cuttingSurfaceGap = abs(cuttingSurfaceMax - cuttingSurfaceMin);
            divideSpacing = memberBoundingBox(6) - memberBoundingBox(5)+ cuttingSurfaceGap;
%             figure(1)
%             hold on
%             axis equal
%             view([1 1 1]);
            surface1.vertices = V;
            surface1.faces = F;
            memberVector = currentMember([4, 5, 6]) - currentMember([1, 2, 3]);
            memberLength = norm(memberVector);
            boundingBoxDiagonal = norm(memberBoundingBox([4 5 6]) - memberBoundingBox([1 2 3]));
            memberLengthInBox = getMemberLengthInBox(currentMember, memberBoundingBox);
            increasedSpacingNumber = floor(memberLengthInBox/printSpacing);
            tempDivideSpacing = divideSpacing / increasedSpacingNumber;
            
%             figure(3)
%             clf
%             hold on
%             axis equal
%             xlabel x
%             ylabel y
%             zlabel z
%             trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
            
            toolPathSpacing = 1.5;
            piecePath = cell(1, 1);
            piecePathNum = 1;
                for printNum = memberStartingLevel(i, 1):increasedSpacingNumber*2
                    verticalShift = - (max(cuttingSurfaceMin, cuttingSurfaceMax) - memberBoundingBox(5)) + tempDivideSpacing * (printNum-1) +0.001;
                    
                    if currentCalibrationLevel + verticalShift > calibrationLevel
                        memberStartingLevel(i, 1) = printNum;
                        break;
                    end
                    
                    surface2.vertices = surfaceCurrent.Points;
                    surface2.vertices(:, 3) = surface2.vertices(:, 3) + verticalShift;
                    surface2.faces = surfaceCurrent.ConnectivityList;

%                     figure(3)
%                     surfacePlot = triangulation(surface2.faces, surface2.vertices);
%                     trisurf(surfacePlot, 'EdgeColor', 'none', 'FaceAlpha',0.2);
%                     view([ 1 1 1]);
                    
                    [intersect12, Surf12] = SurfaceIntersection(surface1, surface2);
                    S=Surf12; 
                    if isempty(S.faces) 
                        if memberstarted(i, 1)
                            finishedCutting(i, 1) = true;
                            break
                        else
                            continue;
                        end
                    elseif ~memberstarted(i, 1)
                        memberstarted(i, 1) = true;
                    end
%                     figure(1)
%                     trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');

                    toolPathes = structureTools.generateToolPathForCuttingCurve(S, surfaceCoordinates, verticalShift, toolPathSpacing);

%                     figure(4)
%                     clf
%                     hold on
%                     axis equal
%                     view([ 1 1 1]);
    %                 trisurf(surfacePlot, 'EdgeColor', 'none', 'FaceAlpha',0.2);
%                     trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
                    nozzleDirections = cell(size(toolPathes, 1), 1);
                    for pathNum = 1:size(toolPathes, 1)
                        currectNozzleDirection = zeros(size(toolPathes{pathNum, 1}, 1), 3);
                        for segmentNum = 1:size(toolPathes{pathNum, 1}, 1)
                            [nozzleDirection, overhangAngle] = structureTools.getRealNozzleAngleForPath(toolPathes{pathNum, 1}(segmentNum, :), memberVector, surfaceCoordinates, surfaceAngles, maximumOverhangAngle, maximumB);
                            if abs(overhangAngle) > maximumOverhang
                                maximumOverhang = abs(overhangAngle);
                            end
                            currectNozzleDirection(segmentNum, :) = nozzleDirection;
                            %plot3(toolPathes{pathNum, 1}(segmentNum, [1 4]), toolPathes{pathNum, 1}(segmentNum, [2 5]), toolPathes{pathNum, 1}(segmentNum, [3 6]), '-g');
                            middlePoint = (toolPathes{pathNum, 1}(segmentNum, 1:3) + toolPathes{pathNum, 1}(segmentNum, 4:6))/2;
                            endPoint = middlePoint + nozzleDirection*0.5;
                            %plot3([middlePoint(1), endPoint(1)], [middlePoint(2), endPoint(2)], [middlePoint(3), endPoint(3)], '-b');
                        end
                        nozzleDirections{pathNum, 1} = currectNozzleDirection;
                    end
                    toolPath.paths = toolPathes;
                    toolPath.nozzleDirection = nozzleDirections;
                    piecePath{piecePathNum, 1} = toolPath;
                    piecePathNum = piecePathNum + 1;
%                 for toolPathNum = 1:size(toolPathes, 1)
%                     for segmentNum = 1:size(toolPathes{toolPathNum, 1}, 1)
%                     plot3(toolPathes{toolPathNum, 1}(segmentNum, [1 4]), toolPathes{toolPathNum, 1}(segmentNum, [2 5]), toolPathes{toolPathNum, 1}(segmentNum, [3 6]), '-r');                        
%                     end
%                 end
%                 for intersecNum = 1:size(intersectionPoints, 1)
%                     scatter3(intersectionPoints(intersecNum, 1), intersectionPoints(intersecNum, 2), intersectionPoints(intersecNum, 3), '*g')
%                 end
                end
                if ~isempty(piecePath{1, 1})
                totalPieces{addedPieceNum, 1} = piecePath;
                addedPieceNum = addedPieceNum+1;
                end
            else
               finishedCutting(i, 1) = true; 
            end
        end
        floorFinished = ~all(finishedCutting);
    end
end
maximumOverhang = 180*(maximumOverhang/pi)
finalCuttings = figure(1);
save('toolPaths.mat', 'totalPieces');
%savefig(finalCuttings, 'cuttings.fig');

%% output2GCode
structureTools = OptStructureTools;
structureTools.toGCode(totalPieces, 0);
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
