function toolLines = alighToolPaths(self,toolpaths)
    toolLines = cell(1, 1);
    toolLines{1, 1} = toolpaths(1, :);
    toolLinesNum = 1;
    for i = 2:size(toolpaths, 1)
        if abs(toolpaths(i, 1)- toolLines{toolLinesNum, 1}(1))>1e-6
            toolLinesNum = toolLinesNum + 1;
        end
        if toolLinesNum > size(toolLines, 1)
            toolLines{toolLinesNum, 1} = [];
        end
        toolLines{toolLinesNum, 1} = [toolLines{toolLinesNum, 1};  toolpaths(i, :)];
    end
end

