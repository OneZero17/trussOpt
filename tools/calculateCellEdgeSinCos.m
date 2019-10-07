function edgeSinCos = calculateCellEdgeSinCos(cellNodeIndices,voroniNodes)
    cellNum = size(cellNodeIndices, 1);
    edges = createCellEdges(cellNodeIndices);
    edgeSinCos = calculateEdgeSinCos(edges, voroniNodes);
    edgeNumInCells = zeros(cellNum, 1);
    
    for i = 1:cellNum
        edgeNumInCells(i, 1) = size(cellNodeIndices{i, 1}, 1) - 1;
    end
    edgeSinCos = mat2cell(edgeSinCos, edgeNumInCells, [2]);
end

