classdef PhySupport3D < PhySupport
  
    properties
        fixedZ = 1
    end
    
    methods
        function obj = PhySupport3D(node, xFix, yFix, zFix)
            if nargin >0
                obj.node = node;
            end
            if nargin >1
                obj.fixedX = xFix;
            end
            if nargin >2
                obj.fixedY = yFix;
            end
            if nargin > 3
                obj.fixedZ = zFix;
            end
        end
    end
end

