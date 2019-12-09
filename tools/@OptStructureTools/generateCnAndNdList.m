function [Cn, Nd] = generateCnAndNdList(self, structure)
    memberNum = size(structure, 1);
    nodes = [structure(:, 1:3); structure(:, 4:6)];
    [Nd, ~, map] = unique(nodes, 'rows');
    Cn = [map(1:memberNum, 1), map(memberNum+1:end, 1), abs(structure(:, end))];    
end

