classdef OptObject < handle
    
    properties
        index
    end
    
    methods
        function obj = OptObject()
        end
        
        function matrix = addConstraint(matrix)
        end
        
        function matrix = initialize(matrix)
        end
        
        function matrix = calcConstraint(self, matrix)
        end
        
        function matrix = calcObjective(self, matrix)
        end
        
        function [conNum, varNum] = getConAndVarNum()
        end
        
        function feedBackResult(self, loadCaseNum)
        end
    end
end

