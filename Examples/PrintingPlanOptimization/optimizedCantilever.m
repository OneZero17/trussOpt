clear
structure = [[0,0,0,25,50,100,2.68510293702253;
        0,0,0,25,0,125,3.98360897164573;
        0,100,0,25,50,100,2.95361323393586;
        0,100,0,50,66.67,66.67,2.10;
        50,66.67,66.67,75,50,100,2.10;
        0,100,0,25,100,125,3.66492026704775;
        100,0,0,75,50,100,2.68510293702253;
        100,0,0,75,0,125,3.98360897164573;
        100,100,0,50,66.67,66.67,2.10;
        50,66.67,66.67,25,50,100,2.10;
        100,100,0,75,50,100,2.95361323393586;
        100,100,0,75,100,125,3.66492026704775;
        25,50,100,25,0,125,1.74692809709897;
        25,50,100,25,100,125,1.04815686147718;
        75,50,100,75,0,125,1.74692809709897;
        75,50,100,75,100,125,1.04815686147718;
        25,0,125,50,50,225,3.58013724037771;
        25,100,125,50,50,225,2.14808235084934;
        25,100,125,50,100,250,1.27475487618655;
        75,0,125,50,50,225,3.58013724037771;
        75,100,125,50,50,225,2.14808235084934;
        75,100,125,50,100,250,1.27475487602000;
        50,50,225,50,100,250,5.59016993685697]];

plotStructure3D(structure, 10, [0.3, 0.3, 0.3], true);
structureTools = OptStructureTools;
volume = calcStructureVolume(structure);
outputPath = '..\vtkPython\polydatas\';
outputStructure = structure;
outputStructure(:, end) = abs(structure(:, end) * 50);
outputStructure(:, 3) = outputStructure(:, 3)+15;
outputStructure(:, 6) = outputStructure(:, 6)+15;
structureTools.outputStructureFiles(outputStructure, outputPath);
structureTools.outputConnectivity(outputStructure, outputPath);
maximumAreaList = structureTools.getMaximumAreaList(outputStructure);
%% Building sectors
close all
xMax=100; yMax=100; zMax=250;
startCoordinates = [0, 0, 0];
endCoordinates = [xMax, yMax, zMax + 15];
floorLineZ = outputBoxForEachFloor(startCoordinates, endCoordinates, outputStructure, false);

