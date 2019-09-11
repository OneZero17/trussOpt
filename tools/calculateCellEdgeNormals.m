function edgeNormals = calculateCellEdgeNormals(cellNodeIndices,voroniNodes)
    cellNum = size(cellNodeIndices, 1);
    edges = createCellEdges(cellNodeIndices);
    edgeNormals = calculateEdgeNormals(edges, voroniNodes);
    edgeNumInCells = zeros(cellNum, 1);
    
    for i = 1:cellNum
        edgeNumInCells(i, 1) = size(cellNodeIndices{i, 1}, 1) - 1;
    end
    edgeNormals = mat2cell(edgeNormals, edgeNumInCells, [2]);
end

