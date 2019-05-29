classdef PhySupport  
    properties
        node
        fixedX = 1
        fixedY = 1
    end
    
    methods
        function obj = PhySupport(node, xFix, yFix)
            if (nargin >0)
                obj.node = node;
            end
            if (nargin >1)
                obj.fixedX = xFix;
            end
            if (nargin >2)
                obj.fixedY = yFix;
            end
        end
    end
end

