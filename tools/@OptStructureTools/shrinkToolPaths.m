function shrinkedToolPaths = shrinkToolPaths(self, toolPath, shrinkLength)
   
    alighedToolPath = self.alighToolPaths(toolPath);
    for i = 1:size(alighedToolPath, 1)
        currentPaths = alighedToolPath{i, 1};
        currentPaths = shrinkTop(currentPaths, shrinkLength);
        currentPaths = shrinkEnd(currentPaths, shrinkLength);
        alighedToolPath{i, 1} = currentPaths;
    end
    shrinkedToolPaths = cell2mat(alighedToolPath);
end

function modifiedToolPaths = shrinkTop(toolPaths, shrinkLength)
    yCoordinates = reshape(toolPaths(:, [2 4]), [], 1);
    maxValue = max(yCoordinates);
    shrinkThreshold = maxValue - shrinkLength;
    shrinkStatus = [toolPaths(:, 2)>shrinkThreshold, toolPaths(:, 4)>shrinkThreshold];
    toBeKept = ~(shrinkStatus(:, 1) & shrinkStatus(:, 2));
    for i = 1:size(shrinkStatus)
        if shrinkStatus(i, 1)
            if ~shrinkStatus(i, 2)
                toolPaths(i, 2) = shrinkThreshold;
            end
        end
        
        if shrinkStatus(i, 2)
            if ~shrinkStatus(i, 1)
                toolPaths(i, 4) = shrinkThreshold;
            end
        end
    end
    modifiedToolPaths = toolPaths(toBeKept, :);
end

function modifiedToolPaths = shrinkEnd(toolPaths, shrinkLength)
    yCoordinates = reshape(toolPaths(:, [2 4]), [], 1);
    minValue = min(yCoordinates);
    shrinkThreshold = minValue + shrinkLength;
    shrinkStatus = [toolPaths(:, 2)<shrinkThreshold, toolPaths(:, 4)<shrinkThreshold];
    toBeKept = ~(shrinkStatus(:, 1) & shrinkStatus(:, 2));
    for i = 1:size(shrinkStatus)
        if shrinkStatus(i, 1)
            if ~shrinkStatus(i, 2)
                toolPaths(i, 2) = shrinkThreshold;
            end
        end
        
        if shrinkStatus(i, 2)
            if ~shrinkStatus(i, 1)
                toolPaths(i, 4) = shrinkThreshold;
            end
        end
    end
    modifiedToolPaths = toolPaths(toBeKept, :);
end

