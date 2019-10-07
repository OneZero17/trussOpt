classdef MLOptBoundaryCellSlave < MLOptCellSlave

    
    methods
        function obj = MLOptBoundaryCellSlave()
        end
        
        function initialize(self, matrix)
            variablesNum = 0;
            for i = 1:size(self.cellNodeSlaves, 1)
                currentPoint = self.cellNodeSlaves{i, 1};
                variablesNum = variablesNum + size(currentPoint, 1);    
            end
            if self.master.xSupported
                self.equilibriumX = -1;
            else
                self.equilibriumX = matrix.addConstraint(0, 0, variablesNum * 2, 'ElementEquilibriumX');
            end
            if self.master.ySupported
                self.equilibriumY = -1;
            else
                self.equilibriumY = matrix.addConstraint(0, 0, variablesNum * 2, 'ElementEquilibriumY');
            end
        end
        
        function calcConstraint(self, matrix)
            sinTheta = self.master.sinCos(1);
            cosTheta = self.master.sinCos(2);
            
            T = [sinTheta^2, cosTheta^2, -2*sinTheta*cosTheta;
                 -sinTheta*cosTheta, sinTheta*cosTheta, 1-2*sinTheta^2];
            
            segmentNum = size(self.cellNodeSlaves, 1);
            for i = 1:size(self.cellNodeSlaves, 1)
                currentPoint = self.cellNodeSlaves{i, 1};
                firstIndex = i;
                if i == 1
                    lastIndex = segmentNum;
                else
                    lastIndex = i - 1;
                end
                firstLength = self.master.cellLengths(firstIndex, 1);
                lastLength = self.master.cellLengths(lastIndex, 1);
                firstNormal = self.master.cellNormals(firstIndex, :);      
                lastNormal = self.master.cellNormals(lastIndex, :);
                boundaryNormal = self.master.boundaryNormal;
                area = self.master.area;      
                for j = 1:size(currentPoint, 1)
                    currentNode = currentPoint{j, 1};
                    supportingWeight = self.master.supportingDomainCoefficients{i, 1}(j, 1);
                    CXXforX = (0.5 * firstLength + 0.5 * lastLength) * boundaryNormal(1) * T(1, 1) * supportingWeight / area;
                    CYYforX = (0.5 * firstLength + 0.5 * lastLength) * boundaryNormal(1) * T(1, 2) * supportingWeight / area;
                    CXYforX = (0.5 * firstLength + 0.5 * lastLength) * boundaryNormal(1) * T(1, 3) * supportingWeight / area;
                    CXXforY = (0.5 * firstLength + 0.5 * lastLength) * boundaryNormal(2) * T(2, 1) * supportingWeight / area;
                    CYYforY = (0.5 * firstLength + 0.5 * lastLength) * boundaryNormal(2) * T(2, 2) * supportingWeight / area;
                    CXYforY = (0.5 * firstLength + 0.5 * lastLength) * boundaryNormal(2) * T(2, 3) * supportingWeight / area;
                    if abs(CXXforX) > 1e-9 && self.equilibriumX~=-1
                        self.equilibriumX.addVariable(currentNode.sigmaXXVariable, CXXforX);
                    end
                    if abs(CYYforX) > 1e-9 && self.equilibriumX~=-1
                        self.equilibriumX.addVariable(currentNode.sigmaYYVariable, CYYforX);
                    end
                    if abs(CXYforX) > 1e-9 && self.equilibriumX~=-1
                        self.equilibriumX.addVariable(currentNode.tauXYVariable, CXYforX);
                    end
                    
                    if abs(CXXforY) > 1e-9 && self.equilibriumY~=-1
                        self.equilibriumY.addVariable(currentNode.sigmaXXVariable, CXXforY);
                    end                    
                    if abs(CYYforY) > 1e-9 && self.equilibriumY~=-1
                        self.equilibriumY.addVariable(currentNode.sigmaYYVariable, CYYforY);
                    end
                    if abs(CXYforY) > 1e-9 && self.equilibriumY~=-1
                        self.equilibriumY.addVariable(currentNode.tauXYVariable, CXYforY);
                    end
                end
            end
        end
    end
end

