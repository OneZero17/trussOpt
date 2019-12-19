function [P, T] = createSphere(center, radius)
[ P, T ] = generateSphereMesh( 3, 'oct');
P = P * radius;
P = (P' +  center)';
end

