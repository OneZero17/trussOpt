function splitedMembers = splitSector3D(members, sectors)
    memberNum = size(members, 1);
    sectorNum = size(sectors, 1);
    tempMembers = members;
    splitedMembers = cell(sectorNum, 1);
    for i = 1:sectorNum
        if i == sectorNum
            splitedMembers{i, 1} = tempMembers;
            break;
        end
        
        tempSplitedMembers = zeros(memberNum * sectorNum, 7);
        addedNum = 1;
        sectorXStart = sectors(i, 1);
        sectorXEnd   = sectors(i, 2);
        sectorYStart = sectors(i, 3);
        sectorYEnd   = sectors(i, 4);
        
        % add fully within members first
        fullyWithinMembers = tempMembers(tempMembers(:, 1)>=sectorXStart & tempMembers(:, 1)<=sectorXEnd &...
                                         tempMembers(:, 4)>=sectorXStart & tempMembers(:, 4)<=sectorXEnd &...
                                         tempMembers(:, 2)>=sectorYStart & tempMembers(:, 2)<=sectorYEnd &...
                                         tempMembers(:, 5)>=sectorYStart & tempMembers(:, 5)<=sectorYEnd, :);
        fullyWithinNum = size(fullyWithinMembers, 1);
        tempSplitedMembers(addedNum : addedNum + fullyWithinNum - 1, :) = fullyWithinMembers;
        addedNum = addedNum + fullyWithinNum;
        tempMembers = setdiff(tempMembers, fullyWithinMembers, 'rows');

        %identify partly within members
        partlyWithinMembers1 = tempMembers((tempMembers(:, 1)>=sectorStart & tempMembers(:, 1)<sectorEnd), :);
        partlyWithinMembers2 = tempMembers((tempMembers(:, 3)>=sectorStart & tempMembers(:, 3)<sectorEnd), :);
        partlyWithinMembers = [partlyWithinMembers1; partlyWithinMembers2];
        tempMembers = setdiff(tempMembers, partlyWithinMembers, 'rows');
        intersectY = partlyWithinMembers(:, 2) + (partlyWithinMembers(:, 4) - partlyWithinMembers(:, 2)) ./ (partlyWithinMembers(:, 3) - partlyWithinMembers(:, 1)) .* (sectorEnd - partlyWithinMembers(:, 1));
        
        partlyWithinFirstNum = size(partlyWithinMembers1, 1);
        toBeAddedPartlyWithinFirst = partlyWithinMembers1;
        toBeAddedPartlyWithinFirst(:, 3) = repmat(sectorEnd, partlyWithinFirstNum, 1);
        toBeAddedPartlyWithinFirst(:, 4) = intersectY(1:partlyWithinFirstNum);
        newPartlyWithinFirst = partlyWithinMembers1;
        newPartlyWithinFirst(:, 1) = repmat(sectorEnd, partlyWithinFirstNum, 1);
        newPartlyWithinFirst(:, 2) = intersectY(1:partlyWithinFirstNum);
        
        partlyWithinSecondNum = size(partlyWithinMembers2, 1);
        toBeAddedPartlyWithinSecond = partlyWithinMembers2;
        toBeAddedPartlyWithinSecond(:, 1) = repmat(sectorEnd, partlyWithinSecondNum, 1);
        toBeAddedPartlyWithinSecond(:, 2) = intersectY(partlyWithinFirstNum+1:end);
        newPartlyWithinSecond = partlyWithinMembers2;
        newPartlyWithinSecond(:, 3) = repmat(sectorEnd, partlyWithinSecondNum, 1);
        newPartlyWithinSecond(:, 4) = intersectY(partlyWithinFirstNum+1:end);
        
        toBeAdded = [toBeAddedPartlyWithinFirst; toBeAddedPartlyWithinSecond];
        newMembers = [newPartlyWithinFirst; newPartlyWithinSecond];
        toBeAddedNum = size(toBeAdded, 1);
        
        tempSplitedMembers(addedNum : addedNum + toBeAddedNum - 1, :) = toBeAdded;
        tempSplitedMembers(addedNum + toBeAddedNum:end, :) = [];
        tempMembers = [tempMembers; newMembers];
        splitedMembers{i, 1} = tempSplitedMembers;
    end
end

