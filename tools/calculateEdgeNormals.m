function normals = calculateEdgeNormals(edges, nodes)
    edgeNodes = [nodes(edges(:, 1), :), nodes(edges(:, 2), :)];
    edgeNum = size(edgeNodes, 1);
    normals = zeros(edgeNum, 2);
    for i = 1:edgeNum
        vector = edgeNodes(i, 3:4) - edgeNodes(i, 1:2);
        vector = [vector, 0];
        zVector = [0 0 -1];
        normal = cross(zVector, vector);
        normal = normal / norm(normal);
        normals(i, :) = normal(1:2);
    end
    
end

