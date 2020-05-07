function [rotXYZ,R,structureType] = projectSWC(SWC,cameraPosition,cameraTarget,cameraUpVector,showFig)

% Created by Ryosuke Tanaka 05/06/2020
% Rotate SWC data into the standard Left hand coordinate

% SWC contains matrix of a SWC file for a neuron or a cell containing those
% matrices (output of showswcnodes functions)
% The rest of input arguments do what they say
% position arguments should be provided in the native coordinate
% cameraupvector is interpreted in the standard left hand coordinate

if nargin<5
    showFig = 1;
end

if iscell(SWC)
    SWCcell = SWC;
    SWC = [];
    for ii = 1:length(SWCcell)
        SWC = [SWC;SWCcell{ii}];
    end
end
% extract position info
XYZ = SWC(:,3:5); % native coordinate of neuPrint SWC : (X,Y,Z) = (R,A,V) 
                  % By R I mean the right side when seen from the front
                  % actually left hemisphere is positive x
                  
XYZ = [XYZ(:,1),-XYZ(:,3),-XYZ(:,2)]; % standard left hand coordinate 
cameraPosition = cameraPosition([1,3,2]).*[1,-1,-1];
cameraTarget   = cameraTarget([1,3,2]).*[1,-1,-1];


% other information
R = SWC(:,6); % not sure if I am going to use this...
structureType = SWC(:,2); % used to ignore soma brightness

if showFig
    figure;
    hold on
    scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'MarkerEdgeColor',[0.5,0.5,0.5]);
    scatter3(cameraPosition(1),cameraPosition(2),cameraPosition(3),100,'MarkerEdgeColor',[1,0,0]);
    scatter3(cameraTarget(1),cameraTarget(2),cameraTarget(3),100,'MarkerEdgeColor',[0,0,1]);
    plot3(cameraPosition(1)+[0,cameraUpVector(1)]*10000,...
        cameraPosition(2)+[0,cameraUpVector(2)]*10000,...
        cameraPosition(3)+[0,cameraUpVector(3)]*10000);
    xlabel('x (\mum)');
    ylabel('y (\mum)');
    zlabel('z (\mum)');
    title('Before Shift');
    axis equal ij % ij is the left hand
end

% shift origin to the position of camera
XYZ = XYZ - cameraPosition;

% unit vector of the direction of your gaze
eyevec = cameraTarget - cameraPosition;
eyevec = eyevec/norm(eyevec);

% figure out how to rotate eyevec to align it 
eyevec_xz = eyevec;
eyevec_xz(2) = 0; % laying on xz plane
if norm(eyevec_xz)~=0
    theta1 = acos(eyevec_xz(3)/norm(eyevec_xz)); % rotate eyevec by theta1 around y-axis, then it wil be on yz-plane
else
    theta1 = 0;
end
if eyevec(1)>0
    R1 = myrot(-theta1,2);
else
    R1 = myrot(theta1,2);
end    

eyevec_yz = (R1*eyevec')';
if norm(eyevec_yz)~=0
    theta2 = acos(eyevec_yz(3)/norm(eyevec_yz)); % rotate eyevec by theta2 around y-axis, then it wil be on yz-plane
else
    theta2 = 0;
end
if eyevec_yz(2) > 0
    R2 = myrot(theta2,1);
else
    R2 = myrot(-theta2,1);
end

newCamUp = (R2*R1*cameraUpVector')'; % camera-up in the new coordinate (note that positive y is down in the image coordinate -- this will be taken care later)
newCamUp(3) = 0; % ignore depth (Z)
if norm(newCamUp)~=0
    theta3 = acos(newCamUp(2)/norm(newCamUp)); 
else
    theta3 = 0;
end
if newCamUp(1)>0
    R3 = myrot(-theta3,3); % rotate around the depth axis 
else
    R3 = myrot(theta3,3);
end

rotXYZ = (R3*R2*R1*XYZ')';
rotCTarg = (R3*R2*R1*(cameraTarget - cameraPosition)')'; % only Z should have non-zero
rotXYZ(:,3) = rotXYZ(:,3) - rotCTarg(3); % target centered z depth because camera position doesn't mean anything

if showFig
    figure;
    title('After rotation (Z discarded)')
    depth = rotXYZ(:,3);
    depth = (depth-min(depth))/range(depth);
    % green is close, pink is away
    scatter(rotXYZ(:,1),rotXYZ(:,2),R,[depth,1-depth,depth/2]);

    axis equal xy
end

end