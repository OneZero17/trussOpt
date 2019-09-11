function [edges, edgeCellNum] = createCellEdges(voronicells)
    numFacet = size(voronicells, 1);
    edgeNum = 0;
    
    for i = 1:numFacet
        edgeNum = edgeNum + size(voronicells{i, 1}, 1) - 1;
    end
    
    edges = zeros(edgeNum, 2);
    edgeCellNum = zeros(edgeNum, 1);
    edgeNum = 0;
    
    for i = 1:numFacet
        nodeNum = size(voronicells{i, 1}, 1) - 1;
        for j = 1:nodeNum
           edgeNum = edgeNum +1;
           edgeCellNum(edgeNum, 1) = i;
           edges(edgeNum, 1) = voronicells{i, 1}(j, 1);
           edges(edgeNum, 2) = voronicells{i, 1}(j + 1, 1);
        end
    end
end

