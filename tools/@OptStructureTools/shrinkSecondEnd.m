function newMember = shrinkSecondEnd(self, member, shrinkLength)
    memberVectors = member(:, 4:6) - member(:, 1:3);
    memberVectorNorms = memberVectors./(vecnorm(memberVectors'))';
    changeToSecondPoint = -shrinkLength .*memberVectorNorms;
    newMember = member;
    newMember(:, 4:6) = newMember(:, 4:6) + changeToSecondPoint;
end

