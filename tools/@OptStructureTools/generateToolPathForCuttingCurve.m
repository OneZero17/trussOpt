function curvePaths = generateToolPathForCuttingCurve(self, curve, surface, verticalShift, toolPathSpacing)
    
    xGridNum = size(surface, 1);
    yGridNum = size(surface, 2);
    gridCells = reshape(surface, [], 1);
    gridMatrix = cell2mat(gridCells);
    gridMatrix(:, 3) = gridMatrix(:, 3) + verticalShift;
    gridCells = mat2cell(gridMatrix, ones(size(gridMatrix, 1), 1));
    surface = reshape(gridCells, xGridNum, yGridNum);
    
    curveBoundingBox = boundingBox3d(curve.vertices);
    xSpan = curveBoundingBox(2) - curveBoundingBox(1);
    spacingNum = floor(xSpan / toolPathSpacing);
    if spacingNum == 0 
        spacingNum = 1;
    end
    adjustedSpacing = xSpan / spacingNum;

    toolPathes = cell(spacingNum+1, 1);
    for i = 0:spacingNum
        currentX = curveBoundingBox(1) + i*adjustedSpacing;
        currentToolPath = zeros(size(surface, 2)-1, 6);
        for j = 1:size(surface, 2)-1
            yStart = surface{1, j}(2);
            yEnd = surface{1, j + 1}(2);
            zStart = self.getZCoordinateOnSurface(currentX, yStart, surface);
            zEnd = self.getZCoordinateOnSurface(currentX, yEnd, surface);
            currentToolPath(j, :) = [currentX, yStart, zStart, currentX, yEnd, zEnd];
        end
        toolPathes{i+1} = currentToolPath;
    end
    
    curves = splitFV(curve.faces, curve.vertices);
    polygons = cell(size(curves, 1), 2);
    for curveNum = 1:size(curves, 1)
            polygons{curveNum, 1} = self.generatePolygonFor3DCurve(curves(curveNum));
            polygons{curveNum, 2} = polyarea(polygons{curveNum, 1}(:, 1), polygons{curveNum, 1}(:, 2));
            polygons{curveNum, 3} = curves(curveNum);
    end
    polygons = sortrows(polygons, 2, 'descend');
    holes = cell(size(curves, 1), 1);
    if size(curves, 1) > 1
        for i = 1:size(curves, 1)
            if isempty(polygons{i, 1})
                continue;
            end
            for j = i+1:size(curves, 1)
                if isempty(polygons{j, 1})
                    continue;
                end
                if polyInPoly(polygons{i, 1}, polygons{j, 1})
                    currentholeNum = size(holes{i, 1}, 1);
                    holes{i, 1}{currentholeNum+1, 1} = polygons{j, 1};
                    polygons{j, 1} = [];
                end
            end
        end
    end
    
    curvePaths = [];
    for curveNum = 1:size(curves, 1)
        if isempty(polygons{curveNum, 1})
            continue;
        end
        [toolPaths, polygonPath, holePaths] = self.infillPolygonWithToolPaths(polygons{curveNum, 3}, toolPathes, holes{curveNum, 1});
        threeDToolPaths = cell(size(toolPaths, 1), 1);

        for i = 1:size(toolPaths, 1)
            if ~isempty(toolPaths{i, 1})
            threeDToolPaths{i, 1} = self.transform2Dto3DToolPath(toolPaths{i, 1}, surface);
            end
        end
        
        threeDToolPaths = threeDToolPaths(~cellfun('isempty',threeDToolPaths));
        curvePaths = [curvePaths; threeDToolPaths; polygonPath; holePaths];
    end
    

%     for i = 1:size(threeDToolPaths, 1)
%         for j = 1:size(threeDToolPaths{i, 1}, 1)
%             plot3(threeDToolPaths{i, 1}(j, [1 4]), threeDToolPaths{i, 1}(j, [2 5]), threeDToolPaths{i, 1}(j, [3 6]), '-g');
%         end
%     end
    
%     intersectionPoints = [];
%     for i = 1:size(toolPathes)
%         for j = 1:size(toolPathes{i, 1}, 1)
%             currentPathSegment = toolPathes{i, 1}(j, :);
% %             figure(4)
% %             clf
% %             axis equal
% %             view([ 1 1 1]);
% %             hold on
%             for k = 1:size(curves.faces, 1)
%                 currentSegment = curves.faces(k, [1 2]);
%                 %plot3(currentPathSegment([1 4]), currentPathSegment([2 5]), currentPathSegment([3 6]), '-g');
%                 currentFaceSegment = [curves.vertices(currentSegment(1), :), curves.vertices(currentSegment(2), :)];
%                 %plot3(currentFaceSegment([1 4]), currentFaceSegment([2 5]), currentFaceSegment([3 6]), '-g');
%                 [d, out1, out2, out3] = DistBetween2Segment(currentPathSegment([1:3]), currentPathSegment([4:6]), currentFaceSegment([1:3]), currentFaceSegment([4:6]));
%                 if d<1e-3
%                     intersectionPoints = [intersectionPoints; out2];
%                 end
%             end
%         end
%     end
    
%     polygon = self.generatePolygonFor3DCurve(curves);
%     intersectionPoints = [];
%     for i = 1:size(toolPathes)
%         inter = intersectLinePolygon3d(toolPathes{i, 1}, polygon);
%         intersectionPoints = [intersectionPoints; inter];
%     end
end

