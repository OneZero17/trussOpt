classdef PhyLoad
   
    properties
        nodeIndex
        loadX = 0
        loadY = 0
        loadMoment = 0
    end
    
    methods
        function obj = PhyLoad(nodeInput, xLoadInput, yloadInput, momentLoadInput)
            if nargin > 0
                obj.nodeIndex = nodeInput;
            end
            if nargin >1
                obj.loadX = xLoadInput;
            end
            if nargin > 2
                obj.loadY = yloadInput;
            end
            if nargin > 3
                obj.loadMoment = momentLoadInput;
            end
        end
    end
end

