if  strcmp(computer, 'MACI64')  
    machine = '/Users/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost/'];
else
    machine = '/mn/stornext/u3/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost_cvs/'];
end
addpath('~/Documents/MATLAB/subaxis/')
%% Load models
MODELS = load([modelsfile 'models.mat']);
MODELS_REDUCED_on_DT = load([modelsfile 'MODELS_REDUCED_on_DT.mat']);
net = MODELS.net; % Decission Trees
DT = MODELS.DT; % Decission Trees
% NB = MODELS.Nb; % Naive Bayes
DA = MODELS.da; % Discriminant Analysis
GLM = MODELS.glm; % Generalized Linear Model - Logistic Regression
KNN = MODELS.knn; % Nearest Neighbors
svm_std = MODELS.svm_std;
TB = MODELS.tb; % tree bagger
% DTr = MODELS_REDUCED_on_DT.DTr;
tb_r = MODELS_REDUCED_on_DT.tb_r;
fs = MODELS_REDUCED_on_DT.fs;


TT = load([sourcefile 'cb24ni/5th_project/nop1e6_rand_nof54_50_50_rng20/tablenop1e6_rand_nof54_50_50_rng20.mat']);
TT=TT.TT;
names = TT.Properties.VariableNames;

% Responses and features
Ytest = TT.L;
Xtest = double(table2array(TT(:,1:end-1)));

rng(1);
irandom = randperm(1e6,100000);
%%
Mdls = {DA ; DT ; KNN ; svm_std ;  tb_r} ; 

ha =zeros(numel(Mdls));
pa = ha;
e1ma = ha;
e2ma = ha;
for i = 1:numel(Mdls)
    for j = 1:numel(Mdls)
        if ((i~=j) && (j>i))
            disp(['i = ' num2str(i) '    j = ' num2str(j) ])
            if ((i==numel(Mdls)) || (j==numel(Mdls)))
                [h, p, e1, e2] = testckfold(Mdls{i},Mdls{j},Xtest(irandom,fs),Xtest(irandom,fs),Ytest(irandom) ,...
            'Alternative', 'unequal', 'Test', '5x2t',  'Options', statset('UseParallel',true));
        e1mean = mean(e1(:)); e2mean = mean(e2(:));
            else
                [h, p, e1, e2] = testckfold(Mdls{i},Mdls{j},Xtest(irandom,:),Xtest(irandom,:),Ytest(irandom),'Alternative', 'unequal', 'Test', '5x2t',  'Options', statset('UseParallel',true));
            e1mean = mean(e1(:)); e2mean = mean(e2(:));
            end
            ha(i,j) =  h;
            pa(i,j) = p;
            e1ma(i,j) = e1mean;
            e2ma(i,j) = e2mean;
        end
    end
end
Rownam = {'DA';'DT';'KNN';'svm_syd';'TB_r'};
Varnam = Rownam;
ha = array2table(ha, 'RowNames', Rownam, 'VariableNames', Varnam);
pa = array2table(pa, 'RowNames', Rownam, 'VariableNames', Varnam);
e1ma = array2table(e1ma, 'RowNames', Rownam, 'VariableNames', Varnam);
e2ma = array2table(e2ma, 'RowNames', Rownam, 'VariableNames', Varnam);

ha.Properties.VariableDescriptions{'DA'} = 'DescriminantAnalysis testckfoldDecision:aprove/reject unequal accur';
pa.Properties.VariableDescriptions{'DA'} = 'DescriminantAnalysis test p-value';
e1.Properties.VariableDescriptions{'DA'} = 'DescriminantAnalysis mdl 1 mean classification losses ';
e2.Properties.VariableDescriptions{'DA'} = 'DescriminantAnalysis mdl 2 mean classification losses ';

save([modelsfile 'accuracy_comparison.mat'], 'ha', 'pa', 'e1ma', 'e2ma')