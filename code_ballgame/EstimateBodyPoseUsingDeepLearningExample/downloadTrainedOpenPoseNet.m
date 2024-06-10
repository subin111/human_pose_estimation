function downloadTrainedOpenPoseNet(url,destination)
% The downloadTrainedOpenPoseNet function downloads a pretrained 
% OpenPose network.
%
% Copyright 2020 The MathWorks, Inc.

filename = 'human-pose-estimation.zip';
netDirFullPath = destination;
netFileFullPath = fullfile(destination,filename);

if ~exist(netFileFullPath,'file')
    fprintf('Downloading pretrained OpenPose network.\n');
    fprintf('This can take several minutes to download...\n');
    if ~exist(netDirFullPath,'dir')
        mkdir(netDirFullPath);
    end
    websave(netFileFullPath,url);
    fprintf('Done.\n\n');
else
    fprintf('Pretrained OpenPose network already exists.\n\n');
end
end