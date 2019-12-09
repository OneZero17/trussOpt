function newStructure = shrinkTwoEnds(self, structure, shrinkLength)
    memberVectors = structure(:, 4:6) - structure(:, 1:3);
    memberVectorNorms = memberVectors./(vecnorm(memberVectors'))';
    changeToFirstPoint = shrinkLength .* memberVectorNorms;
    changeToSecondPoint = -shrinkLength .*memberVectorNorms;
    newStructure = structure;
    newStructure(:, 1:3) = newStructure(:, 1:3) + changeToFirstPoint;
    newStructure(:, 4:6) = newStructure(:, 4:6) + changeToSecondPoint;
end

