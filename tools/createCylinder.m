function [P,T] = createCylinder(startPoint, endPoint, radius)
[X, Y, Z] = cylinder2P(radius, 20, startPoint, endPoint);
DT = delaunayTriangulation(X(:),Y(:),Z(:))
T = delaunay(X, Y);
surface = triangulation(T,X(:),Y(:),Z(:));
trisurf(surface, 'FaceAlpha',0.5, 'EdgeColor', 'none');
end

