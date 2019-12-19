function angle = angleBetweenVectors(vector1, vector2)
    angle = atan2(norm(cross(vector1, vector2)), dot(vector1, vector2));
end

