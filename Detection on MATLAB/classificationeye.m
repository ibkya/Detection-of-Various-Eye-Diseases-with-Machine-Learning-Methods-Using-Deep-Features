outputFolder = fullfile('eyed');
rootFolder = fullfile(outputFolder, 'eyeclasses');

categories = {'cataract','diabetic_retinopathy','glaucoma','normal'};

imds = imageDatastore(fullfile(rootFolder,categories),'LabelSource','foldernames');

tbl = countEachLabel(imds)



c = find(imds.Labels == 'cataract', 1);
dr = find(imds.Labels == 'diabetic_retinopathy', 1);
g = find(imds.Labels == 'glaucoma', 1);
n = find(imds.Labels == 'normal', 1);

figure
subplot(2,2,1);
imshow(readimage(imds,c));

subplot(2,2,2);
imshow(readimage(imds,dr));

subplot(2,2,3);
imshow(readimage(imds,g));

subplot(2,2,4);
imshow(readimage(imds,n));

net = resnet50();
figure
plot(net)
title('ResNet-50 Mimarisi')
set(gca,  'YLim', [150 170]);

net.Layers(1)
net.Layers(end)

numel(net.Layers(end).ClassNames)

[trainingSet, testSet] = splitEachLabel(imds, 0.3, 'randomize');

imageSize = net.Layers(1).InputSize;

augmentedTrainingSet = augmentedImageDatastore(imageSize, trainingSet, 'ColorPreprocessing','gray2rgb');

augmentedTestSet = augmentedImageDatastore(imageSize, testSet, 'ColorPreprocessing','gray2rgb');

wl = net.Layers(2).Weights;
wl = mat2gray(wl);

figure
montage(wl)
title('first convolutional layer weight')

featureLayer = 'fc1000';

trainingFeatures = activations(net, augmentedTrainingSet, featureLayer, 'MiniBatchSize',32, 'OutputAs','columns');

trainingLabels = trainingSet.Labels;
classifier = fitcecoc(trainingFeatures, trainingLabels, 'Learner','Linear', 'Coding','onevsall','ObservationsIn','columns');

testFeatures = activations(net, augmentedTestSet, featureLayer, 'MiniBatchSize', 32, 'OutputAs', 'columns');

predictLabels = predict(classifier, testFeatures, 'ObservationsIn','columns');
testLabels = testSet.Labels;

confMat = confusionmat(testLabels, predictLabels);
 confMat = bsxfun(@rdivide, confMat, sum(confMat,2));

 mean(diag(confMat));

  newImage = imread(fullfile('test1-2(g).jpg'));

 ds = augmentedImageDatastore(imageSize, newImage, 'ColorPreprocessing','gray2rgb');

 imageFeatures = activations(net, ds, featureLayer, 'MiniBatchSize',32, 'OutputAs','columns');
 label = predict(classifier, imageFeatures, 'ObservationsIn','columns');

 sprintf('Gelen Görüntü %s sınıfına ait', label)








