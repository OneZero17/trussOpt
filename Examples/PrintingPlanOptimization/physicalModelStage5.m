clear
structure = [0,0,0, 0,0,40,5;
             0,0,40, 60, 0, 100, 5
             120, 0, 0, 120, 0, 40, 5
             120, 0, 40,60, 0, 100, 5
             60, -60, 0, 60, -60, 40, 5
             60, -60, 40, 60, 0, 100, 5
             60, 60, 0, 60, 60, 40, 5
             60, 60, 40, 60, 0, 100, 5];

plotStructure3D(structure, 10, [0.3, 0.3, 0.3], true);
structureTools = OptStructureTools;
volume = calcStructureVolume(structure);
outputPath = '..\vtkPython\polydatas\';
outputStructure = structure;
outputStructure(:, end) = abs(structure(:, end) * 50);
maximumAreaList = structureTools.getMaximumAreaList(outputStructure);
%% Building sectors
close all
xMax=120; yMax=0; zMax=100;
startCoordinates = [0, 0, 0];
endCoordinates = [xMax, yMax, zMax + 15];
floorLineZ = outputBoxForEachFloor(startCoordinates, endCoordinates, outputStructure, false); % splitted floors in Z direction

%% Printing plan optimization
checkingMaxAngle = 0.977;
floorSpacing = 6.25;
splineSpacing = 5;
expandX = 20;
expandY = 80;
splintLineX = startCoordinates(1)- expandX:splineSpacing:endCoordinates(1)+ expandY; % splitted zones in X direction
splintLineY = startCoordinates(2)- expandY:splineSpacing:endCoordinates(2)+ expandY; % splitted zones in Y direction
maximumTurnAngle = 0.6;
[cuttingSurfaces, splitedStructureEachFloor, anglesForEachFloor, printable, zGrids] = findPrintingPlan(outputStructure, splintLineX, splintLineY, floorLineZ, checkingMaxAngle, false, [], floorSpacing, maximumTurnAngle);

%% Tool path slicing
close all
tempStructure = [outputStructure, (1:size(outputStructure, 1))'];
membersInEachFloor = splitSector3DInZ(tempStructure, floorLineZ);
printSpacing = 0.375; % Vertical spacing betwen layers
toolPathSpacing = 0.92; % Horizontal spacing betwen layers
levelSpacing = 4.0;
maximumOverhangAngle = 0.262; % Maximum allowed overhang angle, in radians
maximumB = 42; % Maximum allowed overhang angle, in degree
shrinkLength = 2.0; % End shrink length for infill tool paths
modelPath = 'stage5\\level%i\\'; % Path for the .stl files

[totalPieces, maximumOverhang] = slicing(membersInEachFloor, zGrids, anglesForEachFloor, maximumOverhangAngle, maximumB, splintLineX, splintLineY, floorLineZ, levelSpacing, printSpacing, toolPathSpacing, shrinkLength, false, true);

maximumOverhang = 180*(maximumOverhang/pi);
finalCuttings = figure(1);
save('toolPaths.mat', 'totalPieces');
%savefig(finalCuttings, 'cuttings.fig');

%% output2GCode
structureTools = OptStructureTools;
structureTools.toGCode(totalPieces, [-50, -50, 0]);


function floorLineZ = outputBoxForEachFloor(startCoordinates, endCoordinates, structure, outputFlag)
    structureTools = OptStructureTools;
    floorLineZ = unique([structure(:, 3); structure(:, 6)])';
    boxStart = startCoordinates;
    boxStart(1) = boxStart(1) - 40;
    boxStart(2) = boxStart(2) - 40;
    boxEnd = endCoordinates;
    boxEnd(1) = boxEnd(1) + 40;
    boxEnd(2) = boxEnd(2) + 40;
    tempStructure = structure;
    tempStructure(:, end) = abs(tempStructure(:, end) * 50);
    if outputFlag
        structureTools.outputLevelBoxes(tempStructure, floorLineZ, boxStart, boxEnd, '..\vtkPython\levelBoxes\');
    end
end




