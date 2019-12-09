function points = calculateCircleEdgePoints(self, center, normalDirection, startingPoint, divideNum)
    points = zeros(divideNum, 3);
    points(1, :) = startingPoint;
    for i = 1 : divideNum - 1
        currentRotationAngle = i * 2 * pi / divideNum;
        relativeStartingPosition = startingPoint - center;
        rotatedRelativePosition = rotate_3D(relativeStartingPosition', 'any', currentRotationAngle, normalDirection');
        rotatedPosition = rotatedRelativePosition' + center;
        points(i + 1, :) = rotatedPosition;
    end
end

