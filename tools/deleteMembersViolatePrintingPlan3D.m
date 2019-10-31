function memberExist = deleteMembersViolatePrintingPlan3D(memberList, splitedLineX, splitedLineY, zoneAngles, nozzleMaxAngle)
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
    
    for i = 1 : xSplitNum
        for j = 1 : ySplitNum
            currentAngles = zoneAngles{i, j};
            currentMembers = tempMembersSplitedXY{i, j};
            toBeCheckedMembers = currentMembers(memberExist(currentMembers(:, end)) == 1, :);
            XZAngles = atan((toBeCheckedMembers(:, 6) - toBeCheckedMembers(:, 3)) ./ (toBeCheckedMembers(:, 4) - toBeCheckedMembers(:, 1)));
            YZAngles = atan((toBeCheckedMembers(:, 6) - toBeCheckedMembers(:, 3)) ./ (toBeCheckedMembers(:, 5) - toBeCheckedMembers(:, 2)));
            XZAngles(isnan(XZAngles)) = currentAngles(1);
            YZAngles(isnan(YZAngles)) = currentAngles(2);
            XZAngles(XZAngles<0) = XZAngles(XZAngles<0) + pi;
            YZAngles(YZAngles<0) = YZAngles(YZAngles<0) + pi;
            
            toBeDeletedMembers1 = toBeCheckedMembers(abs(XZAngles - currentAngles(1)) > nozzleMaxAngle, end);
            toBeDeletedMembers2 = toBeCheckedMembers(abs(YZAngles - currentAngles(2)) > nozzleMaxAngle, end);
            memberExist(toBeDeletedMembers1) = 0;
            memberExist(toBeDeletedMembers2) = 0;
        end
    end
end

