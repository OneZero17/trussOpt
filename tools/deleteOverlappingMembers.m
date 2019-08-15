function deleteOverlappingMembers(groundStructure, mesh, meshSpacing)
    if (nargin <= 2)
        meshSpacing = 1;
    end

    elementNum = size(mesh.Elements, 2);
    meshFacetNodes = zeros(elementNum, 8);
    meshNodes = mesh.Nodes';
    meshElements = mesh.Elements';
    
    for i = 1: elementNum
        meshFacetNodes(i, :) = [meshNodes(meshElements(i, 1), :), meshNodes(meshElements(i, 2), :), meshNodes(meshElements(i, 3), :), meshNodes(meshElements(i, 1), :)];
    end
    meshElements2 = [meshFacetNodes(:, [1 3 5 7]), meshFacetNodes(:, [2 4 6 8])];
    
    gElements = groundStructure.memberList;
    gElements = [gElements, zeros(size(gElements, 1), 1)];
    gElementNum = size(gElements, 1);
    meshElementsX = meshElements2(:, 1:4);
    meshElementsY = meshElements2(:, 5:8);
    existList = zeros(gElementNum, 1);
    memberXList = [gElements(:, 3), gElements(:, 5)];
    memberYList = [gElements(:, 4), gElements(:, 6)];

    gBoundXMin = min(memberXList, [], 2);
    gBoundXMax = max(memberXList, [], 2);
    gBoundYMin = min(memberYList, [], 2);
    gBoundYMax = max(memberYList, [], 2);

    mBoundXMin = min(meshElementsX, [], 2);
    mBoundXMax = max(meshElementsX, [], 2);
    mBoundYMin = min(meshElementsY, [], 2);
    mBoundYMax = max(meshElementsY, [], 2);
    mIndex = (1:elementNum)';

    contactMap = cell(gElementNum, 2);
    for i = 1:gElementNum
        contactMap{i, 2} = i;
    end

    for i = 1:gElementNum
        contact = mIndex(mBoundXMin<=gBoundXMax(i) & mBoundXMax>=gBoundXMin(i)& mBoundYMin<=gBoundYMax(i)& mBoundYMax>=gBoundYMin(i));
        contactMap{i, 1} = contact;
    end

    contactMap = contactMap(~cellfun('isempty', contactMap(:, 1)), :);
    contactMemberNum = size(contactMap, 1);
    
    for i = 1:contactMemberNum
        memberNum = contactMap{i, 2};
        elementList = contactMap{i, 1};
        memberX = memberXList(memberNum, :);
        memberY = memberYList(memberNum, :);
        mBounds = [mIndex, mBoundXMin, mBoundXMax, mBoundYMin, mBoundYMax];
        mBounds = mBounds(elementList, :);
        boundingBoxes = getDividedBoundingBoxes(memberX, memberY, meshSpacing);

        if size(boundingBoxes, 1)<=1
            continue;
        else
            totalContact = cell(size(boundingBoxes, 1), 1);
            for j = 1:size(boundingBoxes, 1)
                contact = mBounds(mBounds(:, 2)<=boundingBoxes(j, 2) & mBounds(:, 3)>=boundingBoxes(j, 1)& mBounds(:, 4)<=boundingBoxes(j, 4)& mBounds(:, 5)>=boundingBoxes(j, 3));
                totalContact{j, 1} = contact;
            end
            contactMap{i, 1} = cell2mat(totalContact);
        end
    end
    
    contactMap = contactMap(~cellfun('isempty', contactMap(:, 1)), :);
    contactMemberNum = size(contactMap, 1);
    for i = 1:contactMemberNum
            memberNum = contactMap{i, 2};
            memberX = memberXList(memberNum, :);
            memberY = memberYList(memberNum, :);
            elementList = contactMap{i, 1};
            contactElementNum = size(elementList, 1);

        for j = 1:contactElementNum 
            elementNum = elementList(j, 1);
            [xIntersect, yIntersect, ~, ~] = intersections(memberX, memberY, meshElementsX(elementNum, :), meshElementsY(elementNum, :), true);
            if (size(xIntersect, 1)~=0)
                if (size(xIntersect, 1) == 1)
                    distanceToNodeA = (xIntersect - memberX(1))^2 + (yIntersect - memberY(1))^2;
                    distanceToNodeB = (xIntersect - memberX(2))^2 + (yIntersect - memberY(2))^2;
                    if distanceToNodeA < 1e-9 || distanceToNodeB < 1e-9 
                        continue;
                    else
                        existList(memberNum, 1) = 1;
                        break
                    end
                else    
                        existList(memberNum, 1) = 1;
                        break
                end
            end
        end
    end
    newMemberList = groundStructure.memberList(~existList == 1, :) ;

    nodeList = unique(reshape(newMemberList(:, 1:2), [], 1));
    oldNodeList = groundStructure.nodeGrid;
    oldNodeList = [oldNodeList, zeros(size(oldNodeList, 1), 1)];
    for i = 1:size(nodeList, 1)
        oldNodeList(nodeList(i, 1), 3) = i;
    end

    for i = 1:size(newMemberList, 1)
        newMemberList(i, 1) = oldNodeList(newMemberList(i, 1), 3);
        newMemberList(i, 2) = oldNodeList(newMemberList(i, 2), 3);
    end
    
    groundStructure.memberList = newMemberList;
    groundStructure.nodeGrid = oldNodeList(oldNodeList(:, 3)~=0, 1:2);
end

function [xMin, xMax, yMin, yMax] = getBoundingBox(x, y)
    xMin = min(x, [], 2);
    xMax = max(x, [], 2);
    yMin = min(y, [], 2);
    yMax = max(y, [], 2);
end

function boundingBoxes = getDividedBoundingBoxes(x, y, spacing)
    length = sqrt((x(2)-x(1))^2 + (y(2)-y(1))^2);
    divideNum = floor(length/spacing);
    boundingBoxes = zeros(divideNum, 4);
    
    xSpacing = (x(2) - x(1))/divideNum;
    ySpacing = (y(2) - y(1))/divideNum;
    
    for i = 1:divideNum
        [xMin, xMax, yMin, yMax] = getBoundingBox([x(1)+(i-1)*xSpacing, x(1)+i*xSpacing], [y(1)+(i-1)*ySpacing, y(1)+i*ySpacing]);
        boundingBoxes(i, :) = [xMin, xMax, yMin, yMax];
    end
end

