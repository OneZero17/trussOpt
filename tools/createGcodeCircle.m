function gcodeCoordinates = createGcodeCircle(center, radius, normalDirection, spacing, startZ, endZ, startX, endX, layerNum)

perimeter = 2*radius*pi;
spcingNum = round(perimeter / spacing);
firstPoint = center;

gcodeCoordinates = zeros(spcingNum+1, 4);
Zspacing = (endZ - startZ)/spcingNum;
Xspacing = (endX - startX)/spcingNum;
for i = 0:spcingNum
    currentPoint = firstPoint - [radius, 0, 0] + [-Xspacing * i, 0, Zspacing*i];
    PointG54 = getG54Coordinates(currentPoint, normalDirection(currentPoint(3), 50));
    gcodeCoordinates(i+1, :) = PointG54(1:4);
end

gcodeCoordinates = [gcodeCoordinates, (layerNum*360:360/spcingNum:(layerNum+1)*360)'];
end

