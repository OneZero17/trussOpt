classdef OptNodeMaster < OptObjectMaster
    properties
        geoNode
    end
    
    methods
        function obj = OptNodeMaster()
        end
        
        function [matrix, obj] = initialize(self, matrix)
            [matrix, obj] = self.initializeSlaves(matrix);
        end
        
        function [conNum, varNum] = getConAndVarNum(self)
            conNum = 0;
            varNum = 0;
        end
    end
end

