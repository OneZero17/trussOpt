classdef PhyUniformLoad < handle
    
    properties
        range
        loads
        loadX
        loadY
    end
    
    methods
        function obj = PhyUniformLoad(range, loadX, loadY, mesh)
            if (nargin > 0)
                obj.range = range;
            end
            if (nargin >1)
                obj.loadX = loadX;
            end
            if (nargin >2)
                obj.loadY = loadY;
            end
            if (nargin > 3)
                obj.createLoads(mesh);
            end
        end
        
        function createLoads(self, mesh)
            nodeIDs = findNodes(mesh,'box',self.range(1,:),self.range(2,:));
            nodeNum = size(nodeIDs, 2);
            self.loads = cell(nodeNum, 1);
            for i = 1:nodeNum
                self.loads{i, 1} = PhyLoad(nodeIDs(i), self.loadX / nodeNum, self.loadY / nodeNum);
            end
        end
    end
end

