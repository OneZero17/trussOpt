function toTapFile(self, toolPaths, Shifting)
    fileName = "testTapFile.tap";
    fid = fopen( fileName, 'wt' );
    boundingBox = [];
    scalingFactor = 1;
    
    figure(1)
    hold on
    axis equal
    view([1 1 1])
    xlabel x
    ylabel y
    zlabel z
    xmax = 0;
    xmin = 10000;
    ymax = 0;
    ymin = 10000;
    zmax = 0;
    zmin = 10000;
    layerNum = 0;
    for pieceNum = 1:size(toolPaths, 1)
        currentPiece = toolPaths{pieceNum, 1};
        printedNumInCurrentPiece = 0;
        for cuttingNum = 1:size(currentPiece, 1)
            layerNum = layerNum + 1;
            currentCutting = currentPiece{cuttingNum, 1};
            for pathNum = 1:size(currentCutting.paths, 1)
                currentPath = currentCutting.paths{pathNum, 1};
                currentDirections = currentCutting.nozzleDirection{pathNum, 1};
                lastPosition = [];
                for segmentNum = 1:size(currentPath, 1)
                    currentSegment = currentPath(segmentNum, :);
                    currentSegment = currentSegment * scalingFactor;
                    %plot3(currentSegment([1 4]), currentSegment([2 5]), currentSegment([3 6]), '-g');
                    currentDirection = currentDirections(segmentNum, :);
                                       
                    middlePoint = (currentSegment(1:3) + currentSegment(4:6))/2;
                    endPoint = middlePoint + currentDirection*2;
                    %plot3([middlePoint(1), endPoint(1)], [middlePoint(2), endPoint(2)], [middlePoint(3), endPoint(3)], '-b');
                    if isempty(boundingBox)
                        boundingBox = boundingBox3d([currentSegment(1:3); currentSegment(4:6)]);
                    else
                        points = [boundingBoxCornerPoints(boundingBox); currentSegment(1:3); currentSegment(4:6)];
                        boundingBox = boundingBox3d(points);
                    end
                    
                    if printedNumInCurrentPiece == 0
                        benchmarkPoint = currentSegment(1:3);
                        benchmarkPoint = benchmarkPoint+Shifting;
                        pieceStartingPosition = getG54Coordinates(benchmarkPoint, currentDirection);
                        zmax = getRotatedBoundingBoxZmax(boundingBox, currentDirection);
                        pieceStartingPosition(3, 1) = zmax*1.1+Shifting(3);
                        angles = getEularAngles(currentDirection);
                        fprintf(fid, 'G01 X%.2f Y%.2f Z%.2f RZ%.2f RY%.2f RX%.2f L%.1f APP\n', [benchmarkPoint(1:3)'; rad2deg(angles)'; layerNum]);
                        if pieceStartingPosition(1) > xmax
                            xmax = pieceStartingPosition(1);
                        end
                        if pieceStartingPosition(1) < xmin
                            xmin = pieceStartingPosition(1);
                        end
                        if pieceStartingPosition(2) > ymax
                            ymax = pieceStartingPosition(2);
                        end
                        if pieceStartingPosition(2) < ymin
                            ymin = pieceStartingPosition(2);
                        end
                        if pieceStartingPosition(3) > zmax
                            zmax = pieceStartingPosition(3);
                        end
                        if pieceStartingPosition(3) < zmin
                            zmin = pieceStartingPosition(3);
                        end                        
                    end
                    
                    if segmentNum == 1
                        benchmarkPoint = currentSegment(1:3);
                        benchmarkPoint = benchmarkPoint+Shifting;
                        angles = getEularAngles(currentDirection);
                        startingPosition = getG54Coordinates(benchmarkPoint, currentDirection);
                        fprintf(fid, 'G01 X%.2f Y%.2f Z%.2f RZ%.2f RY%.2f RX%.2f L%.1f LINK\n', [benchmarkPoint(1:3)'; rad2deg(angles)'; layerNum]);
                        lastPosition.Gposition = startingPosition;
                        lastPosition.currentDirection = currentDirection;
                        lastPosition.coordinate = benchmarkPoint;
                        if startingPosition(1) > xmax
                            xmax = startingPosition(1);
                        end
                        if startingPosition(1) < xmin
                            xmin = startingPosition(1);
                        end
                        if startingPosition(2) > ymax
                            ymax = startingPosition(2);
                        end
                        if startingPosition(2) < ymin
                            ymin = startingPosition(2);
                        end
                        if startingPosition(3) > zmax
                            zmax = startingPosition(3);
                        end
                        if startingPosition(3) < zmin
                            zmin = startingPosition(3);
                        end                        
                    end
                    
                    printedNumInCurrentPiece = printedNumInCurrentPiece+1;
                    benchmarkPoint = currentSegment(4:6);
                    benchmarkPoint = benchmarkPoint+Shifting;
                    nextPosition = getG54Coordinates(benchmarkPoint, currentDirection);
                    angles = getEularAngles(currentDirection);
                    if abs(lastPosition.Gposition(4) - nextPosition(4))>1e-3 || abs(lastPosition.Gposition(5) - nextPosition(5))>1e-3
                        tempPosition = getG54Coordinates(lastPosition.coordinate, currentDirection);
                        angles = getEularAngles(currentDirection);
                        fprintf(fid, 'G01 X%.2f Y%.2f Z%.2f RZ%.2f RY%.2f RX%.2f L%.1f LINK\n', [lastPosition.coordinate(1:3)'; rad2deg(angles)'; layerNum]);
                        if tempPosition(1) > xmax
                            xmax = tempPosition(1);
                        end
                        if tempPosition(1) < xmin
                            xmin = tempPosition(1);
                        end
                        if tempPosition(2) > ymax
                            ymax = tempPosition(2);
                        end
                        if tempPosition(2) < ymin
                            ymin = tempPosition(2);
                        end
                        if tempPosition(3) > zmax
                            zmax = tempPosition(3);
                        end
                        if tempPosition(3) < zmin
                            zmin = tempPosition(3);
                        end                        
                    end
                    lastPosition.Gposition = nextPosition;
                    lastPosition.currentDirection = currentDirection;
                    lastPosition.coordinate = benchmarkPoint;
                    fprintf(fid, 'G01 X%.2f Y%.2f Z%.2f RZ%.2f RY%.2f RX%.2f L%.1f ADD\n', [benchmarkPoint(1:3)'; rad2deg(angles)'; layerNum]);
                        if nextPosition(1) > xmax
                            xmax = nextPosition(1);
                        end
                        if nextPosition(1) < xmin
                            xmin = nextPosition(1);
                        end
                        if nextPosition(2) > ymax
                            ymax = nextPosition(2);
                        end
                        if nextPosition(2) < ymin
                            ymin = nextPosition(2);
                        end
                        if nextPosition(3) > zmax
                            zmax = nextPosition(3);
                        end
                        if nextPosition(3) < zmin
                            zmin = nextPosition(3);
                        end
                    %fprintf(fid, 'G01 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', nextPosition);
                end
            end
        end
    end
    xmax
    xmin
    ymax
    ymin
    zmin
    zmax