%% Printing plan optimization
checkingMaxAngle = 0.977;
floorSpacing = 6.25;
splineSpacing = 5;
expandX = 20;
expandY = 20;
splintLineX = startCoordinates(1)- expandX:splineSpacing:endCoordinates(1)+ expandY;
splintLineY = startCoordinates(2)- expandX:splineSpacing:endCoordinates(2)+ expandY;
maximumTurnAngle = 0.6;
[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(outputStructure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing, maximumTurnAngle);

%% Tool path slicing
tempStructure = [outputStructure, (1:size(outputStructure, 1))'];
membersInEachFloor = splitSector3DInZ(tempStructure, floorLineZ);
printSpacing = 0.375;
toolPathSpacing = 0.92;
levelSpacing = 4.0;
totalPieces = cell(1, 1);
addedPieceNum = 1;
maximumOverhangAngle = 0.262;
maximumOverhang = 0;
maximumB = 42;
for floorNum = 1:size(membersInEachFloor, 1)
    currentZStart = floorLineZ(floorNum);
    stlFileFolder = sprintf('..\\vtkPython\\booleanResults\\MARK1\\level%i\\', floorNum);
    figure(1)
    view([ 1 1 1]);
    axis equal
    hold on
    currentStructure = membersInEachFloor{floorNum, 1};
    currentZGrid = zGrids{floorNum, 1};
    memberStartingLevel = -1*ones(size(currentStructure, 1), 1); 
    currentZGrid = resetZGrid(currentZGrid, currentZStart);

    floorFinished = true;
    currentLevel = 0;
    finishedCutting = false(size(currentStructure, 1), 1);
    memberstarted = false(size(currentStructure, 1), 1);
    currentStructure(:, 7) = abs(currentStructure(:, 7));
    currentStructure = sortrows(currentStructure, 7, 'descend');
    
    while floorFinished    
       currentLevel = currentLevel + levelSpacing;
       for i = 1:size(currentStructure, 1)
            if finishedCutting(i, 1)
                continue;
            end
            memberFileName = [stlFileFolder, sprintf('cutCylinder%i.stl', currentStructure(i, end)-1)];
            if isfile(memberFileName)
               [F,V] = stlread(memberFileName);
            else 
               finishedCutting(i, 1) = true;
               continue;
            end
        
            if ~isempty(V) 
                memberBoundingBox = boundingBox3d(V);

                testSurface = triangulation(F, V);
                currentMember = currentStructure(i, :);

                [surfaceCurrent, surfaceCoordinates, calibrationPoint, surfaceAngles] = getCustomizedZGridForMember(currentMember, memberBoundingBox, splintLineX, splintLineY, anglesForEachFloor{floorNum, 1});
                calibrationLevel = structureTools.getZCoordinateOnSurface(calibrationPoint(1), calibrationPoint(2), currentZGrid) + currentLevel;
                currentCalibrationLevel = structureTools.getZCoordinateOnSurface(calibrationPoint(1), calibrationPoint(2), surfaceCoordinates);
                [cuttingSurfaceMin, cuttingSurfaceMax] = getCuttingSurfaceMinAndMax(currentMember, memberBoundingBox, surfaceCoordinates);
                cuttingSurfaceGap = abs(cuttingSurfaceMax - cuttingSurfaceMin);
                divideSpacing = memberBoundingBox(6) - memberBoundingBox(5)+ cuttingSurfaceGap;

                surface1.vertices = V;
                surface1.faces = F;
                memberVector = currentMember([4, 5, 6]) - currentMember([1, 2, 3]);
                memberLengthInBox = getMemberLengthInBox(currentMember, memberBoundingBox);
                increasedSpacingNumber = floor(memberLengthInBox/printSpacing); 
                tempDivideSpacing = divideSpacing / increasedSpacingNumber;

                piecePath = cell(1, 1);
                piecePathNum = 1;
                for printNum = memberStartingLevel(i, 1):increasedSpacingNumber*2
                    verticalShift = - (max(cuttingSurfaceMin, cuttingSurfaceMax) - memberBoundingBox(5)) + tempDivideSpacing * (printNum-1) + 0.01;
                    
                    if currentCalibrationLevel + verticalShift > calibrationLevel
                        memberStartingLevel(i, 1) = printNum;
                        break;
                    end
                    
                    surface2.vertices = surfaceCurrent.Points;
                    surface2.vertices(:, 3) = surface2.vertices(:, 3) + verticalShift;
                    surface2.faces = surfaceCurrent.ConnectivityList;
                    
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

                    toolPathes = structureTools.generateToolPathForCuttingCurve(S, surfaceCoordinates, verticalShift, toolPathSpacing);
                    nozzleDirections = cell(size(toolPathes, 1), 1);
                    for pathNum = 1:size(toolPathes, 1)
                        currectNozzleDirection = zeros(size(toolPathes{pathNum, 1}, 1), 3);
                        for segmentNum = 1:size(toolPathes{pathNum, 1}, 1)
                            [nozzleDirection, overhangAngle] = structureTools.getRealNozzleAngleForPath(toolPathes{pathNum, 1}(segmentNum, :), memberVector, surfaceCoordinates, surfaceAngles, maximumOverhangAngle, maximumB);
                            if abs(overhangAngle) > maximumOverhang
                                maximumOverhang = abs(overhangAngle);
                            end
                            currectNozzleDirection(segmentNum, :) = nozzleDirection;
                        end
                        nozzleDirections{pathNum, 1} = currectNozzleDirection;
                    end
                    toolPath.paths = toolPathes;
                    toolPath.nozzleDirection = nozzleDirections;
                    piecePath{piecePathNum, 1} = toolPath;
                    piecePathNum = piecePathNum + 1;
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
maximumOverhang = 180*(maximumOverhang/pi);
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

function ZGrid = resetZGrid(currentZGrid, currentZStart)
    zGridColumnNum = size(currentZGrid, 2);
    currentZGrid = reshape(currentZGrid, [], 1);
    tempZGrid = cell2mat(currentZGrid);
    tempzmax = max(tempZGrid(:, 3));
    tempZGrid(:, 3) = tempZGrid(:, 3) - (tempzmax - currentZStart);
    tempZGrid = mat2cell(tempZGrid, ones(size(tempZGrid, 1), 1));
    ZGrid = reshape(tempZGrid, [], zGridColumnNum);
end


function [cuttingSurfaceMin, cuttingSurfaceMax] = getCuttingSurfaceMinAndMax(currentMember, memberBoundingBox, surfaceCoordinates)
    structureTools = OptStructureTools;
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
end