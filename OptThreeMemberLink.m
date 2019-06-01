classdef OptThreeMemberLink < OptObject

    properties
        linkedMemberA
        linkedMemberB
        coefficientB
        linkedMemberC
        coefficientC
        linkConstraint
    end
    
    methods
        function obj = OptThreeMemberLink()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, self.linkConstraint] = matrix.addConstraint(0, inf, 3);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            % memberA area - coefficientB * memberB area  - coefficientC * memberC area = 0
            self.linkConstraint.addVariable(self.linkedMemberA.areaVariable, 1);
            self.linkConstraint.addVariable(self.linkedMemberB.areaVariable, -self.coefficientB);
            self.linkConstraint.addVariable(self.linkedMemberC.areaVariable, -self.coefficientC);
        end
        
        function [conNum, varNum] = getConAndVarNum(self)
            conNum = 1;
            varNum = 0;
        end
    end
end

