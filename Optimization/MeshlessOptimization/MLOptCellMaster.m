classdef MLOptCellMaster < OptObjectMaster
    
    properties
        cellNodeMasters
        cellLengths
        cellNormals
        supportingDomainCoefficients
        area
        densityCoefficient = 1;
        thickness = 1;
    end
    
    methods
        function obj = MLOptCellMaster(cellNodes, cellLengths, supportingDomainCoefficients, area, cellNormals)
            if nargin > 0
                obj.cellNodeMasters = cellNodes;
            end
            if nargin > 1
                obj.cellLengths = cellLengths;
            end
            if nargin > 2
                obj.supportingDomainCoefficients = supportingDomainCoefficients;
            end
            if nargin > 3
                obj.area = area;
            end
            if nargin > 4
                obj.cellNormals = cellNormals;
            end
        end
        
        function calcConstraint(self, matrix)
            self.calcSlavesConstraints(matrix);
        end
           
        function initialize(self, matrix)
            for i = 1:size(self.slaves, 1)
                cellNodeSlaves = self.cellNodeMasters;
                for j = 1:size(self.cellNodeMasters, 1)
                    currentPoint = self.cellNodeMasters{j, 1};
                    currentPointSlaves = cell(size(currentPoint, 1), 1);
                    for k = 1:size(currentPoint, 1)
                        currentPointSlaves{k, 1} = currentPoint{k, 1}.slaves{i, 1};
                    end
                    cellNodeSlaves{j, 1} = currentPointSlaves;
                end
                self.slaves{i, 1}.cellNodeSlaves = cellNodeSlaves;
            end
            
            self.initializeSlaves(matrix);
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 0;
            varNum = 0;
            objVarNum = 0;
        end
    end
end

