classdef GeoMember < handle
    properties
        index
        nodeA
        nodeB
        length
        area
        force
    end
    
    methods
        function obj = GeoMember(aNode,bNode, index, length)
            if (nargin > 0)
                obj.nodeA = aNode;
            end
            if (nargin > 1)
                obj.nodeB = bNode;
                
            end
            if (nargin > 2)
                obj.index = index;
            end
            
            if (nargin<=3)
                obj.length = aNode.calcDistance(bNode);
            else
                obj.length = length;
            end
        end
    end
end

