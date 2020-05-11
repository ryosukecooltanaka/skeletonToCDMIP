function [pxRatioZ,cent] = InteractiveZalignment(cellType,tifpath,varargin)

% 5/11/20 by RT
% Interactively compare projected skeleton image with intensity discarded
% depth depth image to find Z alignment parameter
% This does not do re-projection of skeleton so camera parameter must be 
% fixed first

%% Default parameters
% camera parameters
cameraPosition = [26000,36000,22000]; % looks at the target along the native depth axis
cameraTarget   = [26000,26000,21000]; % Center of the ellipsoid body, based on R4m
cameraUpVector = [0,1,0];
% projection to image conversion parameters
defPxRatioZ = 8/1000;
defCenterZ  = 80; % this depends on cameraTarget, obviously
XYPxRatio = [1,1] * 8/620;
XYCenter  = [605,191]; % this depends on cameraTarget, obviously

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
dMap = CDMIPtoDepthMap(tifpath);
dMapSize = size(dMap);

%% get projection
disp('Projecting SWC...');
SWC = showswcnodesByCellType(cellType,0);
[rotXYZ,R] = projectSWC(SWC,cameraPosition,cameraTarget,cameraUpVector,0);
rotXYZ(:,2) = -rotXYZ(:,2);
projdMap = XYZtodMap(rotXYZ, R, XYPxRatio, XYCenter, dMapSize);

% Show target depth Map
figure;
% Update Z scaling/positioning, show XZ slice
slice = round(dMapSize(1)/2);
pxRatioZ = defPxRatioZ;
cent     = defCenterZ;
while 1
    % Show slice location
    s1 = subplot(2,2,1); 
    cla(s1);
    hold(s1, 'on');
    imagesc(dMap); 
    colormap(s1,'gray');
    caxis([1,255]);
    plot([1,dMapSize(2)],slice*[1,1],'r--');
    axis ij tight
    xlim([1,dMapSize(2)]); ylim([1,dMapSize(1)]);
    colorbar;
    hold(s1, 'off');
    
    % Show depth map
    s2 = subplot(2,2,3);
    cla(s2)
    hold(s2, 'on');
    projImg = projdMap*pxRatioZ + cent;
    imagesc(projImg);
    colormap(s2,'gray');
    caxis([1,255]);
    plot([1,dMapSize(2)],slice*[1,1],'r--');
    axis ij tight
    xlim([1,dMapSize(2)]); ylim([1,dMapSize(1)]);
    colorbar;
    hold(s2, 'off');
    
    % show slices
    s3 = subplot(1,2,2);
    cla(s3);
    title(['pixel conversion = ',num2str(pxRatioZ),' center = ',num2str(cent)]);
    targSlice = dMap(slice,:);
    moveSlice = projImg(slice,:);
    hold(s3, 'on');
    scatter(1:dMapSize(2),targSlice,'ko');
    scatter(1:dMapSize(2),moveSlice,'r+');
    xlim([1,dMapSize(2)]); ylim([1,255]);
    xlabel('x (px)'); ylabel('slice');
    hold(s3, 'off');
    
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
            slice = slice + 5;
        elseif kc(keySet(3))
            slice = slice - 5;
        end
    else % translation
        if kc(keySet(2))
            cent = cent + 1;
        elseif kc(keySet(3))
            cent = cent - 1;
        elseif kc(keySet(4))
            pxRatioZ = pxRatioZ+0.0001;
        elseif kc(keySet(5))
            pxRatioZ = pxRatioZ-0.0001;
        end
    end
end

end

function out = XYZtodMap(XYZ, R, pxR, cent, imSize)

    out = nan(imSize);

    % convert projected XYZ to image coordinate
    imgX = round(XYZ(:,1)*pxR(1)+cent(1));
    imgY = round(XYZ(:,2)*pxR(2)+cent(2));
    Z = XYZ(:,3); % use native Z
    
    % ignore nodes that are out of image
    outOfImage = imgX>imSize(2) | imgX<1 | imgY>imSize(1) | imgY<1; 
    imgX = imgX(~outOfImage);
    imgY = imgY(~outOfImage);
    R    = R(~outOfImage); 
    Z    = Z(~outOfImage);
    
    % Only search through pixels with something, using combinatorial unique
    % pixel number search with this hacky algorithm
    % maybe faster than going through all the pixels?
    pxIdx = imgX*1000 + imgY; 
    uniquePxIdx = unique(pxIdx);
    for ii = 1:length(uniquePxIdx)
        maxR = max(R(pxIdx == uniquePxIdx(ii)));
        thisZ = Z(pxIdx == uniquePxIdx(ii));
        maxZ  = thisZ(R(pxIdx == uniquePxIdx(ii))==maxR);
        thisX = floor(uniquePxIdx(ii)/1000);
        thisY = mod(uniquePxIdx(ii),1000);
        out(thisY,thisX) = maxZ(1);
    end

end