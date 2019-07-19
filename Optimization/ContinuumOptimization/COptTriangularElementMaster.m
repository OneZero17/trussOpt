classdef COptTriangularElementMaster < OptObjectMaster
  
    properties
        facet
        yieldConstraints
        sigmaMax
        densityVariable
        densityCoefficient
    end
    
    methods
        function obj = COptTriangularElementMaster(sigmaMax, facet)
            obj.densityCoefficient = 1;
            if (nargin > 0)
                obj.sigmaMax = sigmaMax;
            end
            if (nargin >1)
                obj.facet = facet;
            end
        end
        
        function obj = getLocalNodalIndex(self, index)
            if self.facet.nodeA.index == index
                obj = 1;
                return
            elseif  self.facet.nodeB.index == index
                obj = 2;
                return
            elseif self.facet.nodeC.index == index
                obj = 3;
                return
            end
            obj = 0;
        end
        
        function [matrix, obj] = initialize(self, matrix)
            % one variable created here
            self.densityVariable = matrix.addVariable(0, 1, 'densityVariable');
            self.yieldConstraints = cell(size(self.slaves, 1), 1);
            yieldConstraintNum = 0;
            for i = 1:size(self.slaves, 1)
                for j = 1:3
                    yieldConstraintNum = yieldConstraintNum + 1;
                    % one constraint created here
                    self.yieldConstraints{yieldConstraintNum,1} = matrix.addConicConstraint(2);
                end
            end
            self.initializeSlaves(matrix);
            obj = self;
        end
       
        function calcConstraint(self, matrix)
            yieldConstraintNum = 0;
            for i = 1:size(self.slaves, 1)
                for j = 1:3
                    yieldConstraintNum = yieldConstraintNum + 1;
                    sigmaXXCone = ProgCone(1, self.slaves{i,1}.sigmaXXVariables{j, 1});
                    sigmaYYCone = ProgCone(1, self.slaves{i,1}.sigmaYYVariables{j, 1});
                    sigmaXXminusSigmaYYCone = ProgCone(2);
                    sigmaXXminusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaXXVariables{j, 1}, 1);
                    sigmaXXminusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaYYVariables{j, 1}, -1);
                    tauCone = ProgCone(1, self.slaves{i,1}.tauXYVariables{j, 1}, 2);
                    sigmaMaxCone = ProgCone(1, self.densityVariable, 2*self.sigmaMax);
                    yieldConicConstraint = self.yieldConstraints{yieldConstraintNum,1};
                    
                    yieldConicConstraint.addRHSCone(sigmaMaxCone);
                    %yieldConicConstraint.addLHSCone(sigmaXXCone);
                    %yieldConicConstraint.addLHSCone(sigmaYYCone);
                    yieldConicConstraint.addLHSCone(sigmaXXminusSigmaYYCone);
                    yieldConicConstraint.addLHSCone(tauCone);
                end
            end
            self.calcSlavesConstraints(matrix);
        end
        
        function calcObjective(self, matrix)
            matrix.objectiveFunction.addVariable(self.densityVariable, self.densityCoefficient);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = size(self.slaves, 1) * 3;
            varNum = 1;
            objVarNum = 1;
        end
        
        function feedBackResult(self, loadCaseNum)
            self.facet.density = self.densityVariable.value;
        end
        
    end
end

