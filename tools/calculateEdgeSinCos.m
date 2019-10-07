function sinCos = calculateEdgeSinCos(edges, nodes)
    edgeNodes = [nodes(edges(:, 1), :), nodes(edges(:, 2), :)];
    edgeNum = size(edgeNodes, 1);
    sinCos = zeros(edgeNum, 2);
    length = ((edgeNodes(:, 1) - edgeNodes(:, 3)).^2 + (edgeNodes(:, 2) - edgeNodes(:, 4)).^2).^0.5;
    sinCos(:, 2) = (edgeNodes(:, 3) - (edgeNodes(:, 1)))./length;
    sinCos(:, 1) = (edgeNodes(:, 4) - (edgeNodes(:, 2)))./length;
end