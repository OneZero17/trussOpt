function angles = calculateRealNozzleAngles(allSlices, normalVectors, maximumOverhangAngle)
    angles = cell(size(allSlices, 1), 1);
    for sliceNumber = 1:size(allSlices, 1)
        currentSlice = allSlices{sliceNumber, 1};
        currentLayerAngles = cell(size(currentSlice, 1), size(currentSlice, 2));
        for i = 1:size(currentSlice, 1)
            for j = 1:size(currentSlice, 2)
                currentZoneMembers = currentSlice{i, j};
                if ~isempty(currentZoneMembers)
                    memberVectors = currentZoneMembers(:, 4:6) - currentZoneMembers(:, 1:3);
                    currentNormal = normalVectors{i, j} / norm(normalVectors{i, j});
                    nozzleVector = zeros(size(memberVectors, 1), 3);   
                    for k = 1:size(memberVectors, 1)
                        currentMemberVector = memberVectors(k, :);
                        angle = atan2(norm(cross(currentNormal, currentMemberVector)), dot(currentNormal, currentMemberVector));
                        if abs(angle) < maximumOverhangAngle
                            nozzleVector(k, :) = currentNormal;
                        else
                            crossProduct = cross(currentNormal, currentMemberVector);
                            toBeRotatedAngle = sign(angle) * (abs(angle) - maximumOverhangAngle);
                            nozzleVector(k, :) = rotate_3D(currentNormal', 'any', toBeRotatedAngle, crossProduct')';
                            %checkangle = atan2(norm(cross(nozzleVector(k, :), currentMemberVector)), dot(nozzleVector(k, :), currentMemberVector));
                        end
                    end
                    currentLayerAngles{i, j} = nozzleVector;
                end
            end
        end
        angles{sliceNumber, 1} = currentLayerAngles;
    end
end

