function regroupedToolPaths = regroupToolpaths(self, toolpaths)
    toolLines = self.alighToolPaths(toolpaths);
    gapNumber = zeros(size(toolLines, 1), 1);
    
    for i = 1:size(toolLines, 1)
        currentGapNumber = 0;
        for j = 2:size(toolLines{i, 1}, 1)
             if abs(toolLines{i, 1}(j, 2) - toolLines{i, 1}(j-1, 4)) > 1e-6
                 currentGapNumber = currentGapNumber + 1;
             end
        end
        gapNumber(i, 1) = currentGapNumber;
    end
    
    regroupedToolPaths = cell(gapNumber(1, 1)+1, 1);
    startingCellNum = 1;
    for i = 1:size(toolLines, 1)
        if i>1 && gapNumber(i)~=gapNumber(i-1)
            startingCellNum = startingCellNum + gapNumber(i-1)+1;
        end
        currentCellNum = startingCellNum;
        if size(regroupedToolPaths, 1)<currentCellNum
          regroupedToolPaths{currentCellNum, 1} = [];
        end
        regroupedToolPaths{currentCellNum, 1} = [regroupedToolPaths{currentCellNum, 1}; toolLines{i, 1}(1, :)];
        for j = 2:size(toolLines{i, 1}, 1)
             if abs(toolLines{i, 1}(j, 2) - toolLines{i, 1}(j-1, 4)) > 1e-6
                 currentCellNum = currentCellNum + 1;
             end
             
             if size(regroupedToolPaths, 1)<currentCellNum
                regroupedToolPaths{currentCellNum, 1} = [];
             end
             regroupedToolPaths{currentCellNum, 1} = [regroupedToolPaths{currentCellNum, 1}; toolLines{i, 1}(j, :)]; 
        end
    end
end

