function testProcessRelatedExample()
    clear
    groundStructure = GeoGroundStructure;
    x = 10; y = 10; newAngleConstraint = true;
    groundStructure.createCustomizedNodeGrid(0, 0, x, y, 0.5, 0.5);
    groundStructure.createMemberListFromNodeGrid();
    
    if newAngleConstraint
        circleCenter = [0, 0; 10, 0];
        members = groundStructure.memberList(:, 3:end);
        memebrNum = size(members, 1);
        members = [members,(1:memebrNum)'];
        distance = zeros(memebrNum, 4);
        angle = zeros(memebrNum, 4);
        for i = 1:2
            [distance(:, 2*i-1:2*i) angle(:, 2*i-1:2*i)] = intersectionWithCircleNew(members, circleCenter(i, :));
        end
        
        finalAngle = zeros(memebrNum, 1);
        for i = 1 : memebrNum  
            [minDistance, point1Index] = min([distance(i, 1), distance(i, 3)]);
            [minDistance, point2Index] = min([distance(i, 2), distance(i, 4)]);
            finalAngle(i, 1) = max([angle(i, 2 * point1Index - 1), angle(i, 2 * point2Index)]);
        end
        groundStructure.memberList = groundStructure.memberList(finalAngle < 0.977, :);
    end
    
%     if angleConstraint
%         members = groundStructure.memberList(:, 3:end);
%         memebrNum = size(members, 1);
%         members = [members,(1:memebrNum)'];
% %% Calculate in and out angle
%         circleCenter = [0, 0; 3, 0];
%         radius = 0.5:0.1:12;
%         centerNum = size(circleCenter, 1);
%         circleNum = size(radius, 2);
%         
%         defaultInOutAngle = [0, 2*pi];
%         inOutAngles = repmat(defaultInOutAngle, circleNum, 2);
%         
%         for i = 1:circleNum
%            [intersectionPointX, intersectionPointY] = circcirc(circleCenter(1, 1), circleCenter(1, 2), radius(i), circleCenter(2, 1), circleCenter(2, 2), radius(i));
%            if isnan(intersectionPointX(1, 1)) 
%                continue;
%            else
%                inAngleA = atan((intersectionPointY(1) - circleCenter(1, 2)) / (intersectionPointX(1) - circleCenter(1, 1)));
%                outAngleA = 2*pi + atan((intersectionPointY(2) - circleCenter(1, 2)) / (intersectionPointX(2) - circleCenter(1, 1)));
%                inAngleB = -pi + atan((intersectionPointY(2) - circleCenter(2, 2)) / (intersectionPointX(2) - circleCenter(2, 1)));
%                outAngleB = pi + atan((intersectionPointY(1) - circleCenter(2, 2)) / (intersectionPointX(1) - circleCenter(2, 1)));
%                inOutAngles(i, :) = [inAngleA, outAngleA, inAngleB, outAngleB];
%            end
%         end
%         
%         fullExistList = cell(centerNum, 1);   
%         axis equal
%         hold on;
%         xlim([0 x])
%         ylim([0 y])
%         
% %         for i = 1:circleNum
% %             circle(circleCenter(1, 1), circleCenter(1, 2), radius(i), 1, inOutAngles(i, 1), inOutAngles(i, 2));
% %             circle(circleCenter(2, 1), circleCenter(2, 2), radius(i), 1, inOutAngles(i, 3), inOutAngles(i, 4));
% %         end
%         
%         for i = 1:size(circleCenter, 1)
%             existList = -1*ones(memebrNum, circleNum);
%             for j = 1:size(radius, 2)
%                 existList(:, j) = intersectionWithCircleNew(members, circleCenter(i, :), inOutAngles(j, 2*i - 1), inOutAngles(j, 2*i));
%                 existList(:, j) = intersectionWithCircle(members, circleCenter(i, :), radius(j), inOutAngles(j, 2*i - 1), inOutAngles(j, 2*i), i);
%                 circle(circleCenter(i, 1), circleCenter(i, 2), radius(j), 1, inOutAngles(j, 2*i - 1), inOutAngles(j, 2*i));
%             end
%             fullExistList{i, 1} = existList;
%         end
% %%
%         finalExistList = -1*ones(memebrNum, centerNum);
%         for i = 1:centerNum
%             existList = fullExistList{i, 1};
%             for j = 1:memebrNum
%                 check0 = sum(existList(j, :) == 0);
%                 checkMinus1 = sum(existList(j, :) == -1);
%                 if checkMinus1 == circleNum
%                     %plot(members(i,[1 3]), members(i,[2 4]), '-b');
%                 elseif check0 > 0
%                     finalExistList(j, i) = 0;
%                     continue
%                     %plot(members(i,[1 3]), members(i,[2 4]), '-r');
%                 else
%                     finalExistList(j, i) = 1;
%                     %plot(members(i,[1 3]), members(i,[2 4]), '-g');
%                 end
%             end
%         end
% 
%         groundStructure.memberList = groundStructure.memberList((finalExistList(:, 1) == 1 & finalExistList(:, 2) ~= 0) | (finalExistList(:, 2) == 1 & finalExistList(:, 1) ~= 0), :);
%         %groundStructure.memberList = groundStructure.memberList(finalExistList(:, 1) == 1, :);
%     end
    
%     existList = intersectionWithHorizontalLine(groundStructure.memberList(:, 3:end));
%     groundStructure.memberList = groundStructure.memberList(existList ==1, :);
    groundStructure.createNodesFromGrid();
    groundStructure.createGroundStructureFromMemberList();
    %groundStructure.plotMembers('plotGroundStructure', true, 'figureNumber', 2);   
    
    loadcase = PhyLoadCase();
    load1NodeIndex = groundStructure.findOrAppendNode(x, 0);
    load1 = PhyLoad(load1NodeIndex, 0.0, 0.2);
    loadcase.loads = {load1};
    loadcases = {loadcase};
    
    supports  = cell(2, 1);
    supportNodeIndex1 = groundStructure.findOrAppendNode(3, 0);
    support1 = PhySupport(supportNodeIndex1, 1, 1);
    supports{1, 1} = support1;
    
    supportNodeIndex2 = groundStructure.findOrAppendNode(0, 0);
    support2 = PhySupport(supportNodeIndex2, 0, 1);
    supports{2, 1} = support2;    
    solverOptions = OptOptions();
    
    trussProblem = OptProblem();
    trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);
    
    [conNum, varNum, objVarNum] = trussProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    trussProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 1);
    matrix.feedBackResult(result);
    trussProblem.feedBackResult(1);
    groundStructure.plotMembers();    
    %groundStructure.plotMembers('plotGroundStructure', true, 'figureNumber', 2);   
