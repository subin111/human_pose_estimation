%% 
% https://dash.readme.com/project/makepictogram/v1.0/docs/onnx-converter
% readme 사용설명서 입니다 입력코드에 문제가 있을 시 사용설명서를 참고해야 할 것 같습니다!
% openpose net 외부 url로 다운받아서 압축 해제
dataDir = fullfile(tempdir,'OpenPose');
trainedOpenPoseNet_url = "https://ssd.mathworks.com/supportfiles/vision/data/human-pose-estimation.zip";
downloadTrainedOpenPoseNet(trainedOpenPoseNet_url,dataDir)

unzip(fullfile(dataDir,'human-pose-estimation.zip'),dataDir);

modelfile = fullfile(dataDir,'human-pose-estimation.onnx');

layers = importONNXLayers(modelfile,"ImportWeights",true);
layers = removeLayers(layers,layers.OutputNames);
net = dlnetwork(layers);

%% 
% input image

I = imread("https://files.readme.io/df7b86a-pose4.jpg");

% 성공한 축구 사진
% "https://files.readme.io/c832775-pose8.jpg"
% "https://files.readme.io/ec0edc6-pose9.jpg"
% 배구, shape 사이의 간격이 좁아 마스크 필터링이 덜 괜찮게 됨.
% "https://files.readme.io/03617e1-pose14.jpg"
% "https://files.readme.io/ac624ff-pose22.jpg"
% 축구, 무게중심 잘 못 된 사진
% "https://files.readme.io/054fde0-pose16.jpg"
% 채도, 밝기, 사진 크기 수정 등으로 pose 인식이 잘 안 된.
% "https://files.readme.io/11ede50-pose17.jpg"
% "https://files.readme.io/106b86e-pose19.jpg"

im = imresize(I,[470 470]);

%% 

% openpose net을 이용한 body-pose-estimation 예제 code
netInput = im2single(im)-0.5;
netInput = netInput(:,:,[3 2 1]);
netInput = dlarray(netInput,"SSC");
[heatmaps,pafs] = predict(net,netInput);
heatmaps = extractdata(heatmaps);
montage(rescale(heatmaps),"BackgroundColor","b","BorderSize",3)
idx = 1;
hmap = heatmaps(:,:,idx);
hmap = imresize(hmap,size(im,[1 2]));
imshowpair(hmap,im);
heatmaps = heatmaps(:,:,1:end-1);
pafs = extractdata(pafs);
montage(rescale(pafs),"Size",[19 2],"BackgroundColor","b","BorderSize",3)
idx = 1;
impair = horzcat(im,im);
pafpair = horzcat(pafs(:,:,2*idx-1),pafs(:,:,2*idx));
pafpair = imresize(pafpair,size(impair,[1 2]));
imshowpair(pafpair,impair);
params = getBodyPoseParameters;
poses = getBodyPoses(heatmaps,pafs,params);
renderBodyPoses(im,poses,size(heatmaps,1),size(heatmaps,2),params);

figure(gcf)

%% 
% poses에서 nan 값을 그 전 데이터값과 동일하게 만들어 insertshape의 input data를 모두 finite하게 만듦
poses(:,:,1)=fillmissing(poses(:,:,1),'previous');
poses(:,:,2)=fillmissing(poses(:,:,2),'previous');

%% 
figure;
im2= im;

rneck = 5*sqrt((poses(1)-poses(2)).^2 + (poses(19)-poses(20)).^2);
rleftear = 5*sqrt((poses(1)-poses(17)).^2 + (poses(19)-poses(35)).^2);
rrightear = 5*sqrt((poses(1)-poses(18)).^2 + (poses(19)-poses(36)).^2);

r = max([rneck, rrightear,rleftear]); % 얼굴의 반지름을 코를 기준으로 목, 왼쪽 귀, 오른쪽 귀 까지의 거리 중 가장 긴 값으로 선택