end

function eul = getEularAngles(direction)

    r = vrrotvec([0, 0, 1],direction);
    m = vrrotvec2mat(r);
    eul = rotm2eul(m, 'ZYX');
 
end

function newSegment = getRotatedNewSegment(segment, angle)
     relativeSegPoint1 = segment(1:3);
     relativeSegPoint2 = segment(4:6);
     relativeSegPoint1(1:2) = relativeSegPoint1(1:2)-50;
     relativeSegPoint2(1:2) = relativeSegPoint2(1:2)-50;
         
     rotatedSegPoint1 = rotate_3D(relativeSegPoint1', 'any', angle, [0 0 1]')';
     rotatedSegPoint2 = rotate_3D(relativeSegPoint2', 'any', angle, [0 0 1]')';
     rotatedSegPoint1(1:2) = rotatedSegPoint1(1:2)+ 50;
     rotatedSegPoint2(1:2) = rotatedSegPoint2(1:2)+ 50;
     newSegment = [rotatedSegPoint1, rotatedSegPoint2];
end

function zmax = getRotatedBoundingBoxZmax(boundingBox, direction)

    cornerPoints = boundingBoxCornerPoints(boundingBox);
    rotatedPoints = zeros(size(cornerPoints, 1), 5);
    for i = 1:size(rotatedPoints, 1)
        rotatedPoints(i, :) = getG54Coordinates(cornerPoints(i, :), direction)';
    end
    zmax = max(rotatedPoints(:, 3));
end