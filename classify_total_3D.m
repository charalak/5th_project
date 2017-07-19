it =299;
if  strcmp(computer, 'MACI64')  
    machine = '/Users/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost/'];
else
    machine = '/mn/stornext/u3/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost_cvs/'];
end
lcc_file = [machine 'cb24ni/RUNS/fiji4d/'];
addpath('~/Documents/MATLAB/subaxis/')
%% Load models
disp('Loading Model')
Mdl = load([modelsfile 'MODEL_BagOptimized_12features.mat']);

disp('Loading Data')
TT = load([sourcefile 'cb24ni/5th_project/nopALL_top12_BagOptimized/tablenopALL_top12_BagOptimized.mat']);

TT=TT.TT;
names = TT.Properties.VariableNames;
Ytest = TT.L; 
tabulate(Ytest)

disp('Predicting Responses')

dier = 40.;
h = height(TT);
Ypredict = zeros(h,1,'logical');
dh = round(h/dier);
parfor n=0:dier-1
    nn = n; % temp
%     n+1
    if (nn==(dier-1))
       in= (dier-1)*dh:h;
       disp([num2str(nn+1) '  ' num2str(in(1)) '   ' num2str(in(end))])
    else
        in = (nn*dh)+1:(nn+1)*dh;
       disp([num2str(nn+1) '  ' num2str(in(1)) '   ' num2str(in(end))])
    end 
    
    Xtest = double(table2array(TT(in,1:end-1)));
    Y = predict(Mdl.BagOptimized,Xtest);
    Ypredict{n} = Y;
end



plotconf(Ytest, Ypredict,{'E','S-B'}, 'GentleBoost')
save([modelsfile 'Ypredict_BagOptimized_top12.mat'],'Ypredict','-v7.3')
