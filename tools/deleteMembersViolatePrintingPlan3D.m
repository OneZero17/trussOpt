function [memberExist, penaltyValue] = deleteMembersViolatePrintingPlan3D(memberList, splitedLineX, splitedLineY, zoneAngles, nozzleMaxAngle)
    xSplitNum = size(splitedLineX, 2) - 1;
    ySplitNum = size(splitedLineY, 2) - 1;
    tempMembers = memberList(:, 3:end);
    tempMembers = [tempMembers, (1:size(tempMembers, 1))'];
    tempMembersSplitedX = splitSector3DInX(tempMembers, splitedLineX);
    tempMembersSplitedXY = cell(xSplitNum, ySplitNum);
    for i = 1:xSplitNum
        tempMembersSplitedXY(i, :) = splitSector3DInY(tempMembersSplitedX{i, 1}, splitedLineY)';
    end
    memberExist = ones(size(tempMembers, 1), 1);
    penaltyValue = zeros(size(tempMembers, 1), 1);
    for i = 1 : xSplitNum
        for j = 1 : ySplitNum
            currentAngles = zoneAngles{i, j};
            if isempty(currentAngles)
                checkingAngle = 1.4835;
                currentAngles = [pi/2, pi/2];
            else
                checkingAngle = nozzleMaxAngle;
            end
            currentNormal = [1 / tan(currentAngles(1)), 1 / tan(currentAngles(2)), 1];
            
            currentMembers = tempMembersSplitedXY{i, j};
            toBeCheckedMembers = currentMembers(memberExist(currentMembers(:, end)) == 1, :);
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
            
            toBeDeletedMembers1 = toBeCheckedMembers(intersectionAngles > checkingAngle, end);
            angleViolation = intersectionAngles - checkingAngle;
            
            if ~isempty(toBeDeletedMembers1)
                penaltyValue(toBeDeletedMembers1) = angleViolation(angleViolation>0);
            end
            memberExist(toBeDeletedMembers1) = 0;
        end
    end
end

