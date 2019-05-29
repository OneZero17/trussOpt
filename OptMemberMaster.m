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
                matrix.constraints{self.tensionStressConstraints(i), 1} = matrix.constraints{self.tensionStressConstraints(i), 1}.addVariable(self.areaVariable, 1);
                matrix.constraints{self.tensionStressConstraints(i), 1} = matrix.constraints{self.tensionStressConstraints(i), 1}.addVariable(self.slaves{i, 1}.forceVariable, -1/self.sigma);
                matrix.constraints{self.compressionStressConstraints(i), 1} = matrix.constraints{self.compressionStressConstraints(i), 1}.addVariable(self.areaVariable, 1);
                matrix.constraints{self.compressionStressConstraints(i), 1} = matrix.constraints{self.compressionStressConstraints(i), 1}.addVariable(self.slaves{i, 1}.forceVariable, 1/self.sigma);

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
    end
end

