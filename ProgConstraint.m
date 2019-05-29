classdef ProgConstraint < handle
    properties
        index
        variableIndices
        coefficients
        type
        dualValue
        lowerBound
        upperBound
    end
    
    methods
        function obj = ProgConstraint(lowerBoundary, upperBoundary)
            if nargin > 0
                obj.lowerBound = lowerBoundary;
            end
            if nargin > 1
                obj.upperBound = upperBoundary;
            end
        end
        
        function obj = addVariable(self, variable, coefficient)
            %% TO DO
            self.variableIndices =[self.variableIndices; variable];
            self.coefficients = [self.coefficients; coefficient];
            obj = self;
        end
        
        function obj = changeCoefficient(self, variable, coefficient)
            variableExist = 0;
            for i = 1:size(self.variableIndices,1)
                if self.variableIndices(i) == variable.index
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
    end
end

