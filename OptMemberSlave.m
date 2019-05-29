classdef OptMemberSlave < OptObjectSlave
   
    properties
        optNodeA
        optNodeB
        forceVariable
    end
    
    methods
        function obj = OptMemberSlave()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, self.forceVariable] = matrix.addVariable(-inf,inf);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            cosTheta = (self.optNodeB.master.geoNode.x - self.optNodeA.master.geoNode.x)/self.master.geoMember.length;
            sinTheta = (self.optNodeB.master.geoNode.y - self.optNodeA.master.geoNode.y)/self.master.geoMember.length;
            
            if (self.optNodeA.equilibriumConstraintX ~= -1)
                self.optNodeA.equilibriumConstraintX = self.optNodeA.equilibriumConstraintX.addVariable(self.forceVariable, cosTheta);
                self.optNodeA.equilibriumConstraintY = self.optNodeA.equilibriumConstraintY.addVariable(self.forceVariable, sinTheta);
            end
            
            if (self.optNodeB.equilibriumConstraintX ~= -1)
                self.optNodeB.equilibriumConstraintX = self.optNodeB.equilibriumConstraintX.addVariable(self.forceVariable, -cosTheta);
                self.optNodeB.equilibriumConstraintY = self.optNodeB.equilibriumConstraintY.addVariable(self.forceVariable, -sinTheta);
            end
        end
        
        function [conNum, varNum] = getConAndVarNum(self)
            conNum = 0;
            varNum = 1;
        end
    end
end

