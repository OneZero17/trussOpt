cylinderHeight = 50;
beamThickness = 0.8;
cylinderDiamter = 100;
radius = 50;
spacing = 5;
axis3 = false;
% start

circlePerimeter = cylinderDiamter* pi;
layerNumber = round(circlePerimeter/(0.5*4));
layers = cell(layerNumber+1, 1);
overhang = 0;
zOverhangMax = radius*sin(pi*(90-overhang)/180);
for i = 0:layerNumber-1
    z = radius * sin(i*pi/2/layerNumber);
    nextZ = radius * sin((i+1)*pi/2/layerNumber);
    currentR = sqrt(radius^2 - z^2);
    nextR = sqrt(radius^2 - nextZ^2);
    overhangZ = z;
    if z>zOverhangMax
        overhangZ = zOverhangMax;
    end
    gCodeCoordinates = createTapCircle([0, 0, z], currentR, @(z, r)[0, overhangZ, sqrt(radius^2 - overhangZ^2)], spacing, z, nextZ, currentR, nextR, i);
    layers{i+1, 1} = gCodeCoordinates;
end

% write
fileName = "testTapFile.tap";
fid = fopen( fileName, 'wt' );
fprintf(fid, 'G01 X%.2f Y%.2f Z%.2f RZ%.2f RY%.2f RX%.2f L%.1f LINK\n', [radius, 0, 0, 0, 0, 0, 1]);
for i = 1 : size(layers, 1)
    currentlayer = layers{i, 1};
    for j = 1:size(currentlayer, 1)
            fprintf(fid, 'G01 X%.2f Y%.2f Z%.2f RZ%.2f RY%.2f RX%.2f L%.1f ADD\n', [currentlayer(j, :), i]);
            %fprintf(fid, 'G01 X%.2f Y%.2f Z%.2f C%.2f A%.2f B%.2f L%.1f ADD\n', [currentlayer(j, :), i]);
    end
end

function gcodeCoordinates = createTapCircle(center, radius, normalDirection, spacing, startZ, endZ, startX, endX, layerNum)

    perimeter = 2*radius*pi;
    spcingNum = round(perimeter / spacing);
    firstPoint = center;

    gcodeCoordinates = zeros(spcingNum+1, 6);
    Zspacing = (endZ - startZ)/spcingNum;
    Xspacing = (endX - startX)/spcingNum;
    rotateCAngle = pi/180*(layerNum*360:360/spcingNum:(layerNum+1)*360)' ;
    for i = 0:spcingNum
        currentPoint = firstPoint + [radius, 0, 0] + [-Xspacing * i, 0, Zspacing*i];
        normalDirections = normalDirection(currentPoint(3), 50);
        currentPoint = rotate_3D(currentPoint', 'any', rotateCAngle(i+1), [0, 0, 1]')';
        currentDirection = rotate_3D(normalDirections', 'any', rotateCAngle(i+1), [0, 0, 1]')';
        currentDirection = currentDirection/norm(currentDirection);
        angles = getEularAngles(currentDirection);
        angles = rad2deg(angles);
        gcodeCoordinates(i+1, :) = [currentPoint, angles];
    end

end

function eul = getEularAngles(direction)

    r = vrrotvec([0, 0, 1], direction);
    m = vrrotvec2mat(r);
    eul = rotm2eul(m, 'ZYX');
 
end