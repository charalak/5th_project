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

% THIS IS WRONG. WE HAVE OBSERVATIONS OF MULTIVARIABLES IN 2 GROUPS - USE MANOVA INSTEAD
% If it was observation of one varible, e.g. joule heating then you could use that. 
%-------------------------------------------------------------------------
clear;
%% Load data
% machine 
if  strcmp(computer, 'MACI64')  
    machine = '/Users/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost/'];
else
    machine = '/mn/stornext/u3/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost_cvs/'];
end

TT = load([sourcefile 'cb24ni/5th_project/nop1e6_rand_nof54_50_50_rng20/tablenop1e6_rand_nof54_50_50_rng20.mat']);
TT=TT.TT;
names = TT.Properties.VariableNames;

%% Response and features
Ytest = TT.L;
Xtest = double(table2array(TT(:,1:end-1)));

inputG0 = Xtest(Ytest==0,:);
inputG1 = Xtest(Ytest==1,:);

%% T-test

[h,P, ci, stats] = ttest2(inputG0,inputG1,'Vartype' ,'unequal');


% 
% Null hypothesis: Two samples are: 
% 'Independent'
% 'distributed normally'
% 'with equal MEAN '
% 'and unknown and unequal variance'
% 'EQUAL MEANS is the main fact!!!'
%  Rejection of the null hypothesis means that the two groups do not
%  have equal means
% 

%% Names of variables of REJECTED NULL HYPOTHESIS
% According to t-test the following features that are grouped as events 
% (Ytest == 1), and slow-burning pixels (Ytest==0) do not have equal mean
% value within 95% of confidence level.

namesc = cell2table(names);
namesc(:,logical(h==1))

%% Names of variables of NON REJECTED NULL HYPOTHESIS

namesc(:,logical(h==0))

%% t-test scores:  T values 
% The closer T is to 0, the more likely there isn't a significant 
% difference between group 1 and 2.

[t2_sorted,isort_t2] = sort(stats.tstat.^2,'descend');
% namesc(isort_t2)
t_scores = array2table(t2_sorted,'VariableNames',TT.Properties.VariableNames(isort_t2));