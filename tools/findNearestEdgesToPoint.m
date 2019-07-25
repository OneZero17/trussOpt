function outPutEdges = findNearestEdgesToPoint(mesh, edges, x, y)
    nodeID = findNearestNode(mesh,'nearest',[x; y]);
    elementIDs = findElements(mesh,'attached',nodeID);
    outPutEdges = [];
    edges = [edges, [1:size(edges, 1)]'];
    for i = 1:size(elementIDs, 2)
        newEdges = edges(edges(:, 3) == elementIDs(i) | edges(:, 4) == elementIDs(i), :);
        newEdges(newEdges(:, 1) ~= nodeID & newEdges(:, 2) ~= nodeID, :) = [];
        outPutEdges = [outPutEdges; newEdges];
    end
    outPutEdges = unique(outPutEdges,'rows');
end