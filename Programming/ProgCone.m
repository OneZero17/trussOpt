classdef ProgCone < handle
    
    properties
        variables
        coefficients
        constant = 0
        variableNum = 0
    end
    
    methods
        function obj = ProgCone(variableNum, variable, coefficient)
            if (nargin > 0)
                obj.variables = cell(variableNum, 1);
                obj.coefficients = zeros(variableNum);
            end
            if (nargin == 2)
                obj.addVariable(variable, 1);
            end
            if (nargin == 3)
                obj.addVariable(variable, coefficient);
            end
        end
        
        function addVariable(self, variable, coefficient)
            self.variableNum = self.variableNum + 1;
            self.variables{self.variableNum, 1} = variable;
            self.coefficients(self.variableNum, 1) = coefficient;
        end
        
        function addConstant(self, constant)
            self.constant = constant;
        end
    end
end

