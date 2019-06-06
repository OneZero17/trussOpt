classdef OptMemberLink < OptObject
    
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
            [matrix, self.linkConstraint] = matrix.addConstraint(0, 0, 2);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            % memberA area - coefficient * memberB area = 0
            self.linkConstraint.addVariable(self.linkedMemberA.areaVariable, 1);
            self.linkConstraint.addVariable(self.linkedMemberB.areaVariable, -self.coefficient);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 1;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

