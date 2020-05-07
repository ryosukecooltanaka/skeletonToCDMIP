function R = myrot(theta,axis)

% Created by Ryosuke Tanaka 05/06/2020

% THETA in radian
% AXIS 1 for x, 2 for y, 3 for z
R = [];
switch axis
    case 1
        R = [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];
    case 2
        R = [cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];
    case 3
        R = [cos(theta) -sin(theta) 0 ; sin(theta) cos(theta) 0 ; 0 0 1];
end

end