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
            
            for i = 1:size(self.optBoundarySlaves)            
             thickness = self.optBoundarySlaves{i, 1}.master.coptElement.thickness;
             
                if (self.master.linkedLocalNodes(i, 1) == 1)
                    if ~self.optBoundarySlaves{i, 1}.master.node1XSupported
                        self.optBoundarySlaves{i, 1}.node1SigmaXEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintX, 2 / (totalLength * thickness));
                    end
                    if ~self.optBoundarySlaves{i, 1}.master.node1YSupported
                        self.optBoundarySlaves{i, 1}.node1SigmaYEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintY, 2 / (totalLength * thickness));
                    end
                else
                    if ~self.optBoundarySlaves{i, 1}.master.node2XSupported 
                        self.optBoundarySlaves{i, 1}.node2SigmaXEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintX, 2 / (totalLength * thickness));
                    end
                    if ~self.optBoundarySlaves{i, 1}.master.node2YSupported
                        self.optBoundarySlaves{i, 1}.node2SigmaYEquilibrium.addConstraintToRHS(self.optNodeSlave.equilibriumConstraintY, 2 / (totalLength * thickness));
                    end
                end
            end          
        end
    end
end

