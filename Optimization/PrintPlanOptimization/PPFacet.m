classdef PPFacet < OptObject
    
    properties
        angles
        weights 
        nozzleMaxAngle
        xAngleVariable
        yAngleVariable
        xDiffVariables1
        xDiffVariables2
        yDiffVariables1
        yDiffVariables2
        xAngleConstraints1
        xAngleConstraints2
        yAngleConstraints1
        yAngleConstraints2
        useCosAngleValue
        knownAngleValue = [];
    end
    
    methods
        function obj = PPFacet(inputAngles, inputWeights, nozzleMaxAngle, useCosAngleValue, knownAngleValue)
            if nargin > 0
                obj.angles = inputAngles;
            end
            if nargin > 1
                obj.weights = inputWeights;
            end
            if nargin > 2
                obj.nozzleMaxAngle = nozzleMaxAngle;
            end
            if nargin > 3
                obj.useCosAngleValue = useCosAngleValue;
            end
            if nargin > 4
                obj.knownAngleValue = knownAngleValue;
            end
        end
        
        function [matrix, obj] = initialize(self, matrix)
            memberNum = size(self.angles, 1);
            if self.useCosAngleValue
                self.xAngleVariable = matrix.addVariable(-0.96, 0.96);
                self.yAngleVariable = matrix.addVariable(-0.96, 0.96);
            elseif ~isempty(self.knownAngleValue)
                self.xAngleVariable = matrix.addVariable(self.knownAngleValue(1), self.knownAngleValue(1));
                self.yAngleVariable = matrix.addVariable(self.knownAngleValue(2), self.knownAngleValue(2));
            else
                self.xAngleVariable = matrix.addVariable(0, pi);
                self.yAngleVariable = matrix.addVariable(0, pi);
            end
            
            self.xDiffVariables1 = cell(memberNum, 1);
            self.xDiffVariables2 = cell(memberNum, 1);
            self.yDiffVariables1 = cell(memberNum, 1);
            self.yDiffVariables2 = cell(memberNum, 1);
            
            self.xAngleConstraints1 = cell(memberNum, 1);
            self.xAngleConstraints2 = cell(memberNum, 1);
            self.yAngleConstraints1 = cell(memberNum, 1);
            self.yAngleConstraints2 = cell(memberNum, 1);
            
            for i = 1:memberNum
                if ~isnan(self.angles(i, 1))
                    self.xDiffVariables1{i, 1} = matrix.addVariable(0, inf);
                    self.xDiffVariables2{i, 1} = matrix.addVariable(0, inf);
                    self.xAngleConstraints1{i, 1} = matrix.addConicConstraint(1);
                    self.xAngleConstraints2{i, 1} = matrix.addConicConstraint(1);
                end
                
                if ~isnan(self.angles(i, 2))
                    self.yDiffVariables1{i, 1} = matrix.addVariable(0, inf);
                    self.yDiffVariables2{i, 1} = matrix.addVariable(0, inf);  
                    self.yAngleConstraints1{i, 1} = matrix.addConicConstraint(1);
                    self.yAngleConstraints2{i, 1} = matrix.addConicConstraint(1);  
                end
            end
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            memberNum = size(self.angles, 1);
            for i = 1 : memberNum
                if ~isnan(self.angles(i, 1))
                    XrhsCone1 = ProgCone(1, self.xDiffVariables1{i, 1}, 1);
                    XlhsCone1 = ProgCone(1, self.xAngleVariable, self.weights(i));

                    XrhsCone2 = ProgCone(1, self.xDiffVariables2{i, 1}, 1);
                    XlhsCone2 = ProgCone(1, self.xAngleVariable, self.weights(i));
        
                    if self.useCosAngleValue
                        currentAngle = acos(self.angles(i, 1));
                        lowerBound = currentAngle - self.nozzleMaxAngle;
                        upperBound = currentAngle + self.nozzleMaxAngle;
                        
                        if lowerBound < 0
                            XlhsCone1.addConstant(-1 * self.weights(i));
                        else
                            XlhsCone1.addConstant(-cos(lowerBound) * self.weights(i));
                        end
                        if upperBound > pi
                            XlhsCone2.addConstant(1 * self.weights(i));
                        else
                            XlhsCone2.addConstant(-cos(upperBound) * self.weights(i));
                        end
                    else
                        XlhsCone1.addConstant(-(self.angles(i, 1) - self.nozzleMaxAngle)* self.weights(i));
                        XlhsCone2.addConstant(-(self.angles(i, 1) + self.nozzleMaxAngle)* self.weights(i));
                    end
                    
                    self.xAngleConstraints1{i, 1}.addRHSCone(XrhsCone1);
                    self.xAngleConstraints1{i, 1}.addLHSCone(XlhsCone1);
                    self.xAngleConstraints2{i, 1}.addRHSCone(XrhsCone2);
                    self.xAngleConstraints2{i, 1}.addLHSCone(XlhsCone2);
                end
                
                if ~isnan(self.angles(i, 2))
                    YrhsCone1 = ProgCone(1, self.yDiffVariables1{i, 1}, 1);
                    YlhsCone1 = ProgCone(1, self.yAngleVariable, self.weights(i));
                    YrhsCone2 = ProgCone(1, self.yDiffVariables2{i, 1}, 1);
                    YlhsCone2 = ProgCone(1, self.yAngleVariable, self.weights(i));
                    
                    if self.useCosAngleValue
                        currentAngle = acos(self.angles(i, 2));
                        lowerBound = currentAngle - self.nozzleMaxAngle;
                        upperBound = currentAngle + self.nozzleMaxAngle;
                        
                        if lowerBound < 0
                            YlhsCone1.addConstant(-1 * self.weights(i));
                        else
                            YlhsCone1.addConstant(-cos(lowerBound) * self.weights(i));
                        end
                        if upperBound > pi
                            YlhsCone2.addConstant(1 * self.weights(i));
                        else
                            YlhsCone2.addConstant(-cos(upperBound) * self.weights(i));
                        end
                    else
                        YlhsCone1.addConstant(-(self.angles(i, 2) - self.nozzleMaxAngle)* self.weights(i));
                        YlhsCone2.addConstant(-(self.angles(i, 2) + self.nozzleMaxAngle)* self.weights(i));
                    end
                    
                    self.yAngleConstraints1{i, 1}.addRHSCone(YrhsCone1);
                    self.yAngleConstraints1{i, 1}.addLHSCone(YlhsCone1);
                    self.yAngleConstraints2{i, 1}.addRHSCone(YrhsCone2);
                    self.yAngleConstraints2{i, 1}.addLHSCone(YlhsCone2);
                end
            end  
        end
        
       function calcObjective(self, matrix)
            memberNum = size(self.angles, 1);
            for i = 1 : memberNum
                if ~isnan(self.angles(i, 1))
                    matrix.objectiveFunction.addVariable(self.xDiffVariables1{i, 1}, 1);
                    matrix.objectiveFunction.addVariable(self.xDiffVariables2{i, 1}, 1);
                end
                if ~isnan(self.angles(i, 2))                                
                    matrix.objectiveFunction.addVariable(self.yDiffVariables1{i, 1}, 1);
                    matrix.objectiveFunction.addVariable(self.yDiffVariables2{i, 1}, 1);      
                end
            end
       end
        
       function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            memberNum = size(self.angles, 1);
            conNum = 4*memberNum;
            varNum = 4*memberNum + 2;
            objVarNum = 4*memberNum;
        end
        
    end
end

