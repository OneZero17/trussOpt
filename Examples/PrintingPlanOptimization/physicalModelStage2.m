cylinderHeight = 50;
beamThickness = 0.5;
cylinderDiamter = 100;
radius = 50;
spacing = 1;
% start

circlePerimeter = cylinderDiamter* pi;
layerNumber = round(circlePerimeter/(0.5*4));
layers = cell(layerNumber+1, 1);
overhang = 90;
zOverhangMax = radius*sin(pi*(90-overhang)/180);
for i = 0:layerNumber
    z = radius * sin(i*pi/2/layerNumber);
    nextZ = radius * sin((i+1)*pi/2/layerNumber);
    overhangZ = z;
    if z>zOverhangMax
        overhangZ = zOverhangMax;
    end
    gCodeCoordinates = createGcodeCircle([0, 0, z], sqrt(radius^2 - z^2), [0, overhangZ, sqrt(radius^2 - overhangZ^2)], spacing);
    zstep = (nextZ - z) / (size(gCodeCoordinates, 1)-1)    
    gCodeCoordinates(:, 3) = z:zstep:nextZ
    layers{i+1, 1} = gCodeCoordinates;
end

% write
fileName = "testGCode.txt";
fid = fopen( fileName, 'wt' );

for i = 1 : size(layers, 1)
    currentlayer = layers{i, 1};
    for j = 1:size(currentlayer, 1)
        if j == 1
            fprintf(fid, 'G54 X%.3f Y%.3f Z%.3f B%.3f C%.3f\n', currentlayer(j, :));
            fprintf(fid, 'M110\n'); 
        elseif j == size(currentlayer, 1)
            fprintf(fid, 'G1 X%.3f Y%.3f Z%.3f B%.3f C%.3f\n', currentlayer(j, :));
            fprintf(fid, 'M111\n');   
        else
            fprintf(fid, 'G1 X%.3f Y%.3f Z%.3f B%.32f C%.3f\n', currentlayer(j, :));
        end
    end
end

