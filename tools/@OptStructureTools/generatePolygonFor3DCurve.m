function polygon = generatePolygonFor3DCurve(self, curve)
    tempEdges = curve.faces(:, 1:2);
    nodeNum = size(tempEdges, 1);
    polygon = zeros(nodeNum, 3);
    polygon(1, :) = curve.vertices(tempEdges(1, 1), :);
    polygon(2, :) = curve.vertices(tempEdges(1, 2), :);
    
    pointNum = 3;
    currentBegin = tempEdges(1, 2);
    keepRunning = true;
    
    toBeRemove = zeros(size(tempEdges, 1), 1);
    for i = 1:size(tempEdges, 1)
        if tempEdges(i, 1) == tempEdges(i, 2)
            toBeRemove(i, 1) = 1;
        end
    end
    tempEdges(toBeRemove==1, :) = [];
    tempEdges = unique(tempEdges, 'rows');
    if ~isempty(tempEdges)
        while keepRunning
            nextOne = tempEdges(tempEdges(:, 1) == currentBegin, 2);
            polygon(pointNum, :) = curve.vertices(nextOne, :);
            currentBegin = nextOne;
            pointNum = pointNum + 1;

            if pointNum-1 == nodeNum
                keepRunning =false;
            end
        end
        polygon = [polygon; polygon(1, :)];
    else
        polygon = [];
    end
    
end

