function angles = adjustAnglesToBeSymmetryInX(angles)

    for i = 1:floor(size(angles, 1)/2)
        for j = 1:size(angles, 2)
            angles{i, j}(1) = pi - angles{size(angles, 1) + 1 - i, j}(1);
        end
    end
    
    for j = 1:size(angles, 2)
        angles{ceil(size(angles, 1)/2), j}(1) = pi/2;
    end
end