RGB = insertShape(im2,"filled-polygon",[8*poses(3) 8*poses(21); 8*poses(6) 8*poses(24); 8*poses(12) 8*poses(30); 8*poses(9) 8*poses(27)],...
                  Color=[255 255 255],Opacity=1); % 몸통의 흰 색 다각형 

RGB = insertShape(RGB,"polygon",[8*poses(3) 8*poses(21); 8*poses(6) 8*poses(24); 8*poses(12) 8*poses(30); 8*poses(9) 8*poses(27)],...
                  Color=[0 0 140],Opacity=1,LineWidth=20); % 몸통의 흰 색 다각형의 테두리

RGB = insertShape(RGB,"filled-circle",[8*poses(1) 8*poses(19) r],Color=[0 0 140],Opacity=1); % 얼굴

RGB = insertShape(RGB,"line",[8*poses(3) 8*poses(21) 8*poses(4) 8*poses(22); 8*poses(4) 8*poses(22) 8*poses(5) 8*poses(23); ...
                              8*poses(6) 8*poses(24) 8*poses(7) 8*poses(25); 8*poses(7) 8*poses(25) 8*poses(8) 8*poses(26); ...
                              8*poses(9) 8*poses(27) 8*poses(10) 8*poses(28); 8*poses(10) 8*poses(28) 8*poses(11) 8*poses(29); ...
                              8*poses(12) 8*poses(30) 8*poses(13) 8*poses(31); 8*poses(13) 8*poses(31) 8*poses(14) 8*poses(32)], ...
                              Color=[0 0 140],Opacity=1,LineWidth=30); % 팔, 다리

RGB = insertShape(RGB,"filled-circle",[8*poses(3) 8*poses(21) 15; 8*poses(4) 8*poses(22) 15; ...
                                       8*poses(5) 8*poses(23) 15; 8*poses(6) 8*poses(24) 15; ...
                                       8*poses(7) 8*poses(25) 15; 8*poses(8) 8*poses(26) 15; ...
                                       8*poses(9) 8*poses(27) 15; 8*poses(10) 8*poses(28) 15; ...
                                       8*poses(11) 8*poses(29) 15; 8*poses(12) 8*poses(30) 15; ...
                                       8*poses(13) 8*poses(31) 15; 8*poses(14) 8*poses(32) 15; ...
                                       ],Color=[0 0 140],Opacity=1); % 팔, 다리 사이의 관절 (poses points)

imshow(RGB)
%% 
% chromakey code week4 참고.
% msk : im3에서 픽토그램으로 그려진 인물의 파란색만 흰 색으로 인식, 나머지는 검은색으로 인식. 
im3 = RGB;
im3_ = im3;
[h,s,v]=rgb2hsv(im3); % RGB 영상을 색, 채도, 명도로 나타내는 hsv 영상으로 변환.
msk = (h>0.66665 & h<0.66667);

figure;
imshow(msk);
%%
BW = imclearborder(msk,4); 
figure;
imshow(BW);

% while 반복문으로 마스크 BW_의 경계를 뚜렷하게 하고, floor(r^2*pi-130)보다 작은 크기를 가지는 흰색
% 부분을 제거한 작업.

k = 1;
while k < 16
    BW_ = imclearborder(BW,4);
    BW_ = bwareaopen(BW_,floor(r^2*pi-130),4);
    k = k + 1;
end

figure;
imshow(BW_);

%%
% 마스크 BW_에 해당 안 되는 배경 부분을 흰색으로 바꾸는 과정.

im3(find(~BW_(:)) + numel(~BW_)*0) = 256;
im3(find(~BW_(:)) + numel(~BW_)*1) = 256;
im3(find(~BW_(:)) + numel(~BW_)*2) = 256;

figure, imshow(cat(2,im3_,im3)); % im3에서 ~BW_가 흰색으로 변한 결과와 원래의 im3을 함께 figure

%% 
% GoogLeNet을 사용하여 영상 분류하기 예제 코드

