classdef HybridNodeSlave < OptObjectSlave

    properties
        optNodeSlave
        optBoundarySlaves
    end
    
    methods
        function obj = HybridNodeSlave()
        end
        
        
        function [matrix] = calcConstraint(self, matrix)
            
            for i = 1:size(self.optBoundarySlaves)            
             length = self.optBoundarySlaves{i, 1}.master.edge.length;
             thickness = self.optBoundarySlaves{i, 1}.master.coptElement.thickness;
             coefficient = 1;
             
             if i > 1 && self.master.linkedLocalNodes(1, 2) == 0
                 continue;
             end
             
                if (self.master.linkedLocalNodes(i, 1) == 1)
                    if ~self.optBoundarySlaves{i, 1}.master.node1XSupported
                        self.optNodeSlave.equilibriumConstraintX.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node1SigmaXEquilibrium, 0.5 * length * thickness * coefficient);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node1SigmaXEquilibrium.index, 1} = [];
                        delete(self.optBoundarySlaves{i, 1}.node1SigmaXEquilibrium);
                    end
                    if ~self.optBoundarySlaves{i, 1}.master.node1YSupported
                        self.optNodeSlave.equilibriumConstraintY.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node1SigmaYEquilibrium, 0.5 * length * thickness * coefficient);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node1SigmaYEquilibrium.index, 1} = [];
                        delete(self.optBoundarySlaves{i, 1}.node1SigmaYEquilibrium);
                    end
                else
                    if ~self.optBoundarySlaves{i, 1}.master.node2XSupported 
                        self.optNodeSlave.equilibriumConstraintX.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node2SigmaXEquilibrium, 0.5 * length * thickness * coefficient);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node2SigmaXEquilibrium.index, 1} = [];
                        delete(self.optBoundarySlaves{i, 1}.node2SigmaXEquilibrium);
                    end
                    if ~self.optBoundarySlaves{i, 1}.master.node2YSupported
                        self.optNodeSlave.equilibriumConstraintY.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node2SigmaYEquilibrium, 0.5 * length * thickness * coefficient);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node2SigmaYEquilibrium.index, 1} = [];
                        delete(self.optBoundarySlaves{i, 1}.node2SigmaYEquilibrium);
                    end
                end
            end
        end
    end
end

