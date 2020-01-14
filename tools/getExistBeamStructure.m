function existList = getExistBeamStructure(structure, areaAndForceList, plotLimit)
    existList = zeros(size(structure, 1), 1);
    memberVectors = structure(:, 5:6) - structure(:, 3:4);
    memberLengths = zeros(size(memberVectors, 1), 1);
    for i = 1:size(memberVectors, 1)
        memberLengths(i) = norm(memberVectors(i, :));
    end
    totalArea = areaAndForceList(:, 1);
    maximumArea = max(totalArea);
    for i = 1:size(areaAndForceList, 1)
        coefficient = areaAndForceList(i, 1) / maximumArea;
        if coefficient > plotLimit
            existList(i, 1) = 1;
        end
    end
end
