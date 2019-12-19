function surface = getSurfaceForMember(memberBoundingBox, zGrid, splintLineX, splintLineY)
    memberXMin = memberBoundingBox(1);
    memberXMax = memberBoundingBox(2);
    memberYMin = memberBoundingBox(3);
    memberYMax = memberBoundingBox(4);
    coverCells = cell(size(zGrid, 1), size(zGrid, 2));
    
    for i = 1:size(splintLineX, 2) - 1
        currentXStart = splintLineX(i);
        currentXEnd = splintLineX(i + 1);
        for j = 1:size(splintLineY, 2) - 1
            currentYStart = splintLineY(j);
            currentYEnd = splintLineY(j+1);
            if (currentXEnd>=memberXMin && currentXStart<=memberXMax && currentYEnd>=memberYMin && currentYStart<=memberYMax)
                coverCells{i, j} = [currentXStart, currentYStart, zGrid{i, j}(3); currentXStart, currentYEnd, zGrid{i, j+1}(3); currentXEnd, currentYEnd, zGrid{i+1, j+1}(3); currentXEnd, currentYStart, zGrid{i+1, j}(3)];
            end
        end
    end
    
    toBePlot = reshape(coverCells, [], 1);
    toBePlot = toBePlot(~cellfun('isempty', toBePlot));
    toBePlot = cell2mat(toBePlot);
    T = delaunay(toBePlot(:, 1:2));
    surface = triangulation(T,toBePlot);
%     hold on
%     trisurf(surface, 'FaceAlpha',0.5, 'EdgeColor', 'none');
%     plotStructure3D(member, 1);
end

