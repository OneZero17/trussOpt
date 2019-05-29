classdef OptObjectMaster < OptObject    
    properties
        slaves
    end
    
    methods
        function obj = OptObjectMaster()
        end
        
        function initializeSlaves(self, matrix)
            for i = 1: size(self.slaves)
                self.slaves{i, 1}.initialize(matrix);
            end
        end
        
        function matrix = calcSlavesConstraints(self, matrix)
            for i = 1: size(self.slaves)
                matrix = self.slaves{i, 1}.calcConstraint(matrix);
            end
        end
        
        function obj = addSlaves(self, slaves)
            for i = 1:size(slaves,1)
                slaves{i,1}.master = self;
            end
            self.slaves = slaves;
            obj = self;
        end
        
        function [conNum, varNum] = getSlavesConAndVarNum(self)
            conNum = 0;
            varNum = 0;
            for i = 1:size(self.slaves)
                [slaveConNum, slaveVarNum] = self.slaves{i, 1}.getConAndVarNum();
                conNum = conNum + slaveConNum;
                varNum = varNum + slaveVarNum;
            end
        end
    end
end

