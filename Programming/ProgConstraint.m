classdef ProgConstraint < handle
    properties
        name
        index
        variables
        coefficients
        type
        dualValue
        lowerBound
        upperBound
        variableNum = 0
    end
    
    methods
        function obj = ProgConstraint(lowerBoundary, upperBoundary, variableNum, name)
            if nargin > 0
                obj.lowerBound = lowerBoundary;
            end
            if nargin > 1
                obj.upperBound = upperBoundary;
            end
            if nargin > 2
                obj.variables=cell(variableNum, 1);
                obj.coefficients = zeros(variableNum, 1);
            end
            if nargin >3
                obj.name = name;
            end
        end
        
        function obj = addVariable(self, variable, coefficient)
            self.variableNum = self.variableNum+1;
            self.variables{self.variableNum , 1} = variable;
            self.coefficients(self.variableNum, 1) = coefficient;
            obj = self;
        end
        
        function obj = changeCoefficient(self, variable, coefficient)
            variableExist = 0;
            for i = 1:size(self.variables,1)
                if self.variables(i) == variable.index
                    self.coefficients(i) = coefficient;
                    variableExist = 1;
                end
            end
            obj = self;
            if variableExist == 0
                ME = MException('MyComponent:noSuchVariable','Variable [%s] not found',variable.index);
                throw(ME)
            end
        end
        
        % Currently only works for equilibrium constraint
        function addConstraintToRHS(self, constraint, coefficient)
            self.variables = [self.variables; constraint.variables];
            if nargin > 2
                self.coefficients = [self.coefficients; -1 *coefficient* constraint.coefficients];
            else
                self.coefficients = [self.coefficients; -1 * constraint.coefficients];
            end
            self.variableNum = self.variableNum + constraint.variableNum;
        end
        
    end
end

