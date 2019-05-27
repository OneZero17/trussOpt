classdef OptNodeMaster < OptObjectMaster
    properties
    end
    
    methods
        function obj = OptNodeMaster()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, obj] = self.initializeSlaves(matrix);
        end
    end
end

