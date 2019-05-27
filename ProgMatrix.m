classdef ProgMatrix  
    properties
        objectiveFunction
        constraints
        variables
    end
    
    methods
        function obj = ProgMatrix()

        end
        
        function matrix = getJacobian(self, type)
            matrix = zeros(size(self.constraints, 1)*size(self.variables, 1), 3);
            coefficientNum = 1;
            for i = 1:size(self.constraints, 1)
                currentConstraint = self.constraints(i);
                if (type == ProgConstraintType.objectiveFunction)
                    currentConstraint = self.objectiveFunction;
                end
                
                for j = 1:size(currentConstraint.variableIndices)
                    if (type == ProgConstraintType.objectiveFunction)
                        matrix(coefficientNum, 1) = 1;
                    else
                        matrix(coefficientNum, 1) = currentConstraint.index;
                    end
                    matrix(coefficientNum, 2) = currentConstraint.variableIndices(j);
                    matrix(coefficientNum, 3) = currentConstraint.coefficients(j);
                    coefficientNum = coefficientNum+1;
                end
                
                if (type == ProgConstraintType.objectiveFunction)
                    break;  
                end
            end
            matrix(coefficientNum:end,:)=[];
            matrix = sparse(matrix(:,1), matrix(:,2), matrix(:,3));
        end
        
        function [obj, index] = addConstraint(self, lowerBound, upperBound)
            if nargin > 2
                newConstraint = progConstraint(lowerBound, upperBound);
            else
                 newConstraint = progConstraint(); 
            end
            index = size(self.constraints)+1;
            newConstraint.index = index;
            self.constraints = [self.constraints; newConstraint];
            obj = self;
        end
        
        function [obj, index] = addVariable(self, lowerBound, upperBound)
            if nargin > 2
                newVariable = progVariable(lowerBound, upperBound);
            else
                newVariable = progVariable(); 
            end
            index = size(self.variables)+1;
            newVariable.index = index;
            self.variables = [self.variables; newVariable];
            obj = self;
        end
        
        function [obj, constraints, variables] = initialize(self)
            for i = 1:size(self.constraints)
                self.constraints(i).index = i;
            end
            for i = 1:size(self.variables)
                self.variables(i).index = i;
            end
            obj =self;
            constraints = self.constraints;
            variables = self.variables;
        end
        
        function matrix = getConstraintBoundary(self)
            matrix = zeros(size(self.constraints, 1), 2);
            for i = 1:size(self.constraints, 1)
                matrix(i,:) = [self.constraints(i).lowerBound, self.constraints(i).upperBound];
            end
        end
        
        function matrix = getVariableBoundary(self)
            matrix = zeros(size(self.variables, 1), 2);
            for i = 1:size(self.variables, 1)
                matrix(i,:) = [self.variables(i).lowerBound, self.variables(i).upperBound];
            end
        end  
    end
end

