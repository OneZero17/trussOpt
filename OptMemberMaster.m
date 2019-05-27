classdef OptMemberMaster < OptObjectMaster
   
    properties
        sigma;
        areaVariable;
        stressConstraints;
    end
    
    methods
        function obj = OptMemberMaster()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, self.areaVariable] = matrix.addVariable(0,inf);
            for i =1:size(slaves)
                [matrix, stressConstraint] = matrix.addConstraint(0,inf);
                self.stressConstraints = [self.stressConstraints; stressConstraint];
            end
            [matrix, self] = self.initializeSlaves(matrix);
            obj = self;
        end
        
        function [matrix] = calculateConstraint(self, matrix)
            for i =1:size(slaves)
                matrix.constraints(self.stressConstraints(i)) = matrix.constraints(self.stressConstraints(i)).addVariable(self.areaVariable, 1);
                matrix.constraints(self.stressConstraints(i)) = matrix.constraints(self.stressConstraints(i)).addVariable(slaves(i).forceVariable, -1/self.sigma);
            end
        end
    end
end

