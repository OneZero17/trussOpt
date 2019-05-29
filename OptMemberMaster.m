classdef OptMemberMaster < OptObjectMaster
   
    properties
        sigma;
        geoMember;
        areaVariable;
        tensionStressConstraints;
        compressionStressConstraints
    end
    
    methods
        function obj = OptMemberMaster()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, self.areaVariable] = matrix.addVariable(0,inf);
            self.tensionStressConstraints = cell(size(self.slaves, 1), 1);
            self.compressionStressConstraints = cell(size(self.slaves, 1), 1);
            for i =1:size(self.slaves, 1)
                [matrix, stressConstraint] = matrix.addConstraint(0,inf, size(self.slaves, 1) +1);
                self.tensionStressConstraints{i, 1} = stressConstraint;
                [matrix, stressConstraint] = matrix.addConstraint(0,inf, size(self.slaves, 1) +1);
                self.compressionStressConstraints{i, 1} = stressConstraint;
            end
            self.initializeSlaves(matrix);
            obj = self;
        end
        
        function calcConstraint(self, matrix)
            for i =1:size(self.slaves, 1)
                self.tensionStressConstraints{i,1} = self.tensionStressConstraints{i,1}.addVariable(self.areaVariable, 1);
                self.tensionStressConstraints{i,1} = self.tensionStressConstraints{i,1}.addVariable(self.slaves{i, 1}.forceVariable, -1/self.sigma);
                self.compressionStressConstraints{i,1} = self.compressionStressConstraints{i,1}.addVariable(self.areaVariable, 1);
                self.compressionStressConstraints{i,1} = self.compressionStressConstraints{i,1}.addVariable(self.slaves{i, 1}.forceVariable, 1/self.sigma);
            end
            self.calcSlavesConstraints(matrix);
        end
        
        function calcObjective(self, matrix)
            matrix.objectiveFunction.addVariable(self.areaVariable, self.geoMember.length);
        end
        
        function [conNum, varNum] = getConAndVarNum(self)
            conNum = size(self.slaves, 1);
            varNum = 1;
        end
        
        function feedBackResult(self)
            self.geoMember.area = self.areaVariable.value;
        end
    end
end

