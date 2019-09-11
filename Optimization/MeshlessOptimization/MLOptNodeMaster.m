classdef MLOptNodeMaster < OptObjectMaster    
    properties
        sigmaMax
        densityVariable
        yieldConstraints
        controlArea
    end
    
    methods
        function obj = MLOptNodeMaster(sigmaMax, controlArea)
            if nargin > 0
                obj.sigmaMax = sigmaMax;
            end
            if nargin > 1
                obj.controlArea = controlArea;
            end
        end
        
        
        function initialize(self, matrix)
            self.densityVariable = matrix.addVariable(0, 1, 'densityVariable');
            self.yieldConstraints = cell(size(self.slaves, 1), 1);
            for i = 1:size(self.slaves, 1)
                self.yieldConstraints{i,1} = matrix.addConicConstraint(4);
            end
            self.initializeSlaves(matrix);
        end
        
        function calcConstraint(self, matrix)
            for i = 1:size(self.slaves, 1)
                sigmaXXCone = ProgCone(1, self.slaves{i,1}.sigmaXXVariable);
                sigmaYYCone = ProgCone(1, self.slaves{i,1}.sigmaYYVariable);
                sigmaXXminusSigmaYYCone = ProgCone(2);
                sigmaXXminusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaXXVariable, 1);
                sigmaXXminusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaYYVariable, -1);
                tauCone = ProgCone(1, self.slaves{i,1}.tauXYVariable, sqrt(6));
                sigmaMaxCone = ProgCone(1, self.densityVariable, sqrt(2)*self.sigmaMax);
                yieldConicConstraint = self.yieldConstraints{i,1};

                yieldConicConstraint.addRHSCone(sigmaMaxCone);
                yieldConicConstraint.addLHSCone(sigmaXXCone);
                yieldConicConstraint.addLHSCone(sigmaYYCone);
                yieldConicConstraint.addLHSCone(sigmaXXminusSigmaYYCone);
                yieldConicConstraint.addLHSCone(tauCone);
            end
            self.calcSlavesConstraints(matrix);
        end
        
        function calcObjective(self, matrix)
            matrix.objectiveFunction.addVariable(self.densityVariable, self.controlArea);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = size(self.slaves, 1);
            varNum = 1;
            objVarNum = 1;
        end
    end
end

