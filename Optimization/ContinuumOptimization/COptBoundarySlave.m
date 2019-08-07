classdef COptBoundarySlave < OptObjectSlave
   
    properties
        forces = zeros(4, 1);
        node1Variables
        node2Variables
        node1SigmaEquilibrium;
        node1TauEquilibrium;
        node2SigmaEquilibrium;
        node2TauEquilibrium;
    end
    
    methods
        function obj = COptBoundarySlave(forces)
            if (nargin > 0)
                obj.forces = forces;
            end
        end
        
        function initialize(self, matrix)
            externalForces = self.forces;
            thisEdge = self.master.edge;
            sinTheta = (thisEdge.nodeB.y - thisEdge.nodeA.y) / thisEdge.length;
            cosTheta = (thisEdge.nodeB.x - thisEdge.nodeA.x) / thisEdge.length;
            forces = self.forces;
            transformedForces = [-forces(1, 1)*sinTheta + forces(2, 1)*cosTheta;
                                 forces(1, 1)*cosTheta + forces(2, 1)*sinTheta;
                                 -forces(3, 1)*sinTheta + forces(4, 1)*cosTheta;
                                 forces(3, 1)*cosTheta + forces(4, 1)*sinTheta;];
                             
            if ~self.master.node1XSupported
                self.node1SigmaEquilibrium = matrix.addConstraint(transformedForces(1, 1), transformedForces(1, 1), 3, 'BoundarySigmaEquilibrium');
            end
            if ~self.master.node1YSupported
                self.node1TauEquilibrium = matrix.addConstraint(transformedForces(2, 1), transformedForces(2, 1), 3, 'BoundaryTauEquilibrium');
            end

            if ~self.master.node2XSupported
                self.node2SigmaEquilibrium = matrix.addConstraint(transformedForces(3, 1), transformedForces(3, 1), 3, 'BoundarySigmaEquilibrium');
            end
            if ~self.master.node2YSupported
                self.node2TauEquilibrium = matrix.addConstraint(transformedForces(4, 1), transformedForces(4, 1), 3, 'BoundaryTauEquilibrium');
            end
        end
        
        function [matrix] = calcConstraint(self, matrix)
            thisEdge = self.master.edge;
            sinTheta = (thisEdge.nodeB.y - thisEdge.nodeA.y) / thisEdge.length;
            cosTheta = (thisEdge.nodeB.x - thisEdge.nodeA.x) / thisEdge.length;
            T = [sinTheta^2, cosTheta^2, -2*sinTheta*cosTheta;
                 -sinTheta*cosTheta, sinTheta*cosTheta, 1-2*sinTheta^2];
            for i = 1:3
                if ~self.master.node1XSupported
                    self.node1SigmaEquilibrium.addVariable(self.node1Variables{i, 1}, T(1, i));
                end
                
                if ~self.master.node1YSupported
                    self.node1TauEquilibrium.addVariable(self.node1Variables{i, 1}, T(2, i));
                end
                
                if ~self.master.node2XSupported
                    self.node2SigmaEquilibrium.addVariable(self.node2Variables{i, 1}, T(1, i));
                end
                
                if ~self.master.node2YSupported
                    self.node2TauEquilibrium.addVariable(self.node2Variables{i, 1}, T(2, i));
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

