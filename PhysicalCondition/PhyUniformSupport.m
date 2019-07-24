classdef PhyUniformSupport < handle
    
    properties
        range
        supports
        fixedX
        fixedY
    end
    
    methods
        function obj = PhyUniformSupport(range, supportX, supportY, mesh)
            if (nargin> 0)
                obj.range = range;
            end
            if (nargin> 1)
                obj.fixedX = supportX;
            end
            if (nargin> 2)
                obj.fixedY = supportY;
            end
            if (nargin> 3)
                obj.createSupports(mesh);
            end
        end
        
        function createSupports(self, mesh)
            nodeIDs = findNodes(mesh,'box',self.range(1,:),self.range(2,:));
            nodeNum = size(nodeIDs, 2);
            self.supports = cell(nodeNum, 1);
            for i = 1:nodeNum
                self.supports{i, 1} = PhySupport(nodeIDs(i), self.fixedX, self.fixedY);
            end
        end
    end
end

