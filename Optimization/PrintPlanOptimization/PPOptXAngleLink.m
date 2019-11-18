classdef PPOptXAngleLink < OptObject    
    properties
        LinkedFacetA
        LinkedFacetB
        constant = 0
        linkConstraint
        % type 0 A+B=c type 1 A+V<=C
        type = 0
    end
    
    methods
        function obj = PPOptXAngleLink(LinkedFacetA, LinkedFacetB, constant, type)
            if nargin > 0 
                obj.LinkedFacetA = LinkedFacetA;
            end    
            if nargin > 1 
                obj.LinkedFacetB = LinkedFacetB;
            end
            if nargin > 2
                obj.constant = constant;
            end
            if nargin > 3
                obj.type = type;
            end
        end
        
        function [matrix, obj] = initialize(self, matrix)
            if self.type == 0
                self.linkConstraint = matrix.addConstraint(self.constant, self.constant, 2);
            elseif self.type == 1
                self.linkConstraint = matrix.addConstraint(-inf, self.constant, 2);               
            end
            
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            % facetA x angle - facetB x angle = constant
            self.linkConstraint.addVariable(self.LinkedFacetA.xAngleVariable,  1);
            self.linkConstraint.addVariable(self.LinkedFacetB.xAngleVariable, -1);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 1;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

