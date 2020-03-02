clear
structure = [0,0,0,25,50,100,3.00228766378999;
             0,0,0,25,0,125,4.33653955431493;
             0,100,0,25,50,100,3.27079796037665;
             0,100,0,50.0000,66.67,66.67,2.1;
             50.0000,66.67,66.67,75,50,100,2.1;
             0,100,0,25,100,125,4.01785085031571;
             100,0,0,75,50,100,2.36791821025506;
             100,0,0,75,0,125,3.63067838897653;
             100,100,0,50,66.67,66.67,2.1;
             50,66.67,66.67,25,50,100,2.1;
             100,100,0,75,50,100,2.63642850749507;
             100,100,0,75,100,125,3.31198968377979;
             25,50,100,25,0,125,1.90169839608546;
             25,50,100,25,100,125,1.20292716050889;
             75,50,100,75,0,125,1.59215779811248;
             75,50,100,75,100,125,0.893386562445462;
             25,0,125,50,50,225,3.89732196705811;
             25,100,125,50,50,225,2.46526707769795;
             25,100,125,50,100,250,1.27475487618655;
             75,0,125,50,50,225,3.26295251369731;
             75,100,125,50,50,225,1.83089762400072;
             75,100,125,50,100,250,1.27475487602000;
             50,50,225,50,100,250,5.59016993685697];

structure = adjustStructureArea(structure, 18, 21);
structure = adjustStructureArea(structure, 17, 20);
structure = adjustStructureArea(structure, 13, 15);
structure = adjustStructureArea(structure, 14, 16);
structure = adjustStructureArea(structure, 2, 8);
structure = adjustStructureArea(structure, 1, 7);
structure = adjustStructureArea(structure, 3, 11);
structure = adjustStructureArea(structure, 6, 12);

