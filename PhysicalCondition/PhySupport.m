classdef PhySupport  
    properties
        node
        fixedX = 1
        fixedY = 1
        fixedMoment = 1
    end
    
    methods
        function obj = PhySupport(node, xFix, yFix, fixedMoment)
            if nargin > 0
                obj.node = node;
            end
            if nargin > 1
                obj.fixedX = xFix;
            end
            if nargin > 2
                obj.fixedY = yFix;
            end
            if nargin > 3
                obj.fixedMoment = fixedMoment;
            end
        end
    end
end

