classdef OptBeamNodeSlave < OptObjectSlave
    properties
        forceEquilibriumConstraintX
        forceEquilibriumConstraintY
        momentConstraint
        loadX = 0
        loadY = 0
        loadMoment = 0
        fixedX = 0
        fixedY = 0
        fixedMoment = 0
    end
    
    methods
        function obj = OptBeamNodeSlave()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            if (self.fixedX == 0)
                self.forceEquilibriumConstraintX = matrix.addConstraint(self.loadX, self.loadX, self.master.connectedMemberNum, 'equilibriumConstraintX');
            else
                self.forceEquilibriumConstraintX = -1;
            end
            
            if (self.fixedY == 0)
                self.forceEquilibriumConstraintY = matrix.addConstraint(self.loadY, self.loadY, self.master.connectedMemberNum, 'equilibriumConstraintY');
            else
                self.forceEquilibriumConstraintY = -1;
            end
            
            if (self.fixedMoment == 0)
                self.momentConstraint = matrix.addConstraint(self.fixedMoment, self.fixedMoment, self.master.connectedMemberNum, 'equilibriumConstraintMoment');
            else
                self.momentConstraint = -1;
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

