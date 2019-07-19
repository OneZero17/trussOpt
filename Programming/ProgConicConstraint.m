classdef ProgConicConstraint < handle
   
    properties
        rhsCone
        lhsCones
        lhsConeNum = 0;
    end
    
    methods
        function obj = ProgConicConstraint(lhsConeNum)
            if nargin > 0
                obj.lhsCones = cell(lhsConeNum, 1);
            end
        end
        
        function addRHSCone(self, cone)
            self.rhsCone = cone;     
        end
        
        function addLHSCone(self, cone)
            self.lhsConeNum = self.lhsConeNum + 1;
            self.lhsCones{self.lhsConeNum, 1} = cone;
        end
        
        function variableNum = getVariableNum(self)
            variableNum = 0;
            for i = 1:size(self.lhsCones, 1)
                variableNum = variableNum + self.lhsCones{i, 1}.variableNum;
            end
            variableNum = variableNum + self.rhsCone.variableNum;
        end
    end
end

