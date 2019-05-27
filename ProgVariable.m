classdef ProgVariable    
    properties
        index
        upperBound 
        lowerBound
        value
    end
    
    methods
        function obj = ProgVariable(lowerBound,upperBound)
            if nargin > 0
                obj.upperBound = upperBound;
            end
            if nargin > 1
                obj.lowerBound = lowerBound;
            end
        end
    end
end