end


function existList = intersectionWithHorizontalLine(members)
    memebrNum = size(members, 1);
    slope = (members(:, 4) - members(:, 2))./(members(:, 3) - members(:, 1));
    
    existList = ones(memebrNum, 1);
    existList(slope>-1.072 & slope<1.072) = 0;
end

function [distances, angles] = intersectionWithCircleNew(members, circleCenter)
    memebrNum = size(members, 1);
    distances = zeros(memebrNum, 2);
    distances(:, 1) = ((members(:, 1) - circleCenter(1)).^2 + (members(:, 2) - circleCenter(2)).^2).^0.5;
    distances(:, 2) = ((members(:, 3) - circleCenter(1)).^2 + (members(:, 4) - circleCenter(2)).^2).^0.5;
    point1NormalVector = zeros(memebrNum, 3);
    point2NormalVector = zeros(memebrNum, 3);
    point1NormalVector(distances(:, 1) < 1e-9, 1:2) = repmat([0, 1], size(point1NormalVector(distances(:, 1) < 1e-9), 1), 1);
    point2NormalVector(distances(:, 2) < 1e-9, 1:2) = repmat([0, 1], size(point2NormalVector(distances(:, 2) < 1e-9), 1), 1);
    
    point1NormalVector(distances(:, 1) >= 1e-9, 1:2) = members(distances(:, 1) >= 1e-9, 1:2) - circleCenter;
    point2NormalVector(distances(:, 2) >= 1e-9, 1:2) = members(distances(:, 2) >= 1e-9, 3:4) - circleCenter;
    memberVector = members(:, 3:4) - members(:, 1:2);
    memberVector = [memberVector, zeros(memebrNum, 1)];
    
    angles  = zeros(memebrNum, 2);
    for i = 1:memebrNum
        dotProduct1 = dot(point1NormalVector(i, :)/norm(point1NormalVector(i, :)), memberVector(i, :)/norm(memberVector(i, :)));
        dotProduct2 = dot(point2NormalVector(i, :)/norm(point2NormalVector(i, :)), memberVector(i, :)/norm(memberVector(i, :)));
        if abs(dotProduct1) > 1
            dotProduct1 = 1*sign(dotProduct1);
        end
        if abs(dotProduct2) > 1
            dotProduct2 = 1*sign(dotProduct2);
        end       
        angles(i, 1) = acos(dotProduct1);
        angles(i, 2) = acos(dotProduct2);
    end   
end

function existList = intersectionWithCircle(members, circleCenter, radius, inDegree, outDegree, circleNum)
    memebrNum = size(members, 1);
    intersections = cell(memebrNum, 1);
    %slope = (members(:, 4) - members(:, 2))./(members(:, 3) - members(:, 1));
    
    for i = 1:memebrNum
        potentialIntersectionPoint = lineXCircle([members(i,[1 2]); members(i,[3 4])], circleCenter, radius);
        intersectionPointNum = size(potentialIntersectionPoint, 1);
        if (intersectionPointNum > 0)
            %angle = atan((potentialIntersectionPoint(:, 2) - circleCenter(2))./ (potentialIntersectionPoint(:, 1) - circleCenter(1)));
            vector = [potentialIntersectionPoint(:, 1) - circleCenter(1), potentialIntersectionPoint(:, 2) - circleCenter(2), zeros(intersectionPointNum, 1)];   
            angle = zeros(intersectionPointNum, 1);
            for j = 1:intersectionPointNum
                angle(j) = dot(vector(j, :), [1,0,0]) / norm(vector(j, :));
                angle(j) = acos(angle(j));
            end
            potentialIntersectionPoint = potentialIntersectionPoint(angle>=inDegree & angle<=outDegree, :);
        end
        intersections{i, 1} = potentialIntersectionPoint;
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
        elseif max(angles{i, 1}) > 56
            existList(i, 1) = 0;
        else
            existList(i, 1) = 1;
        end
    end
end

