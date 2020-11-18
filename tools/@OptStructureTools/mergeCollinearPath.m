function improvedPath = mergeColinearPath(self, threeDToolPaths, tolerance)
    if nargin < 3
        tolerance = 1e-6;
    end
    improvedPath = threeDToolPaths;   
    for i = 1:size(threeDToolPaths, 1)
        currentPath = threeDToolPaths{i, 1};
        colinearFlags = zeros(size(currentPath, 1), 1);
        for j = 1:size(currentPath, 1) - 1
            currentSegment = currentPath(j, :);
            nextSegment = currentPath(j+1, :);
            pointsToCheck = [currentSegment(1:3); currentSegment(4:6); nextSegment(4:6)];
            if collinear(pointsToCheck, tolerance)
               colinearFlags(j+1) = 1;
            end
        end
        pathId = -1;     
        for j = 1:size(currentPath, 1)
            if colinearFlags(j) == 0
                pathId = j;
            end
            
            if colinearFlags(j) == 1 && (j == size(currentPath, 1) || colinearFlags(j + 1) == 0)
                currentPath(pathId, 4:6) = currentPath(j, 4:6);
            end
        end
        currentPath(colinearFlags==1, :) = [];
        improvedPath{i, 1} = currentPath;
    end
end

