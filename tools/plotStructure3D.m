function plotStructure3D(structure, figNum, color, showText)
    figure(figNum);
    hold on
    axis equal
    maximumArea = max(abs(structure(:, end)));
    if nargin < 3
       color = [0.3, 0.3, 0.3];
    end
    if nargin < 4
       showText = false;
    end
    for i = 1:size(structure, 1)
        if showText
            text((structure(i, 1) + structure(i, 4))/2, (structure(i, 2) + structure(i, 5))/2, (structure(i, 3) + structure(i, 6))/2, int2str(i));
        end
        coefficient = (abs(structure(i, end)) / maximumArea)^0.2; 
%         if (structure(i, end) > 0)
%         color = [1, 1, 1] - coefficient^0.3 * [1, 1, 0];
%         else
%         color = [1, 1, 1] - coefficient^0.3 * [0, 1, 1];
%         end
        width = 1 * coefficient;
        [X,Y,Z] = cylinder2P(width, 20, structure(i, 1:3),structure(i, 4:6));
        s = surf(X,Y,Z);
        s.EdgeColor = 'none';
        s.FaceColor = color;
        %plot3([structure(i, 1), structure(i, 4)], [structure(i, 2), structure(i, 5)], [structure(i, 3), structure(i, 6)], 'LineWidth', width, 'Color', color);
    end
end

