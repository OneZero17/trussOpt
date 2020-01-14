function deltaValues = calculateDeltaForMembers(memberList, splitedLineX, splitedLineY, zoneAngles, nozzleMaxAngle, scalingFactor)
    xSplitNum = size(splitedLineX, 2) - 1;
    ySplitNum = size(splitedLineY, 2) - 1;
    tempMembers = memberList(:, 1:7);
    tempMembers = [tempMembers, (1:size(tempMembers, 1))'];
    tempMembersSplitedX = splitSector3DInX(tempMembers, splitedLineX);
    tempMembersSplitedXY = cell(xSplitNum, ySplitNum);
    
    for i = 1:xSplitNum
        tempMembersSplitedXY(i, :) = splitSector3DInY(tempMembersSplitedX{i, 1}, splitedLineY)';
    end
    deltaValues = zeros(size(tempMembers, 1), 2);
    
    for i = 1 : xSplitNum
        for j = 1 : ySplitNum
            currentAngles = zoneAngles{i, j};
            if isempty(currentAngles)
                 checkingAngle = 1.4835;
                %checkingAngle = 0.977;
                currentAngles = [pi/2, pi/2];
            else
                checkingAngle = nozzleMaxAngle;
            end
            currentNormal = [1 / tan(currentAngles(1)), 1 / tan(currentAngles(2)), 1];
            
            currentMembers = tempMembersSplitedXY{i, j};
            toBeCheckedMembers = currentMembers;
            toBeCheckedMemberVectors = toBeCheckedMembers(:, [4 5 6]) - toBeCheckedMembers(:, [1 2 3]);
            intersectionAngles = zeros(size(toBeCheckedMembers, 1), 1);
            for k = 1:size(toBeCheckedMembers, 1)
                currentMemberVector = toBeCheckedMemberVectors(k, :);
                if currentMemberVector(3) < 0
                    currentMemberVector = -currentMemberVector;
                end
                
                if norm(currentMemberVector) < 1e-6
                    intersectionAngles(k, 1) = 0;
                    continue
                end
                intersectionAngles(k, 1) = atan2(norm(cross(currentNormal,currentMemberVector)),dot(currentNormal,currentMemberVector));
            end
            intersectionAngles(intersectionAngles>pi/2) = pi - intersectionAngles(intersectionAngles>pi/2);
            currentDeltaValues = (abs(intersectionAngles + checkingAngle) + abs(checkingAngle - intersectionAngles)) / (2 * checkingAngle);
            if ~isempty(zoneAngles{i, j})
                currentDeltaValues = currentDeltaValues * scalingFactor;
            end
            deltaValues(currentMembers(:, end), 1) = deltaValues(currentMembers(:, end), 1) + currentDeltaValues.*currentMembers(:, 7);
            deltaValues(currentMembers(:, end), 2) = deltaValues(currentMembers(:, end), 2) + currentMembers(:, 7);
        end
    end
end