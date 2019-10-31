function plotStructure3D(structure, figNum)
    figure(figNum);
    hold on
    axis equal
    maximumArea = max(abs(structure(:, end)));
    for i = 1:size(structure, 1)
        coefficient = (abs(structure(i, end)) / maximumArea)^0.2; 
        if (structure(i, end) > 0)
        color = [1, 1, 1] - coefficient^0.3 * [1, 1, 0];
        else
        color = [1, 1, 1] - coefficient^0.3 * [0, 1, 1];
        end
        color = [0.3, 0.3, 0.3];
        width = 6 * coefficient;
        plot3([structure(i, 1), structure(i, 4)], [structure(i, 2), structure(i, 5)], [structure(i, 3), structure(i, 6)], 'LineWidth', width, 'Color', color);
    end
end

