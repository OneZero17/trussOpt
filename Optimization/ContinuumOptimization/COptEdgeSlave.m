classdef COptEdgeSlave < OptObjectSlave
 
    properties
        node1AVariables
        node1BVariables
        node2AVariables
        node2BVariables  
        node1SigmaEquilibrium;
        node1TauEquilibrium;
        node2SigmaEquilibrium;
        node2TauEquilibrium;
    end
    
    methods
        function obj = COptEdgeSlave()
        end
        
        function initialize(self, matrix)
            self.node1SigmaEquilibrium = matrix.addConstraint(0, 0, 6, 'EdgeSigmaEquilibrium');
            self.node1TauEquilibrium = matrix.addConstraint(0, 0, 6, 'EdgeTauEquilibrium');
            self.node2SigmaEquilibrium = matrix.addConstraint(0, 0, 6,'EdgeSigmaEquilibrium');
            self.node2TauEquilibrium = matrix.addConstraint(0, 0, 6, 'EdgeTauEquilibrium');
        end
        
        function [matrix] = calcConstraint(self, matrix)
            thisEdge = self.master.edge;
            sinTheta = (thisEdge.nodeB.y - thisEdge.nodeA.y) / thisEdge.length;
            cosTheta = (thisEdge.nodeB.x - thisEdge.nodeA.x) / thisEdge.length;
            T = [sinTheta^2, cosTheta^2, -2*sinTheta*cosTheta;
                 -sinTheta*cosTheta, sinTheta*cosTheta, 1-2*sinTheta^2];
            for i = 1:3
                self.node1SigmaEquilibrium.addVariable(self.node1AVariables{i, 1}, T(1, i));
                self.node1SigmaEquilibrium.addVariable(self.node1BVariables{i, 1}, -T(1, i));
                self.node1TauEquilibrium.addVariable(self.node1AVariables{i, 1}, T(2, i));
                self.node1TauEquilibrium.addVariable(self.node1BVariables{i, 1}, -T(2, i));
                self.node2SigmaEquilibrium.addVariable(self.node2AVariables{i, 1}, T(1, i));
                self.node2SigmaEquilibrium.addVariable(self.node2BVariables{i, 1}, -T(1, i));
                self.node2TauEquilibrium.addVariable(self.node2AVariables{i, 1}, T(2, i));
                self.node2TauEquilibrium.addVariable(self.node2BVariables{i, 1}, -T(2, i));
            end
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 4;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

