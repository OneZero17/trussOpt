classdef CellBasic < GeoGroundStructure

    properties
        xStart
        yStart
        size
    end
    
    methods
        function obj = CellBasic(xStart,yStart)
            if (nargin > 0)
                obj.xStart = xStart;
            end
            if (nargin > 1)
                obj.yStart = yStart;
            end
        end
    end
end

