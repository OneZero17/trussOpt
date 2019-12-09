function [printPlanGrid, normalVectors, surface] = plotPrintingSurface(angles, xSplitLine, ySplitLine, startingZ, splitedStructures, figNum)
    if nargin < 5
        figNum = 1;
    end
    figure(figNum)
    hold on
    zGrid = cell(size(angles, 1)+1, size(angles, 2)+1);
    normalVectors = cell(size(angles, 1), size(angles, 2));
    plotCells = cell(size(angles, 1), size(angles, 2));
    for i = 1:size(angles, 1)
        currentXStart = xSplitLine(i);
        currentXEnd = xSplitLine(i+1);
        for j = 1:size(angles, 2)
            currentYStart = ySplitLine(j);
            currentYEnd = ySplitLine(j+1);
            currentAngles = angles{i, j};
            length1 = 1 / tan(currentAngles(1));
            length2 = 1 / tan(currentAngles(2));
            normalVector = [length1, length2, 1];
            normalVectors{i, j} = normalVector;
            if i == 1 && j == 1
                zConstant = startingZ;
            elseif j == 1
                zConstant = zGrid{i, j}(3);
            else
                zConstant = z4;
            end
            normalVector = normalVectors{i, j};
            x1 = currentXStart;
            y1 = currentYStart;
            z1 = zConstant;
            
            z2 = z1 - (currentXEnd   - x1) * normalVector(1) - (currentYStart - y1) * normalVector(2);
            z3 = z1 - (currentXEnd   - x1) * normalVector(1) - (currentYEnd   - y1) * normalVector(2);
            z4 = z1 - (currentXStart - x1) * normalVector(1) - (currentYEnd   - y1) * normalVector(2);
            zGrid{i,     j} = [currentXStart, currentYStart, z1];
            zGrid{i + 1, j} = [currentXEnd, currentYStart, z2]; 
            zGrid{i    , j + 1} = [currentXStart, currentYEnd, z4]; 
            zGrid{i + 1, j + 1} = [currentXEnd, currentYEnd, z3]; 
            if ~isempty(splitedStructures{i, 1}{j, 1})
                plotCells{i, j} = [currentXStart, currentYStart, z1; currentXStart, currentYEnd, z4; currentXEnd, currentYEnd, z3; currentXEnd, currentYStart, z2];
            end
        end
    end
    printPlanGrid = zGrid;
    
    nodex = zeros(size(angles, 1)+1, size(angles, 2)+1);
    nodey = zeros(size(angles, 1)+1, size(angles, 2)+1);
    nodez = zeros(size(angles, 1)+1, size(angles, 2)+1);
    for i = 1:size(zGrid, 1)
        for j = 1:size(zGrid, 2)
            nodex(i, j) = zGrid{i, j}(1);
            nodey(i, j) = zGrid{i, j}(2);
            nodez(i, j) = zGrid{i, j}(3);
        end
    end
%     toBePlot = reshape(plotCells, [], 1);
%     toBePlot = toBePlot(~cellfun('isempty', toBePlot));
%     for i = 1:size(toBePlot, 1)
%         T = delaunay(toBePlot{i, 1}(:, 1:2));
%         surface = triangulation(T,toBePlot{i, 1});
%         trisurf(surface, 'FaceAlpha',0.5, 'EdgeColor', 'none');
%     end
    T = delaunay(nodex, nodey);
    surface = triangulation(T,nodex(:), nodey(:), nodez(:));
    trisurf(surface, 'FaceAlpha',0.5, 'EdgeColor', 'none');
    
%     outerBoarder = [xSplitLine(1), ySplitLine(1); xSplitLine(1), ySplitLine(end); xSplitLine(end),  ySplitLine(end); xSplitLine(end), ySplitLine(1)];
%     innerBorder = reshape(plotCells, [], 1);
%     innerBorder = innerBorder(~cellfun('isempty', innerBorder));
%     primary = [reshape(nodex, [], 1), reshape(nodey, [], 1), reshape(nodez, [], 1)];
%     secondary = [outerBoarder; innerBorder([19], 1)];
%     [DT, xyz, ~] = delaunayConstrained(primary,secondary,'mesh');
%     trisurf(DT.ConnectivityList(isInterior(DT),:),xyz(:,1),xyz(:,2),xyz(:,3), 'FaceAlpha',0.5, 'EdgeColor', 'none');
%     surface = surf(nodex, nodey, nodez, 'FaceAlpha',0.5);
%     surface.EdgeColor = 'none';
end

