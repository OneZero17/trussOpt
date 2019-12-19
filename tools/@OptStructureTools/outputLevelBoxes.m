function outputLevelBoxes(self, zSplitLine, startingPoint, EndPoint, path)
    for i = 1:size(zSplitLine, 2) - 1
        currentStartZ = zSplitLine(i);
        currentEndZ = zSplitLine(i+1);
        box1StartPoint = [startingPoint(1) startingPoint(2) startingPoint(3) - 5];
        box1EndPoint = [EndPoint(1) EndPoint(2) currentStartZ];
        if abs(box1EndPoint(3)-box1StartPoint(3)) >1e-3
            [F, V] = generateCuboid(box1StartPoint, box1EndPoint);
            fileName = [path, sprintf('level%dbox1.stl', i)];
            stlwrite(fileName, F, V);
        end
        
        box2StartPoint = [startingPoint(1) startingPoint(2) currentEndZ];
        box2EndPoint = [EndPoint(1) EndPoint(2) EndPoint(3) + 5];
        if abs(box2EndPoint(3)-box2StartPoint(3)) >1e-3
            [F, V] = generateCuboid(box2StartPoint, box2EndPoint);
            fileName = [path, sprintf('level%dbox2.stl', i)];
            stlwrite(fileName, F, V);
        end
    end
end

