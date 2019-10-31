classdef PPOptYAngleLink < OptObject    
    properties
        LinkedFacetA
        LinkedFacetB
        constant = 0
        linkConstraint
    end
    
    methods
        function obj = PPOptYAngleLink(LinkedFacetA, LinkedFacetB, constant)
            if nargin > 0 
                obj.LinkedFacetA = LinkedFacetA;
            end    
            if nargin > 1 
                obj.LinkedFacetB = LinkedFacetB;
            end
            if nargin > 2
                obj.constant = constant;
            end
        end
        
        function [matrix, obj] = initialize(self, matrix)
            self.linkConstraint = matrix.addConstraint(self.constant, self.constant, 2);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            % facetA x angle - facetB x angle = constant
            self.linkConstraint.addVariable(self.LinkedFacetA.yAngleVariable,  1);
            self.linkConstraint.addVariable(self.LinkedFacetB.yAngleVariable, -1);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 1;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

