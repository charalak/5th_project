%% load data
it =299;
if  strcmp(computer, 'MACI64')  
    machine = '/Users/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost/'];
    lcc_file = [machine 'charalak/Bifrost/cb24ni/RUNS/fiji4d/'];

else
    machine = '/mn/stornext/u3/';
    modelsfile = [machine 'charalak/Bifrost/IDL/5th_project/'];
    sourcefile = [machine 'charalak/Bifrost_cvs/'];
    lcc_file = [machine 'charalak/Bifrost_cvs/cb24ni/RUNS/fiji4d/'];

end
L = fitsread([lcc_file 'lcc_' num2str(it,'%04.0f')  '_fiji_3Donly.fits']);
L = reshape(L,[],1); 


num =5e5;

pros = 0;

areaL = regionprops(L,'area');
areaL = struct2array(areaL);
for i=1:numel(areaL)
    
    if pros<=num
        pros = pros+areaL(i)
    else
        break;
    end
end


i = i-1;
idx_only_events = find((L<=i) &(L>0));
idx_no_events = find(L==0);
rng(20)
idx_rand = randperm(numel(idx_no_events),numel(idx_only_events));
idx_no_events = idx_no_events(idx_rand);

idx = [idx_only_events ;  idx_no_events];

z = fitsread([sourcefile 'cb24ni/cb24ni_source/z_cb24ni.fits']);
z = z(20:350);
zz(1,1,:)=z;
z=repmat(zz,768,768,1);
z = reshape(z,[],1);
clearvars zz

%  qjoule max_jxyz j job etaohm j2b z qvisc min_jxyz jdb    
var_names = {'qjoule'  ; 'job';'etaohm';'j2b' ;'qvisc'; 'jdb';  'jx'; 'jy'; 'jz'};
nov = numel(var_names);


TT = zeros(numel(idx),nov);
% row_name = arrayfun(@num2str, idx, 'UniformOutput',false);

tic;
parfor i=1:numel(var_names)
    display(num2str(i))
    input_array = fitsread([sourcefile 'cb24ni/cb24ni_source/'...
        var_names{i,1} '_cb24ni_' num2str(it,'%04.0f') '.fits' ]);
    input_array = reshape(input_array,[],1);
    input_array =input_array(idx);
    TT(:,i) = input_array;
    
        
end
toc

TT = array2table(TT);
TT.Properties.VariableNames=var_names;
TT.z = z(idx);
TT.min_jxyz = min([abs(TT.jx)'; abs(TT.jy)'; abs(TT.jz)'])';
TT.max_jxyz = max([abs(TT.jx)'; abs(TT.jy)'; abs(TT.jz)'])';
TT.j = sqrt(TT.jx.^2 + TT.jy.^2 + TT.jz.^2);
TT.jx =[]; TT.jy =[]; TT.jz =[];
TT.L = L(idx);

filename = 'nop1e6_BagEnsemble_top10_multi_class';
save([sourcefile 'cb24ni/5th_project/' filename '/table' filename '.mat'],'TT','-v7.3')
