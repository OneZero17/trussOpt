function threeDToolPath = transform2Dto3DToolPath(self, twoDToolPaths, surface)
    threeDToolPath = zeros(size(twoDToolPaths, 1), 6);
    threeDToolPath(:, 1:2) = twoDToolPaths(:, 1:2);
    threeDToolPath(:, 4:5) = twoDToolPaths(:, 3:4);
    for i = 1:size(threeDToolPath, 1)
        threeDToolPath(i, 3) = self.getZCoordinateOnSurface(threeDToolPath(i, 1), threeDToolPath(i, 2), surface);
        threeDToolPath(i, 6) = self.getZCoordinateOnSurface(threeDToolPath(i, 4), threeDToolPath(i, 5), surface);
    end
end

