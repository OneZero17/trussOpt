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
                              
                if (self.master.linkedLocalNodes(i) == 1)
                    if ~self.optBoundarySlaves{i, 1}.master.node1XSupported
                        self.optNodeSlave.equilibriumConstraintX.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node1TauEquilibrium, 0.5 * cosTheta * length * thickness );
                        self.optNodeSlave.equilibriumConstraintX.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node1SigmaEquilibrium, -0.5 * sinTheta * length * thickness );
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node1SigmaEquilibrium.index, 1} = [];
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node1TauEquilibrium.index, 1} = [];
                    elseif self.optNodeSlave.equilibriumConstraintX ~= []
                        matrix.constraints{self.optNodeSlave.equilibriumConstraintX.index, 1} = [];
                        delete(self.optNodeSlave.equilibriumConstraintX);
                    end
                    
                    if ~self.optBoundarySlaves{i, 1}.master.node1YSupported
                        self.optNodeSlave.equilibriumConstraintY.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node1TauEquilibrium, 0.5 * sinTheta * length * thickness);
                        self.optNodeSlave.equilibriumConstraintY.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node1SigmaEquilibrium, 0.5 * cosTheta * length * thickness);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node1SigmaEquilibrium.index, 1} = [];
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node1TauEquilibrium.index, 1} = [];
                    elseif self.optNodeSlave.equilibriumConstraintY~=[]
                        matrix.constraints{self.optNodeSlave.equilibriumConstraintY.index, 1} = [];
                        delete(self.optNodeSlave.equilibriumConstraintY);
                    end
                    

                    delete(self.optBoundarySlaves{i, 1}.node1SigmaEquilibrium);
                    delete(self.optBoundarySlaves{i, 1}.node1TauEquilibrium);
                end
                if (self.master.linkedLocalNodes(i) == 2)  
                    if ~self.optBoundarySlaves{i, 1}.master.node2XSupported
                        self.optNodeSlave.equilibriumConstraintX.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node2TauEquilibrium, 0.5 * cosTheta * length * thickness );
                        self.optNodeSlave.equilibriumConstraintX.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node2SigmaEquilibrium, -0.5 * sinTheta * length * thickness );
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node2SigmaEquilibrium.index, 1} = [];
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node2TauEquilibrium.index, 1} = [];                    
                    elseif self.optNodeSlave.equilibriumConstraintX ~= []
                        matrix.constraints{self.optNodeSlave.equilibriumConstraintX.index, 1} = [];
                        delete(self.optNodeSlave.equilibriumConstraintX);   
                    end
                    
                    if ~self.optBoundarySlaves{i, 1}.master.node2YSupported
                        self.optNodeSlave.equilibriumConstraintY.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node2TauEquilibrium, 0.5 * sinTheta * length * thickness);
                        self.optNodeSlave.equilibriumConstraintY.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node2SigmaEquilibrium, 0.5 * cosTheta * length * thickness);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node2SigmaEquilibrium.index, 1} = [];
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node2TauEquilibrium.index, 1} = [];    
                    elseif self.optNodeSlave.equilibriumConstraintY~=[]
                        matrix.constraints{self.optNodeSlave.equilibriumConstraintY.index, 1} = [];
                        delete(self.optNodeSlave.equilibriumConstraintX);                           
                    end
                    
                    delete(self.optBoundarySlaves{i, 1}.node2SigmaEquilibrium);
                    delete(self.optBoundarySlaves{i, 1}.node2TauEquilibrium);
                end
            end
        end
    end
end

