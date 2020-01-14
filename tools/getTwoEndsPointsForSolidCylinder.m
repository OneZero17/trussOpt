function [startingPoints, endPoints] = getTwoEndsPointsForSolidCylinder(self, member, radius, circleDivideNum)
    memberVector = member(4:6) - member(1:3);
    tempPoint = self.getSpaceCircleStartingPoint(member(1:3), memberVector);
    radiusVector = tempPoint - member(1:3);
    startPoint1 = member(1:3) + radius * radiusVector/norm(radiusVector);
    startingPoints = self.calculateCircleEdgePoints(member(1:3), memberVector, startPoint1, circleDivideNum);
    
    tempPoint = self.getSpaceCircleStartingPoint(member(4:6), memberVector);
    radiusVector = tempPoint - member(4:6);
    startPoint2 = member(4:6) + radius * radiusVector/norm(radiusVector);
    endPoints = self.calculateCircleEdgePoints(member(4:6), memberVector, startPoint2, circleDivideNum);
end

