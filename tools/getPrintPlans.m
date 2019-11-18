function zoneEndYs = getPrintPlans(splitedZones, angles, splitedStructures)
    zoneNum = size(splitedZones, 2) - 1;
    zoneEndYs = zeros(1, zoneNum);
    for i = 1:zoneNum
        zoneStartX = splitedZones(i);
        zoneEndX = splitedZones(i+1);
        if i == 1
            zoneStartY = 0;
            zoneEndYs(i) = zoneStartY;
        else
            zoneStartY = zoneEndY;
        end
        
        if isempty(splitedStructures{i, 1})
            zoneEndY = zoneStartY;
            zoneEndYs(i + 1) = zoneStartY;
            continue;
        end
        
        angle = angles(i);
        angle = angle - pi/2;
        slope = tan(angle);
        zoneEndY = zoneStartY + (zoneEndX-zoneStartX)*slope;
        zoneEndYs(i + 1) = zoneEndY;
    end
end

