classdef OptNodeSlave

    properties
        equilibriumConstraintX
        equilibriumConstraintY
    end
    
    methods
        function obj = OptNodeSlave()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, self.equilibriumConstraintX] = matrix.addConstraint(0,0);
            [matrix, self.equilibriumConstraintY] = matrix.addConstraint(0,0);
            obj = self;
        end
        
        function matrix = calcConstraint(matrix)
        end
    end
end

