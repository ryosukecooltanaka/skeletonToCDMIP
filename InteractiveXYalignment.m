function [pxRatio,cent,dispImg] = InteractiveXYalignment(cellType,tifpath,varargin)

% 5/11/20 by RT
% Interactively compare projected skeleton image with depth discarded MIP
% image to find XY alignment parameter
% This does not do re-projection of skeleton so camera parameter must be 
% fixed first

%% Default parameters
% camera parameters
cameraPosition = [26000,36000,22000]; % looks at the target along the native depth axis
cameraTarget   = [26000,26000,21000]; % Center of the ellipsoid body, based on R4m
cameraUpVector = [0,1,0];
% projection to image conversion parameters
defPxRatio = [1,1] * 8/620;
defCenter  = [605,191]; % this depends on cameraTarget, obviously

if ismac
    keySet = [41,79:82,225];
elseif IsWin
    keySet = [0,0,0,0,0,0];
elseif IsLinux
    keySet = [0,0,0,0,0,0];
else
    error('Unknown OS');
end

% register optional arguments
for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% get MIP
disp('Loading tif image...');
MIP = CDMIPtoMIP(tifpath);
MIPSize = size(MIP);

%% get projection
disp('Projecting SWC...');
SWC = showswcnodesByCellType(cellType,0);
[rotXYZ,R] = projectSWC(SWC,cameraPosition,cameraTarget,cameraUpVector,0);
rotXYZ(:,2) = -rotXYZ(:,2);

pxRatio = defPxRatio;
cent    = defCenter;

dispImg = uint8(zeros(MIPSize(1),MIPSize(2),3));
dispImg(:,:,1) = MIP/2;
figure;

while 1
    projImg = XYZtoMIP(rotXYZ, R, pxRatio, cent, MIPSize);
    projImg = uint8(projImg/max(projImg(:))*255);
    dispImg(:,:,2) = projImg;
    dispImg(:,:,3) = projImg;
    imagesc(dispImg); 
    title(['pixel conversion = ',num2str(pxRatio),' center = ',num2str(cent)]);
    drawnow;
    
    % move paramters
    while 1
        [~,~,kc] = KbCheck;
        if any(kc(keySet(1:5)))
            break
        end
    end
    if kc(keySet(1)); break; end % ESC
    if kc(keySet(6)) % scaling
        if kc(keySet(2))
            pxRatio(1) = pxRatio(1)+0.0005;
        elseif kc(keySet(3))
            pxRatio(1) = pxRatio(1)-0.0005;
        elseif kc(keySet(4))
            pxRatio(2) = pxRatio(2)+0.0005;
        elseif kc(keySet(5))
            pxRatio(2) = pxRatio(2)-0.0005;
        end
    else % translation
        if kc(keySet(2))
            cent(1) = cent(1)+1;
        elseif kc(keySet(3))
            cent(1) = cent(1)-1;
        elseif kc(keySet(4))
            cent(2) = cent(2)+1;
        elseif kc(keySet(5))
            cent(2) = cent(2)-1;
        end
    end
end

end

function out = XYZtoMIP(XYZ, R, pxR, cent, imSize)

    out = zeros(imSize);

    % convert projected XYZ to image coordinate
    imgX = round(XYZ(:,1)*pxR(1)+cent(1));
    imgY = round(XYZ(:,2)*pxR(2)+cent(2));
    
    % ignore nodes that are out of image
    outOfImage = imgX>imSize(2) | imgX<1 | imgY>imSize(1) | imgY<1; 
    imgX = imgX(~outOfImage);
    imgY = imgY(~outOfImage);
    R    = R(~outOfImage); 

    % Only search through pixels with something, using combinatorial unique
    % pixel number search with this hacky algorithm
    % maybe faster than going through all the pixels?
    pxIdx = imgX*1000 + imgY; 
    uniquePxIdx = unique(pxIdx);
    for ii = 1:length(uniquePxIdx)
        maxR = max(R(pxIdx == uniquePxIdx(ii)));
        thisX = floor(uniquePxIdx(ii)/1000);
        thisY = mod(uniquePxIdx(ii),1000);
        out(thisY,thisX) = maxR;
    end

end