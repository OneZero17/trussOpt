function length = getMemberLengthInBox(memberVector, memberBoundingBox)
    
    if memberVector(3) < memberVector(6)
        point1 = memberVector([1 2 3]);
        point2 = memberVector([4 5 6]);
    else
        point2 = memberVector([1 2 3]);
        point1 = memberVector([4 5 6]);       
    end
    
    memVector = point2 - point1;
    memVector = memVector / norm(memVector);
    
    xLength = max((memberBoundingBox(1) - point1(1)) / memVector(1), (memberBoundingBox(2) - point1(1)) / memVector(1));
    yLength = max((memberBoundingBox(3) - point1(2)) / memVector(2), (memberBoundingBox(4) - point1(2)) / memVector(2));
    zLength = max((memberBoundingBox(5) - point1(3)) / memVector(3), (memberBoundingBox(6) - point1(3)) / memVector(3));
    
    lengthes = [xLength; yLength; zLength];
    length = min(lengthes);
end

