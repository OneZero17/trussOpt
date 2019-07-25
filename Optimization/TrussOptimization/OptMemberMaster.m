classdef OptMemberMaster < OptObjectMaster
   
    properties
        sigmaT;
        sigmaC;
        geoMember;
        areaVariable;
        tensionStressConstraints;
        compressionStressConstraints
    end
    
    methods
        function obj = OptMemberMaster(geoMember, sigmaT, sigmaC)
            if (nargin > 0)
                obj.geoMember = geoMember;
            end
            if (nargin > 1)
                obj.sigmaT = sigmaT;
            end
            if (nargin > 1)
                obj.sigmaC = sigmaC;
            end
        end
        
        function [matrix, obj] = initialize(self, matrix)
            self.areaVariable = matrix.addVariable(0,inf);
            self.tensionStressConstraints = cell(size(self.slaves, 1), 1);
            self.compressionStressConstraints = cell(size(self.slaves, 1), 1);
            for i =1:size(self.slaves, 1)
                stressConstraint = matrix.addConstraint(0,inf, size(self.slaves, 1) +1);
                self.tensionStressConstraints{i, 1} = stressConstraint;
                stressConstraint = matrix.addConstraint(0,inf, size(self.slaves, 1) +1);
                self.compressionStressConstraints{i, 1} = stressConstraint;
            end
            self.initializeSlaves(matrix);
            obj = self;
        end
        
        function calcConstraint(self, matrix)
            for i =1:size(self.slaves, 1)
                self.tensionStressConstraints{i,1}.addVariable(self.areaVariable, 1);
                self.tensionStressConstraints{i,1}.addVariable(self.slaves{i, 1}.forceVariable, -1/self.sigmaT);
                self.compressionStressConstraints{i,1}.addVariable(self.areaVariable, 1);
                self.compressionStressConstraints{i,1}.addVariable(self.slaves{i, 1}.forceVariable, 1/self.sigmaC);
            end
            self.calcSlavesConstraints(matrix);
        end
        
        function calcObjective(self, matrix)
            matrix.objectiveFunction.addVariable(self.areaVariable, self.geoMember.length);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = size(self.slaves, 1);
            varNum = 1;
            objVarNum = 1;
        end
        
        function feedBackResult(self, loadCaseNum)
            self.geoMember.area = self.areaVariable.value;
            self.geoMember.force = self.slaves{loadCaseNum, 1}.forceVariable.value;
        end
    end
end

