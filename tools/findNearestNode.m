function nodeIndex = findNearestNode(mesh, x, y)
   nodes = mesh.Nodes; 
   distanceSquare = (nodes(:, 1) - x).^2 + (nodes(:, 2) - y).^2;
   [~, nodeIndex] = min(distanceSquare);
end

