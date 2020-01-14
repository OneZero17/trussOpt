clear
solverOptions = OptOptions();
x=50; y=150; z=50;
startCoordinates = [0, 0, 0];
endCoordinates = [x, y, z];
spacing = 12.5;   
groundStructure = GeoGroundStructure3D;
groundStructure.createCustomizedNodeGrid([0,0,0], [x, y, z], [spacing, spacing, spacing]);
groundStructure.createMembersFromNodes();
groundStructure.members = deleteCollinearMembers(groundStructure.nodes, groundStructure.members);
groundStructure.deleteNearHorizontalMembers(0);
%   groundStructure.deleteHorizontalMembers();
loadcase1 = PhyLoadCase();
load1NodeIndex = groundStructure.findNodeIndex([x/2, y, 0]);
load1 = PhyLoad3D(load1NodeIndex, 0.0, 0.0, -5.0);
loadcase1.loads = {load1};    

loadcases = {loadcase1};
support1NodeIndex = groundStructure.findNodeIndex([x/2, 0, 0]);
support2NodeIndex = groundStructure.findNodeIndex([0, 50, 0]);
support3NodeIndex = groundStructure.findNodeIndex([x, 50, 0]);
support1 = PhySupport3D(support1NodeIndex, 1, 1, 1);
support2 = PhySupport3D(support2NodeIndex, 1, 1, 1);
support3 = PhySupport3D(support3NodeIndex, 1, 1, 1);
supports = {support1; support2; support3};  
solverOptions.nodalSpacing = spacing * 1.75; 

[forceList, potentialMemberList, initialVolume] = memberAdding(groundStructure, loadcases, supports, solverOptions);
%groundStructure.plotMembers(forceList);
%
structure = groundStructure.createOptimizedStructureList(forceList);
structure = mergeCollinear(structure);
plotStructure3D(structure, 1);
toRhino('rhinoFiles', 'truss', structure);
plotStructure3D(structure, 10);
%
shrinkLength = 0;
structureTools = OptStructureTools;
outputPath = '..\vtkPython\polydatas\';

%%
structureTools.outputStructureFiles(structure, outputPath)
%%
structureTools.outputConnectivity(structure, outputPath);

