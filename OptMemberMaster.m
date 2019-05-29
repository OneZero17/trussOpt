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
            for i =1:size(self.slaves, 1)
                %% TO DO
                [matrix, stressConstraint] = matrix.addConstraint(0,inf);
                self.tensionStressConstraints = [self.tensionStressConstraints; stressConstraint];
                [matrix, stressConstraint] = matrix.addConstraint(0,inf);
                self.compressionStressConstraints = [self.compressionStressConstraints; stressConstraint];
            end
            [matrix, self] = self.initializeSlaves(matrix);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            for i =1:size(self.slaves, 1)
                self.tensionStressConstraints(i) = self.tensionStressConstraints(i).addVariable(self.areaVariable, 1);
                self.tensionStressConstraints(i) = self.tensionStressConstraints(i).addVariable(self.slaves{i, 1}.forceVariable, -1/self.sigma);
                self.compressionStressConstraints(i) = self.compressionStressConstraints(i).addVariable(self.areaVariable, 1);
                self.compressionStressConstraints(i) = self.compressionStressConstraints(i).addVariable(self.slaves{i, 1}.forceVariable, 1/self.sigma);
            end
            matrix = self.calcSlavesConstraints(matrix);
        end
        
        function matrix = calcObjective(self, matrix)
            matrix.objectiveFunction = matrix.objectiveFunction.addVariable(self.areaVariable, self.geoMember.length);
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

