classdef COptTriangularElementMaster < OptObjectMaster
  
    properties
        facet
        yieldConstraints
        nullTensorConstraints
        sigmaMax
        densityVariable
        densityCoefficient
        isVonMises = true
    end
    
    methods
        function obj = COptTriangularElementMaster(sigmaMax, facet, isVonMises)
            obj.densityCoefficient = 1;
            if (nargin > 0)
                obj.sigmaMax = sigmaMax;
            end
            if (nargin > 1)
                obj.facet = facet;
            end
            if (nargin > 2)
                obj.isVonMises = isVonMises;
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
            self.yieldConstraints = cell(size(self.slaves, 1)*3, 1);
            isVonMises = self.isVonMises;
            if (~isVonMises)
                self.nullTensorConstraints = cell(size(self.slaves, 1)*3, 1);
            end
            yieldConstraintNum = 0;
            for i = 1:size(self.slaves, 1)
                for j = 1:3
                    yieldConstraintNum = yieldConstraintNum + 1;
                    % one constraint created here
                    if (isVonMises)
                        self.yieldConstraints{yieldConstraintNum,1} = matrix.addConicConstraint(4);
                    else
                        self.yieldConstraints{yieldConstraintNum,1} = matrix.addConicConstraint(2);
                        self.nullTensorConstraints{yieldConstraintNum,1} = matrix.addConicConstraint(1);
                    end
                end
            end
            self.initializeSlaves(matrix);
            obj = self;
        end
       
        function calcConstraint(self, matrix)
            yieldConstraintNum = 0;
            isVonMises = self.isVonMises;
            for i = 1:size(self.slaves, 1)
                for j = 1:3
                    if (isVonMises)
                        yieldConstraintNum = yieldConstraintNum + 1;
                        sigmaXXCone = ProgCone(1, self.slaves{i,1}.sigmaXXVariables{j, 1});
                        sigmaYYCone = ProgCone(1, self.slaves{i,1}.sigmaYYVariables{j, 1});
                        sigmaXXminusSigmaYYCone = ProgCone(2);
                        sigmaXXminusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaXXVariables{j, 1}, 1);
                        sigmaXXminusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaYYVariables{j, 1}, -1);
                        tauCone = ProgCone(1, self.slaves{i,1}.tauXYVariables{j, 1}, sqrt(6));
                        sigmaMaxCone = ProgCone(1, self.densityVariable, 2*sqrt(2)*self.sigmaMax);
                        yieldConicConstraint = self.yieldConstraints{yieldConstraintNum,1};

                        yieldConicConstraint.addRHSCone(sigmaMaxCone);
                        yieldConicConstraint.addLHSCone(sigmaXXCone);
                        yieldConicConstraint.addLHSCone(sigmaYYCone);
                        yieldConicConstraint.addLHSCone(sigmaXXminusSigmaYYCone);
                        yieldConicConstraint.addLHSCone(tauCone);
                    else
                        yieldConstraintNum = yieldConstraintNum + 1;
                        sigmaXXminusSigmaYYCone = ProgCone(2);
                        sigmaXXminusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaXXVariables{j, 1}, 0.5);
                        sigmaXXminusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaYYVariables{j, 1}, -0.5);
                        tauCone = ProgCone(1, self.slaves{i,1}.tauXYVariables{j, 1}, 1);
                        sigmaMaxCone = ProgCone(1, self.densityVariable, self.sigmaMax);
                        
                        yieldConicConstraint = self.yieldConstraints{yieldConstraintNum,1};
                        yieldConicConstraint.addRHSCone(sigmaMaxCone);
                        yieldConicConstraint.addLHSCone(sigmaXXminusSigmaYYCone);
                        yieldConicConstraint.addLHSCone(tauCone);
                        
                        sigmaXXplusSigmaYYCone = ProgCone(2);
                        sigmaXXplusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaXXVariables{j, 1}, 1);
                        sigmaXXplusSigmaYYCone.addVariable(self.slaves{i,1}.sigmaYYVariables{j, 1}, 1);
                        densityCone = ProgCone(1, self.densityVariable, 100);
                        nullTensorConstraint = self.nullTensorConstraints{yieldConstraintNum, 1};
                        nullTensorConstraint.addRHSCone(densityCone);
                        nullTensorConstraint.addLHSCone(sigmaXXplusSigmaYYCone);
                    end
                end
            end
            self.calcSlavesConstraints(matrix);
        end
        
        function calcObjective(self, matrix)
            matrix.objectiveFunction.addVariable(self.densityVariable, self.facet.area*self.densityCoefficient);
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

