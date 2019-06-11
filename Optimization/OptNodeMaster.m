classdef OptNodeMaster < OptObjectMaster
    properties
        geoNode
        connectedMemberNum
    end
    
    methods
        function obj = OptNodeMaster()
        end
        
        function initialize(self, matrix)
            self.initializeSlaves(matrix);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 0;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

