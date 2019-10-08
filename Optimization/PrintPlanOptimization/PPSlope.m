classdef PPSlope < OptObject    
    
    properties
        angles
        weights 
        angleVariable
        diffVariable1
        diffVariable2
        angleConstraint1
        angleConstraint2
    end
    
    methods
        function obj = PPSlope(inputAngles, inputWeights)
            if nargin > 0
                obj.angles = inputAngles;
            end
            if nargin > 1
                obj.weights = inputWeights;
            end
        end

        function [matrix, obj] = initialize(self, matrix)
            self.angleVariable = matrix.addVariable(0, pi);
            self.diffVariable1 = matrix.addVariable(0, inf);
            self.diffVariable2 = matrix.addVariable(0, inf);
            self.angleConstraint1 = matrix.addConicConstraint(size(self.angles, 1));
            self.angleConstraint2 = matrix.addConicConstraint(size(self.angles, 1));
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            memberNum = size(self.angles, 1);
            rhsCone1 = ProgCone(1, self.diffVariable1, 1);
            rhsCone2 = ProgCone(1, self.diffVariable2, 1);
            self.angleConstraint1.addRHSCone(rhsCone1);
            self.angleConstraint2.addRHSCone(rhsCone2);
            for i = 1 : memberNum
                lhsCone1 = ProgCone(1, self.angleVariable, self.weights(i));
                lhsCone1.addConstant(-(self.angles(i, 1) - 0.977)* self.weights(i));
                self.angleConstraint1.addLHSCone(lhsCone1);
                
                lhsCone2 = ProgCone(1, self.angleVariable, self.weights(i));
                lhsCone2.addConstant(-(self.angles(i, 1) + 0.977)* self.weights(i) );
                self.angleConstraint2.addLHSCone(lhsCone2);
            end   
        end
        
        function calcObjective(self, matrix)
            matrix.objectiveFunction.addVariable(self.diffVariable1, 1);
            matrix.objectiveFunction.addVariable(self.diffVariable2, 1);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 2;
            varNum = 3;
            objVarNum = 2;
        end
    end
end

