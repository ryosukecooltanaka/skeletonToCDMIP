function CDMIP = generateColorDepthMIPfromSWC(cellType)

% Created by Ryosuke Tanaka 05/07/2020
% The main function that generates Color Depth MIP image from SWC skeleton
% data downloaded from neuprint

% Default camera parameters
% they use 0.62 um isotropic XY pixels
% Color Depth MIP tif says they have 174 slices and the slice appears to be
% thicker than 0.62um. FlyLight LSM are 1 um, so I am guessing they are 1
% um thick... might change
% neuPrint EM data are in 8nm pixel

% these are in 8nm pixels
cameraPosition = [26000,36000,22000]; % looks at the target along the native depth axis
cameraTarget   = [26000,26000,21000]; % Center of the ellipsoid body, based on R4m
cameraUpVector = [0,1,0];

% image related
sizeX = 1210;
sizeY = 566;
load psychedericrainbow % color depth MIP LUT by Otsuna 2018

targetLocOnImageXY = [605,191]; % in px, center of R4m, to be adjusted
pxRatioXY = 8/620; % for xy; 8nm vs 0.62um - may need adjustment b/c of brain size difference
targetLocOnImageZ = 80;
pxRatioZ = 8/1000; % 1um = 1000nm slice vs 8nm native pixel
nZSlice = 174;


SWC = showswcnodesByCellType(cellType,0);
[rotXYZ,R,structureType] = projectSWC(SWC,cameraPosition,cameraTarget,cameraUpVector,0);


% transfor rotated XYZ into pixel location
rotXYZ(:,2) = -rotXYZ(:,2); % flip Y to transform from xy to ij coordinate
nodeInPxXY   = round(rotXYZ(:,1:2)*pxRatioXY + targetLocOnImageXY);
nodeInZSlice = round(rotXYZ(:,3)*pxRatioZ + targetLocOnImageZ);
if any(nodeInZSlice<1)
    nodeInZSlice(nodeInZSlice<1) = 1;
    warning('Flattened nodes to close');
end
if any(nodeInZSlice>nZSlice)
    nodeInZSlice(nodeInZSlice>nZSlice) = nZSlice;
    warning('Flattened nodes to far');
end

grayIntensity = R/max(R)*255;

CDMIP = zeros(sizeY,sizeX,3);
for ii = 1:sizeY
    for jj = 1:sizeX
        thisPxInd = find(nodeInPxXY(:,2)==ii & nodeInPxXY(:,1)==jj);
        if ~isempty(thisPxInd) % if there is any node in this pixel
            [maxGray,maxPxInd] = max(grayIntensity(thisPxInd));
            maxPxZ = nodeInZSlice(thisPxInd(maxPxInd));
            CDMIP(ii,jj,:) = psychedericrainbow(ceil(maxPxZ/nZSlice*255),:); 
        end
    end
end

CDMIP = uint8(CDMIP);
figure; imshow(CDMIP);


end