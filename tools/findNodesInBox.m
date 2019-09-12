function nodeIndices = findNodesInBox(nodes, xRange, yRange)
   nodes = [1:size(nodes, 2); nodes]';
   nodeIndices = nodes(nodes(:, 2)>= xRange(1) & nodes(:, 2)<= xRange(2)...
                       & nodes(:, 3)>= yRange(1) & nodes(:, 3)<= yRange(2));
   nodeIndices = nodeIndices';
end

