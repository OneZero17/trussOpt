clear
solverOptions = OptOptions();
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
load1 = PhyLoad3D(load1NodeIndex, 0.0, 00.0, -20.0);
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

[forceList, potentialMemberList, initialVolume] = memberAdding(groundStructure, loadcases, supports, solverOptions);
%groundStructure.plotMembers(forceList);
%
structure = groundStructure.createOptimizedStructureList(forceList);
structure = mergeCollinear(structure);
tempStructure = structure;
tempStructure(:, 2) = structure(:, 3);
tempStructure(:, 3) = structure(:, 2);
tempStructure(:, 5) = structure(:, 6);
tempStructure(:, 6) = structure(:, 5);
structure = tempStructure;
plotStructure3D(structure, 10);

x=50; y=50; z=150;
startCoordinates = [0, 0, 0];
endCoordinates = [x, y, z];
%plotStructure3D(structure, 1);
%toRhino('rhinoFiles', 'truss', structure);
%plotStructure3D(structure, 10);
%
%shrinkLength = 0;
structureTools = OptStructureTools;
outputPath = '..\vtkPython\polydatas\';

%%
structure = rotateStructureInYZPlane(structure,0.1745, [25, 0, 0]);
plotStructure3D(structure, 10);
%%
structureTools.outputStructureFiles(structure, outputPath)
%%
structureTools.outputConnectivity(structure, outputPath);
%% Building sectors
checkingMaxAngle = 0.977;
floorSpacing = 6.25;
splineSpacing = 5;
%floorLineZ = 0:floorSpacing:z;
floorLineZ = unique([structure(:, 3); structure(:, 6)])';
boxStart = startCoordinates;
boxStart(1) = boxStart(1) - 5;
boxStart(2) = boxStart(2) - 5;
boxEnd = endCoordinates;
boxEnd(1) = boxEnd(1) + 5;
boxEnd(2) = boxEnd(2) + 5;
structureTools.outputLevelBoxes(structure, floorLineZ, boxStart, boxEnd, '..\vtkPython\levelBoxes\');
%%
splintLineX = startCoordinates(1)-5:splineSpacing:endCoordinates(1)+5;
splintLineY = startCoordinates(2)-40:splineSpacing:endCoordinates(2)+5;
[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing);

%% cutSupports
totalSupportNum = 4;
figure(1)
view([ 1 1 1]);
axis equal
hold on
printSpacing = 0.5;
toolPathSpacing = 0.1;
for supportNum = 1:totalSupportNum
    currentSupportFile = sprintf('..\\vtkPython\\additionalSupports\\support%i.stl', supportNum);
    [F,V] = stlread(currentSupportFile);
    supportBox = boundingBox3d(V);
    [surfaceCurrent, surfaceCoordinates] = getHorizontalCuttingSurfaceForComponents(supportBox, splineSpacing);
    surfaceZLevel = structureTools.getZCoordinateOnSurface(supportBox(1), supportBox(3), surfaceCoordinates);
    cuttingNum = ceil((supportBox(6) - supportBox(5)) / printSpacing);
    surface1.vertices = V;
    surface1.faces = F;
%     figure(3)
%     axis equal 
%     hold on
%     surfacePlot = triangulation(surface1.faces, surface1.vertices);
%     trisurf(surfacePlot, 'EdgeColor', 'r', 'FaceColor', 'r');
%     view([ 1 1 1]);

    for i = 0:cuttingNum*1.5
        verticalShift = supportBox(5) - surfaceZLevel + i * printSpacing-0.001;
        surface2.vertices = surfaceCurrent.Points;
        surface2.vertices(:, 3) = surface2.vertices(:, 3) + verticalShift;
        surface2.faces = surfaceCurrent.ConnectivityList;
%         figure(3)
%         surfacePlot = triangulation(surface2.faces, surface2.vertices);
%         trisurf(surfacePlot, 'EdgeColor', 'none', 'FaceAlpha',0.2);
%         view([ 1 1 1]);
        [intersect12, S] = SurfaceIntersection(surface1, surface2);
       
        if isempty(S.faces) 
            continue;
        end
        
        figure(1)
        trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
        toolPathes = structureTools.generateToolPathForCuttingCurve(S, surfaceCoordinates, verticalShift, toolPathSpacing);
%         nozzleDirections = cell(size(toolPathes, 1), 1);
%         for pathNum = 1:size(toolPathes, 1)
%             currectNozzleDirection = zeros(size(toolPathes{pathNum, 1}, 1), 3);
%             for segmentNum = 1:size(toolPathes{pathNum, 1}, 1)
%                 nozzleDirection = [0 0 1];
%                 currectNozzleDirection(segmentNum, :) = nozzleDirection;
%                 plot3(toolPathes{pathNum, 1}(segmentNum, [1 4]), toolPathes{pathNum, 1}(segmentNum, [2 5]), toolPathes{pathNum, 1}(segmentNum, [3 6]), '-g');
%                 middlePoint = (toolPathes{pathNum, 1}(segmentNum, 1:3) + toolPathes{pathNum, 1}(segmentNum, 4:6))/2;
%                 endPoint = middlePoint + nozzleDirection*0.5;
%                 
%                 %plot3([middlePoint(1), endPoint(1)], [middlePoint(2), endPoint(2)], [middlePoint(3), endPoint(3)], '-b');
%             end
%             nozzleDirections{pathNum, 1} = currectNozzleDirection;
%         end
    end
end
%
tempStructure = [structure, (1:size(structure, 1))'];
membersInEachFloor = splitSector3DInZ(tempStructure, floorLineZ);
printSpacing = 1.5;
levelSpacing = 5.0;
maximumOverhangAngle = 0.262;
% totalPieces = cell(1, 1);
% addedPieceNum = 1;
maximumOverhang = 0;
maximumB = 43;
for floorNum = 2
%for floorNum = 1
    %surfaceCurrent = cuttingSurfaces{floorNum, 1};
    currentZStart = floorLineZ(floorNum);
    stlFileFolder = sprintf('..\\vtkPython\\booleanResults\\level%i\\', floorNum);
%     figure(1)
%     view([ 1 1 1]);
%     axis equal
%     hold on
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
        for i = 1:size(currentStructure, 1)
%      for i = 7
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
           %trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
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
            increasedSpacingNumber = floor(memberLength/printSpacing);
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
                    verticalShift = - (max(cuttingSurfaceMin, cuttingSurfaceMax) - memberBoundingBox(5)) + tempDivideSpacing * (printNum-1);
                    
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
                    %figure(1)
                    %trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');

                    toolPathes = structureTools.generateToolPathForCuttingCurve(S, surfaceCoordinates, verticalShift, toolPathSpacing);

                    figure(4)
                    clf
                    hold on
                    axis equal
                    view([ 1 1 1]);
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
                            plot3(toolPathes{pathNum, 1}(segmentNum, [1 4]), toolPathes{pathNum, 1}(segmentNum, [2 5]), toolPathes{pathNum, 1}(segmentNum, [3 6]), '-g');
                            middlePoint = (toolPathes{pathNum, 1}(segmentNum, 1:3) + toolPathes{pathNum, 1}(segmentNum, 4:6))/2;
                            endPoint = middlePoint + nozzleDirection*0.5;
                            plot3([middlePoint(1), endPoint(1)], [middlePoint(2), endPoint(2)], [middlePoint(3), endPoint(3)], '-b');
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
structureTools.toGCode(totalPieces);



