% INPUT
%   pairs: matrix of size [numPairs * 4(x1,y1,x2,y2)] contains the valid
%       pairs of the pair type we are adding to poses
%   poses: matrix of size [numPeople * 18(aka numBodyParts) * 2(x,y)]
%       contains already existing poses
%   partAIdx: body part index of the first body part in the pair type we
%       are adding
%   partBIdx: body part index of the second body part in the pair type we
%       are adding
% OUTPUT
%   poses: matrix of size [numPeople * 18(aka numBodyParts) * 2(x,y)] that
%       the inputted poses with the valid pairs added to the appropriate
%       poses
function [poses] = addBodyPartPairsToBodyPoses(pairs,poses,partAIdx,partBIdx)
    EMPTY_POSE = repmat([NaN NaN],18,1);
    
    for i = 1:size(pairs,1)
        % get pair and each part
        pair = squeeze(pairs(i,:));
        partA = pair(1:2);
        partB = pair(3:4);
        
        partsAFound = poses(:,partAIdx,:); %all part As already found
        partsAFoundSize = size(partsAFound);
        partsAFound = reshape(partsAFound, partsAFoundSize([1 3])); %want to squeeze out only middle dimension
        partsBFound = poses(:,partBIdx,:); %all part Bs already found
        partsBFoundSize = size(partsBFound);
        partsBFound = reshape(partsBFound, partsBFoundSize([1 3]));
        
        % find if partA and/or partB are already in poses 
        partAInPoses = ismember(partsAFound, partA, 'rows');
        poseAIdx = find(partAInPoses, 1);
        partAInPoses = any(partAInPoses, 'all');
        partBInPoses = ismember(partsBFound, partB, 'rows');
        poseBIdx = find(partBInPoses, 1);
        partBInPoses = any(partBInPoses, 'all');
        
        % if only partA is in poses, we want to add partB to the pose that
        % partA is in
        if partAInPoses
            if ~partBInPoses
               poses(poseAIdx, partBIdx, :) =  partB;
            end
        % if only partB is in poses, we want to add partA to the pose that
        % partB is in
        elseif partBInPoses
            poses(poseBIdx, partAIdx, :) = partA;
        % if neither partA or partB are in poses, we should create a new
        % pose with these parts
        else
            poses(end + 1, :, :) = EMPTY_POSE; %empty pose with nans
            poses(end, partAIdx, :) = partA;
            poses(end, partBIdx, :) = partB;
        end
        % if both partA and partB are in poses, we should have skipped and
        % not added them
    end
end