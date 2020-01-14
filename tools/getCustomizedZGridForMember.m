function [customizedSurface, zGrid] = getCustomizedZGridForMember(currentMember, memberBoundingBox, splintLineX, splintLineY, angles)
    memberMinX = min([currentMember(1); currentMember(4)]);
    memberMaxX = max([currentMember(1); currentMember(4)]);
    memberMinY = min([currentMember(2); currentMember(5)]);
    memberMaxY = max([currentMember(2); currentMember(5)]);
    indicesForMember = getIndicesInSplitLinesWithoutBound([memberMinX, memberMaxX, memberMinY, memberMaxY], splintLineX, splintLineY);
    indicesForBoundingBox = getIndicesInSplitLinesWithBound(memberBoundingBox, splintLineX, splintLineY);
        
    if indicesForMember(2) == indicesForMember(1)
        indicesForMember(2) = indicesForMember(2)+1;
    end
    
    if indicesForMember(4) == indicesForMember(3)
        indicesForMember(4) = indicesForMember(4) + 1;
    end
        
    expandNumInYStart = max(indicesForMember(1) - indicesForBoundingBox(1), 0);
    expandNumInYEnd = max(indicesForBoundingBox(2) - indicesForMember(2), 0);
    expandNumInXStart = max(indicesForMember(3) - indicesForBoundingBox(3), 0);
    expandNumInXEnd = max(indicesForBoundingBox(4) - indicesForMember(4), 0);
    
    initialMatrix = angles(indicesForMember(1):indicesForMember(2)-1, indicesForMember(3):indicesForMember(4)-1);
    expandInXStart = cell(size(initialMatrix, 1), expandNumInXStart);
    for i = 1:expandNumInXStart
        expandInXStart(:, i) = initialMatrix(:, 1);
    end
    initialMatrix = [expandInXStart, initialMatrix];
    
    expandInXEnd = cell(size(initialMatrix, 1), expandNumInXEnd);
    for i = 1:expandNumInXEnd
        expandInXEnd(:, i) = initialMatrix(:, end);
    end
    initialMatrix = [initialMatrix, expandInXEnd];
    
    expandInYStart = cell(expandNumInYStart, size(initialMatrix, 2));
    for i = 1:expandNumInYStart
        expandInYStart(i, :) = initialMatrix(1, :);
    end
    initialMatrix = [expandInYStart; initialMatrix];
    
    expandInYEnd = cell(expandNumInYEnd, size(initialMatrix, 2));
    for i = 1:expandNumInYEnd
        expandInYEnd(i, :) = initialMatrix(end, :);
    end
   initialMatrix = [initialMatrix; expandInYEnd];
%     zGrid = calculateZGridBasedOnAngles(initialMatrix, splintLineX(indicesForMember(1):indicesForMember(2)), splintLineY(indicesForMember(3):indicesForMember(4)));
    zGrid = calculateZGridBasedOnAngles(initialMatrix, splintLineX(min(indicesForMember(1), indicesForBoundingBox(1)):max(indicesForMember(2), indicesForBoundingBox(2)))...
                                                    , splintLineY(min(indicesForMember(3), indicesForBoundingBox(3)):max(indicesForMember(4), indicesForBoundingBox(4))));
    
    nodex = zeros(size(initialMatrix, 1)+1, size(initialMatrix, 2)+1);
    nodey = zeros(size(initialMatrix, 1)+1, size(initialMatrix, 2)+1);
    nodez = zeros(size(initialMatrix, 1)+1, size(initialMatrix, 2)+1);
    for i = 1:size(zGrid, 1)
        for j = 1:size(zGrid, 2)
            nodex(i, j) = zGrid{i, j}(1);
            nodey(i, j) = zGrid{i, j}(2);
            nodez(i, j) = zGrid{i, j}(3);
        end
    end
    
    T = delaunay(nodex, nodey);
    customizedSurface = triangulation(T,nodex(:), nodey(:), nodez(:));
end

