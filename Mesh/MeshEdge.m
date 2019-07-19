classdef MeshEdge

    properties
        nodeA
        nodeB
        facetA
        facetB
        length
    end
    
    methods
        function obj = MeshEdge(nodes, facets)
            if (nargin > 0)
                obj.nodeA = nodes(1, 1);
                obj.nodeB = nodes(2, 1);
                obj.length = ((obj.nodeA.x - obj.nodeB.x)^2 + (obj.nodeA.y - obj.nodeB.y)^2)^0.5;
            end
            if (nargin > 1)
                obj.facetA = facets(1, 1);
                if (size(facets, 1)>1)
                    obj.facetB = facets(2, 1);
                else
                    obj.facetB = 0;
                end
            end
        end
    end
end

