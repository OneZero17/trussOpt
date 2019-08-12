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
            
            length = self.optBoundarySlaves{i, 1}.master.edge.length;
            thickness = self.optBoundarySlaves{i, 1}.master.coptElement.thickness;
            
%             for i = 1:size(self.optBoundarySlaves, 1)
            for i = 1:1
                if (self.master.linkedLocalNodes(i) == 1)
                    if ~self.optBoundarySlaves{i, 1}.master.node1XSupported
                        self.optNodeSlave.equilibriumConstraintX.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node1SigmaXEquilibrium, 0.5 * length * thickness);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node1SigmaXEquilibrium.index, 1} = [];
                        delete(self.optBoundarySlaves{i, 1}.node1SigmaXEquilibrium);
                    end
                    if ~self.optBoundarySlaves{i, 1}.master.node1YSupported
                        self.optNodeSlave.equilibriumConstraintY.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node1SigmaYEquilibrium, 0.5 * length * thickness);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node1SigmaYEquilibrium.index, 1} = [];
                        delete(self.optBoundarySlaves{i, 1}.node1SigmaYEquilibrium);
                    end
                else
                    if ~self.optBoundarySlaves{i, 1}.master.node2XSupported 
                        self.optNodeSlave.equilibriumConstraintX.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node2SigmaXEquilibrium, 0.5 * length * thickness);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node2SigmaXEquilibrium.index, 1} = [];
                        delete(self.optBoundarySlaves{i, 1}.node2SigmaXEquilibrium);
                    end
                    if ~self.optBoundarySlaves{i, 1}.master.node2YSupported
                        self.optNodeSlave.equilibriumConstraintY.addConstraintToRHS(self.optBoundarySlaves{i, 1}.node2SigmaYEquilibrium, 0.5 * length * thickness);
                        matrix.constraints{self.optBoundarySlaves{i, 1}.node2SigmaYEquilibrium.index, 1} = [];
                        delete(self.optBoundarySlaves{i, 1}.node2SigmaYEquilibrium);
                    end
                end
            end
        end
    end
end

