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
            nodeA = self.optNodeA;
            nodeB = self.optNodeB;
            cosTheta = (nodeB.master.geoNode.x - nodeA.master.geoNode.x)/self.master.geoMember.length;
            sinTheta = (nodeB.master.geoNode.y - nodeA.master.geoNode.y)/self.master.geoMember.length;
            
            if (self.optNodeA.equilibriumConstraintX ~= -1)
                nodeA.equilibriumConstraintX.addVariable(self.forceVariable, cosTheta);
            end
            
            if (self.optNodeA.equilibriumConstraintY ~= -1)
                nodeA.equilibriumConstraintY.addVariable(self.forceVariable, sinTheta);
            end
            
            if (self.optNodeB.equilibriumConstraintX ~= -1)
                nodeB.equilibriumConstraintX.addVariable(self.forceVariable, -cosTheta);
            end
            
            if (self.optNodeB.equilibriumConstraintY ~= -1)
                nodeB.equilibriumConstraintY.addVariable(self.forceVariable, -sinTheta);
            end
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 0;
            varNum = 1;
            objVarNum = 0;
        end
    end
end

