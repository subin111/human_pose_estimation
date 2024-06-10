dataDir = fullfile(tempdir, 'OpenPose' );
modelfile = fullfile(dataDir, 'human-pose-estimation.onnx' );

layers = importONNXLayers("C:\Users\tnqsg\Documents\human-pose-estimation\human-pose-estimation.onnx", "ImportWeights" ,true);
layers = removeLayers(layers,layers.OutputNames);
net = dlnetwork(layers);




im = imread("visionteam.jpg");
imshow(im)
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

