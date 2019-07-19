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
        
        function plotMesh(self)
            facetNum = size(self.meshFacets, 1);
            x = zeros(3, facetNum);
            y = zeros(3, facetNum);
            color = zeros(3, facetNum);
            faces = zeros(facetNum, 3);
            facetNo = 0;
            hold on
            for i = 1:facetNum
                currentFacet = self.meshFacets{i, 1};
                fill ([currentFacet.nodeA.x; currentFacet.nodeB.x; currentFacet.nodeC.x], ...
                      [currentFacet.nodeA.y; currentFacet.nodeB.y; currentFacet.nodeC.y],...
                      [1, 1, 1]-currentFacet.density^0.3*[1, 1, 1], 'EdgeColor', [1, 1, 1]-currentFacet.density^0.3*[1, 1, 1]);
                x(:,i) = [currentFacet.nodeA.x; currentFacet.nodeB.x; currentFacet.nodeC.x];
                y(:,i) = [currentFacet.nodeA.y; currentFacet.nodeB.y; currentFacet.nodeC.y];
                %color(:,i) = 1-(1-currentFacet.density)^0.3;
                color(:,i) = [currentFacet.density, currentFacet.density, currentFacet.density];
                facetNo = facetNo +1;
                faces(facetNo, :) = [3*(facetNo - 1)+1, 3*(facetNo - 1)+2, 3*(facetNo - 1)+3];
            end

            x(:,color(:, 1)==0)=[];
            y(:,color(:, 1)==0)=[];
            color(:,color(:, 1)==0)=[];
            faces(faces(:, 1)==0, :)=[];
            clear graph
            x = x(:);
            y = y(:);
            graph.Vertices = [x, y];
            graph.Faces  = faces;
            graph.FaceVertexCData  = color';
            %patch(graph);
            colormap(flipud(gray(256)));
            colorbar;
            %color = [1, 1, 1] - (self.members{i,1}.area)^0.3 * [1, 1, 1];
            
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

