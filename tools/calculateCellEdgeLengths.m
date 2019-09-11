function lengths = calculateCellEdgeLengths(cellNodeIndices,voroniNodes)
    cellNum = size(cellNodeIndices, 1);
    edges = createCellEdges(cellNodeIndices);
    edgeLengths = calculateEdgeLengths(edges, voroniNodes);
    
    edgeNumInCells = zeros(cellNum, 1);
    
    for i = 1:cellNum
        edgeNumInCells(i, 1) = size(cellNodeIndices{i, 1}, 1) - 1;
    end
    lengths = mat2cell(edgeLengths, edgeNumInCells, [1]);
end

