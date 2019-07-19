classdef COptBoundaryMaster < OptObjectMaster

    properties
        node1SigmaSupported = false;
        node1TauSupported = false;
        node2SigmaSupported = false;
        node2TauSupported = false;
        edge;
        coptElement;
    end
    
    methods
        function obj = COptBoundaryMaster(edge, element)
            if (nargin > 0)
                obj.edge = edge;
            end
            if (nargin > 1)
                obj.coptElement = element;
            end
        end
        
        function initialize(self, matrix)
            node1Index = self.edge.nodeA.index;
            node2Index = self.edge.nodeB.index;
            node1LocalIndex = self.coptElement.getLocalNodalIndex(node1Index);
            node2LocalIndex = self.coptElement.getLocalNodalIndex(node2Index);
            for i = 1:size(self.slaves, 1)
                self.slaves{i, 1}.node1Variables = {self.coptElement.slaves{i, 1}.sigmaXXVariables{node1LocalIndex, 1};...
                                                     self.coptElement.slaves{i, 1}.sigmaYYVariables{node1LocalIndex, 1};...
                                                     self.coptElement.slaves{i, 1}.tauXYVariables{node1LocalIndex, 1};};
                self.slaves{i, 1}.node2Variables = {self.coptElement.slaves{i, 1}.sigmaXXVariables{node2LocalIndex, 1};...
                                                     self.coptElement.slaves{i, 1}.sigmaYYVariables{node2LocalIndex, 1};...
                                                     self.coptElement.slaves{i, 1}.tauXYVariables{node2LocalIndex, 1};};                                               
            end
            self.initializeSlaves(matrix);
            
        end
        
        function calcConstraint(self, matrix)
            self.calcSlavesConstraints(matrix);
        end

    end
end

