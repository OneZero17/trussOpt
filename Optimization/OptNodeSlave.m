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
                self.equilibriumConstraintX = matrix.addConstraint(self.loadX,self.loadX, self.master.connectedMemberNum);
            else
                self.equilibriumConstraintX = -1;
            end
            
            if (self.fixedY == 0)
                self.equilibriumConstraintY = matrix.addConstraint(self.loadY,self.loadY, self.master.connectedMemberNum);
            else
                self.equilibriumConstraintY = -1;
            end
            obj = self;
        end
        
        function matrix = calcConstraint(matrix)
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 2;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

