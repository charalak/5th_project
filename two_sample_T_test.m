% Important note:
% To perform this t-test the following conditions must be met:
%http://stattrek.com/hypothesis-test/difference-in-means.aspx?Tutorial=AP
% The sampling method for each sample is simple random sampling.
% The samples are independent.
% Each population is at least 20 times larger than its respective sample.
% The sampling distribution is approximately normal, which is generally the
% case if any of the following conditions apply:
% 
% The population distribution is normal.
% The population data are symmetric, unimodal, without outliers, and the sample size is 15 or less.
% The population data are slightly skewed, unimodal, without outliers, and the sample size is 16 to 40.
% The sample size is greater than 40, without outliers.


%Therefore in our case. T-TEST is NOT APPROPIRATE

% Two-sample T-test:
% h = ttest2(x,y) returns a test decision for the null hypothesis that the 
% data in vectors x and y comes from independent random samples from normal 
% distributions with equal means and equal but unknown variances, using the
% two-sample t-test. The alternative hypothesis is that the data in x and y 
% comes from populations with unequal means. The result h is 1 if the test
% rejects the null hypothesis at the 5% significance level, and 0 otherwise.
%-------------------------------------------------------------------------
clear all;
%% Load data
% machine 
if strcmp(computer, 'MACI64') 
    machine = '/Users/charalak/Bifrost/';
else
    machine = '/mn/stornext/u3/charalak/Bifrost_cvs/';
end

datafile = 'nop_1e5_rand';
input = load([machine 'cb24ni/5th_project/' datafile '/input_nn_' datafile '.mat'],'input2');
input = input.input2; input = input';
target = load([machine 'cb24ni/5th_project/' datafile '/target_nn_' datafile '.mat'],'L2');
target = target.L2; 
target = target';
target = target(:,1);

inputG1 = input(grp2idx(target)==1,:);
inputG2 = input(grp2idx(target)==2,:);

%% T-test

[h,P] = ttest2(inputG1,inputG2,'Alpha',0.01,'Vartype' ,'unequal');


% [h,p] = ttest2(x,y,'Vartype' ,'unequal')

disp('------------------------------------------')
disp('Null hypothesis: Two samples are: ')
disp('Independent')
disp('distributed normally')
disp('with equal MEAN ')
disp('and unknown and unequal variance')
disp('EQUAL MEANS is the main fact!!!')
disp('------------------------------------------')

varname = {'qj'; 'qv' ;'tg' ;'P'; 'nel'; 'z'};

for i = 1:numel(h)
    
if h(i) == 0
    disp([varname{i} ': Two samples have EQUAL MEANS'])
else
    disp([varname{i} ': Two samples have UNEQUAL MEANS'])
    G1_vs_G2 = [mean(inputG1(:,i)), mean(inputG2(:,i))]
end
end
disp('------------------------------------------')
disp('T-TEST in our case is not appropriate because we dont have random sampling')





