classdef PPOptAngleLink < OptObject  
    
    properties
        LinkedSegmentA
        LinkedSegmentB
        rhsValue = 0
        linkConstraint
    end
    
    methods
        function obj = PPOptAngleLink(LinkedSegmentA, LinkedSegmentB, rhsValue)
            if nargin > 0
                obj.LinkedSegmentA = LinkedSegmentA;
            end
            if nargin > 1
                obj.LinkedSegmentB = LinkedSegmentB;
            end
            if nargin > 2
                obj.rhsValue = rhsValue;
            end            
        end
        
        function [matrix, obj]  = initialize(self, matrix)
            self.linkConstraint = matrix.addConstraint(-inf, self.rhsValue, 2);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            self.linkConstraint.addVariable(self.LinkedSegmentA.angleVariable,  1);
            self.linkConstraint.addVariable(self.LinkedSegmentB.angleVariable, -1);
        end
        
    end
end

