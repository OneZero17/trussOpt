classdef PhyLoad3D < PhyLoad
    
    properties
        loadZ = 0
    end
    
    methods
        function obj = PhyLoad3D(nodeInput, xLoadInput, yloadInput, zloadInput)
            if (nargin > 0)
                obj.nodeIndex = nodeInput;
            end
            if  (nargin >1)
                obj.loadX = xLoadInput;
            end
            if (nargin > 2)
                obj.loadY = yloadInput;
            end 
            if nargin > 3
                obj.loadZ = zloadInput;
            end
        end
    end
end

