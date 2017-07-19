%  function tab = collect_data(it)
clearvars
it =299;
% Collect data
%--------------------------------------------------------------------------
%% set path
if strcmp(computer, 'MACI64') 
    machine = '/Users/charalak/Bifrost/';
else
    machine = '/mn/stornext/u3/charalak/Bifrost_cvs/';
end

source_file = [machine 'cb24ni/cb24ni_source/'];
lcc_file = [machine 'cb24ni/RUNS/fiji4d/'];
%% load data

z = fitsread([source_file 'z_cb24ni.fits']);
z = z(20:350);
zz(1,1,:)=z;
z=repmat(zz,768,768,1);
z = reshape(z,[],1);
clearvars zz
L = fitsread([lcc_file 'lcc_' num2str(it,'%04.0f')  '_fiji_3Donly.fits']);
L = reshape(L,[],1);
L = L>0;

%  qjoule max_jxyz j job etaohm j2b z qvisc min_jxyz jdb    

var_names = {'qjoule'  ; 'j2b';'etaohm';'cs' ;'b2'; 'qvisc'; 'bh' ; 'jb'; 'man'};
% var_names = {'qjoule'  ; 'job';'etaohm';'j2b' ;'qvisc'; 'jdb';  'jx'; 'jy'; 'jz'};
nov = numel(var_names);

idx_only_events = find(L==1);
idx_no_events = find(L==0);

rng(20)
idx_rand = randperm(numel(idx_only_events),numel(idx_only_events));
idx_rand2 = randperm(numel(idx_no_events),numel(idx_only_events));
idx_no_events = idx_no_events(idx_rand2);

idx = [idx_only_events ;  idx_no_events];

TT = zeros(numel(idx),nov);
% num = numel(idx);

% row_name = cell(num,1);
% for i=1:num
%     row_name{i,1} = num2str(idx(i));
% end
% row_name = arrayfun(@num2str, idx, 'UniformOutput',false);


tic;
parfor i=1:numel(var_names)
    display(num2str(i))
    input_array = fitsread([machine 'cb24ni/cb24ni_source/'...
        var_names{i,1} '_cb24ni_' num2str(it,'%04.0f') '.fits' ]);
    input_array = reshape(input_array,[],1);
    input_array =input_array(idx);
    TT(:,i) = input_array;
    
        
end
toc

%%
% var_names = {'qjoule' ;  'j2b' ;'etaohm';'cs' ;'beta'; 'bh'; 'job'; 'man'; 'pressure'; 'z';'max_jxyz'...
%     ; 'j'};

%  qjoule max_jxyz j job etaohm j2b z qvisc min_jxyz jdb   

TT = array2table(TT);
TT.Properties.VariableNames=var_names;
% TT.Properties.RowNames=row_name;

TT.z = z(idx);
% TT.min_jxyz = min([abs(TT.jx)'; abs(TT.jy)'; abs(TT.jz)'])';
% TT.max_jxyz = max([abs(TT.jx)'; abs(TT.jy)'; abs(TT.jz)'])';
% TT.j = sqrt(TT.jx.^2 + TT.jy.^2 + TT.jz.^2);
% TT.jx =[]; TT.jy =[]; TT.jz =[];
% TT.L = L(idx);
% TT.Properties.VariableNames=var_names;
%%
filename = 'nopALLevents_top10_BagEnsemble';
save([machine 'cb24ni/5th_project/' filename '/table' filename '.mat'],'TT','-v7.3')
% save('/Users/charalak/Bifrost/cb24ni/5th_project/nop_1e6_rand/target_nn1e6_rand.mat','L2')







 
