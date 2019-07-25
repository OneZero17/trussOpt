function mesh = createRectangularMeshMK2(xMax, yMax, spacing)

xSpacingNumber = floor(xMax / spacing);
ySpacingNumber = floor(yMax / spacing);

x = 0 : xSpacingNumber;
y = 0 : ySpacingNumber;

[X,Y] = meshgrid(x,y);
points = [X(:), Y(:)];
pointIndices = 1:size(points, 1);
pointIndices = reshape(pointIndices, ySpacingNumber + 1, []);


Xmid = X(1:end - 1, 2:end) - 0.5;
Ymid = Y(1:end - 1, 2:end) + 0.5;
midPoints = [Xmid(:), Ymid(:)];
rectangles = zeros(size(midPoints, 1), 4);

rectanguleNum = 0;
for j = 1:size(pointIndices, 2) - 1
    for i = 1:size(pointIndices, 1) - 1
        rectanguleNum = rectanguleNum + 1;
        rectangles(rectanguleNum, :) = reshape(pointIndices(i:i+1, j:j+1), 1, []);    
    end
end

rectangles(:,[3 4]) = rectangles(:,[4 3]);
rectangles = [rectangles, rectangles(:, 1)];

midPointIndices = size(points, 1)+1 :1: size(points, 1) + size(midPoints, 1);
triangles = zeros(size(midPoints, 1)*4, 3);
triangles(:, 3) = reshape([midPointIndices; midPointIndices; midPointIndices; midPointIndices], [], 1);

for i = 1:size(rectangles, 1)
    triangles((i-1)*4+1:i*4, 1) = rectangles(i, 1:4)';
    triangles((i-1)*4+1:i*4, 2) = rectangles(i, 2:5)';
end

mesh.Nodes = [points; midPoints]';
mesh.Nodes(1, :) = mesh.Nodes(1, :) * (xMax / xSpacingNumber);
mesh.Nodes(2, :) = mesh.Nodes(2, :) * (yMax / ySpacingNumber);
mesh.Elements = triangles';

end

