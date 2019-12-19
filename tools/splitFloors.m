function splitedMembers = splitFloors(members,splitLine)
    memberNum = size(members, 1);
    sectorNum = size(splitLine, 2) - 1;
    tempMembers = members;
    splitedMembers = cell(sectorNum, 1);
    for i = 1:sectorNum
        if i == sectorNum
            splitedMembers{i, 1} = tempMembers;
            break;
        end
        
        tempSplitedMembers = zeros(memberNum * sectorNum, 5);
        addedNum = 1;
        sectorStart = splitLine(i);
        sectorEnd = splitLine(i + 1);
        
        % add fully within members first
        fullyWithinMembers = tempMembers(tempMembers(:, 2)>=sectorStart & tempMembers(:, 2)<=sectorEnd & tempMembers(:, 4)<=sectorEnd & tempMembers(:, 4)>=sectorStart, :);
        fullyWithinNum = size(fullyWithinMembers, 1);
        tempSplitedMembers(addedNum : addedNum + fullyWithinNum - 1, :) = fullyWithinMembers;
        addedNum = addedNum + fullyWithinNum;
        tempMembers = setdiff(tempMembers, fullyWithinMembers, 'rows');

        %identify partly within members
        partlyWithinMembers1 = tempMembers((tempMembers(:, 2)>=sectorStart & tempMembers(:, 2)<sectorEnd), :);
        partlyWithinMembers2 = tempMembers((tempMembers(:, 4)>=sectorStart & tempMembers(:, 4)<sectorEnd), :);
        partlyWithinMembers = [partlyWithinMembers1; partlyWithinMembers2];
        tempMembers = setdiff(tempMembers, partlyWithinMembers, 'rows');
        intersectX = partlyWithinMembers(:, 1) + (partlyWithinMembers(:, 3) - partlyWithinMembers(:, 1)) ./ (partlyWithinMembers(:, 4) - partlyWithinMembers(:, 2)) .* (sectorEnd - partlyWithinMembers(:, 2));
        
        partlyWithinFirstNum = size(partlyWithinMembers1, 1);
        toBeAddedPartlyWithinFirst = partlyWithinMembers1;
        toBeAddedPartlyWithinFirst(:, 3) = intersectX(1:partlyWithinFirstNum);
        toBeAddedPartlyWithinFirst(:, 4) = repmat(sectorEnd, partlyWithinFirstNum, 1);
        newPartlyWithinFirst = partlyWithinMembers1;
        newPartlyWithinFirst(:, 1) = intersectX(1:partlyWithinFirstNum);
        newPartlyWithinFirst(:, 2) = repmat(sectorEnd, partlyWithinFirstNum, 1);
        
        partlyWithinSecondNum = size(partlyWithinMembers2, 1);
        toBeAddedPartlyWithinSecond = partlyWithinMembers2;       
        toBeAddedPartlyWithinSecond(:, 1) = intersectX(partlyWithinFirstNum+1:end);
        toBeAddedPartlyWithinSecond(:, 2) = repmat(sectorEnd, partlyWithinSecondNum, 1);
        newPartlyWithinSecond = partlyWithinMembers2;
        newPartlyWithinSecond(:, 3) = intersectX(partlyWithinFirstNum+1:end);
        newPartlyWithinSecond(:, 4) = repmat(sectorEnd, partlyWithinSecondNum, 1);
        
        toBeAdded = [toBeAddedPartlyWithinFirst; toBeAddedPartlyWithinSecond];
        newMembers = [newPartlyWithinFirst; newPartlyWithinSecond];
        toBeAddedNum = size(toBeAdded, 1);
        
        tempSplitedMembers(addedNum : addedNum + toBeAddedNum - 1, :) = toBeAdded;
        tempSplitedMembers(addedNum + toBeAddedNum:end, :) = [];
        tempMembers = [tempMembers; newMembers];
        splitedMembers{i, 1} = tempSplitedMembers;
    end
    
end

