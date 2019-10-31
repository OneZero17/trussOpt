classdef PPSlope < OptObject    
    
    properties
        angles
        weights 
        angleVariable
        diffVariables1
        diffVariables2
        angleConstraints1
        angleConstraints2
        nozzleMaxAngle
    end
    
    methods
        function obj = PPSlope(inputAngles, inputWeights, nozzleMaxAngle)
            if nargin > 0
                obj.angles = inputAngles;
            end
            if nargin > 1
                obj.weights = inputWeights;
            end
            if nargin > 2
                obj.nozzleMaxAngle = nozzleMaxAngle;
            end
            
        end

        function [matrix, obj] = initialize(self, matrix)
            memberNum = size(self.angles, 1);
            self.angleVariable = matrix.addVariable(0, pi);
            self.diffVariables1 = cell(memberNum, 1);
            self.diffVariables2 = cell(memberNum, 1);
            self.angleConstraints1 = cell(memberNum, 1);
            self.angleConstraints2 = cell(memberNum, 1);
            
            for i = 1:memberNum
                self.diffVariables1{i, 1} = matrix.addVariable(0, inf);
                self.diffVariables2{i, 1} = matrix.addVariable(0, inf);
                self.angleConstraints1{i, 1} = matrix.addConicConstraint(1);
                self.angleConstraints2{i, 1} = matrix.addConicConstraint(1);
            end
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            memberNum = size(self.angles, 1);
            for i = 1 : memberNum
                rhsCone1 = ProgCone(1, self.diffVariables1{i, 1}, 1);
                lhsCone1 = ProgCone(1, self.angleVariable, self.weights(i));
                lhsCone1.addConstant(-(self.angles(i, 1) - self.nozzleMaxAngle)* self.weights(i));
                self.angleConstraints1{i, 1}.addRHSCone(rhsCone1);
                self.angleConstraints1{i, 1}.addLHSCone(lhsCone1);
                
                rhsCone2 = ProgCone(1, self.diffVariables2{i, 1}, 1);
                lhsCone2 = ProgCone(1, self.angleVariable, self.weights(i));
                lhsCone2.addConstant(-(self.angles(i, 1) + self.nozzleMaxAngle)* self.weights(i));
                self.angleConstraints2{i, 1}.addLHSCone(lhsCone2);
                self.angleConstraints2{i, 1}.addRHSCone(rhsCone2);
            end  
        end
        
        function calcObjective(self, matrix)
            memberNum = size(self.angles, 1);
            for i = 1 : memberNum
                matrix.objectiveFunction.addVariable(self.diffVariables1{i, 1}, 1);
                matrix.objectiveFunction.addVariable(self.diffVariables2{i, 1}, 1);
            end
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            memberNum = size(self.angles, 1);
            conNum = 2*memberNum;
            varNum = 2*memberNum + 1;
            objVarNum = 2*memberNum;
        end
    end
end

