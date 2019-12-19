function newMember = shrinkFirstEnd(self, member, shrinkLength)
    memberVectors = member(:, 4:6) - member(:, 1:3);
    memberVectorNorms = memberVectors./(vecnorm(memberVectors'))';
    changeToFirstPoint = shrinkLength .* memberVectorNorms;
    newMember = member;
    newMember(:, 1:3) = newMember(:, 1:3) + changeToFirstPoint;
end

