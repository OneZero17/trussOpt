classdef ProgMatrix < handle
    properties
        objectiveFunction
        constraints
        variables
        addConNum = 0;
        addVariableNum = 0;
    end
    
    methods
        function obj = ProgMatrix(conNum, varNum, objVarNum)
            obj.objectiveFunction = ProgConstraint();
            if nargin > 0
                obj.constraints = cell(conNum, 1);
            end
            if nargin > 1
                obj.variables = cell(varNum, 1);
            end
            if nargin > 2
                obj.objectiveFunction.variables = cell(objVarNum, 1);
                obj.objectiveFunction.coefficients = zeros(objVarNum, 1);
            end
        end
        
        function obj = feedBackResult(self, result)
            for i = 1:size(self.variables)
                self.variables{i, 1}.value = result(i);
            end
            obj = self;
        end
        
        function matrix = getJacobianObjective(self)
            matrix = zeros(size(self.variables, 1), 1);
            for i = 1:size(self.objectiveFunction.variables)
                matrix(self.objectiveFunction.variables{i,1}.index, 1) = self.objectiveFunction.coefficients(i);
            end
        end
                 
        function matrix = getJacobianConstraint(self)
            totalCoefficientNum = 0;
            for i = 1:size(self.constraints, 1)
                totalCoefficientNum = totalCoefficientNum + size(self.constraints{i, 1}.variables, 1);
            end
            matrix = zeros(totalCoefficientNum, 3);
            coefficientNum = 1;
            for i = 1:size(self.constraints, 1)
                currentConstraint = self.constraints{i, 1};
                for j = 1:size(currentConstraint.variables)
                    matrix(coefficientNum, 1) = currentConstraint.index;
                    matrix(coefficientNum, 2) = currentConstraint.variables{j,1}.index;
                    matrix(coefficientNum, 3) = currentConstraint.coefficients(j);
                    coefficientNum = coefficientNum+1;
                end
            end
            matrix = sparse(matrix(:,1), matrix(:,2), matrix(:,3));
        end
        
        function [obj, constraint] = addConstraint(self, lowerBound, upperBound, variableNum)
            if nargin > 2
                constraint = ProgConstraint(lowerBound, upperBound, variableNum);
            else
                constraint = ProgConstraint(); 
            end
    
            self.addConNum = self.addConNum+1;
            self.constraints{self.addConNum, 1} = constraint;
            obj = self;
        end
        
        function [obj, variable] = addVariable(self, lowerBound, upperBound)
            if nargin > 2
                variable = ProgVariable(lowerBound, upperBound);
            else
                variable = ProgVariable(); 
            end
            self.addVariableNum = self.addVariableNum+1;
            self.variables{self.addVariableNum, 1} = variable;
            obj = self;
        end
        
        function [obj, constraints, variables] = initialize(self)
            for i = 1:size(self.constraints)
                self.constraints{i,1}.index = i;
            end
            for i = 1:size(self.variables)
                self.variables{i,1}.index = i;
            end
            obj =self;
            constraints = self.constraints;
            variables = self.variables;
        end
        
        function matrix = getConstraintBoundary(self)
            matrix = zeros(size(self.constraints, 1), 2);
            for i = 1:size(self.constraints, 1)
                matrix(i,:) = [self.constraints{i,1}.lowerBound, self.constraints{i,1}.upperBound];
            end
        end
        
        function matrix = getVariableBoundary(self)
            matrix = zeros(size(self.variables, 1), 2);
            for i = 1:size(self.variables, 1)
                matrix(i,:) = [self.variables{i,1}.lowerBound, self.variables{i,1}.upperBound];
            end
        end  
        
        function deleteEmptyCells(self)
            totalConNum = size(self.constraints, 1);
            for i = self.addConNum+1:totalConNum
                self.constraints{i, 1} = [];
            end
            self.constraints = self.constraints(~cellfun('isempty',self.constraints));
            totalVarNum = size(self.variables, 1);
            for i = self.addVariableNum+1:totalVarNum
                self.variables{i, 1} = [];
            end     
            self.variables = self.variables(~cellfun('isempty',self.variables));
        end
    end
end

