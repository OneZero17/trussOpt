classdef OptBeamMemberSlave < OptObjectSlave    
    
   properties
        optNodeA
        optNodeB
        sectionModulus;
        forceAreaVariable
        momentAreaVariable
        forceVariable
        momentVariableA
        momentVariableB
        forceAreaConstraint
        momentAreaConstraintA1
        momentAreaConstraintA2
        momentAreaConstraintB1
        momentAreaConstraintB2
    end
    
    methods
        function obj = OptBeamMemberSlave(sectionModulus)
            if nargin > 0
                obj.sectionModulus = sectionModulus;
            end
        end
        
        function [matrix, obj] = initialize(self, matrix)
            self.forceAreaVariable = matrix.addVariable(0, inf);
            self.momentAreaVariable = matrix.addVariable(0, inf);
            self.forceVariable = matrix.addVariable(-inf, inf);
            self.momentVariableA = matrix.addVariable(-inf, inf);
            self.momentVariableB = matrix.addVariable(-inf, inf);
            self.forceAreaConstraint = matrix.addConicConstraint(2);
            self.momentAreaConstraintA1 = matrix.addConstraint( -self.sectionModulus(1) * self.master.sigma, inf, 3);
            self.momentAreaConstraintA2 = matrix.addConstraint( -self.sectionModulus(1) * self.master.sigma, inf, 3);
            self.momentAreaConstraintB1 = matrix.addConstraint( -self.sectionModulus(1) * self.master.sigma, inf, 3);
            self.momentAreaConstraintB2 = matrix.addConstraint( -self.sectionModulus(1) * self.master.sigma, inf, 3);
            obj = self;
        end
        
        function [matrix] = calcConstraint(self, matrix)
            %% Equilibrium Constraint
            nodeA = self.optNodeA;
            nodeB = self.optNodeB;
            memberVector = nodeB.master.geoNode - nodeA.master.geoNode;
            memberLength = norm(memberVector);
            cosTheta = (nodeB.master.geoNode(1) - nodeA.master.geoNode(1))/memberLength;
            sinTheta = (nodeB.master.geoNode(2) - nodeA.master.geoNode(2))/memberLength;
            
            if (nodeA.forceEquilibriumConstraintX ~= -1)
                nodeA.forceEquilibriumConstraintX.addVariable(self.forceVariable, cosTheta);
                nodeA.forceEquilibriumConstraintX.addVariable(self.momentVariableA, sinTheta / memberLength);
                nodeA.forceEquilibriumConstraintX.addVariable(self.momentVariableB, sinTheta / memberLength);
            end
            
            if (nodeA.forceEquilibriumConstraintY ~= -1)
                nodeA.forceEquilibriumConstraintY.addVariable(self.forceVariable, sinTheta);
                nodeA.forceEquilibriumConstraintY.addVariable(self.momentVariableA, -cosTheta / memberLength);
                nodeA.forceEquilibriumConstraintY.addVariable(self.momentVariableB, -cosTheta / memberLength);                
            end
            
            if (nodeA.momentConstraint ~= -1)
                nodeA.momentConstraint.addVariable(self.momentVariableA, 1);
            end
            
            if (nodeB.forceEquilibriumConstraintX ~= -1)
                nodeB.forceEquilibriumConstraintX.addVariable(self.forceVariable, -cosTheta);
                nodeB.forceEquilibriumConstraintX.addVariable(self.momentVariableA, -sinTheta / memberLength);
                nodeB.forceEquilibriumConstraintX.addVariable(self.momentVariableB, -sinTheta / memberLength);                
            end
            
            if (nodeB.forceEquilibriumConstraintY ~= -1)
                nodeB.forceEquilibriumConstraintY.addVariable(self.forceVariable, -sinTheta);
                nodeB.forceEquilibriumConstraintY.addVariable(self.momentVariableA, cosTheta / memberLength);
                nodeB.forceEquilibriumConstraintY.addVariable(self.momentVariableB, cosTheta / memberLength);     
            end
            
            if (nodeB.momentConstraint ~= -1)
                nodeB.momentConstraint.addVariable(self.momentVariableB, 1);
            end
            
            %% Stress Constraint
            % an^2 >= q^2 + 3*(ma/l + mb/l)^2
            forceAreaCone = ProgCone(1, self.forceAreaVariable, self.master.sigma);
            axialForceCone = ProgCone(1, self.forceVariable, 1);
            shearForceCone = ProgCone(2);
            shearForceCone.addVariable(self.momentVariableA, sqrt(3) / memberLength);
            shearForceCone.addVariable(self.momentVariableB, sqrt(3) / memberLength);
            self.forceAreaConstraint.addRHSCone(forceAreaCone);
            self.forceAreaConstraint.addLHSCone(axialForceCone);
            self.forceAreaConstraint.addLHSCone(shearForceCone);
            
            % z1*an+z2*am - m >=0
            self.momentAreaConstraintA1.addVariable(self.forceAreaVariable, self.sectionModulus(2) * self.master.sigma);
            self.momentAreaConstraintA1.addVariable(self.momentAreaVariable, self.sectionModulus(3) * self.master.sigma);
            self.momentAreaConstraintA1.addVariable(self.momentVariableA, 1);
            
            self.momentAreaConstraintA2.addVariable(self.forceAreaVariable, self.sectionModulus(2) * self.master.sigma);
            self.momentAreaConstraintA2.addVariable(self.momentAreaVariable, self.sectionModulus(3) * self.master.sigma);
            self.momentAreaConstraintA2.addVariable(self.momentVariableA, -1);
            
            self.momentAreaConstraintB1.addVariable(self.forceAreaVariable, self.sectionModulus(2) * self.master.sigma);
            self.momentAreaConstraintB1.addVariable(self.momentAreaVariable, self.sectionModulus(3) * self.master.sigma);
            self.momentAreaConstraintB1.addVariable(self.momentVariableB, 1);
            
            self.momentAreaConstraintB2.addVariable(self.forceAreaVariable, self.sectionModulus(2) * self.master.sigma);
            self.momentAreaConstraintB2.addVariable(self.momentAreaVariable, self.sectionModulus(3) * self.master.sigma);
            self.momentAreaConstraintB2.addVariable(self.momentVariableB, -1);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 5;
            varNum = 3;
            objVarNum = 0;
        end        
    end
end