%% Building sectors
checkingMaxAngle = 0.977;
floorSpacing = 6.25;
splineSpacing = 5;
floorLineZ = 0:floorSpacing:z;
boxStart = startCoordinates;
boxStart(1) = boxStart(1) - 5;
boxStart(2) = boxStart(2) - 5;
boxEnd = endCoordinates;
boxEnd(1) = boxEnd(1) + 5;
boxEnd(2) = boxEnd(2) + 5;
%structureTools.outputLevelBoxes(structure, floorLineZ, boxStart, boxEnd, '..\vtkPython\levelBoxes\');
%%
splintLineX = startCoordinates(1)-5:splineSpacing:endCoordinates(1)+5;
splintLineY = startCoordinates(2)-5:splineSpacing:endCoordinates(2)+5;
[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(structure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing);

%%
close all
tempStructure = [structure, (1:size(structure, 1))'];
membersInEachFloor = splitSector3DInZ(tempStructure, floorLineZ);
printSpacing = 0.5;

for floorNum = 1 : size(membersInEachFloor, 1)
%for floorNum = 3
    %surfaceCurrent = cuttingSurfaces{floorNum, 1};
    stlFileFolder = sprintf('..\\vtkPython\\booleanResults\\level%i\\', floorNum);
    figure(1)
    view([ 1 1 1]);
    axis equal
    hold on

    currentStructure = membersInEachFloor{floorNum, 1};
    currentZGrid = zGrids{floorNum, 1};
    
   for i = 1:size(currentStructure, 1)
    %for i = 5
%      if floorNum==1 && i==6
%          continue;
%      end
        memberFileName = [stlFileFolder, sprintf('cutCylinder%i.stl', currentStructure(i, end)-1)];
        if isfile(memberFileName)
            [F,V] = stlread(memberFileName);
        else 
            continue;
        end
        if ~isempty(V) 
            memberBoundingBox = boundingBox3d(V);
%           figure(2)
%           hold on
%           axis equal
           testSurface = triangulation(F, V);
           %trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
            currentMember = currentStructure(i, :);
            plotStructure3D(currentMember, 10);
            [surfaceCurrent, surfaceCoordinates] = getCustomizedZGridForMember(currentMember, memberBoundingBox, splintLineX, splintLineY, anglesForEachFloor{floorNum, 1});
            %[surfaceCurrent, surfaceCoordinates] = getSurfaceForMember(memberBoundingBox, currentZGrid, splintLineX, splintLineY);
            %trisurf(surfaceCurrent, 'EdgeColor', 'none', 'FaceAlpha',0.2);
            
            if currentMember(1) > currentMember(4)
                point1X = 2;
                point2X = 1;
            else
                point1X = 1;
                point2X = 2;
            end
            
            if currentMember(2) > currentMember(5)
                point1Y = 4;
                point2Y = 3;
            else
                point1Y = 3;
                point2Y = 4;                
            end
            
            cuttingSurfaceMin = structureTools.getZCoordinateOnSurface(memberBoundingBox(point1X), memberBoundingBox(point1Y), surfaceCoordinates);
            cuttingSurfaceMax = structureTools.getZCoordinateOnSurface(memberBoundingBox(point2X), memberBoundingBox(point2Y), surfaceCoordinates);
            
            %[cuttingSurfaceMin, cuttingSurfaceMax] = getHeightBoundPointsInSurface(memberBoundingBox, currentZGrid, splintLineX, splintLineY);
            cuttingSurfaceGap = abs(cuttingSurfaceMax - cuttingSurfaceMin);
            divideSpacing = memberBoundingBox(6) - memberBoundingBox(5)+ cuttingSurfaceGap;
            figure(1)
            hold on
            axis equal
            view([1 1 1]);
            surface1.vertices = V;
            surface1.faces = F;
            memberVector = currentMember([4, 5, 6]) - currentMember([1, 2, 3]);
            memberLength = norm(memberVector);
            increasedSpacingNumber = floor(memberLength/printSpacing);
            tempDivideSpacing = divideSpacing / increasedSpacingNumber;
            
            figure(3)
            clf
            hold on
            axis equal
            xlabel x
            ylabel y
            zlabel z
            %trisurf(testSurface, 'EdgeColor', 'none', 'FaceAlpha',0.2);
            
            toolPathSpacing = 0.1;     
            started = false;
            for printNum = 0:increasedSpacingNumber*2
                
                if printNum == 6
                    xx=0.0;
                end
                verticalShift = - (max(cuttingSurfaceMin, cuttingSurfaceMax) - memberBoundingBox(5)) + tempDivideSpacing * (printNum-1);
                surface2.vertices = surfaceCurrent.Points;
                surface2.vertices(:, 3) = surface2.vertices(:, 3) + verticalShift;
                surface2.faces = surfaceCurrent.ConnectivityList;
                
                figure(3)
                surfacePlot = triangulation(surface2.faces, surface2.vertices);
                trisurf(surfacePlot, 'EdgeColor', 'none', 'FaceAlpha',0.2);
                view([ 1 1 1]);
                [intersect12, Surf12] = SurfaceIntersection(surface1, surface2);
                S=Surf12; 
                if isempty(S.faces) 
                    if started == true
                        break
                    else
                        continue;
                    end
                elseif started == false
                    started = true;
                end
                figure(1)
                trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
                
                toolPathes = structureTools.generateToolPathForCuttingCurve(S, surfaceCoordinates, verticalShift, toolPathSpacing);
                
                figure(4)
                clf
                hold on
                axis equal
                view([ 1 1 1]);
%                 trisurf(surfacePlot, 'EdgeColor', 'none', 'FaceAlpha',0.2);
                trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
                
                for pathNum = 1:size(toolPathes, 1)
                    for segmentNum = 1:size(toolPathes{pathNum, 1}, 1)
                    plot3(toolPathes{pathNum, 1}(segmentNum, [1 4]), toolPathes{pathNum, 1}(segmentNum, [2 5]), toolPathes{pathNum, 1}(segmentNum, [3 6]), '-g');
                    end
                end
%                 for toolPathNum = 1:size(toolPathes, 1)
%                     for segmentNum = 1:size(toolPathes{toolPathNum, 1}, 1)
%                     plot3(toolPathes{toolPathNum, 1}(segmentNum, [1 4]), toolPathes{toolPathNum, 1}(segmentNum, [2 5]), toolPathes{toolPathNum, 1}(segmentNum, [3 6]), '-r');                        
%                     end
%                 end
%                 for intersecNum = 1:size(intersectionPoints, 1)
%                     scatter3(intersectionPoints(intersecNum, 1), intersectionPoints(intersecNum, 2), intersectionPoints(intersecNum, 3), '*g')
%                 end
            end
        end
    end
end

finalCuttings = figure(1);
savefig(finalCuttings, 'cuttings.fig')
%%
[~, Nd] = structureTools.generateCnAndNdList(structure);
[~, nodeRadiusList] = structureTools.getRadiusList(structure);
floorNumForNode = zeros(size(Nd, 1), 1);
printSpacing = 0.1;
for i=1:size(Nd, 1)
    for j = 1:size(floorLineZ, 2)-1
        if floorLineZ(j) <= Nd(i, 3) && floorLineZ(j+1) >= Nd(i, 3)
            floorNumForNode(i, 1) = j;
            break
        end
    end
end

for i = 1:size(Nd, 1)
% for i = 5
    currentZGrid = zGrids{floorNumForNode(i, 1), 1};
    stlFileFolder = '..\\vtkPython\\booleanResults\\';
    memberFileName = [stlFileFolder, sprintf('sphere%i.stl', i-1)];
    [F,V] = stlread(memberFileName);
    if ~isempty(V) 
        memberBoundingBox = boundingBox3d(V);
        surfaceCurrent = getSurfaceForMember(memberBoundingBox, currentZGrid, splintLineX, splintLineY);
        surface1.vertices = V;
        surface1.faces = F;
        testSurface = triangulation(F, V);
        [cuttingSurfaceMin, cuttingSurfaceMax] = getHeightBoundPointsInSurface(memberBoundingBox, currentZGrid, splintLineX, splintLineY);
        cuttingSurfaceGap = abs(cuttingSurfaceMax - cuttingSurfaceMin);
        divideSpacing = memberBoundingBox(6) - memberBoundingBox(5)+ cuttingSurfaceGap;
        nodeDiameter = nodeRadiusList(i, 1) * 2;
        increasedSpacingNumber = floor(nodeDiameter/printSpacing);
        tempDivideSpacing = divideSpacing / increasedSpacingNumber;
        
        figure(3)
        hold on
        trisurf(testSurface, 'EdgeColor', 'r', 'FaceColor', 'r', 'FaceAlpha',0.2);
%         for printNum = -10:increasedSpacingNumber*2
%             surface2.vertices = surfaceCurrent.Points;
%             surface2.vertices(:, 3) = surface2.vertices(:, 3) - (max(cuttingSurfaceMin, cuttingSurfaceMax) - memberBoundingBox(5)) + tempDivideSpacing * (printNum-1);
%             surface2.faces = surfaceCurrent.ConnectivityList;
%             figure(3)
%             surfacePlot = triangulation(surface2.faces, surface2.vertices);
%             trisurf(surfacePlot, 'EdgeColor', 'none', 'FaceAlpha',0.2);
%             view([ 1 1 1]);
%             [intersect12, Surf12] = SurfaceIntersection(surface1, surface2);
%             S=Surf12; 
%             if isempty(S.faces)
%                 continue;
%             end
%             figure(1)
%             hold on
%             axis equal
%             trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
%         end
   end
end

