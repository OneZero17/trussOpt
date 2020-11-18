cylinderHeight = 50;
beamThickness = 0.5;
cylinderDiamter = 100;
radius = 50;
spacing = 5;
axis3 = false;
% start

circlePerimeter = cylinderDiamter* pi;
layerNumber = round(circlePerimeter/(0.5*4));
layers = cell(layerNumber+1, 1);
overhang = 90;
zOverhangMax = radius*sin(pi*(90-overhang)/180);
pieceNum = 5;
increaseRadiusForEachPiece = radius/pieceNum;
pieceStartingLayerNum = zeros(pieceNum, 1); 
currentPieceHeight = radius;
currentPieceNum = 1;

for i = 0:layerNumber-1
    z = radius * sin(i*pi/2/layerNumber);
    nextZ = radius * sin((i+1)*pi/2/layerNumber);
    currentR = 2* radius - sqrt(radius^2 - z^2);
    if currentR>=currentPieceHeight
       currentPieceHeight = currentPieceHeight + increaseRadiusForEachPiece;
       pieceStartingLayerNum(currentPieceNum) = i;
       currentPieceNum = currentPieceNum+1;
    end
    nextR = 2* radius - sqrt(radius^2 - nextZ^2);
    overhangZ = z;
    gCodeCoordinates = createGcodeCircle([0, 0, z], currentR, @(z, r)[0, z, sqrt(r^2 - z^2)], spacing, z, nextZ, currentR, nextR, i);
    layers{i+1, 1} = gCodeCoordinates;
end

% write
fileName = "testGCode.txt";
fid = fopen( fileName, 'wt' );
for i = 1:pieceNum
    pieceAverageRadius = radius + (i-0.5)*increaseRadiusForEachPiece;
    fprintf(fid, 'VIT_TIR%i = rRequiredVelocity * %.2f \n', i, pieceAverageRadius/radius);
end

fprintf(fid, 'G54 X%.3f Y%.3f Z%.3f B%.3f C%.3f\n', [radius, 0, 0, 0, 0]);
fprintf(fid, 'M110\n'); 
for i = 1 : size(layers, 1)
    currentlayer = layers{i, 1};
    currentPieceNum = 0;
    for j = 1:pieceNum
        if i>pieceStartingLayerNum(j)
            currentPieceNum = j;
        end
    end
     
    for j = 1:size(currentlayer, 1)
            fprintf(fid, 'G1 X%.3f Y%.3f Z%.3f B%.3f C%.3f F=VIT_TIR%i\n', currentlayer(j, :), currentPieceNum);

    end
end
fprintf(fid, 'M111\n');   



