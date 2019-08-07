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
meshElementsNode1 = meshElements2(:, 1:4);
meshElementsNode2 = meshElements2(:, 5:8);
existList = zeros(gElementNum, 1);
memberXList = [gElements(:, 3), gElements(:, 5)];
memberYList = [gElements(:, 4), gElements(:, 6)];

for i = 1:gElementNum
        memberX = memberXList(i, :);
        memberY = memberYList(i, :);
    for j = 1:elementNum 
        [xIntersect, yIntersect, ~, ~] = intersections(memberX, memberY, meshElementsNode1(j, :), meshElementsNode2(j, :), true);
        if (size(xIntersect, 1)~=0)
            if (size(xIntersect, 1) == 1)
                distanceToNodeA = (xIntersect - memberX(1))^2 + (yIntersect - memberY(1))^2;
                distanceToNodeB = (xIntersect - memberX(2))^2 + (yIntersect - memberY(2))^2;
                if distanceToNodeA < 1e-9 || distanceToNodeB < 1e-9
                    continue;
                else
                    existList(i, 1) = 1;
                    break
                end
            else
                    existList(i, 1) = 1;
                    break
            end
        end
    end
end
groundStructure.memberList(existList == 1, :) = [];
end