net = googlenet;
im4 = im;
inputSize = net.Layers(1).InputSize;
classNames = net.Layers(end).ClassNames;
numClasses = numel(classNames);
disp(classNames(randperm(numClasses,10))) % 임의로 10개의 클래스 이름을 표시.

Inin = imresize(im4,inputSize(1:2));
[label,scores] = classify(net,Inin);

[~,idx] = sort(scores,'descend');
idx = idx(5:-1:1); 
classNamesTop = net.Layers(end).ClassNames(idx);
scoresTop = scores(idx);
% classNamesTop(단어)과 scoresTop(그 해당 단어일 확률)을 상위 5개 중 
% 스코어링이 낮은 것 부터 오름차순으로 배열. 

figure
barh(scoresTop)
xlim([0 1])
title('Top 5 Predictions')
xlabel('Probability')
yticklabels(classNamesTop)

%%

TF1 = contains(classNamesTop(5),"ball"); % 가장 스코어를 많이 받은 단어에 ball이 들어가 있으면 TF 값에 1을 대입, 가장 이상적인 경우.
TF2 = contains(classNamesTop(4),"ball"); % 스코어링 1위가 목표 단어가 아닐 경우.
TF3 = contains(classNamesTop(3),"ball");
TF4 = contains(classNamesTop(2),"ball");
TF5 = contains(classNamesTop(1),"ball");

if TF1 == 1 
    sports = classNamesTop(5);
elseif TF2 == 1 
    sports = classNamesTop(4);
elseif TF3 == 1
    sports = classNamesTop(3);
elseif TF4 == 1
    sports = classNamesTop(2);
elseif TF5 == 1
    sports = classNamesTop(1);
end

%%

rnecklefthip = sqrt((poses(2)-poses(9)).^2 + (poses(20)-poses(27)).^2);
rneckrighthip = sqrt((poses(2)-poses(12)).^2 + (poses(20)-poses(30)).^2);
% 목에서 왼쪽 엉덩이까지의 거리와 목에서 오른쪽 엉덩이까지의 거리를 비교해 더 짧은 쪽
% 에 공이 위치하도록 함. (전자가 짧다 그러면 영상의 왼쪽에 공이 위치, 후자면 그 반대)

if (sports == "soccer ball") || (sports == "soccerball") % 종목이 축구인 image

    if rnecklefthip < rneckrighthip

        X = [r min(8*poses(11), 8*poses(14))];
        Y = floor(X); 
        imin = Y(1); imax = Y(2);
        positionx = randi([imin imax],1,1);
        positiony = max(8*poses(29), 8*poses(32));
    
    elseif rnecklefthip > rneckrighthip

        X = [max(8*poses(11), 8*poses(14)) 470-r];
        Y = floor(X); 
        imin = Y(1); imax = Y(2);

        positionx = randi([imin imax],1,1);
        positiony = max(8*poses(29), 8*poses(32));
     
    end

    im5 = insertShape(im3,"circle",[positionx positiony r],Color=[0 0 140],Opacity=1,LineWidth=10); % 해당 위치에 공 삽입.


elseif (sports == "volleyball") || (sports == "volley ball") % 종목이 배구인 image

    if rnecklefthip < rneckrighthip

        X = [80+r min(8*poses(5), 8*poses(8))];
        Y = floor(X); 
        imin = Y(1); imax = Y(2);

        positionx = randi([imin imax],1,1);
        positiony = min(8*poses(23), 8*poses(26));
    
    elseif rnecklefthip > rneckrighthip

        X = [max(8*poses(5), 8*poses(8)) 390-r];
        Y = floor(X); 
        imin = Y(1); imax = Y(2);

        positionx = randi([imin imax],1,1);
        positiony = min(8*poses(23), 8*poses(26));
     
    end
    im5 = insertShape(im3,"filled-circle",[positionx positiony r],Color=[256 256 256],Opacity=1);
    im5 = insertShape(im5,"circle",[positionx positiony r],Color=[0 0 140],Opacity=1,LineWidth=5);
    

end

figure;
imshow(im5);
