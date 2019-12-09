function sphere = generateTetrahedronSphere(self, center, radius)
    [P, T] = createSphere(center, radius);
    P = P';
    pointNumber = size(P, 1);
    P = [P; center];
    T = [T, repmat(pointNumber+1, size(T, 1), 1)];
    sphere = triangulation(T, P);
end

