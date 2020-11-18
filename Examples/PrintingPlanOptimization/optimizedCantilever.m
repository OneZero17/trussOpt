clear
structure = [0,0,0,25,50,100,2.68510293702253;
        0,0,0,25,0,125,3.98360897164573;
        0,100,0,25,50,100,2.95361323393586;
        0,100,0,50,66.67,66.67,2.10;
        50,66.67,66.67,75,50,100,2.10;
        0,100,0,25,100,125,3.66492026704775;
        100,0,0,75,50,100,2.68510293702253;
        100,0,0,75,0,125,3.98360897164573;
        100,100,0,50,66.67,66.67,2.10;
        50,66.67,66.67,25,50,100,2.10;
        100,100,0,75,50,100,2.95361323393586;
        100,100,0,75,100,125,3.66492026704775;
        25,50,100,25,0,125,1.74692809709897;
        25,50,100,25,100,125,1.04815686147718;
        75,50,100,75,0,125,1.74692809709897;
        75,50,100,75,100,125,1.04815686147718;
        25,0,125,50,50,225,3.58013724037771;
        25,100,125,50,50,225,2.14808235084934;
        25,100,125,50,100,250,1.27475487618655;
        75,0,125,50,50,225,3.58013724037771;
        75,100,125,50,50,225,2.14808235084934;
        75,100,125,50,100,250,1.27475487602000;
        50,50,225,50,100,250,5.59016993685697];

plotStructure3D(structure, 10, [0.3, 0.3, 0.3], true);
structureTools = OptStructureTools;
volume = calcStructureVolume(structure);
outputPath = '..\vtkPython\polydatas\';
outputStructure = structure;
outputStructure(:, end) = abs(structure(:, end) * 50);
outputStructure(:, 3) = outputStructure(:, 3)+15;
outputStructure(:, 6) = outputStructure(:, 6)+15;
structureTools.outputStructureFiles(outputStructure, outputPath);
structureTools.outputConnectivity(outputStructure, outputPath);
maximumAreaList = structureTools.getMaximumAreaList(outputStructure);
%% Building sectors
close all
xMax=100; yMax=100; zMax=250;
startCoordinates = [0, 0, 0];
endCoordinates = [xMax, yMax, zMax + 15];
floorLineZ = outputBoxForEachFloor(startCoordinates, endCoordinates, outputStructure, false); % splitted floors in Z direction

%% Printing plan optimization
checkingMaxAngle = 0.977;
floorSpacing = 6.25;
splineSpacing = 5;
expandX = 20;
expandY = 20;
splintLineX = startCoordinates(1)- expandX:splineSpacing:endCoordinates(1)+ expandY; % splitted zones in X direction
splintLineY = startCoordinates(2)- expandX:splineSpacing:endCoordinates(2)+ expandY; % splitted zones in Y direction
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
modelPath = 'optimizedCantilever\\level%i\\'; % Path for the .stl files

[totalPieces, maximumOverhang] = slicing(modelPath, membersInEachFloor, zGrids, anglesForEachFloor, maximumOverhangAngle, maximumB, splintLineX, splintLineY, floorLineZ, levelSpacing, printSpacing, toolPathSpacing, shrinkLength, false, true);

maximumOverhang = 180*(maximumOverhang/pi);
finalCuttings = figure(1);
save('toolPaths.mat', 'totalPieces');
%savefig(finalCuttings, 'cuttings.fig');

%% output2GCode
structureTools = OptStructureTools;
structureTools.toGCode(totalPieces, [-50 -50 -15.01]);

%%
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