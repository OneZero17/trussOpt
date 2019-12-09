function outputSurfaces(self, surfaces, path)
    for i = 1 : size(surfaces, 1)
        currentSurface = surfaces{i, 1};
        surfacePointsFileName = [path, '\surfP', int2str(i)];
        surfaceConnectionsFileName = [path, '\surfC', int2str(i)];
        writematrix(currentSurface.Points, surfacePointsFileName, 'Delimiter', ',');
        writematrix(currentSurface.ConnectivityList - 1, surfaceConnectionsFileName, 'Delimiter', ',');
    end
end

