function splitedMembers= splitSector3DInY(members,splitLine)
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
        fullyWithinMembers = tempMembers(tempMembers(:, 2)>=sectorStart & tempMembers(:, 2)<=sectorEnd & tempMembers(:, 5)<=sectorEnd & tempMembers(:, 5)>=sectorStart, :);
        fullyWithinNum = size(fullyWithinMembers, 1);
        tempSplitedMembers(addedNum : addedNum + fullyWithinNum - 1, :) = fullyWithinMembers;
        addedNum = addedNum + fullyWithinNum;
        tempMembers = setdiff(tempMembers, fullyWithinMembers, 'rows');

        %identify partly within members
        partlyWithinMembers1 = tempMembers((tempMembers(:, 2)>=sectorStart & tempMembers(:, 2)<sectorEnd), :);
        partlyWithinMembers2 = tempMembers((tempMembers(:, 5)>=sectorStart & tempMembers(:, 5)<sectorEnd), :);
        partlyWithinMembers = [partlyWithinMembers1; partlyWithinMembers2];
        tempMembers = setdiff(tempMembers, partlyWithinMembers, 'rows');
        intersectX = partlyWithinMembers(:, 1) + (partlyWithinMembers(:, 4) - partlyWithinMembers(:, 1)) ./ (partlyWithinMembers(:, 5) - partlyWithinMembers(:, 2)) .* (sectorEnd - partlyWithinMembers(:, 2));     
        intersectZ = partlyWithinMembers(:, 3) + (partlyWithinMembers(:, 6) - partlyWithinMembers(:, 3)) ./ (partlyWithinMembers(:, 5) - partlyWithinMembers(:, 2)) .* (sectorEnd - partlyWithinMembers(:, 2));
        
        partlyWithinFirstNum = size(partlyWithinMembers1, 1);
        toBeAddedPartlyWithinFirst = partlyWithinMembers1;
        toBeAddedPartlyWithinFirst(:, 4) = intersectX(1:partlyWithinFirstNum);
        toBeAddedPartlyWithinFirst(:, 5) = repmat(sectorEnd, partlyWithinFirstNum, 1);
        toBeAddedPartlyWithinFirst(:, 6) = intersectZ(1:partlyWithinFirstNum);
        newPartlyWithinFirst = partlyWithinMembers1;
        newPartlyWithinFirst(:, 1) = intersectX(1:partlyWithinFirstNum);
        newPartlyWithinFirst(:, 2) = repmat(sectorEnd, partlyWithinFirstNum, 1);
        newPartlyWithinFirst(:, 3) = intersectZ(1:partlyWithinFirstNum);
        
        partlyWithinSecondNum = size(partlyWithinMembers2, 1);
        toBeAddedPartlyWithinSecond = partlyWithinMembers2;
        toBeAddedPartlyWithinSecond(:, 1) = intersectX(partlyWithinFirstNum+1:end);
        toBeAddedPartlyWithinSecond(:, 2) = repmat(sectorEnd, partlyWithinSecondNum, 1);
        toBeAddedPartlyWithinSecond(:, 3) = intersectZ(partlyWithinFirstNum+1:end);
        newPartlyWithinSecond = partlyWithinMembers2;
        newPartlyWithinSecond(:, 4) = intersectX(partlyWithinFirstNum+1:end);
        newPartlyWithinSecond(:, 5) = repmat(sectorEnd, partlyWithinSecondNum, 1);
        newPartlyWithinSecond(:, 6) = intersectZ(partlyWithinFirstNum+1:end);
        
        toBeAdded = [toBeAddedPartlyWithinFirst; toBeAddedPartlyWithinSecond];
        newMembers = [newPartlyWithinFirst; newPartlyWithinSecond];
        toBeAddedNum = size(toBeAdded, 1);
        
        tempSplitedMembers(addedNum : addedNum + toBeAddedNum - 1, :) = toBeAdded;
        tempSplitedMembers(addedNum + toBeAddedNum:end, :) = [];
        tempMembers = [tempMembers; newMembers];
        splitedMembers{i, 1} = tempSplitedMembers;
    end
end
