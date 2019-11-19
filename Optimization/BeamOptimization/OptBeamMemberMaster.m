classdef OptBeamMemberMaster < OptObjectMaster

    properties
        sigma;
        geoMember;
        jointLength = 0;
        totalAreaVariable;
        totalAreaConstraints;
        preExistingBeamVolume = false;
    end
    
    methods
        function obj = OptBeamMemberMaster(geoMember, sigma, jointLength, preExistingBeamVolume)
            if nargin > 0
                obj.geoMember = geoMember;
            end
            if nargin > 1
                obj.sigma = sigma;
            end
            if nargin > 2
                obj.jointLength = jointLength;
            end
            if nargin > 3
                obj.preExistingBeamVolume = preExistingBeamVolume;
            end
        end
        
        function [matrix, obj] = initialize(self, matrix)
            self.totalAreaVariable = matrix.addVariable(0, inf);
            self.totalAreaConstraints = cell(size(self.slaves, 1), 1);
            for i = 1:size(self.slaves, 1)
                self.totalAreaConstraints{i, 1} = matrix.addConstraint(0, inf, 3, 'totalAreaConstraint');
            end
            self.initializeSlaves(matrix);
        end
        
        function calcConstraint(self, matrix)
            for i = 1:size(self.slaves, 1)
                currentSlave = self.slaves{i, 1};
                currentAreaConstraint = self.totalAreaConstraints{i, 1};
                currentAreaConstraint.addVariable(self.totalAreaVariable, 1);
                currentAreaConstraint.addVariable(currentSlave.forceAreaVariable, -1);
                if ~self.preExistingBeamVolume
                    currentAreaConstraint.addVariable(currentSlave.momentAreaVariable, -1);
                end
            end
            self.calcSlavesConstraints(matrix);
        end
        
        function calcObjective(self, matrix)
            memberVector = self.geoMember(5:6) - self.geoMember(3:4);
            memberLength = norm(memberVector);
            matrix.objectiveFunction.addVariable(self.totalAreaVariable, memberLength + 2*self.jointLength);
        end  
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = size(self.slaves, 1);
            varNum = 1;
            objVarNum = 1;
        end   
        
        function feedBackResult(self, loadCaseNum)
%             self.geoMember.area = self.areaVariable.value;
%             self.geoMember.force = self.slaves{loadCaseNum, 1}.forceVariable.value;
        end
    end
end

