function zoneEndYs = getPrintPlans(splitedZones, angles)
    zoneNum = size(splitedZones, 2) - 1;
    zoneEndYs = zeros(1, zoneNum);
%     figure(figureNum);
%     hold on
    for i = 1:zoneNum
        zoneStartX = splitedZones(i);
        zoneEndX = splitedZones(i+1);
        if i == 1
            zoneStartY = 0;
            zoneEndYs(i) = zoneStartY;
        else
            zoneStartY = zoneEndY;
        end
        angle = angles(i);
        angle = angle - pi/2;
        slope = tan(angle);
%         plotcolor = [0.7, 0.7, 0.7];
%         if slope>1e6
%             slope = 0;
%             plotcolor = [0.0, 1.0, 1.0];
%         end
        zoneEndY = zoneStartY + (zoneEndX-zoneStartX)*slope;
        zoneEndYs(i + 1) = zoneEndY;
        %plot([zoneStartX, zoneEndX],[zoneStartY, zoneEndY],':', 'LineWidth', 2, 'color', plotcolor);
    end
end

