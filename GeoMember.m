classdef GeoMember < handle
    properties
        index
        nodeA
        nodeB
        length
    end
    
    methods
        function obj = GeoMember(aNode,bNode, index)
            if (nargin > 0)
                obj.nodeA = aNode;
            end
            if (nargin > 1)
                obj.nodeB = bNode;
                obj.length = aNode.calcDistance(bNode);
            end
            if (nargin > 2)
                obj.index = index;
            end
        end
    end
end

