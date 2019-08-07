function deleteOverlappingMembers(groundStructure, mesh)
elementNum = size(mesh.Elements, 2);
meshFacetNodes = zeros(elementNum, 8);
meshNodes = mesh.Nodes';
meshElements = mesh.Elements';

for i = 1: elementNum
    meshFacetNodes(i, :) = [meshNodes(meshElements(i, 1), :), meshNodes(meshElements(i, 2), :), meshNodes(meshElements(i, 3), :), meshNodes(meshElements(i, 1), :)];
end
%meshElements2 = zeros(elementNum, 8);
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
    contact = mIndex(mBoundXMin>=gBoundXMin(i) & mBoundXMax<=gBoundXMax(i)& mBoundYMin>=gBoundYMin(i)& mBoundYMax<=gBoundYMax(i));
    if gBoundXMin(i) == gBoundXMax(i)
        contact = mIndex(mBoundXMin<=gBoundXMin(i) & mBoundXMax>=gBoundXMax(i)& mBoundYMin>=gBoundYMin(i)& mBoundYMax<=gBoundYMax(i));
    end
    
    if gBoundYMin(i) == gBoundYMax(i)
        contact = mIndex(mBoundXMin>=gBoundXMin(i) & mBoundXMax<=gBoundXMax(i)& mBoundYMin<=gBoundYMin(i)& mBoundYMax>=gBoundYMax(i));
    end
    contactMap{i, 1} = contact;
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
groundStructure.memberList(existList == 1, :) = [];
end

