function volume = calcCellsVolume(cells)

volume = 0;
    for i = 1:size(cells, 1)
        for j = 1:size(cells, 2)
            currentCell = cells{i,j};
            for k = 1:size(currentCell.members, 1)
                volume = volume + currentCell.members{k, 1}.area * currentCell.members{k, 1}.length;
            end
        end
    end
end

