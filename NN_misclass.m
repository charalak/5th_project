function [misclass]= NN_misclass(XTrain,YTrain,xtest,ytest)
XTrain = XTrain'; YTrain=YTrain'; xtest=xtest'; ytest=ytest';

% Feedforward neural network
% net = feedforwardnet(10);
% Pattern recognition network
net = patternnet(10,'trainscg');
% Configure network inputs and outputs to best match input and target data
% net = configure(net,XTrain,YTrain);
% Train neural network
[net,~] = train(net,XTrain,YTrain,'useParallel','yes');   
ypred = net(xtest);    %prediction
ypred = ypred>=0.5;
ytest2 = ytest(1,:);
ypred2 = ypred(1,:);
% perf = perform(net,ytest2,ypred2)
%calculate missclassification rate
misclass = sum(ytest2 ~= ypred2);
end