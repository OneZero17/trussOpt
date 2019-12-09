function boundingBox = getBoundingBox(self, points)
    xmin = min(points(:, 1));
    xmax = max(points(:, 1));
    ymin = min(points(:, 2));
    ymax = max(points(:, 2));
    zmin = min(points(:, 3));
    zmax = max(points(:, 3));
    boundingBox = [xmin, xmax; ymin, ymax; zmin, zmax];
end

