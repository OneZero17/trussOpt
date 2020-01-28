function points = boundingBoxCornerPoints(boundingBox)
    points = [boundingBox(1), boundingBox(3), boundingBox(5);
              boundingBox(1), boundingBox(3), boundingBox(6);
              boundingBox(1), boundingBox(4), boundingBox(5);
              boundingBox(1), boundingBox(4), boundingBox(6);
              boundingBox(2), boundingBox(3), boundingBox(5);
              boundingBox(2), boundingBox(3), boundingBox(6);
              boundingBox(2), boundingBox(4), boundingBox(5);
              boundingBox(2), boundingBox(4), boundingBox(6);];
end

