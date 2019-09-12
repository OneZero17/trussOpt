classdef MLOptBoundaryMaster < OptObjectMaster
    
    properties
        boundaryCellNodeMaster
        boundaryEndNodesMasters
        boundaryLength
        boundaryNormal
        supportingDomainCoefficients
        xSupported = false;
        ySupported = false;
    end
    
    methods
        function obj = MLOptBoundaryMaster(boundaryCellNodeMaster, boundaryEndNodesMasters, boundaryLength, boundaryNormal, supportingDomainCoefficients, fixedX, fixedY)
            if nargin > 0
                obj.boundaryCellNodeMaster = boundaryCellNodeMaster;
            end
            if nargin > 1
                obj.boundaryEndNodesMasters = boundaryEndNodesMasters;
            end
            if nargin > 2
                obj.boundaryLength = boundaryLength;
            end
            if nargin > 3
                obj.boundaryNormal = boundaryNormal;
            end
            if nargin > 4
                obj.supportingDomainCoefficients = supportingDomainCoefficients;
            end
            if nargin > 5
                obj.xSupported = fixedX == 1;
            end
            if nargin > 6
                obj.ySupported = fixedY == 1;
            end
        end
        
        function calcConstraint(self, matrix)
            self.calcSlavesConstraints(matrix);
        end
        
        function initialize(self, matrix)
            for i = 1:size(self.slaves, 1)
                self.slaves{i, 1}.boundarycentralNodeSlave = self.boundaryCellNodeMaster{1, 1}.slaves{i, 1};
                boundaryNodeSlaves = self.boundaryEndNodesMasters;
                for j = 1:size(self.boundaryEndNodesMasters, 1)
                    currentPoint = self.boundaryEndNodesMasters{j, 1};
                    currentPointSlaves = cell(size(currentPoint, 1), 1);
                    for k = 1:size(currentPoint, 1)
                        currentPointSlaves{k, 1} = currentPoint{k, 1}.slaves{i, 1};
                    end
                    boundaryNodeSlaves{j, 1} = currentPointSlaves;
                end
                self.slaves{i, 1}.boundaryEndNodeSlaves = boundaryNodeSlaves;
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

