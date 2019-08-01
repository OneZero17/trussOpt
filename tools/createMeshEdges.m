function edges = createMeshEdges(mesh)
elements = mesh.Elements;
numFacet = size(elements, 2);
edges = zeros(numFacet * 3, 4);

numEdge = 0;

for i = 1 : numFacet
    for j = 1:3
        firstNodeNum = elements(j, i);
        secondNodeNum = elements(rem(j, 3) + 1, i);
        secondMatch = find (edges(1:numEdge, 1) == secondNodeNum);
        
        addNum = 0;
        for k = 1:size(secondMatch, 1)
            if (edges(secondMatch(k,1), 2) == firstNodeNum)
                addNum = secondMatch(k,1);
                break 
            end
        end
        
        if addNum == 0
            numEdge = numEdge + 1;
            edges(numEdge, 1) = firstNodeNum;
            edges(numEdge, 2) = secondNodeNum;
            edges(numEdge, 3) = i;
        else
            edges(addNum, 4) = i; 
        end
        
    end
end
    edges(edges(:,1)==0, :) =[];
end

