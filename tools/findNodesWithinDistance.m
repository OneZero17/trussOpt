function nodeIndex = findNodesWithinDistance(mesh, x, y, distance)
   nodes = mesh.Nodes;
   nodes = [1:size(nodes, 2); nodes]';
   distanceSquare = (nodes(:, 2) - x).^2 + (nodes(:, 3) - y).^2;
   nodes = [nodes, distanceSquare];
   maximumDistanceSquare = distance^2;
   nodeIndex = nodes(nodes(:, 4) <= maximumDistanceSquare, 1)';
end
