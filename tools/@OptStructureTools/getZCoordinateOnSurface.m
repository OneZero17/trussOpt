function zCoordinate = getZCoordinateOnSurface(self, x, y, zGrid)
    xIndex = -1;
    yIndex = -1;
    for i = 1:size(zGrid, 1)-1
        if zGrid{i, 1}(1) - x <= 1e-6 && zGrid{i+1, 1}(1) - x >= -1e-6
            xIndex = i;
            break;
        end
    end
    
    for j = 1:size(zGrid, 2) - 1
        if zGrid{1, j}(2) - y <= 1e-6 && zGrid{1, j+1}(2) - y >= -1e-6
          yIndex = j;
          break
        end
    end
    
    zCoordinate = zGrid{xIndex, yIndex}(3)...
                  + (x - zGrid{xIndex, yIndex}(1)) * (zGrid{xIndex+1, yIndex}(3) - zGrid{xIndex, yIndex}(3)) / (zGrid{xIndex+1, yIndex}(1) - zGrid{xIndex, yIndex}(1))...
                  + (y - zGrid{xIndex, yIndex}(2)) * (zGrid{xIndex, yIndex+1}(3) - zGrid{xIndex, yIndex}(3)) / (zGrid{xIndex, yIndex+1}(2) - zGrid{xIndex, yIndex}(2));
end

