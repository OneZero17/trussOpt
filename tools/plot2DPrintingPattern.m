function plot2DPrintingPattern(splitedZones, zoneEndYs, spacing, floorStartY, floorEndY, figureNum)
    zoneNum = size(splitedZones, 2);
    zoneMaxY = max(zoneEndYs);
    zoneMinY = min(zoneEndYs);
    plotSpan = zoneMaxY - zoneMinY + floorEndY - floorStartY;
    layerNum = floor( plotSpan / spacing);
    realSpacing = plotSpan / layerNum;
    
    figure(figureNum)
    hold on
    for i = 1 : layerNum
        currentZoneEndYs = zoneEndYs - zoneMaxY + floorStartY + realSpacing*i;
        for j = 1 : zoneNum-1
            currentXStart = splitedZones(j);
            currentXEnd = splitedZones(j + 1);
            currentYStart = currentZoneEndYs(j);
            currentYEnd = currentZoneEndYs(j + 1);
            
            if currentYStart>=floorStartY && currentYStart<=floorEndY && currentYEnd>=floorStartY && currentYEnd<=floorEndY
                plot([currentXStart, currentXEnd], [currentYStart, currentYEnd],':', 'LineWidth', 2, 'color', [0.7, 0.7, 0.7]);
                
            elseif currentYStart>=floorStartY && currentYStart<=floorEndY && currentYEnd >= floorEndY
                endX = currentXStart + (currentXEnd - currentXStart) / (currentYEnd - currentYStart) * (floorEndY - currentYStart);
                plot([currentXStart, endX], [currentYStart, floorEndY],':', 'LineWidth', 2, 'color', [0.7, 0.7, 0.7]);
                
            elseif currentYStart>=floorStartY && currentYStart<=floorEndY && currentYEnd <= floorStartY
                endX = currentXStart + (currentXEnd - currentXStart) / (currentYEnd - currentYStart) * (floorStartY - currentYStart);
                plot([currentXStart, endX], [currentYStart, floorStartY],':', 'LineWidth', 2, 'color', [0.7, 0.7, 0.7]);                
                
            elseif currentYEnd>=floorStartY && currentYEnd<=floorEndY && currentYStart <= floorStartY
                startX = currentXEnd + (currentXStart - currentXEnd) / (currentYStart - currentYEnd) * (floorStartY - currentYEnd);
                plot([startX, currentXEnd], [floorStartY, currentYEnd],':', 'LineWidth', 2, 'color', [0.7, 0.7, 0.7]);  
                
            elseif currentYEnd>=floorStartY && currentYEnd<=floorEndY && currentYStart >= floorEndY
                startX = currentXEnd + (currentXStart - currentXEnd) / (currentYStart - currentYEnd) * (floorEndY - currentYEnd);
                plot([startX, currentXEnd], [floorEndY, currentYEnd],':', 'LineWidth', 2, 'color', [0.7, 0.7, 0.7]);   
                
            elseif (currentYStart<=floorStartY && currentYEnd>=floorEndY) || (currentYEnd<=floorStartY && currentYStart>=floorEndY)
                x1 = currentXEnd + (currentXStart - currentXEnd) / (currentYStart - currentYEnd) * (floorStartY - currentYEnd);
                x2 = currentXStart + (currentXEnd - currentXStart) / (currentYEnd - currentYStart) * (floorEndY - currentYStart);
                plot([x1, x2], [floorStartY, floorEndY],':', 'LineWidth', 2, 'color', [0.7, 0.7, 0.7]);   
            end
        end
    end
end

