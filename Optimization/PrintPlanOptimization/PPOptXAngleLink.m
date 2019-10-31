classdef PPOptXAngleLink < OptObject    
    properties
        LinkedFacetA
        LinkedFacetB
        constant = 0
        linkConstraint
    end
    
    methods
        function obj = PPOptXAngleLink(LinkedFacetA, LinkedFacetB, constant)
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
            self.linkConstraint.addVariable(self.LinkedFacetA.xAngleVariable,  1);
            self.linkConstraint.addVariable(self.LinkedFacetB.xAngleVariable, -1);
        end
    end
end

