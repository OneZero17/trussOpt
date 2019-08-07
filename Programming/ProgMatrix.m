classdef ProgMatrix < handle
    properties
        objectiveFunction
        constraints
        variables
        conicConstraints
        addConNum = 0;
        addVariableNum = 0;
        addConicConNum = 0;
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
                for j = 1:currentConstraint.variableNum
                    if (abs(currentConstraint.coefficients(j))>1e-6)
                        matrix(coefficientNum, 1) = currentConstraint.index;
                        matrix(coefficientNum, 2) = currentConstraint.variables{j,1}.index;
                        matrix(coefficientNum, 3) = currentConstraint.coefficients(j);
                        coefficientNum = coefficientNum+1;
                    end
                end
            end
            matrix (matrix(:, 1)==0, :) = [];
            matrix = sparse(matrix(:,1), matrix(:,2), matrix(:,3));
        end
        
        function [coefficients, constants, coneNumbers] = getCoefficientOfConicConstraints(self)
            coneConstraintNum = size(self.conicConstraints, 1);
            totalVariableNum = 0;
            totalConeNum = 0;
            for i = 1:coneConstraintNum
                totalVariableNum = totalVariableNum + self.conicConstraints{i, 1}.getVariableNum();
                totalConeNum = totalConeNum + size(self.conicConstraints{i, 1}.lhsCones, 1) + 1;
            end
            coefficients = zeros(totalVariableNum, 3);
            constants = zeros(totalConeNum, 1);
            coefficientNum = 0;
            coneNumbers = zeros(coneConstraintNum, 1); 
            coneNum = 0;
            for i = 1:coneConstraintNum
                coefficientNum = coefficientNum +1;
                currentConstraint = self.conicConstraints{i, 1};
                coneNumbers(i, 1) = currentConstraint.lhsConeNum + 1;
                % add rhs 
                coneNum = coneNum +1;
                coefficients(coefficientNum, :)=[coneNum, currentConstraint.rhsCone.variables{1, 1}.index, currentConstraint.rhsCone.coefficients(1, 1)];
                constants(coneNum, :) = currentConstraint.rhsCone.constant;
                % add lhs
                for j = 1:size(currentConstraint.lhsCones, 1)
                    currentCone = currentConstraint.lhsCones{j, 1};
                    coneNum = coneNum +1;
                    constants(coneNum, :) = currentCone.constant;
                    for k = 1:size(currentCone.variables)
                        currentVariable = currentCone.variables{k, 1};
                        coefficientNum = coefficientNum + 1;
                        coefficients(coefficientNum, :) = [coneNum, currentVariable.index, currentCone.coefficients(k, 1)];
                    end
                end
            end
            coefficients = sparse(coefficients(:,1), coefficients(:,2), coefficients(:,3));
        end
        
        function constraint = addConstraint(self, lowerBound, upperBound, variableNum, name)
            if nargin == 4
                constraint = ProgConstraint(lowerBound, upperBound, variableNum);
            elseif nargin == 5
                constraint = ProgConstraint(lowerBound, upperBound, variableNum, name);
            else
                constraint = ProgConstraint(); 
            end
    
            self.addConNum = self.addConNum+1;
            self.constraints{self.addConNum, 1} = constraint;
        end

        % Creat a variable equals variable1 minus variable2
        function variable = variable1MinusVariable2(self, variable1, variable2)
            constraint = self.addConstraint(0, 0, 3);
            variable = self.addVariable(-inf, inf);
            constraint.addVariable(variable1, 1);
            constraint.addVariable(variable2, -1);
            constraint.addVariable(variable, -1);
        end
        
        % Create a variable equals coefficient times inputVariable
        function variable = coefficientTimesVariable(self, inputVariable, coefficient)
            constraint = self.addConstraint(0, 0, 2);
            variable = self.addVariable(-inf, inf);
            constraint.addVariable(inputVariable, coefficient);
            constraint.addVariable(variable, -1);
        end
        
        function constraint = addConicConstraint(self, variableNum)
            if nargin > 1
                constraint = ProgConicConstraint(variableNum);
            else
                constraint = ProgConstraint(); 
            end
            
            self.addConicConNum = self.addConicConNum + 1;
            self.conicConstraints{self.addConicConNum, 1} = constraint;
        end
        
        function variable = addVariable(self, lowerBound, upperBound, name)
            if nargin ==3
                variable = ProgVariable(lowerBound, upperBound);
            elseif nargin ==4
                variable = ProgVariable(lowerBound, upperBound, name);
            else
                variable = ProgVariable(); 
            end
            self.addVariableNum = self.addVariableNum+1;
            self.variables{self.addVariableNum, 1} = variable;
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

