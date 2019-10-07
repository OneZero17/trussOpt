function  generatePrintPlan(structure, centers, radius, xLimit, yLimit)
    maxLayerNum = 0;
    for i = 1:size(radius, 1)
        maxLayerNum = max(maxLayerNum, size(radius{i, 1}, 2));
    end
    
    plottingCells = cell(maxLayerNum, size(centers, 1));
    for i = 1:size(centers, 1)
        currentCenter = centers(i, :);
        currentRadiusList = radius{i, 1};
        for j = 1:size(currentRadiusList, 2)
            currentRadius = currentRadiusList(j);
            plottingCells{j, i} = extractLayerFromStructure(structure, currentCenter, currentRadius);
        end
    end
    
    filename = 'testAnimated.gif';
    for i = 1:size(plottingCells, 1)
        tobePrinted = cell2mat(plottingCells(i, :)');
        circle(centers(1, 1), centers(1, 2), radius{1, 1}(i), i);
        circle(centers(2, 1), centers(2, 2), radius{1, 1}(i), i);
        plotStructure(tobePrinted, i, xLimit, yLimit);
        fig = figure(i);
        frame = getframe(fig); 
        im = frame2im(frame); 
        [imind,cm] = rgb2ind(im,256); 
        
        if i == 1 
            imwrite(imind,cm,filename,'gif', 'DelayTime',0.1,'Loopcount',inf); 
        else 
            imwrite(imind,cm,filename,'gif', 'DelayTime',0.1,'WriteMode','append'); 
        end 
    end
end

function [extracted, left] = extractLayerFromStructure(structure, circleCenter, radius)
    memberNum  = size(structure, 1);
    left = [structure; zeros(memberNum, 5)];
    extracted = zeros(memberNum, 5);
    toBeDeleted = zeros(memberNum, 1);
    extractedNum = 0;
    addedNum = 0;
    toBeDeletedNum = 0;
    for k = 1:size(structure, 1)
        nodeAInside = pointInsideCircle(structure(k, 1:2), circleCenter, radius);
        nodeBInside = pointInsideCircle(structure(k, 3:4), circleCenter, radius);

        if nodeAInside && nodeBInside
            extractedNum = extractedNum + 1;
            extracted(extractedNum, :) = structure(k, :);
            toBeDeletedNum = toBeDeletedNum + 1;
            toBeDeleted(toBeDeletedNum, 1) = k;
        elseif nodeAInside || nodeBInside
            intersectionPoint = lineXCircle([structure(k, 1:2); structure(k, 3:4)], circleCenter, radius);
            extractedNum = extractedNum + 1;
            if nodeAInside
               intersectionPoint = setdiff(intersectionPoint, structure(k, 1:2), 'row');
               if size(intersectionPoint, 1)==0
                   continue;
               end
               extracted(extractedNum, :) = [structure(k, 1:2), intersectionPoint, structure(k, 5)];
               left(k, 1:2) = intersectionPoint;
            else
               intersectionPoint = setdiff(intersectionPoint, structure(k, 3:4), 'row');
               if size(intersectionPoint, 1)==0
                   continue;
               end
               extracted(extractedNum, :) = [intersectionPoint, structure(k, 3:4), structure(k, 5)]; 
               left(k, 3:4) = intersectionPoint;
            end
        elseif ~nodeAInside && ~nodeBInside
            intersectionPoint = lineXCircle([structure(k, 1:2); structure(k, 3:4)], circleCenter, radius);
            memberVector = structure(k, 3:4) - structure(k, 1:2);
            memberVectorNorm = memberVector / norm(memberVector);
            if size(intersectionPoint, 1) == 2
                extractedNum = extractedNum + 1;
                extracted(extractedNum, :) = [intersectionPoint(1,:), intersectionPoint(2,:), structure(k, 5)];
                innerVector = intersectionPoint(2,:) - intersectionPoint(1,:);
                innerVectorNorm = innerVector / norm(innerVector);
                if memberVectorNorm(1) + innerVectorNorm(1) < 1e-9
                    addedNum = addedNum + 1;
                    left(memberNum + addedNum, :) = [structure(k, 1:2), intersectionPoint(2,:), structure(k, 5)];
                    addedNum = addedNum + 1;
                    left(memberNum + addedNum, :) = [intersectionPoint(1,:), structure(k, 3:4), structure(k, 5)];
                else
                    addedNum = addedNum + 1;
                    left(memberNum + addedNum, :)  = [structure(k, 1:2), intersectionPoint(1,:), structure(k, 5)];
                    addedNum = addedNum + 1;
                    left(memberNum + addedNum, :) = [intersectionPoint(2,:), structure(k, 3:4), structure(k, 5)];                            
                end
            end
        end
    end
    
    left((memberNum + addedNum + 1):end, :) = [];
    left(toBeDeleted(toBeDeleted~=0), :) = [];
    extracted(extractedNum+1:end, :) = [];
end

function plotStructure(structure, figNum, xLimit, yLimit)
    figure(figNum);
    hold on
    axis equal
    xlim([0 xLimit])
    ylim([0 yLimit])
    for i = 1:size(structure, 1)
        length = ((structure(i, 3) - structure(i, 1))^2 + (structure(i, 4) - structure(i, 2))^2)^0.5;
        coordinates = getLineCornerCoordinates([structure(i, [1 3]); structure(i, [2 4])], length, structure(i, 5));
        fill (coordinates(1,:), coordinates(2,:), [0 0 0], 'EdgeColor', [0 0 0]);
    end
end