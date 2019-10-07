function existList = intersectionWithCircle(members, circleCenter, radius)
    memebrNum = size(members, 1);
    intersections = cell(memebrNum, 1);
    slope = (members(:, 4) - members(:, 2))./(members(:, 3) - members(:, 1));
    
    for i = 1:memebrNum
        intersections{i, 1} = lineXCircle(slope(i),members(i,[1 3]), members(i,[2 4]), circleCenter(1), circleCenter(2), radius);
    end
    
    angles = cell(memebrNum, 1);
    for i = 1:memebrNum
        currentIntersection = intersections{i, 1};
        intersectionNum  = size(currentIntersection, 1);
        angleCell = zeros(intersectionNum, 1);
        for j = 1:intersectionNum
            currentIntersectionPoint = currentIntersection(j, :);
            circleNormal = currentIntersectionPoint - circleCenter;
            memberPoints = [members(i, 1:2); members(i, 3:4)];
            memberPoints = setdiff(memberPoints, currentIntersectionPoint, 'row');
            memberPointNum = size(memberPoints, 1);
            vectors = repmat(currentIntersectionPoint, memberPointNum, 1) - memberPoints ;
            angle = zeros(memberPointNum, 1);
            for k = 1:memberPointNum
                dotProduct = dot(circleNormal/norm(circleNormal), vectors(k, :)/norm(vectors(k, :)));
                if abs(dotProduct) > 1
                    dotProduct = 1*sign(dotProduct);
                end
                angle(k) = acos(dotProduct);
            end
            angleCell(j, 1) = rad2deg(min(angle));
        end
        angles{i, 1} = angleCell;
    end
    
    existList = -1*ones(memebrNum, 1);
    
    for i = 1:memebrNum
        if size(intersections{i, 1}, 1) == 0
            continue;
        elseif max(angles{i, 1}) > 45
            existList(i, 1) = 0;
        else
            existList(i, 1) = 1;
        end
    end
end
