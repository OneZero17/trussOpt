classdef GeoNode
    
    properties
        x
        y
    end
    
    methods
        function obj = GeoNode(xValue,yValue)
            if (nargin > 0)
                obj.x = xValue;       
            end
            if (nargin > 1)
                obj.y = yValue;
            end
        end
        
        function distance = calcDistance(self, anotherNode)
            distance = sqrt((self.x - anotherNode.x)* (self.x - anotherNode.x) + (self.y - anotherNode.y)* (self.y - anotherNode.y));
        end
    end
end

