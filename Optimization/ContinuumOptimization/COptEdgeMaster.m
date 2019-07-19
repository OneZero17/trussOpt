classdef COptEdgeMaster < OptObjectMaster

    properties
        edge
        coptElementA
        coptElementB = cell(1, 1);
    end
    
    methods
        function obj = COptEdgeMaster(edge,coptElementA, coptElementB)
            if (nargin > 0)
                obj.edge = edge;
            end
            if (nargin > 1)
                obj.coptElementA = coptElementA;
            end
            if (nargin > 2)
                obj.coptElementB = coptElementB;
            end
        end
        
        function initialize(self, matrix)
            node1Index = self.edge.nodeA.index;
            node2Index = self.edge.nodeB.index;
            node1AIndex = self.coptElementA.getLocalNodalIndex(node1Index);
            node1BIndex = self.coptElementB.getLocalNodalIndex(node1Index);
            node2AIndex = self.coptElementA.getLocalNodalIndex(node2Index);
            node2BIndex = self.coptElementB.getLocalNodalIndex(node2Index);
            for i = 1:size(self.slaves, 1)
                self.slaves{i, 1}.node1AVariables = {self.coptElementA.slaves{i, 1}.sigmaXXVariables{node1AIndex, 1};...
                                                     self.coptElementA.slaves{i, 1}.sigmaYYVariables{node1AIndex, 1};...
                                                     self.coptElementA.slaves{i, 1}.tauXYVariables{node1AIndex, 1};};
                self.slaves{i, 1}.node1BVariables = {self.coptElementB.slaves{i, 1}.sigmaXXVariables{node1BIndex, 1};...
                                                     self.coptElementB.slaves{i, 1}.sigmaYYVariables{node1BIndex, 1};...
                                                     self.coptElementB.slaves{i, 1}.tauXYVariables{node1BIndex, 1};};
                self.slaves{i, 1}.node2AVariables = {self.coptElementA.slaves{i, 1}.sigmaXXVariables{node2AIndex, 1};...
                                                     self.coptElementA.slaves{i, 1}.sigmaYYVariables{node2AIndex, 1};...
                                                     self.coptElementA.slaves{i, 1}.tauXYVariables{node2AIndex, 1};};
                self.slaves{i, 1}.node2BVariables = {self.coptElementB.slaves{i, 1}.sigmaXXVariables{node2BIndex, 1};...
                                                     self.coptElementB.slaves{i, 1}.sigmaYYVariables{node2BIndex, 1};...
                                                     self.coptElementB.slaves{i, 1}.tauXYVariables{node2BIndex, 1};};                                                 
            end
            
            self.initializeSlaves(matrix);
        end
        
        function calcConstraint(self, matrix)
            self.calcSlavesConstraints(matrix);
        end
    end
end

