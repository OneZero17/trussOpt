function boundaries = createVoroniCellBoundaries(voronicells)
    [edges, edgeCellNum] = createCellEdges(voronicells);
    
    inverseEdges = [edges(:, 2), edges(:, 1)];
    
    tempEdges = [edges; inverseEdges];
    
    [~, uidxa, uidxc] = unique(tempEdges, 'rows');
    count = accumarray(uidxc, 1);
    innerEdges = uidxa(count == 2, :);
    innerEdges = innerEdges(innerEdges <= size(edges, 1));
    
    boundaries = edges(setdiff((1:size(edges, 1))', innerEdges), :);
    boundariesCellNum = edgeCellNum(setdiff((1:size(edges, 1))', innerEdges), :);
    boundaries=[boundaries, boundariesCellNum];
end

