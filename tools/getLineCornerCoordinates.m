function corners = getLineCornerCoordinates(twoEnds, length, thickness)
    x1 = twoEnds(1, 1); x2 = twoEnds(1, 2); y1 = twoEnds(2, 1); y2 = twoEnds(2, 2);
    
    sinTheta = (y2 - y1) / length;
    cosTheta = (x2 - x1) / length;
    
    radius = thickness / 2;
    
    newX1 = x1 - radius * sinTheta;
    newY1 = y1 + radius * cosTheta;
    newX2 = x1 + radius * sinTheta;
    newY2 = y1 - radius * cosTheta;
    newX3 = x2 + radius * sinTheta;
    newY3 = y2 - radius * cosTheta;
    newX4 = x2 - radius * sinTheta;
    newY4 = y2 + radius * cosTheta;
    
    corners = [newX1, newX2, newX3, newX4;
               newY1, newY2, newY3, newY4];
end

