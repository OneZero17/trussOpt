function allSlices = generateOptimizedPrintPlan3D(structure, angles, splitLineX, splitLineY, printPlanGrid, normalVectors, zmax, createPlotting)
    splitedInX = splitSector3DInX(structure, splitLineX);
    splitedInXY = cell(size(normalVectors, 1), size(normalVectors, 2));
    
    printPlanGridTemp = reshape(printPlanGrid, [], 1);
    printPlanGridTemp = cell2mat(printPlanGridTemp);
    zMin = min(printPlanGridTemp(:, 3));
    zmax = zmax - zMin;
    
    for i = 1:size(splitedInX, 1)
        splitedInXY(i, :) = splitSector3DInY(splitedInX{i, 1}, splitLineY);
    end
    
    plotNum = 100;
    spacing = zmax / plotNum;
    zLayers = 0:spacing:zmax;
    layerMembers = cell(size(zLayers, 2), 1); 
    allSlices = cell(size(zLayers, 2), 1); 
    plot = [];
    filename = 'testAnimated.gif';
    for layerNum = 1:size(zLayers, 2)
        zStart = zLayers(layerNum);
        currentLayerMembers = zeros(size(structure, 1), size(structure, 2));
        currentSlice = cell(size(normalVectors, 1), size(normalVectors, 2));
        addedMemberNo = 0;
        for i = 1 : size(normalVectors, 1)
            for j = 1 : size(normalVectors, 2)
                normalVector = normalVectors{i, j};
                currentMembers = splitedInXY{i, j};
                benchmarkNode = printPlanGrid{i, j};
                benchmarkNode(3) = benchmarkNode(3) + zStart;
                toBeDeletedMembers = zeros(size(currentMembers, 1), 1);
                currentLayerCurrentZone = zeros(size(structure, 1), size(structure, 2));
                currentZoneAdded = 0;
                for k = 1:size(currentMembers, 1)
                    currentMember = currentMembers(k, :);
                    projectionZ1 = benchmarkNode(3) - (currentMember(1)   - benchmarkNode(1)) * normalVector(1) - (currentMember(2) - benchmarkNode(2)) * normalVector(2);
                    projectionZ2 = benchmarkNode(3) - (currentMember(4)   - benchmarkNode(1)) * normalVector(1) - (currentMember(5) - benchmarkNode(2)) * normalVector(2);
                    if currentMember(3) >= projectionZ1 && currentMember(6) >= projectionZ2
                        continue;
                    elseif currentMember(3) <= projectionZ1 && currentMember(6) <= projectionZ2
                        addedMemberNo = addedMemberNo + 1;
                        currentLayerMembers(addedMemberNo, :) = currentMember;
                        currentZoneAdded = currentZoneAdded + 1;
                        currentLayerCurrentZone(currentZoneAdded, :) = currentMember;
                        toBeDeletedMembers(k, 1) = 1;
                    elseif currentMember(3) <= projectionZ1 && currentMember(6) >= projectionZ2
                        ratio = 1 + (currentMember(6) - projectionZ2) / (projectionZ1 - currentMember(3));
                        intersectX = currentMember(1) + (currentMember(4) - currentMember(1)) / ratio;
                        intersectY = currentMember(2) + (currentMember(5) - currentMember(2)) / ratio;
                        intersectZ = projectionZ1 + (projectionZ2 - projectionZ1) / ratio;
                        addedMemberNo = addedMemberNo + 1;
                        currentLayerMembers(addedMemberNo, :) = currentMember;
                        currentLayerMembers(addedMemberNo, 4:6) = [intersectX, intersectY, intersectZ];
                        currentZoneAdded = currentZoneAdded + 1;
                        currentLayerCurrentZone(currentZoneAdded, :) = currentLayerMembers(addedMemberNo, :);
                        splitedInXY{i, j}(k, 1:3) = [intersectX, intersectY, intersectZ];
                    elseif currentMember(3) >= projectionZ1 && currentMember(6) <= projectionZ2
                        ratio = 1 + (currentMember(6) - projectionZ2) / (projectionZ1 - currentMember(3));
                        intersectX = currentMember(1) + (currentMember(4) - currentMember(1)) / ratio;
                        intersectY = currentMember(2) + (currentMember(5) - currentMember(2)) / ratio;
                        intersectZ = projectionZ1 + (projectionZ2 - projectionZ1) / ratio;
                        addedMemberNo = addedMemberNo + 1;
                        currentLayerMembers(addedMemberNo, :) = currentMember;
                        currentLayerMembers(addedMemberNo, 1:3) = [intersectX, intersectY, intersectZ];
                        currentZoneAdded = currentZoneAdded + 1;
                        currentLayerCurrentZone(currentZoneAdded, :) = currentLayerMembers(addedMemberNo, :);
                        splitedInXY{i, j}(k, 4:6) = [intersectX, intersectY, intersectZ];
                    end
                end
                currentLayerCurrentZone(currentZoneAdded+1 : end, :) = [];  
                currentSlice{i, j} = currentLayerCurrentZone;
                splitedInXY{i, j}(toBeDeletedMembers == 1, :) = [];
            end
        end
        allSlices{layerNum} = currentSlice;
        
        if createPlotting
            figureNumber = 5;
            fig = figure(figureNumber);
            plotPrintingSurface(angles, splitLineX, splitLineY, zStart, figureNumber);
            currentLayerMembers(addedMemberNo + 1:end, :) = [];
            plot = [plot; currentLayerMembers];
            plotStructure3D(plot, figureNumber)
            layerMembers{layerNum, 1} = currentLayerMembers;
            viewY = 1-0.02 * layerNum;
            view([1, viewY, -0.5]);

            frame = getframe(fig);
            im = frame2im(frame); 
            [imind,cm] = rgb2ind(im,256);

            if layerNum == 1 
                imwrite(imind,cm,filename,'gif', 'DelayTime',0.1,'Loopcount',inf); 
            else 
                imwrite(imind,cm,filename,'gif', 'DelayTime',0.1,'WriteMode','append'); 
            end  
            close(fig);
        end
    end
    
end

