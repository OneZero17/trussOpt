classdef OptNodeSlave3D < OptObjectSlave

    properties
        equilibriumConstraintX
        equilibriumConstraintY
        equilibriumConstraintZ
        loadX = 0
        loadY = 0
        loadZ = 0
        fixedX = 0
        fixedY = 0
        fixedZ = 0
    end
    
    methods
        function obj = OptNodeSlave()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            if (self.fixedX == 0)
                self.equilibriumConstraintX = matrix.addConstraint(self.loadX, self.loadX, self.master.connectedMemberNum, 'equilibriumConstraintX');
            else
                self.equilibriumConstraintX = -1;
            end
            
            if (self.fixedY == 0)
                self.equilibriumConstraintY = matrix.addConstraint(self.loadY, self.loadY, self.master.connectedMemberNum, 'equilibriumConstraintY');
            else
                self.equilibriumConstraintY = -1;
            end
            
            if (self.fixedZ == 0)
                self.equilibriumConstraintZ = matrix.addConstraint(self.loadZ, self.loadZ, self.master.connectedMemberNum, 'equilibriumConstraintZ');
            else
                self.equilibriumConstraintZ = -1;
            end
            obj = self;
        end
        
        function matrix = calcConstraint(matrix)
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 3;
            varNum = 0;
            objVarNum = 0;
        end
    end
end
