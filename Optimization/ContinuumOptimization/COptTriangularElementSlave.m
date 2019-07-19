classdef COptTriangularElementSlave < OptObjectSlave

    properties
        sigmaXXVariables;
        sigmaYYVariables;
        tauXYVariables;
        equilibriumX;
        equilibriumY;
    end
    
    methods
        function obj = COptTriangularElementSlave()
        end
        
        function initialize(self, matrix)
            self.sigmaXXVariables = cell(3, 1);
            self.sigmaYYVariables = cell(3, 1);
            self.tauXYVariables = cell(3, 1);
            for i = 1:3
                self.sigmaXXVariables{i, 1} = matrix.addVariable(-inf, inf, 'sigmaXX');
                self.sigmaYYVariables{i, 1} = matrix.addVariable(-inf, inf, 'sigmaYY');
                self.tauXYVariables{i, 1} = matrix.addVariable(-inf, inf, 'Tau');
            end
            self.equilibriumX = matrix.addConstraint(0, 0, 6, 'ElementEquilibriumX');
            self.equilibriumY = matrix.addConstraint(0, 0, 6, 'ElementEquilibriumY');
        end
                
        function [matrix] = calcConstraint(self, matrix)
            facet = self.master.facet;
            shapeFunction = facet.shapeFunction;
            B = 1/(2*facet.area) *[shapeFunction(1, 2), 0, shapeFunction(1, 3), shapeFunction(2, 2), 0, shapeFunction(2, 3), shapeFunction(3, 2), 0, shapeFunction(3, 3);...
                                        0, shapeFunction(1, 3), shapeFunction(1, 2), 0, shapeFunction(2, 3), shapeFunction(2, 2), 0, shapeFunction(3, 3), shapeFunction(3, 2)];
            variables = [self.sigmaXXVariables{1, 1}, self.sigmaYYVariables{1, 1}, self.tauXYVariables{1, 1}...
                         self.sigmaXXVariables{2, 1}, self.sigmaYYVariables{2, 1}, self.tauXYVariables{2, 1}...                        
                         self.sigmaXXVariables{3, 1}, self.sigmaYYVariables{3, 1}, self.tauXYVariables{3, 1}]';
            for i = 1:9
                if B(1, i) ~= 0
                    self.equilibriumX.addVariable(variables(i, 1), B(1, i));
                end
                if B(2, i) ~= 0 
                    self.equilibriumY.addVariable(variables(i, 1), B(2, i));
                end
            end
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 2;
            varNum = 9;
            objVarNum = 0;
        end

    end
end

