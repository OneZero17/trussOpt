function tempPoint = getSpaceCircleStartingPoint(self, currentCenter, memberVector)
    if memberVector(1)~=0
        tempX = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3) - 2 * memberVector(2) - 2 * memberVector(3)) / memberVector(1);
        tempPoint = [tempX 2 2]; 
    elseif memberVector(3)~=0
        tempZ = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3)) / memberVector(3);
        tempPoint = [0 0 tempZ];
        if currentCenter == [0 0 0]
            tempZ = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3) - memberVector(1) - memberVector(2)) / memberVector(3);
            tempPoint = [1 1 tempZ];
        end       
    else
        tempY = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3)) / memberVector(2);
        tempPoint = [0 tempY 0];
        if currentCenter == [0 0 0]
            tempY = (memberVector(1) * currentCenter(1) + memberVector(2) * currentCenter(2) + memberVector(3) * currentCenter(3)- memberVector(1) - memberVector(3)) / memberVector(2);
            tempPoint = [1 tempY 1];
        end
    end
end

