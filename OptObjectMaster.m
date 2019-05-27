classdef OptObjectMaster < OptObject    
    properties
        slaves
    end
    
    methods
        function obj = OptObjectMaster()
        end
        
        function [matrix, obj] = initializeSlaves(self, matrix)
            for i = 1: size(self.slaves)
                [matrix, self.slaves(i)] = self.slaves(i).initialize(matrix);
            end
            obj = self;
        end
    end
end

