function boundaryIndices = findBoundariesContainNodes(boundaries,nodes)
    boundaryNum = size(boundaries, 1);
    boundaryIndices = zeros(boundaryNum, 1);
    for i = 1 : boundaryNum
        checkResult = setdiff(boundaries(i, 1:2), nodes);
        if size(checkResult, 2) == 0  
            boundaryIndices(i) = 1;
        end
    end

end

