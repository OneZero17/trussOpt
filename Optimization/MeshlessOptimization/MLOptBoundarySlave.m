classdef MLOptBoundarySlave < OptObjectSlave
    
    properties
        boundarycentralNodeSlave
        boundaryEndNodeSlaves
%         zeroStressSlopeX = -1
%         zeroStressSlopeY = -1
        equilibriumX = -1
        equilibriumY = -1
        forceX = 0
        forceY = 0
    end
    
    methods
        function obj = MLOptBoundarySlave(forceX, forceY)
            if nargin > 0
                obj.forceX = forceX;
            end
            if nargin > 1
                obj.forceY = forceY;
            end
        end
        
        function initialize(self, matrix)
            variablesNum = 0;
            for i = 1:size(self.boundaryEndNodeSlaves, 1)
                currentPoint = self.boundaryEndNodeSlaves{i, 1};
                variablesNum = variablesNum + size(currentPoint, 1);    
            end
            if ~self.master.xSupported
                self.equilibriumX = matrix.addConstraint(self.forceX, self.forceX, 2, 'BoundaryEquilibriumX');
            end
            if ~self.master.ySupported
                self.equilibriumY = matrix.addConstraint(self.forceY, self.forceY, 2, 'BoundaryEquilibriumY');
            end
        end
        
        function calcConstraint(self, matrix)      
            
            normal = self.master.boundaryNormal;            
            T = [normal(1) 0         normal(2)
                 0         normal(2) normal(1)];
            if abs(T(1, 1)) > 1e-9 && self.equilibriumX ~= -1
                self.equilibriumX.addVariable(self.boundarycentralNodeSlave.sigmaXXVariable, T(1, 1));
            end
            if abs(T(1, 3)) > 1e-9 && self.equilibriumX ~= -1
                self.equilibriumX.addVariable(self.boundarycentralNodeSlave.tauXYVariable, T(1, 3));
            end
            if abs(T(2, 2)) > 1e-9 && self.equilibriumY ~= -1
                self.equilibriumY.addVariable(self.boundarycentralNodeSlave.sigmaYYVariable, T(2, 2));
            end
            if abs(T(2, 3)) > 1e-9 && self.equilibriumY ~= -1
                self.equilibriumY.addVariable(self.boundarycentralNodeSlave.tauXYVariable, T(2, 3));
            end
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 4;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

