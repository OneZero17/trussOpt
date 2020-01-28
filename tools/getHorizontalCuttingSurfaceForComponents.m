function [surface, zGrid] = getHorizontalCuttingSurfaceForComponents(boundingBox, splitSpacing)
    
    xSplitLineStart = floor(boundingBox(1) / splitSpacing) * splitSpacing;
    xSplitLineEnd = ceil(boundingBox(2) / splitSpacing) * splitSpacing;
    ySplitLineStart = floor(boundingBox(3) / splitSpacing) * splitSpacing;
    ySplitLineEnd = ceil(boundingBox(4) / splitSpacing) * splitSpacing;
    xSplitLine = xSplitLineStart:splitSpacing:xSplitLineEnd;
    ySplitLine = ySplitLineStart:splitSpacing:ySplitLineEnd;
    
    xCellNum = size(xSplitLine, 2) - 1;
    yCellNum = size(ySplitLine, 2) - 1;
    
    angleMatrix = cell(xCellNum, yCellNum);
    for i = 1:xCellNum
        for j = 1:yCellNum
            angleMatrix{i, j} = [pi/2, pi/2];
        end
    end
    
    zGrid = calculateZGridBasedOnAngles(angleMatrix, xSplitLine, ySplitLine);
    nodex = zeros(size(angleMatrix, 1)+1, size(angleMatrix, 2)+1);
    nodey = zeros(size(angleMatrix, 1)+1, size(angleMatrix, 2)+1);
    nodez = zeros(size(angleMatrix, 1)+1, size(angleMatrix, 2)+1);
    for i = 1:size(zGrid, 1)
        for j = 1:size(zGrid, 2)
            nodex(i, j) = zGrid{i, j}(1);
            nodey(i, j) = zGrid{i, j}(2);
            nodez(i, j) = zGrid{i, j}(3);
        end
    end
    
    T = delaunay(nodex, nodey);
    surface = triangulation(T,nodex(:), nodey(:), nodez(:));
end