plotStructure3D(structure, 10);
structureTools = OptStructureTools;
volume = calcStructureVolume(structure);
outputPath = '..\vtkPython\polydatas\';
outputStructure = structure;
outputStructure(:, end) = abs(structure(:, end) * 50);
outputStructure(:, 3) = outputStructure(:, 3)+15;
outputStructure(:, 6) = outputStructure(:, 6)+15;
% structureTools.outputStructureFiles(outputStructure, outputPath);
% structureTools.outputConnectivity(outputStructure, outputPath);
maximumAreaList = structureTools.getMaximumAreaList(outputStructure);
%% Building sectors
close all
x=100; y=100; z=250;
checkingMaxAngle = 0.977;
floorSpacing = 6.25;
splineSpacing = 5;
startCoordinates = [0, 0, 0];
endCoordinates = [x, y, z+15];
structure = outputStructure;
floorLineZ = unique([structure(:, 3); structure(:, 6)])';
boxStart = startCoordinates;
boxStart(1) = boxStart(1) - 40;
boxStart(2) = boxStart(2) - 40;
boxEnd = endCoordinates;
boxEnd(1) = boxEnd(1) + 40;
boxEnd(2) = boxEnd(2) + 40;
tempStructure = structure;
tempStructure(:, end) = abs(tempStructure(:, end) * 50);
%structureTools.outputLevelBoxes(tempStructure, floorLineZ, boxStart, boxEnd, '..\vtkPython\levelBoxes\');
%%
splintLineX = startCoordinates(1)-20:splineSpacing:endCoordinates(1)+20;
splintLineY = startCoordinates(2)-20:splineSpacing:endCoordinates(2)+20;

[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing);
close all

%% cutSupports
% figure(1)
% view([ 1 1 1]);
% axis equal
% hold on
printSpacing = 0.375;
toolPathSpacing = 0.92;
totalPieces = cell(1, 1);
addedPieceNum = 1;
currentSupportFile = sprintf('..\\vtkPython\\additionalSupports\\supportPlate.stl');
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
    view([ 1 1 1]);
piecePath = cell(1, 1);
piecePathNum = 1;
for i = 0:cuttingNum*1.5
    verticalShift = supportBox(5) - surfaceZLevel + i * printSpacing+0.001;
    surface2.vertices = surfaceCurrent.Points;
    surface2.vertices(:, 3) = surface2.vertices(:, 3) + verticalShift;
    surface2.faces = surfaceCurrent.ConnectivityList;
%     figure(3)
%     surfacePlot = triangulation(surface2.faces, surface2.vertices);
%     trisurf(surfacePlot, 'EdgeColor', 'none', 'FaceAlpha',0.2);
%     view([ 1 1 1]);
    [intersect12, S] = SurfaceIntersection(surface1, surface2);

    if isempty(S.faces) 
        continue;
    end

%     figure(1)
%     trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
    toolPathes = structureTools.generateToolPathForCuttingCurve(S, surfaceCoordinates, verticalShift, toolPathSpacing);
    nozzleDirections = cell(size(toolPathes, 1), 1);
    for pathNum = 1:size(toolPathes, 1)
        currectNozzleDirection = zeros(size(toolPathes{pathNum, 1}, 1), 3);
        for segmentNum = 1:size(toolPathes{pathNum, 1}, 1)
            nozzleDirection = [0 0 1];
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
    piecePathNum = piecePathNum+1;
end
%
totalPieces{addedPieceNum, 1} = piecePath;
addedPieceNum = addedPieceNum+1;

%%
tempStructure = [structure, (1:size(structure, 1))'];
membersInEachFloor = splitSector3DInZ(tempStructure, floorLineZ);
printSpacing = 2.0;
levelSpacing = 4.0;
toolPathSpacing = 1.7;
totalPieces = cell(1, 1);
addedPieceNum = 1;
maximumOverhangAngle = 0.262;
maximumOverhang = 0;
maximumB = 42;
for floorNum = 1:5
%     if floorNum == 3 || floorNum == 5
%         printSpacing = 0.4;
%     end
%for floorNum = 5
    %surfaceCurrent = cuttingSurfaces{floorNum, 1};
    currentZStart = floorLineZ(floorNum);
    stlFileFolder = sprintf('..\\vtkPython\\booleanResults\\level%i\\', floorNum);
    figure(1)
    view([ 1 1 1]);
    axis equal
    hold on
    currentStructure = membersInEachFloor{floorNum, 1};
    currentZGrid = zGrids{floorNum, 1};
    memberStartingLevel = -1*ones(size(currentStructure, 1), 1);
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
    currentStructure(:, 7) = abs(currentStructure(:, 7));
%     if floorNum ==4
%         currentStructure = sortrows(currentStructure, 7, 'ascend');
%         levelSpacing = 10;
%     else
        currentStructure = sortrows(currentStructure, 7, 'descend');
%     end
    while floorFinished    
       currentLevel = currentLevel + levelSpacing;
       for i = 1:size(currentStructure, 1)
       %for i = 2
           if finishedCutting(i, 1)
               continue;
           end
       
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
%           trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
%            aa=0.0;
            currentMember = currentStructure(i, :);
%             plotStructure3D(currentMember, 10);
        
            [surfaceCurrent, surfaceCoordinates, calibrationPoint, surfaceAngles] = getCustomizedZGridForMember(currentMember, memberBoundingBox, splintLineX, splintLineY, anglesForEachFloor{floorNum, 1});
            if (currentStructure(i, end)== 2 || currentStructure(i, end)== 8) && floorNum == 3
                [surfaceCurrent, surfaceCoordinates, surfaceAngles] = getHorizontalCuttingSurfaceForComponents(memberBoundingBox, splineSpacing);
            end
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
            if (currentStructure(i, end) == 19 || currentStructure(i, end) == 22)&&(floorNum==4 || floorNum==5)
                increasedSpacingNumber = floor(divideSpacing/printSpacing); 
            end
            tempDivideSpacing = divideSpacing / increasedSpacingNumber;

            
%             figure(3)
%             clf
%             hold on
%             axis equal
%             xlabel x
%             ylabel y
%             zlabel z
%           trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
            
            piecePath = cell(1, 1);
            piecePathNum = 1;
                for printNum = memberStartingLevel(i, 1):increasedSpacingNumber*2
                %for printNum = 15
                    verticalShift = - (max(cuttingSurfaceMin, cuttingSurfaceMax) - memberBoundingBox(5)) + tempDivideSpacing * (printNum-1) + 0.01;
                    
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
                    figure(1)
                    trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');

                    toolPathes = structureTools.generateToolPathForCuttingCurve(S, surfaceCoordinates, verticalShift, toolPathSpacing);

%                    figure(4)
%                    clf
%                    hold on
%                    axis equal
%                    view([ 1 1 1]);
    %                 trisurf(surfacePlot, 'EdgeColor', 'none', 'FaceAlpha',0.2);
    %                 trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
                    nozzleDirections = cell(size(toolPathes, 1), 1);
                    for pathNum = 1:size(toolPathes, 1)
                        currectNozzleDirection = zeros(size(toolPathes{pathNum, 1}, 1), 3);
                        for segmentNum = 1:size(toolPathes{pathNum, 1}, 1)
                            [nozzleDirection, overhangAngle] = structureTools.getRealNozzleAngleForPath(toolPathes{pathNum, 1}(segmentNum, :), memberVector, surfaceCoordinates, surfaceAngles, maximumOverhangAngle, maximumB);
                            if abs(overhangAngle) > maximumOverhang
                                maximumOverhang = abs(overhangAngle);
                            end
                            currectNozzleDirection(segmentNum, :) = nozzleDirection;
%                            plot3(toolPathes{pathNum, 1}(segmentNum, [1 4]), toolPathes{pathNum, 1}(segmentNum, [2 5]), toolPathes{pathNum, 1}(segmentNum, [3 6]), '-g');
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
structureTools.toGCode(totalPieces, [-50 -50 -15.01]);

%%
function outputStructure = adjustStructureArea(structure, index1, index2)
    tempArea = (structure(index1, end) + structure(index2, end))/2;
    outputStructure = structure;
    outputStructure(index1, end) = tempArea;
    outputStructure(index2, end) = tempArea;
end