function outputMesh = meshBooleanOperation(self, mesh1, mesh2, gridNumber, operation)
   spacingNumber = gridNumber;
   boundingBox = self.getBoundingBox([mesh1.Points; mesh2.Points]);
   xLength = boundingBox(1, 2) - boundingBox(1, 1);
   yLength = boundingBox(2, 2) - boundingBox(2, 1);
   zLength = boundingBox(3, 2) - boundingBox(3, 1);
   estimateSpacing = min([xLength; yLength; zLength]) / spacingNumber; 
   
   xSpacingNumber = floor(xLength/estimateSpacing);
   ySpacingNumber = floor(yLength/estimateSpacing);
   zSpacingNumber = floor(zLength/estimateSpacing);
   
   [X, Y, Z] = meshgrid(linspace(boundingBox(1, 1), boundingBox(1, 2), xSpacingNumber),...
                        linspace(boundingBox(2, 1), boundingBox(2, 2), ySpacingNumber),...
                        linspace(boundingBox(3, 1), boundingBox(3, 2), zSpacingNumber));
                    
   QP = [X(:) Y(:) Z(:)];
   switch operation
       case 'AND'
           indexIntersect = (~isnan(pointLocation(mesh1, QP))) & (~isnan(pointLocation(mesh2, QP)));
       case 'OR'
           indexIntersect = (~isnan(pointLocation(mesh1, QP))) | (~isnan(pointLocation(mesh2, QP)));
       case 'NOT'
           indexIntersect = (~isnan(pointLocation(mesh1, QP))) & ~(~isnan(pointLocation(mesh2, QP)));
       case ''
   end
   mask = double(reshape(indexIntersect, [xSpacingNumber ySpacingNumber zSpacingNumber]));
   [F, V] = isosurface(X, Y, Z, mask, 0.5);
   outputMesh = triangulation(F, V);
   FE = featureEdges(outputMesh, pi/6).';
   xV = V(:, 1);
   yV = V(:, 2);
   zV = V(:, 3);
   trisurf(outputMesh, 'FaceColor', 'c', 'FaceAlpha', 0.8, 'EdgeColor', 'none');
   axis equal;
   xlabel('x');
   ylabel('y');
   zlabel('z');
   hold on;
   plot3(xV(FE), yV(FE), zV(FE), 'k');
end