function indices = getIndicesInSplitLinesWithoutBound(member, splintLineX, splintLineY)
    memberXMin = member(1);
    memberXMax = member(2);
    memberYMin = member(3);
    memberYMax = member(4);
    iMin = 1e6;
    iMax = -1;
    jMin = 1e6;
    jMax = -1;
    
    for i = 1:size(splintLineX, 2) - 1
        currentXStart = splintLineX(i);
        currentXEnd = splintLineX(i + 1);
        for j = 1:size(splintLineY, 2) - 1
            currentYStart = splintLineY(j);
            currentYEnd = splintLineY(j+1);
            if (currentXEnd>memberXMin && currentXStart<memberXMin)
                iMin = i;
            end
            
            if (currentXEnd>memberXMax && currentXStart<memberXMax)
                iMax = i+1;
            end
            
            if (currentYEnd>memberYMin && currentYStart<memberYMin)
                jMin = j;
            end
            
            if (currentYEnd>memberYMax && currentYStart<memberYMax)
                jMax = j+1;
            end
                
%             if (currentXEnd>memberXMin && currentXStart<memberXMax && currentYEnd>memberYMin && currentYStart<memberYMax)
%                 if i < iMin
%                     iMin = i;
%                 end
%                 if i+1 > iMax
%                     iMax = i+1;
%                 end
%                 if j < jMin
%                     jMin = j;
%                 end
%                 if j+1>jMax
%                     jMax = j+1;
%                 end
%             end
        end
    end
    
    if iMin == 1e6
        for i = 1:size(splintLineX, 2) - 1
            currentXStart = splintLineX(i);
            if memberXMin == currentXStart 
                iMin=i;
            end
        end
    end
    
    if iMax == -1
        for i = 1:size(splintLineX, 2) - 1
            currentXEnd = splintLineX(i + 1);
            if memberXMax == currentXEnd
                iMax = i+1;
            end
        end        
    end
    
    if jMin == 1e6
        for j = 1:size(splintLineY, 2) - 1
            currentYStart = splintLineY(j);
            if memberYMin == currentYStart
                jMin=j;
            end
        end
    end
    
    if jMax == -1
        for j = 1:size(splintLineY, 2) - 1
            currentYEnd = splintLineY(j+1);
            if memberYMax == currentYEnd
                jMax=j+1;
            end
        end
    end
    
    indices = [iMin, iMax, jMin, jMax];
end

function indices = getIndicesInSplitLinesWithBound(member, splintLineX, splintLineY)
    memberXMin = member(1);
    memberXMax = member(2);
    memberYMin = member(3);
    memberYMax = member(4);
    iMin = 1e6;
    iMax = -1;
    jMin = 1e6;
    jMax = -1;
    
    for i = 1:size(splintLineX, 2) - 1
        currentXStart = splintLineX(i);
        currentXEnd = splintLineX(i + 1);
        for j = 1:size(splintLineY, 2) - 1
            currentYStart = splintLineY(j);
            currentYEnd = splintLineY(j+1);
            if (currentXEnd>=memberXMin && currentXStart<=memberXMax && currentYEnd>=memberYMin && currentYStart<=memberYMax)
                if i < iMin
                    iMin = i;
                end
                if i+1 > iMax
                    iMax = i+1;
                end
                if j < jMin
                    jMin = j;
                end
                if j+1>jMax
                    jMax = j+1;
                end
            end
        end
    end
    
    if iMin == 1e6
        for i = 1:size(splintLineX, 2) - 1
            currentXStart = splintLineX(i);
            if memberXMin == currentXStart 
                iMin=i;
            end
        end
    end
    
    if iMax == -1
        for i = 1:size(splintLineX, 2) - 1
            currentXEnd = splintLineX(i + 1);
            if memberXMax == currentXEnd
                iMax = i+1;
            end
        end        
    end
    
    if jMin == 1e6
        for j = 1:size(splintLineY, 2) - 1
            currentYStart = splintLineY(j);
            if memberYMin == currentYStart
                jMin=j;
            end
        end
    end
    
    if jMax == -1
        for j = 1:size(splintLineY, 2) - 1
            currentYEnd = splintLineY(j+1);
            if memberYMax == currentYEnd
                jMax=j+1;
            end
        end
    end
    
    indices = [iMin, iMax, jMin, jMax];
end