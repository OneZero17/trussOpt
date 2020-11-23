function [totalPieces, maximumOverhang] = slicing(modelpath, membersInEachFloor, zGrids, anglesForEachFloor, maximumOverhangAngle, maximumB, splintLineX, splintLineY, floorLineZ, levelSpacing, printSpacing, toolPathSpacing, shrinkLength, addInfill, showToolPath)
    structureTools = OptStructureTools;
    totalPieces = cell(1, 1);
    maximumOverhang = 0;
    addedPieceNum = 1;
    for floorNum = 1:size(membersInEachFloor, 1)
        currentZStart = floorLineZ(floorNum);
        stlFileFolder = modelpath;
        if showToolPath
            figure(1)
            view([ 1 1 1]);
            axis equal
            hold on
        end
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

                        [~, Surf12] = SurfaceIntersection(surface1, surface2);
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
                        if showToolPath
                            figure(1)
                            trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
                        end

                        toolPathes = structureTools.generateToolPathForCuttingCurve(S, surfaceCoordinates, verticalShift, toolPathSpacing, shrinkLength, addInfill);
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

function outputStructure = adjustStructureArea(structure, index1, index2)
    tempArea = (structure(index1, end) + structure(index2, end))/2;
    outputStructure = structure;
    outputStructure(index1, end) = tempArea;
    outputStructure(index2, end) = tempArea;
end
