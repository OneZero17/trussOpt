function flag = checkMaterialWasting(cell)
    flag = 0;
    for i = 1:size(cell.members,1)
        usageratio = abs(cell.members{i,1}.force) / cell.members{i,1}.area;
        if (abs(usageratio-1) > 0.001)
            flag = 1;
            return;
        end
    end
end

