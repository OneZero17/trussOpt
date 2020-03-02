function [connectedToolPaths, polygonPath, holePaths] = infillPolygonWithToolPaths(self, curves, toolPathLines, holes)
    shrinkLength = 1.1;
%     figure(4)
%     clf
%     axis equal
%     hold on
    polygon = self.generatePolygonFor3DCurve(curves);
%     plot(polyshape(polygon(:, 1:2)));
    toolpaths = [];
    toolPathLines = cell2mat(toolPathLines);
    toolPathLines = toolPathLines(:, [1 2 4 5]);
    if ~isempty(polygon)
        [insideToolPathes, outsideToolPathes] = splitToolPaths(polygon, toolPathLines);
    end
    
%     for i = 1:size(insideToolPathes, 1)
%         plot([insideToolPathes(i, 1), insideToolPathes(i, 3)], [insideToolPathes(i, 2), insideToolPathes(i, 4)], '-g');
%     end
    
%     for i = 1:size(insideToolPathes, 1)
%         plot([outsideToolPathes(i, 1), outsideToolPathes(i, 3)], [outsideToolPathes(i, 2), outsideToolPathes(i, 4)], '-r');
%     end
    
    for i = 1:size(holes, 1)
        [outsideToolPathes, insideToolPathes] = splitToolPaths(holes{i, 1}, insideToolPathes);
    end
     
%     figure(4)
%     for i = 1:size(toolpaths, 1)
%         plot(toolpaths(i, [1 3]), toolpaths(i, [2 4]), '-r');
%     end
    toolpaths = insideToolPathes;
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

    polygonPath = [polygon(1:end-1, :), polygon(2:end, :)];
    
    holePaths = cell(size(holes, 1), 1);
    for i = 1:size(holes, 1)
        holePaths{i, 1} = [holes{i, 1}(1:end-1, :), holes{i, 1}(2:end, :)];
    end
%     connectedToolPaths{size(connectedToolPaths, 1)+1, 1} = polygonPath;
%     connectedToolPaths = cell2mat(connectedToolPaths);
    
%     for i = 1:size(connectedToolPaths, 1)
%         plot(connectedToolPaths(i, [1 3]), connectedToolPaths(i, [2 4]), '-r');
%     end
    
end

function [insideToolPaths, outsideToolPaths] = splitToolPaths(polygon, toolPathLines)
        insideToolPaths = [];
        outsideToolPaths = [];
        for i = 1:size(toolPathLines)
           currentSegment = toolPathLines(i, :);
           [xi, yi] = intersections(polygon(:, 1)', polygon(:, 2)', currentSegment([1 3]), currentSegment([2 4]));
           %plot(currentSegment([1 3]), currentSegment([2 4]), '-r');
           checkfullyInside = false;
           if ~isempty(xi)
               exist= true(size(xi, 1), 1);
               for k = 1:size(xi, 1)
                   distanceToFirstPoint = norm([xi, yi] - currentSegment([1 2]));
                   distanceToSecondPoint = norm([xi, yi] - currentSegment([3 4]));
                   if distanceToFirstPoint < 1e-6 || distanceToSecondPoint < 1e-6
                       exist(k, 1) = false;
                   end
               end
               xi(exist==false) = [];
               yi(exist==false) = [];

               if ~isempty(xi)
                   linePoints = [currentSegment([1 2]); currentSegment([3 4]); [xi, yi]];
                   linePoints = sortrows(linePoints, 2);
                   for k = 1:size(linePoints, 1) - 1
                       currentMiddlePoint = (linePoints(k, :) + linePoints(k + 1, :)) / 2;
                       isInside = inpolygon(currentMiddlePoint(1), currentMiddlePoint(2), polygon(:, 1), polygon(:, 2));
                       if isInside
                           
                           insideToolPaths = [insideToolPaths; [linePoints(k, :),  linePoints(k + 1, :)]];
                       else
                           outsideToolPaths = [outsideToolPaths; [linePoints(k, :),  linePoints(k + 1, :)]];
                       end
                   end
               else
                checkfullyInside = true;   
               end
           else
               checkfullyInside = true;   
           end
            
           if checkfullyInside
               currentMiddlePoint = (currentSegment([1 2]) + currentSegment([3 4]))/2;
               isInside = inpolygon(currentMiddlePoint(1), currentMiddlePoint(2), polygon(:, 1), polygon(:, 2));
               if isInside
                 % plot([currentSegment(1), currentSegment(3)], [currentSegment(2), currentSegment(4)], '-g');
                   insideToolPaths = [insideToolPaths; currentSegment];
               else
                   outsideToolPaths = [outsideToolPaths; currentSegment];
               end
           end
        end
end

