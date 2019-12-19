function splitedMembers = splitSector3DInZ(members, splitLine)
    memberNum = size(members, 1);
    sectorNum = size(splitLine, 2) - 1;
    tempMembers = members;
    splitedMembers = cell(sectorNum, 1);
    columnNum = size(members, 2);
    for i = 1:sectorNum
        if i == sectorNum
            splitedMembers{i, 1} = tempMembers;
            break;
        end
        tempSplitedMembers = zeros(memberNum * sectorNum, columnNum);
        addedNum = 1;
        sectorStart = splitLine(i);
        sectorEnd = splitLine(i + 1);
        
        % add fully within members first
        fullyWithinMembers = tempMembers(tempMembers(:, 3)>=sectorStart & tempMembers(:, 3)<=sectorEnd & tempMembers(:, 6)<=sectorEnd & tempMembers(:, 6)>=sectorStart, :);
        fullyWithinNum = size(fullyWithinMembers, 1);
        tempSplitedMembers(addedNum : addedNum + fullyWithinNum - 1, :) = fullyWithinMembers;
        addedNum = addedNum + fullyWithinNum;
        tempMembers = setdiff(tempMembers, fullyWithinMembers, 'rows');

        %identify partly within members
        partlyWithinMembers1 = tempMembers((tempMembers(:, 3)>=sectorStart & tempMembers(:, 3)<sectorEnd), :);
        partlyWithinMembers2 = tempMembers((tempMembers(:, 6)>=sectorStart & tempMembers(:, 6)<sectorEnd), :);
        partlyWithinMembers = [partlyWithinMembers1; partlyWithinMembers2];
        tempMembers = setdiff(tempMembers, partlyWithinMembers, 'rows');
        intersectX = partlyWithinMembers(:, 1) + (partlyWithinMembers(:, 4) - partlyWithinMembers(:, 1)) ./ (partlyWithinMembers(:, 6) - partlyWithinMembers(:, 3)) .* (sectorEnd - partlyWithinMembers(:, 3));
        intersectY = partlyWithinMembers(:, 2) + (partlyWithinMembers(:, 5) - partlyWithinMembers(:, 2)) ./ (partlyWithinMembers(:, 6) - partlyWithinMembers(:, 3)) .* (sectorEnd - partlyWithinMembers(:, 3));     
        
        partlyWithinFirstNum = size(partlyWithinMembers1, 1);
        toBeAddedPartlyWithinFirst = partlyWithinMembers1;
        toBeAddedPartlyWithinFirst(:, 4) = intersectX(1:partlyWithinFirstNum);
        toBeAddedPartlyWithinFirst(:, 5) = intersectY(1:partlyWithinFirstNum);
        toBeAddedPartlyWithinFirst(:, 6) = repmat(sectorEnd, partlyWithinFirstNum, 1);
        newPartlyWithinFirst = partlyWithinMembers1;
        newPartlyWithinFirst(:, 1) = intersectX(1:partlyWithinFirstNum);
        newPartlyWithinFirst(:, 2) = intersectY(1:partlyWithinFirstNum);
        newPartlyWithinFirst(:, 3) = repmat(sectorEnd, partlyWithinFirstNum, 1);
        
        partlyWithinSecondNum = size(partlyWithinMembers2, 1);
        toBeAddedPartlyWithinSecond = partlyWithinMembers2;
        toBeAddedPartlyWithinSecond(:, 1) = intersectX(partlyWithinFirstNum+1:end);
        toBeAddedPartlyWithinSecond(:, 2) = intersectY(partlyWithinFirstNum+1:end);
        toBeAddedPartlyWithinSecond(:, 3) = repmat(sectorEnd, partlyWithinSecondNum, 1);
        newPartlyWithinSecond = partlyWithinMembers2;
        newPartlyWithinSecond(:, 4) = intersectX(partlyWithinFirstNum+1:end);
        newPartlyWithinSecond(:, 5) = intersectY(partlyWithinFirstNum+1:end);
        newPartlyWithinSecond(:, 6) = repmat(sectorEnd, partlyWithinSecondNum, 1);
        
        toBeAdded = [toBeAddedPartlyWithinFirst; toBeAddedPartlyWithinSecond];
        newMembers = [newPartlyWithinFirst; newPartlyWithinSecond];
        toBeAddedNum = size(toBeAdded, 1);
        
        tempSplitedMembers(addedNum : addedNum + toBeAddedNum - 1, :) = toBeAdded;
        tempSplitedMembers(addedNum + toBeAddedNum:end, :) = [];
        tempMembers = [tempMembers; newMembers];
        splitedMembers{i, 1} = tempSplitedMembers;
    end
end
