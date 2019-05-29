classdef OptNodeSlave < OptObjectSlave

    properties
        equilibriumConstraintX
        equilibriumConstraintY
        loadX = 0
        loadY = 0
        fixedX = 0
        fixedY = 0
    end
    
    methods
        function obj = OptNodeSlave()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            if (self.fixedX == 0)
                [matrix, self.equilibriumConstraintX] = matrix.addConstraint(self.loadX,self.loadX);
            else
                self.equilibriumConstraintX = -1;
            end
            
            if (self.fixedY == 0)
                [matrix, self.equilibriumConstraintY] = matrix.addConstraint(self.loadY,self.loadY);
            else
                self.equilibriumConstraintY = -1;
            end
            obj = self;
        end
        
        function matrix = calcConstraint(matrix)
        end
        
        function [conNum, varNum] = getConAndVarNum(self)
            conNum = 2;
            varNum = 0;
        end
    end
end

