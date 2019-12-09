function cylinder = generateTetrahedronCylinder(self, member, scaleFactor, circleDivideNum)
    radius = scaleFactor * sqrt(member(7)/pi);
    [startPoints, endPoints] = self.getTwoEndsPointsForSolidCylinder(member, radius, circleDivideNum);
    cylinderPoints = [member(1:3); startPoints; member(4:6); endPoints];
    circleDivideNum = circleDivideNum + 1;
    cBottom = ones(circleDivideNum-1, 1);      % Row indices for bottom center coordinate
    cEdgeBottom1 = (2:circleDivideNum).';      % Row indices for bottom edge coordinates
    cEdgeBottom2 = [3:circleDivideNum 2].';    % Shifted row indices for bottom edge coordinates
    cTop = cBottom+circleDivideNum;            % Row indices for top center coordinate
    cEdgeTop1 = cEdgeBottom1+circleDivideNum;  % Row indices for top edge coordinates
    cEdgeTop2 = cEdgeBottom2+circleDivideNum;  % Shifted row indices for top edge coordinates
    T1 = [cEdgeBottom1 cEdgeBottom2 cEdgeTop1 cBottom; ...
          cEdgeBottom2 cEdgeTop1 cEdgeTop2 cBottom; ...
          cEdgeTop1 cEdgeTop2 cTop cBottom];
    cylinder = triangulation(T1, cylinderPoints);
end

