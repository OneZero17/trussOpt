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
