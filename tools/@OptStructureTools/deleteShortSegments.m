function improvedPath = deleteShortSegments(self, threeDToolPaths, tolerance)
    if nargin < 3
        tolerance = 0.5;
    end 
    currentPath = threeDToolPaths;
    segmentLengths = vecnorm((currentPath(:, 4:6) - currentPath(:, 1:3))');
    deleteFlags = segmentLengths < tolerance;
    pathId = -1;   
    deleteFlags(1) = false;
    for j = 1:size(currentPath, 1)
        if deleteFlags(j)== 0
            pathId = j;
        end

        if deleteFlags(j) == 1 && (j == size(currentPath, 1) || deleteFlags(j + 1) == 0)
            currentPath(pathId, 4:6) = currentPath(j, 4:6);
        end
    end
    currentPath(deleteFlags==1, :) = [];
    improvedPath = currentPath;

end

