function volume = calcStructureVolume(structure)
    volume = 0;
    for i = 1:size(structure)
        length = norm(structure(i, 4:6) - structure(i, 1:3));
        volume = volume + length * abs(structure(i, end));
    end
    
end

