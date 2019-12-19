function plotStructure(structure, figNum, xLimit, yLimit, realvalue)
    if nargin<5
        realvalue = false;
    end
    figure(figNum);
    hold on
    axis equal
    xlim([0 xLimit])
    ylim([0 yLimit])
    for i = 1:size(structure, 1)
        length = ((structure(i, 3) - structure(i, 1))^2 + (structure(i, 4) - structure(i, 2))^2)^0.5;
        if realvalue
            width = sqrt(structure(i, 5)) / 1000;
        else
            width = structure(i, 5);
        end
        coordinates = getLineCornerCoordinates([structure(i, [1 3]); structure(i, [2 4])], length, width);
        fill (coordinates(1,:), coordinates(2,:), [0 0 0], 'EdgeColor', [0 0 0]);
    end
end
