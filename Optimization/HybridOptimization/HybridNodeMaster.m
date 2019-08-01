classdef HybridNodeMaster < OptObjectMaster
    
    properties
        optNode
        optBoundaries
        thickness
        linkedLocalNodes
    end
    
    methods
        function obj = HybridNodeMaster(optNode, optBoundaries, linkedLocalNodes, thickness)
            if (nargin > 0)
                obj.optNode = optNode;
            end
            if (nargin > 1)
                obj.optBoundaries = optBoundaries;
            end
            if (nargin > 2)
                obj.linkedLocalNodes = linkedLocalNodes;
            end
            if (nargin > 3)
                obj.thickness = thickness;
            end
        end
        
        function initialize(self, matrix)
            for i = 1:size(self.slaves, 1)
                self.slaves{i, 1}.optNodeSlave = self.optNode.slaves{i, 1};
                
                optBoundarySlaves = cell(size(self.optBoundaries, 1), 1);
                for j = 1:size(self.optBoundaries, 1)
                    optBoundarySlaves{j, 1} = self.optBoundaries{j, 1}.slaves{i, 1};
                end
                self.slaves{i, 1}.optBoundarySlaves = optBoundarySlaves;
            end
            self.initializeSlaves(matrix);
        end
        
        function calcConstraint(self, matrix)
            self.calcSlavesConstraints(matrix);
        end
    end
end

