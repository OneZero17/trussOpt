classdef MLOptNodeSlave < OptObjectSlave
    
    properties
        sigmaXXVariable
        sigmaYYVariable
        tauXYVariable
    end
    
    methods
        function obj = MLOptNodeSlave()
        end
        
        function initialize(self, matrix)
            self.sigmaXXVariable = matrix.addVariable(-inf, inf, 'sigmaXX');
            self.sigmaYYVariable = matrix.addVariable(-inf, inf, 'sigmaYY');
            self.tauXYVariable = matrix.addVariable(-inf, inf, 'tauXY');
        end
        
        
        function matrix = calcConstraint(self, matrix)

        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 0;
            varNum = 3;
            objVarNum = 0;
        end
    end
end

