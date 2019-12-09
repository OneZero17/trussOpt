classdef OptMemberMaster3D < OptObjectMaster

    properties
        sigmaT;
        sigmaC;
        geoMember;
        jointLength = 0;
        areaVariable;
        tensionStressConstraints;
        compressionStressConstraints;
        penalty = 0;
    end
    
    methods
        function obj = OptMemberMaster3D(geoMember, sigmaT, sigmaC, jointLength, penalty)
            if nargin > 0
                obj.geoMember = geoMember;
            end
            if nargin > 1
                obj.sigmaT = sigmaT;
            end
            if nargin > 2
                obj.sigmaC = sigmaC;
            end
            if nargin > 3
                obj.jointLength = jointLength;
            end
            if nargin > 4
                obj.penalty = penalty;
            end
        end
        
        function [matrix, obj] = initialize(self, matrix)
            self.areaVariable = matrix.addVariable(0, inf);
            self.tensionStressConstraints = cell(size(self.slaves, 1), 1);
            self.compressionStressConstraints = cell(size(self.slaves, 1), 1);
            for i =1:size(self.slaves, 1)
                stressConstraint = matrix.addConstraint(0,inf, size(self.slaves, 1) +1, 'tensionStressConstraint');
                self.tensionStressConstraints{i, 1} = stressConstraint;
                stressConstraint = matrix.addConstraint(0,inf, size(self.slaves, 1) +1, 'compressionStressConstraints');
                self.compressionStressConstraints{i, 1} = stressConstraint;
            end
            self.initializeSlaves(matrix);
            obj = self;
        end
        
        function calcConstraint(self, matrix)
            for i =1:size(self.slaves, 1)
                self.tensionStressConstraints{i,1}.addVariable(self.areaVariable, 1);
                self.tensionStressConstraints{i,1}.addVariable(self.slaves{i, 1}.forceVariable, -1/self.sigmaT);
                self.compressionStressConstraints{i,1}.addVariable(self.areaVariable, 1);
                self.compressionStressConstraints{i,1}.addVariable(self.slaves{i, 1}.forceVariable, 1/self.sigmaC);
            end
            self.calcSlavesConstraints(matrix);
        end
        
        function calcObjective(self, matrix)
            matrix.objectiveFunction.addVariable(self.areaVariable, self.geoMember(9) + 2*self.jointLength + self.penalty);
        end    
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = size(self.slaves, 1)*2;
            varNum = 1;
            objVarNum = 1;
        end       
        
        function feedBackResult(self, loadCaseNum)
            self.geoMember.area = self.areaVariable.value;
            self.geoMember.force = self.slaves{loadCaseNum, 1}.forceVariable.value;
        end        
    end
end

