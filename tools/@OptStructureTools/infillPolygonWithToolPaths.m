function connectedToolPaths = infillPolygonWithToolPaths(self, curves, toolPathLines)
    shrinkLength = 0.05;
%     figure(4)
%     clf
%     axis equal
%     hold on
    polygon = self.generatePolygonFor3DCurve(curves);
%     plot(polyshape(polygon(:, 1:2)));
    toolpaths = [];
    if ~isempty(polygon)
        for i = 1:size(toolPathLines)
           currentPaths = [];
           for j = 1:size(toolPathLines{i, 1}, 1)
               currentSegment = toolPathLines{i, 1}(j, :);
               [xi, yi] = intersections(polygon(:, 1)', polygon(:, 2)', currentSegment([1 4]), currentSegment([2 5]));
    %            plot(currentSegment([1 4]), currentSegment([2 5]), '-r');
               if ~isempty(xi)
                   exist= true(size(xi, 1), 1);
                   for k = 1:size(xi, 1)
                       distanceToFirstPoint = norm([xi, yi] - currentSegment([1 2]));
                       distanceToSecondPoint = norm([xi, yi] - currentSegment([4 5]));
                       if distanceToFirstPoint < 1e-6 || distanceToSecondPoint < 1e-6
                           exist(k, 1) = false;
                       end
                   end
                   xi(exist==false) = [];
                   yi(exist==false) = [];

                   if ~isempty(xi)
                       linePoints = [currentSegment([1 2]); currentSegment([4 5]); [xi, yi]];
                       linePoints = sortrows(linePoints, 2);
                       countNum = 0;
                       for k = 1:size(linePoints, 1) - 1
                           currentMiddlePoint = (linePoints(k, :) + linePoints(k + 1, :)) / 2;
                           isInside = inpolygon(currentMiddlePoint(1), currentMiddlePoint(2), polygon(:, 1), polygon(:, 2));
                           if isInside
    %                            plot([linePoints(k, 1), linePoints(k + 1, 1)], [linePoints(k, 2), linePoints(k + 1, 2)], '-g');
                               toolpaths = [toolpaths; [linePoints(k, :),  linePoints(k + 1, :)]];
                           end
                       end
                   end
               end
           end
        end
    end
    
%     figure(4)
%     for i = 1:size(toolpaths, 1)
%         plot(toolpaths(i, [1 3]), toolpaths(i, [2 4]), '-r');
%     end
    
    if (~isempty(toolpaths))
        newToolpaths = self.regroupToolpaths(toolpaths);
        connectedToolPaths = cell(size(newToolpaths, 1), 1);

        for i = 1:size(newToolpaths, 1)
            shrinkedToolPaths = self.shrinkToolPaths(newToolpaths{i, 1}, shrinkLength);
            if ~isempty(shrinkedToolPaths)
                connectedToolPaths{i, 1} = self.connectingToolpaths(shrinkedToolPaths);
            end
        end
    else
        connectedToolPaths{1, 1} = [];
    end
    
%     connectedToolPaths = cell2mat(connectedToolPaths);
    
%     for i = 1:size(connectedToolPaths, 1)
%         plot(connectedToolPaths(i, [1 3]), connectedToolPaths(i, [2 4]), '-r');
%     end
    
end

