classdef OptMemberLink
    
    properties   
        linkedMemberA
        linkedMemberB
        coefficient
        linkConstraint
    end
    
    methods
        function obj = OptMemberLink()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, self.linkConstraint] = matrix.addConstraint(0,0);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            % memberA area - coefficient * memberB area = 0
            matrix.constraints(self.linkConstraint) = matrix.constraints(self.linkConstraint).addVariable(self.linkedMemberA, 1);
            matrix.constraints(self.linkConstraint) = matrix.constraints(self.linkConstraint).addVariable(self.linkedMemberB, -self.coefficient);
        end
    end
end

