function sphere = generateTriangulatedSphere(self, center, radius)
    [P, T] = createSphere(center, radius);
    P = P';
    sphere = triangulation(T, P);
end

