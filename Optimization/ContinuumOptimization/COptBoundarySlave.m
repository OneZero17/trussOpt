classdef COptBoundarySlave < OptObjectSlave
   
    properties
        forces = zeros(4, 1);
        node1Variables
        node2Variables
        node1SigmaXEquilibrium;
        node1SigmaYEquilibrium;
        node2SigmaXEquilibrium;
        node2SigmaYEquilibrium;
    end
    
    methods
        function obj = COptBoundarySlave(forces)
            if (nargin > 0)
                obj.forces = forces;
            end
        end
        
        function initialize(self, matrix)
            externalForces = self.forces;

            if ~self.master.node1XSupported
                self.node1SigmaXEquilibrium = matrix.addConstraint(externalForces(1, 1), externalForces(1, 1), 3, 'BoundarySigmaEquilibrium');
            end
            if ~self.master.node1YSupported
                self.node1SigmaYEquilibrium = matrix.addConstraint(externalForces(2, 1), externalForces(2, 1), 3, 'BoundaryTauEquilibrium');
            end

            if ~self.master.node2XSupported
                self.node2SigmaXEquilibrium = matrix.addConstraint(externalForces(3, 1), externalForces(3, 1), 3, 'BoundarySigmaEquilibrium');
            end
            if ~self.master.node2YSupported
                self.node2SigmaYEquilibrium = matrix.addConstraint(externalForces(4, 1), externalForces(4, 1), 3, 'BoundaryTauEquilibrium');
            end
        end
        
        function [matrix] = calcConstraint(self, matrix)
            thisEdge = self.master.edge;
            sinTheta = (thisEdge.nodeB.y - thisEdge.nodeA.y) / thisEdge.length;
            cosTheta = (thisEdge.nodeB.x - thisEdge.nodeA.x) / thisEdge.length;

            T = [-sinTheta, 0, cosTheta;
                 0, cosTheta, -sinTheta];
            for i = 1:3
                if ~self.master.node1XSupported
                    self.node1SigmaXEquilibrium.addVariable(self.node1Variables{i, 1}, T(1, i));
                end
                
                if ~self.master.node1YSupported
                    self.node1SigmaYEquilibrium.addVariable(self.node1Variables{i, 1}, T(2, i));
                end
                
                if ~self.master.node2XSupported
                    self.node2SigmaXEquilibrium.addVariable(self.node2Variables{i, 1}, T(1, i));
                end
                
                if ~self.master.node2YSupported
                    self.node2SigmaYEquilibrium.addVariable(self.node2Variables{i, 1}, T(2, i));
                end
                    
            end
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 4;
            varNum = 0;
            objVarNum = 0;
        end
            
    end
end

