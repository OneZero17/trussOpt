function generateOptimizedPrintPlan(structure, zones, angles, xLimit, yLimit)
    figureNum = 100;
    zoneNum = size(zones, 2) - 1;
    zoneEndYs = getPrintPlans(zones, angles);
    increaseStep = (yLimit-min(zoneEndYs)) / figureNum;
    splitedMembers = splitSector(structure, zones);
    filename = 'testAnimated.gif';
    for i = 1:figureNum
        currentZoneEndYs = zoneEndYs + i * increaseStep;
        totalPlotStructures = cell(zoneNum, 1);
        for j = 1:zoneNum
            currentZoneEndX1 = zones(j);
            currentZoneEndX2 = zones(j+1);
            currentZoneEndY1 = currentZoneEndYs(j);
            currentZoneEndY2 = currentZoneEndYs(j+1);
            slope = (currentZoneEndY2 - currentZoneEndY1) / (currentZoneEndX2 - currentZoneEndX1);
            zoneMembers = splitedMembers{j, 1};
            zoneMembersX = [zoneMembers(:, 1), zoneMembers(:, 3)];
            zoneMembersYBoundary = (zoneMembersX - currentZoneEndX1) * slope + currentZoneEndY1;
            
            plotMembersPart1 = zoneMembers(zoneMembers(:, 2) <= zoneMembersYBoundary(:, 1) & zoneMembers(:, 4) <= zoneMembersYBoundary(:, 2), :);
            
            plotMembersPart2 = zoneMembers(zoneMembers(:, 2) < zoneMembersYBoundary(:, 1)&zoneMembers(:, 4) > zoneMembersYBoundary(:, 2), :);
            
            for k = 1:size(plotMembersPart2, 1)
                intersectionPoint = lineXline([plotMembersPart2(k, 1:2); currentZoneEndX1, currentZoneEndY1], [plotMembersPart2(k, 3:4); currentZoneEndX2, currentZoneEndY2]);
                plotMembersPart2(k, 3:4) = intersectionPoint;
            end
            
            plotMembersPart3 = zoneMembers(zoneMembers(:, 2) > zoneMembersYBoundary(:, 1)&zoneMembers(:, 4) < zoneMembersYBoundary(:, 2), :);
            
            for k = 1:size(plotMembersPart3, 1)
                intersectionPoint = lineXline([plotMembersPart3(k, 1:2); currentZoneEndX1, currentZoneEndY1], [plotMembersPart3(k, 3:4); currentZoneEndX2, currentZoneEndY2]);
                plotMembersPart3(k, 1:2) = intersectionPoint;
            end
            
            totalPlotStructures{j, 1} = [plotMembersPart1; plotMembersPart2; plotMembersPart3];
        end
        totalPlotStructures = cell2mat(totalPlotStructures);
        
        plotStructure(totalPlotStructures, i, xLimit, yLimit);
        figure(i);
        hold on
        plot(zones, currentZoneEndYs,':', 'LineWidth', 2, 'color', [0.7, 0.7, 0.7]);
        fig = figure(i);
        frame = getframe(fig);
        im = frame2im(frame); 
        [imind,cm] = rgb2ind(im,256);  
        
        if i == 1 
            imwrite(imind,cm,filename,'gif', 'DelayTime',0.1,'Loopcount',inf); 
        else 
            imwrite(imind,cm,filename,'gif', 'DelayTime',0.1,'WriteMode','append'); 
        end        
        
    end  

end

