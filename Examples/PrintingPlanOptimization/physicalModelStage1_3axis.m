cylinderHeight = 50;
beamThickness = 0.5;
cylinderDiamter = 100;
radius = 50;
spacing = 1;
axis3 = false;
% start

circlePerimeter = cylinderDiamter* pi;
layerNumber = round(circlePerimeter/(0.5*4));
layers = cell(layerNumber+1, 1);
fileName = "testGCode.txt";
fid = fopen( fileName, 'wt' );
fprintf(fid, 'G54 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', [-radius, 0, 0, 0, 0]);
fprintf(fid, 'M110\n'); 
for i = 0:layerNumber-1
    z = radius * sin(i*pi/2/layerNumber);
    nextZ = radius * sin((i+1)*pi/2/(layerNumber));
    nexthalfZ = (z + nextZ)/2;
    currentR = 2* radius - sqrt(radius^2 - nexthalfZ^2);
    nextR = 2* radius - sqrt(radius^2 - nextZ^2);
    fprintf(fid, 'G2 X%.2f Y%.2f Z%.2f I0 J0 K0 F=VIT_TIR\n', [currentR, 0, nexthalfZ]);
    fprintf(fid, 'G2 X%.2f Y%.2f Z%.2f I0 J0 K0 F=VIT_TIR\n', [-nextR, 0, nextZ]);
end
fprintf(fid, 'M111\n'); 
% write
% fileName = "testGCode.txt";
% fid = fopen( fileName, 'wt' );
% 
% for i = 1 : size(layers, 1)
%     currentlayer = layers{i, 1};
%     for j = 1:size(currentlayer, 1)
%         if j == 1
%             fprintf(fid, 'G54 X%.2f Y%.2f Z%.2f B%.2f C%.2f\n', currentlayer(j, :));
%             fprintf(fid, 'M110\n'); 
%         elseif j == size(currentlayer, 1)
%             fprintf(fid, 'G1 X%.2f Y%.2f Z%.2f B%.2f C%.2f F=VIT_TIR\n', currentlayer(j, :));
%             fprintf(fid, 'M111\n');   
%         else
%             fprintf(fid, 'G1 X%.2f Y%.2f Z%.2f B%.2f C%.2f F=VIT_TIR\n', currentlayer(j, :));
%         end
%     end
% end