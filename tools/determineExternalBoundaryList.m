function boundaryBooleanList = determineExternalBoundaryList(nodes, edges, boundaries)
    edgeNumber = size(edges, 1);
    boundaryNumber = size(boundaries, 1);
    boundaryBooleanList = zeros(edgeNumber, 1);
    for i = 1 : edgeNumber
        nodeA = edges(i, 1);
        nodeB = edges(i, 2);
        for j = 1 : boundaryNumber
            boundaryNodeAx = boundaries(j, 1);
            boundaryNodeAy = boundaries(j, 2);
            boundaryNodeBx = boundaries(j, 3);
            boundaryNodeBy = boundaries(j, 4);
            
            check1 = [boundaryNodeAx, boundaryNodeAy, 1;
                      boundaryNodeBx, boundaryNodeBy, 1;
                      nodes(nodeA, 1), nodes(nodeA, 2), 1;];
            if abs(det(check1)) > 0.01
                continue;
            else
                check2 = [boundaryNodeAx, boundaryNodeAy, 1;
                          boundaryNodeBx, boundaryNodeBy, 1;
                          nodes(nodeB, 1), nodes(nodeB, 2), 1;];
                if abs(det(check2)) < 0.01
                    boundaryBooleanList(i) = 1;
                    break;
                end
            end
        end
    end
end

