classdef MLOptCellSlave < OptObjectSlave
    
    properties
        cellNodeSlaves
        equilibriumX
        equilibriumY
    end
    
    methods
        function obj = MLOptCellSlave()

        end
        
        function initialize(self, matrix)
            variablesNum = 0;
            for i = 1:size(self.cellNodeSlaves, 1)
                currentPoint = self.cellNodeSlaves{i, 1};
                variablesNum = variablesNum + size(currentPoint, 1);    
            end
            
            self.equilibriumX = matrix.addConstraint(0, 0, variablesNum * 2, 'ElementEquilibriumX');
            self.equilibriumY = matrix.addConstraint(0, 0, variablesNum * 2, 'ElementEquilibriumY');
        end
        
        function calcConstraint(self, matrix)
            segmentNum = size(self.cellNodeSlaves, 1);
            for i = 1:size(self.cellNodeSlaves, 1)
                currentPoint = self.cellNodeSlaves{i, 1};
                firstIndex = i;
                if i == 1
                    lastIndex = segmentNum;
                else
                    lastIndex = i - 1;
                end
                
                firstNormal = self.master.cellNormals(firstIndex, :);
                lastNormal = self.master.cellNormals(lastIndex, :);
                firstLength = self.master.cellLengths(firstIndex, 1);
                lastLength = self.master.cellLengths(lastIndex, 1);
                
                firstT = [firstNormal(1) 0              firstNormal(2)
                          0              firstNormal(2) firstNormal(1)];
                      
                lastT = [lastNormal(1) 0              lastNormal(2)
                          0              lastNormal(2) lastNormal(1)];  
                      
                area = self.master.area;      
                for j = 1:size(currentPoint, 1)
                    currentNode = currentPoint{j, 1};
                    supportingWeight = self.master.supportingDomainCoefficients{i, 1}(j, 1);
                    CXXforX = (0.5 * firstT(1, 1) * firstLength + 0.5 * lastT(1, 1) * lastLength) * supportingWeight / area;
                    CXYforX = (0.5 * firstT(1, 3) * firstLength + 0.5 * lastT(1, 3) * lastLength) * supportingWeight / area;
                    CYYforY = (0.5 * firstT(2, 2) * firstLength + 0.5 * lastT(2, 2) * lastLength) * supportingWeight / area;
                    CXYforY = (0.5 * firstT(2, 3) * firstLength + 0.5 * lastT(2, 3) * lastLength) * supportingWeight / area;
                    if abs(CXXforX) > 1e-9
                        self.equilibriumX.addVariable(currentNode.sigmaXXVariable, CXXforX);
                    end
                    if abs(CXYforX) > 1e-9
                        self.equilibriumX.addVariable(currentNode.tauXYVariable, CXYforX);
                    end
                    if abs(CYYforY) > 1e-9
                        self.equilibriumY.addVariable(currentNode.sigmaYYVariable, CYYforY);
                    end
                    if abs(CXYforY) > 1e-9
                        self.equilibriumY.addVariable(currentNode.tauXYVariable, CXYforY);
                    end
                end
            end
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 2;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

