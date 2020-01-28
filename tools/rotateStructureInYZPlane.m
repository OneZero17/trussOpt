function newStructure = rotateStructureInYZPlane(structure, rotationAngle,rotationCenter)
    Points = [structure(:, 1:3); structure(:, 4:6)];
    for i = 1:size(Points, 1)
        currentVector = Points(i, :) - rotationCenter;
        if norm(currentVector) < 1e-6
            continue;
        end
        rotatedVector = rotate_3D(currentVector', 'any', rotationAngle, [1 0 0]')';
        Points(i, :) = rotatedVector + rotationCenter;
    end
    newStructure = structure;
    memberNum = size(newStructure, 1);
    newStructure(:, 1:3) = Points(1:memberNum, :);
    newStructure(:, 4:6) = Points(memberNum+1:end, :);
end

