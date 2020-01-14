function connectedToolPaths = connectingToolpaths(self, toolpaths)
    toolLines = self.alighToolPaths(toolpaths);
    boundaryYs = zeros(size(toolLines, 1), 2);
    for i = 1:size(toolLines, 1)
        yCoordiniates = [toolLines{i, 1}(:, 2); toolLines{i, 1}(:, 4)];
        boundaryYs(i, 1) = min(yCoordiniates);
        boundaryYs(i, 2) = max(yCoordiniates);
    end
    
    connectings = zeros(size(toolLines, 1) - 1, 4);
    for i = 1:size(toolLines, 1) - 1
        if mod(i, 2) == 1
            connectings(i, :) =[toolLines{i, 1}(1, 1),  boundaryYs(i, 1), toolLines{i+1, 1}(1, 1), boundaryYs(i+1, 1)];
        else
            connectings(i, :) =[toolLines{i, 1}(1, 1),  boundaryYs(i, 2), toolLines{i+1, 1}(1, 1), boundaryYs(i+1, 2)];
        end
    end
    
    reversedToolLines = toolLines;
    for i = 1:size(toolLines, 1)
        if mod(i, 2) == 1
            reversedToolLines{i, 1} = [toolLines{i, 1}(:, 3:4), toolLines{i, 1}(:, 1:2)];
            if (size(reversedToolLines{i, 1}, 1) > 1)
                reversedToolLines{i, 1} = flip(reversedToolLines{i, 1});
            end
        end
    end
    
    connectedToolPaths = cell(size(reversedToolLines, 1) + size(connectings, 1), 1);
    for i = 1:size(connectedToolPaths, 1)
        if mod(i, 2) == 1
            connectedToolPaths{i, 1} = reversedToolLines{ceil(i/2), 1};
        else
            connectedToolPaths{i, 1} = connectings(i/2, :);
        end
    end
    
    connectedToolPaths = cell2mat(connectedToolPaths);
end

