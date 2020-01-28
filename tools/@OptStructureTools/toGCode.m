function toGCode(self, toolPaths, zShifting)
    fileName = "testGCode.txt";
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
    %for pieceNum = 1:size(toolPaths, 1)
    for pieceNum = 3
        currentPiece = toolPaths{pieceNum, 1};
        printedNumInCurrentPiece = 0;
        fprintf(fid, '; Piece number %i\n', pieceNum);
        for cuttingNum = 1:size(currentPiece, 1)
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
                        benchmarkPoint(3) = benchmarkPoint(3)+zShifting;
                        pieceStartingPosition = getG54Coordinates(benchmarkPoint, currentDirection);
                        zmax = getRotatedBoundingBoxZmax(boundingBox, currentDirection);
                        pieceStartingPosition(3, 1) = zmax*1.05+zShifting;
                        fprintf(fid, 'G0 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', pieceStartingPosition);
                    end
                    
                    if segmentNum == 1
                        benchmarkPoint = currentSegment(1:3);
                        benchmarkPoint(3) = benchmarkPoint(3)+zShifting;
                        startingPosition = getG54Coordinates(benchmarkPoint, currentDirection);
                        fprintf(fid, 'G0 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', startingPosition);
                        fprintf(fid, 'M110\n'); 
                        lastPosition.Gposition = startingPosition;
                        lastPosition.currentDirection = currentDirection;
                        lastPosition.coordinate = benchmarkPoint;
                    end
                    
                    printedNumInCurrentPiece = printedNumInCurrentPiece+1;
                    benchmarkPoint = currentSegment(4:6);
                    benchmarkPoint(3) = benchmarkPoint(3)+zShifting;
                    nextPosition = getG54Coordinates(benchmarkPoint, currentDirection);
                    if abs(lastPosition.Gposition(4) - nextPosition(4))>1e-3 || abs(lastPosition.Gposition(5) - nextPosition(5))>1e-3
                        fprintf(fid, 'M111\n'); 
                        tempPosition = getG54Coordinates(lastPosition.coordinate, currentDirection);
                        fprintf(fid, 'G0 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', tempPosition);
                        fprintf(fid, 'M110\n');
                    end
                    lastPosition.Gposition = nextPosition;
                    lastPosition.currentDirection = currentDirection;
                    lastPosition.coordinate = benchmarkPoint;
                    fprintf(fid, 'G1 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', nextPosition);
                    
                    if segmentNum == size(currentPath, 1)
                        fprintf(fid, 'M111\n'); 
                    end
                end
            end
        end
    end
end

function zmax = getRotatedBoundingBoxZmax(boundingBox, direction)

    cornerPoints = boundingBoxCornerPoints(boundingBox);
    rotatedPoints = zeros(size(cornerPoints, 1), 5);
    for i = 1:size(rotatedPoints, 1)
        rotatedPoints(i, :) = getG54Coordinates(cornerPoints(i, :), direction)';
    end
    zmax = max(rotatedPoints(:, 3));
end

