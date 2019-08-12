classdef HybridNodeSlave < OptObjectSlave

    properties
        optNodeSlave
        optBoundarySlaves
    end
    
    methods
        function obj = HybridNodeSlave()
        end
        
        
        function [matrix] = calcConstraint(self, matrix)
            totalLength = 0;
            for i = 1:size(self.optBoundarySlaves, 1)
                totalLength = totalLength + self.optBoundarySlaves{i, 1}.master.edge.length;
            end
            
            for i = 1:size(self.optBoundarySlaves, 1)
                thisEdge = self.optBoundarySlaves{i, 1}.master.edge;
                sinTheta = (thisEdge.nodeB.y - thisEdge.nodeA.y) / thisEdge.length;
                cosTheta = (thisEdge.nodeB.x - thisEdge.nodeA.x) / thisEdge.length;
                length = thisEdge.length;
                thickness = self.optBoundarySlaves{i, 1}.master.coptElement.thickness;
                %connectedNum = size(self.master.linkedLocalNodes, 1);          
                if (self.master.linkedLocalNodes(i) == 1)
                    if ~self.optBoundarySlaves{i, 1}.master.node1XSupported
                        self.optBoundarySlaves{i, 1}.node1SigmaEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintX, -2 * sinTheta * length/(totalLength * thickness));
                        self.optBoundarySlaves{i, 1}.node1SigmaEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintY, 2 * cosTheta * length/(totalLength * thickness));
                    end
                    
                    if ~self.optBoundarySlaves{i, 1}.master.node1YSupported
                        self.optBoundarySlaves{i, 1}.node1TauEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintX, 2 * cosTheta * length/(totalLength * thickness));
                        self.optBoundarySlaves{i, 1}.node1TauEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintY, 2 * sinTheta * length/(totalLength * thickness));
                    end
                end
                if (self.master.linkedLocalNodes(i) == 2)  
                    if ~self.optBoundarySlaves{i, 1}.master.node2XSupported   
                        self.optBoundarySlaves{i, 1}.node2SigmaEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintX, -2 * sinTheta * length/(totalLength * thickness));
                        self.optBoundarySlaves{i, 1}.node2SigmaEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintY, 2 * cosTheta * length/(totalLength * thickness));  
                    end
                    
                    if ~self.optBoundarySlaves{i, 1}.master.node2YSupported
                        self.optBoundarySlaves{i, 1}.node2TauEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintX, 2 * cosTheta * length/(totalLength * thickness));
                        self.optBoundarySlaves{i, 1}.node2TauEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintY, 2 * sinTheta * length/(totalLength * thickness));                          
                    end
                end
            end
            
            if self.optNodeSlave.equilibriumConstraintX ~= -1
                matrix.constraints{self.optNodeSlave.equilibriumConstraintX.index, 1} = [];
                self.optNodeSlave.equilibriumConstraintX = -1;
            end
            if self.optNodeSlave.equilibriumConstraintY ~= -1
                matrix.constraints{self.optNodeSlave.equilibriumConstraintY.index, 1} = [];
                self.optNodeSlave.equilibriumConstraintY = -1;
            end
        end
    end
end

