function edgeLengths = calculateEdgeLengths(edges,nodes)
    edgeNodes = [nodes(edges(:, 1), :), nodes(edges(:, 2), :)];
    edgeLengths = ((edgeNodes(:, 1) - edgeNodes(:, 3)).^2 + (edgeNodes(:, 2) - edgeNodes(:, 4)).^2).^0.5;
end

