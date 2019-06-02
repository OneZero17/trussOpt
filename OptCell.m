classdef OptCell < OptObject
    properties
        maximumArea
        areaVariable
    end
    
    methods
        function obj = OptCell(maxArea)
            if nargin > 0
                obj.maximumArea = maxArea;
            end
        end
        
        function matrix = initialize(self, matrix)
            [matrix, self.areaVariable] = matrix.addVariable(0,self.maximumArea);
        end
        
        function [conNum, varNum] = getConAndVarNum(self)
            conNum = 0;
            varNum = 1;
        end
    end
end

