classdef PhyLoad
   
    properties
        nodeIndex
        loadX = 0
        loadY = 0
    end
    
    methods
        function obj = PhyLoad(nodeInput, xLoadInput, yloadInput)
            if (nargin > 0)
                obj.nodeIndex = nodeInput;
            end
            if  (nargin >1)
                obj.loadX = xLoadInput;
            end
            if (nargin > 2)
                obj.loadY = yloadInput;
            end              
        end
    end
end

