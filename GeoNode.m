classdef GeoNode < handle
    
    properties
        index
        x
        y
    end
    
    methods
        function obj = GeoNode(xValue,yValue, index)
            if (nargin > 0)
                obj.x = xValue;       
            end
            if (nargin > 1)
                obj.y = yValue;
            end
            if (nargin > 2)
                obj.index = index;
            end
        end
        
        function distance = calcDistance(self, anotherNode)
            distance = sqrt((self.x - anotherNode.x)* (self.x - anotherNode.x) + (self.y - anotherNode.y)* (self.y - anotherNode.y));
        end
    end
end

