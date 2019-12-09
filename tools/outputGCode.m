function outputGCode(allSlices, angles, xmid, ymid)
    scaleFactor = 4;
    circleDivideNum = 16;
    fileName = "testGCode.txt";
    fid = fopen( fileName, 'wt' );
    layerthickness = 0.8;
%     angles{10, 1}{7, 9}(1, :) = [-2.0027   -1.0013    2.0027];
%     angles{11, 1}{6, 8}(1, :) = [-2.0027   -1.0013    2.0027];
%     angles{12, 1}{6, 8}(1, :) = [-2.0027   -1.0013    2.0027];
    for sliceNumber  = 1:size(allSlices, 1)
        currentSlice = allSlices{sliceNumber, 1};
        currentSliceAngles = angles{sliceNumber, 1};
        currentSliceMembers = reshape(currentSlice, [], 1);
        currentSliceMembers = cell2mat(currentSliceMembers);
        zmax = max(max(currentSliceMembers(:, 3)), max(currentSliceMembers(:, 6)));
        G54positionMax = getG54Coordinates([xmid, ymid, zmax], [1 1 1]);
        zmax = G54positionMax(3);
        zmax = 400;
        for i = 1 : size(currentSlice, 1)
            for j = 1:size(currentSlice, 2)
                currentZoneMember = currentSlice{i, j};
                if ~isempty(currentZoneMember)
                    nozzleDirectionForMembers = currentSliceAngles{i, j};
                    for k = 1:size(currentZoneMember, 1)
                        currentMember = currentZoneMember(k, :);
                        memberRadius = scaleFactor * sqrt(abs(currentMember(7))/pi);
                        currentNozzleDirection = nozzleDirectionForMembers(k, :);
                        if currentMember(6) > currentMember(3)
                            startingPoint = currentMember(1:3);
                            endPoint = currentMember(4:6);
                        else
                            startingPoint = currentMember(4:6);
                            endPoint = currentMember(1:3);
                        end
                        %fprintf(fid, 'SliceNum%d I%d J%d k%d\n', sliceNumber, i, j, k);
                        benchmarkPoints = getPrintCornerPoints(startingPoint, endPoint, memberRadius, layerthickness, circleDivideNum);
                        for sliceNum = 1:size(benchmarkPoints, 1)
                            edgePoints = benchmarkPoints{sliceNum, 1};
                            for l = 1: size(edgePoints, 1) 
                                G54position = getG54Coordinates(edgePoints(l, :), currentNozzleDirection);
                                middlePosition = G54position;
                                middlePosition(3) = zmax;
                                if l == 1
                                    fprintf(fid, 'G54 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', middlePosition);
                                    fprintf(fid, 'G54 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', G54position);
                                    fprintf(fid, 'M110\n');      
                                else
                                    fprintf(fid, 'G1 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', G54position);
                                end

                                if l == size(edgePoints, 1)
                                    startingPointG54Position = getG54Coordinates(edgePoints(1, :), currentNozzleDirection);
                                    fprintf(fid, 'G1 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', startingPointG54Position);
                                    fprintf(fid, 'M111\n');
                                end
                            end
                        end
                        
                        middlePosition = startingPointG54Position;
                        middlePosition(3) = zmax;
                        fprintf(fid, 'G54 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', middlePosition);
                        fprintf(fid, 'G54 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', xmid, ymid, zmax, 0, 0);
                    end
                end
            end
        end
    end
end


function points = getPrintCornerPoints(startingPoint, endPoint, memberRadius, layerThickness, circleDivideNum)
   memberVector = endPoint - startingPoint;
   layerNum =  ceil(norm(memberVector) / layerThickness);
   points = cell(layerNum + 1, 1);
   for i = 1:layerNum+1
       currentCenter = startingPoint + (i-1) * layerThickness* memberVector/norm(memberVector);
       
        if memberVector(1)~=0
            tempX = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3) - 2 * memberVector(2) - 2 * memberVector(3)) / memberVector(1);
            tempPoint = [tempX 2 2]; 
        elseif memberVector(3)~=0
            tempZ = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3)) / memberVector(3);
            tempPoint = [0 0 tempZ];
            if currentCenter == [0 0 0]
                tempZ = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3) - memberVector(1) - memberVector(2)) / memberVector(3);
                tempPoint = [1 1 tempZ];
            end       
        else
            tempY = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3)) / memberVector(2);
            tempPoint = [0 tempY 0];
            if currentCenter == [0 0 0]
                tempY = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3)- memberVector(1) - memberVector(3)) / memberVector(2);
                tempPoint = [1 tempY 1];
            end
        end
        
        radiusVector = tempPoint - currentCenter;
        edgeStartingPoint = currentCenter + memberRadius * radiusVector/norm(radiusVector);
        edgePoints = calculateCircleEdgePoints(currentCenter, memberVector, edgeStartingPoint, circleDivideNum);
        points{i, 1} = edgePoints;
   end
end

