classdef Mesh < handle
   
    properties
        meshNodes
        meshFacets
        meshEdges
    end
    
    methods
        function obj = Mesh(matlabMesh)
            if (nargin > 0)
                nodeNum = size(matlabMesh.Nodes, 2);
                facetNum = size(matlabMesh.Elements, 2);
                meshNodes = cell(nodeNum, 1);
                meshElements = cell(facetNum, 1);
                for i = 1:nodeNum
                    meshNodes{i, 1} = GeoNode(matlabMesh.Nodes(1, i), matlabMesh.Nodes(2, i), i);
                end
                for i = 1:facetNum
                    nodes = [meshNodes{matlabMesh.Elements(1, i), 1};...
                             meshNodes{matlabMesh.Elements(2, i), 1};...
                             meshNodes{matlabMesh.Elements(3, i), 1}];
                    newFacet = MeshTriangularFacet(nodes);
                    newFacet.calcShapeFunction();
                    meshElements{i, 1} = newFacet;
                end
                obj.meshNodes = meshNodes;
                obj.meshFacets = meshElements;
            end
        end
        
        function createEdges(self, edges)
            numEdges = size(edges, 1);
            self.meshEdges = cell(numEdges, 1);
            for i=1:numEdges
                nodes = [self.meshNodes{edges(i, 1), 1}; self.meshNodes{edges(i, 2), 1}];
                if (edges(i, 4) == 0)
                    adjacentElements = self.meshFacets{edges(i, 3), 1};
                else
                    adjacentElements = [self.meshFacets{edges(i, 3), 1}; self.meshFacets{edges(i, 4), 1}];
                end
                self.meshEdges{i, 1} = MeshEdge(nodes, adjacentElements);
            end    
        end
        
        function maximumDensity = getMaximumDensity(self)
            maximumDensity = 0;
            facetNum = size(self.meshFacets, 1);
            for i = 1:facetNum
                if (self.meshFacets{i, 1}.density > maximumDensity)
                    maximumDensity = self.meshFacets{i, 1}.density;
                end
            end
        end
        
        function plotMesh(self, varargin)
            p = inputParser;
            addOptional(p,'figureNumber',0, @isnumeric);
            addOptional(p,'title',"", @isstring);
            addOptional(p,'fileName',"", @isstring);
            addOptional(p,'fixedMaximumDensity', true, @islogical);
            addOptional(p,'colorBarHorizontal', false, @islogical);
            addOptional(p,'xLimit', 1, @isnumeric);
            addOptional(p,'yLimit', 1, @isnumeric);
            parse(p,varargin{:});
            titleText = p.Results.title;
            figureNo = p.Results.figureNumber;
            fileName = p.Results.fileName;
            fixedMaximumDensity = p.Results.fixedMaximumDensity;
            colorBarHorizontal = p.Results.colorBarHorizontal;
            xLimit = p.Results.xLimit;
            yLimit = p.Results.yLimit;
            if fixedMaximumDensity
                maximumDensity = 1;
            else
                maximumDensity = getMaximumDensity(self);
            end
            figure(figureNo)
            facetNum = size(self.meshFacets, 1);
            axis equal;
            colormap hot;

            if colorBarHorizontal
                colorbar('southoutside');
            else
                colorbar;
            end
            caxis([0 1]);
            cmap = colormap;
            fig=figure(figureNo);
            mycmap = get(fig,'Colormap');
            set(fig,'Colormap',flipud(mycmap));
            xlim([0 xLimit])
            ylim([0 yLimit])
            title(titleText);
            hold on
            for i = 1:facetNum
                currentFacet = self.meshFacets{i, 1};
                if (currentFacet.density > 1)
                    currentFacet.density = 1;
                end
                rgb = interp1( linspace(maximumDensity, 0, size(cmap, 1)), cmap, currentFacet.density);               
                fill ([currentFacet.nodeA.x; currentFacet.nodeB.x; currentFacet.nodeC.x], ...
                      [currentFacet.nodeA.y; currentFacet.nodeB.y; currentFacet.nodeC.y],...
                      rgb, 'EdgeColor', rgb);
            end
            
            if (fileName ~= "")
                saveas(fig,"Results\"+fileName)
            end
            close(figureNo)
        end
        
        function volume = calculateVolume(self)
            volume = 0;
            facetNum = size(self.meshFacets, 1);
            for i = 1:facetNum
                currentFacet = self.meshFacets{i, 1};
                volume = volume + currentFacet.density * currentFacet.area;
            end
        end
        
        function area = calculateArea(self)
            area = 0;
            facetNum = size(self.meshFacets, 1);
            for i = 1:facetNum
                currentFacet = self.meshFacets{i, 1};
                area = area + currentFacet.area;
            end
        end
        
%         function createRectangularMesh(self, xStart, yStart, xElementNum, yElementNum, spacing)     
%             self.meshNodes = cell((xElementNum+1)*(yElementNum+1), 1);
%             self.meshElements = cell(xElementNum * yElementNum, 1);
%             self.meshEdges = cell(4*xElementNum * yElementNum, 1);
%             
%             nodes = cell(xElementNum+1, yElementNum+1);
%             elementNum = 0;
%             nodeNum = 0;
%             
%             for i = 1:xElementNum + 1
%                 for j = 1:yElementNum + 1
%                     nodeNum = nodeNum + 1;
%                     self.meshNodes{nodeNum, 1} = GeoNode(xStart + (i-1)*spacing, yStart +(j-1)* spacing, nodeNum);
%                     nodes{i, j} = self.meshNodes{nodeNum, 1};
%                 end
%             end
%             
%             facets = cell(xElementNum*4, yElementNum);
%             for i = 1:xElementNum
%                 for j = 1:yElementNum
%                     elementNum = elementNum + 1;
%                     elementNodes = [nodes{i, j}.index; nodes{i + 1, j}.index; ...
%                                    nodes{i + 1, j + 1}.index;  nodes{i , j+1}.index];
%                     elementEdges = [(elementNum-1)*4 + 1; (elementNum-1)*4 + 2;(elementNum-1)*4 + 3; (elementNum-1)*4 + 4];          
%                     self.meshEdges{(elementNum-1)*4 + 1} =  MeshEdge([elementNodes(1), elementNodes(2)]);
%                     self.meshEdges{(elementNum-1)*4 + 2} =  MeshEdge([elementNodes(2), elementNodes(3)]);
%                     self.meshEdges{(elementNum-1)*4 + 3} =  MeshEdge([elementNodes(3), elementNodes(4)]);
%                     self.meshEdges{(elementNum-1)*4 + 4} =  MeshEdge([elementNodes(4), elementNodes(1)]);
%                     self.meshElements{elementNum, 1} = MeshRectangularElement(elementNodes, elementEdges, elementNum);
%                     facets{i, j} = self.meshElements{elementNum, 1};
%                 end
%             end
%             
%             for i = 1:xElementNum
%                 for j = 1:yElementNum
%                     
%                     if (i > 1)
%                         facets{i, j}.addNeighbour(facets{i - 1, j}.index, facets{i, j}.edgeIndices(4), facets{i - 1, j}.edgeIndices(2));
%                     end
%                     
%                     if (i < xElementNum)
%                         facets{i, j}.addNeighbour(facets{i + 1, j}.index, facets{i, j}.edgeIndices(2), facets{i + 1, j}.edgeIndices(4));
%                     end
%                     
%                     if (j > 1)
%                         facets{i, j}.addNeighbour(facets{i , j - 1}.index, facets{i, j}.edgeIndices(1), facets{i, j - 1}.edgeIndices(3));
%                     end
%                     
%                     if (j < yElementNum)
%                         facets{i, j}.addNeighbour(facets{i , j + 1}.index, facets{i, j}.edgeIndices(3), facets{i, j + 1}.edgeIndices(1));
%                     end       
%                 end
%             end    
%         end
        
    end
end
