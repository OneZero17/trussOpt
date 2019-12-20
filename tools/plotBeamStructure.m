function plotBeamStructure(structure, areaAndForceList, figNum, xLimit, yLimit, plotLimit, scaleFactor, filename)
    
    fig = figure(figNum);
    hold on
    axis equal
    xlim([0 xLimit])
    ylim([0 yLimit])
    
    memberVectors = structure(:, 5:6) - structure(:, 3:4);
    memberLengths = zeros(size(memberVectors, 1), 1);
    for i = 1:size(memberVectors, 1)
        memberLengths(i) = norm(memberVectors(i, :));
    end
    totalArea = areaAndForceList(:, 1);
    maximumArea = max(totalArea);
    for i = 1:size(areaAndForceList, 1)
        coefficient = areaAndForceList(i, 1) / maximumArea;
        if coefficient > plotLimit
            coordinates = getLineCornerCoordinates([structure(i, [3 5]); structure(i, [4 6])], memberLengths(i, 1), scaleFactor * sqrt(totalArea(i, 1)/(0.19 * pi))/1000);
            fill (coordinates(1,:), coordinates(2,:), 'k', 'EdgeColor', 'none');
            
            coordinates = getLineCornerCoordinates([structure(i, [3 5]); structure(i, [4 6])], memberLengths(i, 1), scaleFactor * sqrt(areaAndForceList(i, 2)/(0.19*pi))/1000);
            %coordinates = getLineCornerCoordinates([structure(i, [3 5]); structure(i, [4 6])], memberLengths(i, 1), scaleFactor * sqrt(totalArea(i, 1)/(0.19*pi))/1000);
            if (areaAndForceList(i, 4)>0)
                fill (coordinates(1,:), coordinates(2,:), 'r', 'EdgeColor', 'none');
            else
                fill (coordinates(1,:), coordinates(2,:), 'b', 'EdgeColor', 'none');
            end
        end
    end
    
    if nargin > 7
        saveas(fig,filename)
        close(figNum)
    end
end