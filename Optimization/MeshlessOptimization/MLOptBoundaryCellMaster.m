classdef MLOptBoundaryCellMaster < MLOptCellMaster
    
    properties
        boundaryNormal
        xSupported = false;
        ySupported = false;
    end
    
    methods
        function obj = MLOptBoundaryCellMaster(cellNodes, cellLengths, supportingDomainCoefficients, area, boundaryNormal, fixedX, fixedY)
            if nargin > 0
                obj.cellNodeMasters = cellNodes;
            end
            if nargin > 1
                obj.cellLengths = cellLengths;
            end
            if nargin > 2
                obj.supportingDomainCoefficients = supportingDomainCoefficients;
            end
            if nargin > 3
                obj.area = area;
            end
            if nargin > 4
                obj.boundaryNormal = boundaryNormal;
            end
            if nargin > 5
                obj.xSupported = fixedX == 1;
            end
            if nargin > 6
                obj.ySupported = fixedY == 1;
            end
        end
    end
end

