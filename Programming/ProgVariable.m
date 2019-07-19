classdef ProgVariable < handle
    properties
        name
        index
        upperBound 
        lowerBound
        value
    end
    
    methods
        function obj = ProgVariable(lowerBound,upperBound, name)
            if nargin > 0
                obj.upperBound = upperBound;
            end
            if nargin > 1
                obj.lowerBound = lowerBound;
            end
            if nargin >2
                obj.name = name;
            end
        end
    end
end

