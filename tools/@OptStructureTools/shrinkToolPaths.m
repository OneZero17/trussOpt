function shrinkedToolPaths = shrinkToolPaths(self, toolPath, shrinkLength)
   
    alighedToolPath = self.alighToolPaths(toolPath);
    for i = 1:size(alighedToolPath, 1)
        yCoordinates = reshape(alighedToolPath{i, 1}(:, [2 4]), [], 1);
        [maxValue, maxIndex] = max(yCoordinates);
        [minValue, minIndex] = min(yCoordinates);
        if maxValue - minValue < shrinkLength * 2
            alighedToolPath{i, 1} = [];
        else
            yCoordinates(maxIndex) = yCoordinates(maxIndex) - shrinkLength;
            yCoordinates(minIndex) = yCoordinates(minIndex) + shrinkLength;
            yCoordinates = reshape(yCoordinates, [], 2);
            alighedToolPath{i, 1}(:, [2 4]) = yCoordinates;
        end
    end
    shrinkedToolPaths = cell2mat(alighedToolPath);
end

