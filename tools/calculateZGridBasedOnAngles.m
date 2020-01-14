function zGrid = calculateZGridBasedOnAngles(angles, xSplitLine, ySplitLine)
    startingZ = 0;
    zGrid = cell(size(angles, 1)+1, size(angles, 2)+1);
    normalVectors = cell(size(angles, 1), size(angles, 2));
    for i = 1:size(angles, 1)
        currentXStart = xSplitLine(i);
        currentXEnd = xSplitLine(i+1);
        for j = 1:size(angles, 2)
            currentYStart = ySplitLine(j);
            currentYEnd = ySplitLine(j+1);
            currentAngles = angles{i, j};
            length1 = 1 / tan(currentAngles(1));
            length2 = 1 / tan(currentAngles(2));
            normalVector = [length1, length2, 1];
            normalVectors{i, j} = normalVector;
            if i == 1 && j == 1
                zConstant = startingZ;
            elseif j == 1
                zConstant = zGrid{i, j}(3);
            else
                zConstant = z4;
            end
            normalVector = normalVectors{i, j};
            x1 = currentXStart;
            y1 = currentYStart;
            z1 = zConstant;
            
            z2 = z1 - (currentXEnd   - x1) * normalVector(1) - (currentYStart - y1) * normalVector(2);
            z3 = z1 - (currentXEnd   - x1) * normalVector(1) - (currentYEnd   - y1) * normalVector(2);
            z4 = z1 - (currentXStart - x1) * normalVector(1) - (currentYEnd   - y1) * normalVector(2);
            zGrid{i,     j} = [currentXStart, currentYStart, z1];
            zGrid{i + 1, j} = [currentXEnd, currentYStart, z2]; 
            zGrid{i    , j + 1} = [currentXStart, currentYEnd, z4]; 
            zGrid{i + 1, j + 1} = [currentXEnd, currentYEnd, z3]; 
        end
    end
end

