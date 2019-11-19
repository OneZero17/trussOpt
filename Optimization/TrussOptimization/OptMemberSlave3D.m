classdef OptMemberSlave3D < OptObjectSlave
    
    properties
        optNodeA
        optNodeB
        forceVariable
    end
    
    methods
        function obj = OptMemberSlave()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            self.forceVariable = matrix.addVariable(-inf,inf);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            nodeA = self.optNodeA;
            nodeB = self.optNodeB;
            memberVector = nodeB.master.geoNode - nodeA.master.geoNode;
            memberVectorNorm = memberVector / norm(memberVector);
            
            xComponent = dot(memberVectorNorm, [1, 0, 0]);
            yComponent = dot(memberVectorNorm, [0, 1, 0]);
            zComponent = dot(memberVectorNorm, [0, 0, 1]);

            if (self.optNodeA.equilibriumConstraintX ~= -1)
                nodeA.equilibriumConstraintX.addVariable(self.forceVariable, xComponent);
            end
            
            if (self.optNodeA.equilibriumConstraintY ~= -1)
                nodeA.equilibriumConstraintY.addVariable(self.forceVariable, yComponent);
            end
            
            if (self.optNodeA.equilibriumConstraintZ ~= -1)
                nodeA.equilibriumConstraintZ.addVariable(self.forceVariable, zComponent);
            end
            
            if (self.optNodeB.equilibriumConstraintX ~= -1)
                nodeB.equilibriumConstraintX.addVariable(self.forceVariable, -xComponent);
            end
            
            if (self.optNodeB.equilibriumConstraintY ~= -1)
                nodeB.equilibriumConstraintY.addVariable(self.forceVariable, -yComponent);
            end
            
            if (self.optNodeB.equilibriumConstraintZ ~= -1)
                nodeB.equilibriumConstraintZ.addVariable(self.forceVariable, -zComponent);
            end
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 0;
            varNum = 1;
            objVarNum = 0;
        end
    end
end

