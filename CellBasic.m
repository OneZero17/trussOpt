classdef CellBasic < GeoGroundStructure

    properties
        xIndex
        yIndex
    end
    
    methods
        function obj = CellBasic(xIndex,yIndex)
            if (nargin > 0)
                obj.xIndex = xIndex;
            end
            if (nargin > 1)
                obj.yIndex = yIndex;
            end
        end
    end
end

