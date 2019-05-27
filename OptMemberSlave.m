classdef OptMemberSlave < OptObject
   
    properties
        optNodeA
        optNodeB
        geoMember
        forceVariable
    end
    
    methods
        function obj = OptMemberSlave()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, self.forceVariable] = matrix.addVariable(-inf,inf);
            obj = self;
        end
        
        function [matrix] = calculateConstraint(self, matrix)
            cosTheta = (self.optNodeB.geoNode.x - self.optNodeA.geoNode.x)/self.geoMember.length;
            sinTheta = (self.optNodeB.geoNode.y - self.optNodeA.geoNode.y)/self.geoMember.length;
            
            matrix.constraints(self.optNodeA.equilibriumConstraintX) = matrix.constraints(self.optNodeA.equilibriumConstraintX).addVariable(self.forceVariable, cosTheta);
            matrix.constraints(self.optNodeA.equilibriumConstraintY) = matrix.constraints(self.optNodeA.equilibriumConstraintY).addVariable(self.forceVariable, sinTheta);
            matrix.constraints(self.optNodeB.equilibriumConstraintX) = matrix.constraints(self.optNodeB.equilibriumConstraintX).addVariable(self.forceVariable, -cosTheta);
            matrix.constraints(self.optNodeB.equilibriumConstraintY) = matrix.constraints(self.optNodeB.equilibriumConstraintY).addVariable(self.forceVariable, -sinTheta);
        end
    end
end

