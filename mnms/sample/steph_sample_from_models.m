if(isempty(which('LoopyModelCollection')))
  addpath(genpath('~/src/crf/fwMatch'));
  exptPath = pwd;
  cd('~/src/crf/fwMatch');
  startup;
  cd(exptPath);
end
dbclear all;


if(isempty(who('EXPT')))
  if(~isempty(who('SCRIPT')))
    error('set EXPT when running from script');
  else
  end
end  

if(isempty(who('PATH')))
  %warning('SET PATH!!!!!');
  PATH = '~/data/steph_225_tree/';
end

if(isempty(who('DEPTH_ID')))
  warning('SET DEPTH_ID!!!!!');
  DEPTH_ID = input('DEPTH_ID = ');
end

if(isempty(who('ORIENT')))
  warning('SET ORIENT!!!!!');
  ORIENT = input('ORIENT = ');
end

%for E = {'002_h', '002_v', '002_l', '002_r', '002_i'}
%EXPT = E{1};

load([PATH '/model_collection_' EXPT '.mat']);

best_model = model_collection.get_best_model;
inferred_model = best_model.inference_model;
vars_N = size(inferred_model.x_train,2);

clear model_collection best_model;

%load ~/data/mouse/291114_luis_opto/ge3/ ...
%     model_collection_001_s_tree.mat;


node_potentials = inferred_model.theta.node_potentials;
edge_potentials = inferred_model.theta.edge_potentials;
vars_N = size(inferred_model.x_train,2);
sample_count = 50000;
burn_in = 40000;
sample_interval = 200;

random_seed = 1;

fload = [PATH '/' EXPT  '_gibbs.mat'];
if(exist(fload, 'file'))
  load(fload);
  fprintf('Loaded: %s\n', fload);
  if(~isempty(who('E_IMG')))
    fprintf('Looks like you have computed everything, so returning\n');
    return
  end
else

  [X, log_like] = gibbs_fast_sampler(node_potentials, edge_potentials, ...
                                     vars_N, sample_count, burn_in, ...
                                     sample_interval, random_seed);
  X = logical(X);
  log_like = log_like(((burn_in+1)*sample_interval):sample_interval:end);
  sampled_X = X(burn_in+1:end,:);
  ave_X = sum(sampled_X,1)./size(sampled_X,1);
  save([PATH '/' EXPT  '_gibbs.mat'], 'X', ...
       'sample_count', 'burn_in', 'sample_interval', 'random_seed', ...
       'log_like', 'ave_X');
  fprintf('Phew.\nSAVED: %s\n', [PATH '/' EXPT '_gibbs.mat']);
end

%ROIs:
load('~/data/CAM/steph_all_rois.mat');
load('~/data/CAM/steph_all_rois_img.mat');

%E_IMG = [];
ave_X_orig = ave_X;
ave_X = ave_X./max(ave_X);
d = DEPTH_ID;
ROIs = ROIS_IMG{d};
E_IMG = zeros(size(ROIs));
vars_in_depth = 1:vars_N;
for n = 1:vars_N
  temp = zeros(size(ROIs));
  temp(ALL_ROIS{d}(n,1), size(ROIs,2)-ALL_ROIS{d}(n,2)) = 1;
  temp = imdilate(temp, strel('disk',10));
  ii = find(temp);
  E_IMG(ii) = ave_X(vars_in_depth(n));
end
  
cmap = [1,1,1; jet(100)];
imwrite(double(E_IMG).*100, cmap, [PATH '/sampled_' EXPT '_d' num2str(d, '%02d') ...
                    '.jpg']);

ave_X = ave_X_orig;
save([PATH '/' EXPT  '_gibbs.mat'], 'X', ...
     'sample_count', 'burn_in', 'sample_interval', 'random_seed', ...
     'log_like', 'E_IMG', 'ave_X');

fprintf('Phew.\nSAVED: %s\n', [PATH '/' EXPT '_gibbs.mat']);


clear ROIS_IMG;

return








load(['~/data/mouse/291114_luis_opto/' ...
      'SPK_REG_C1V1GCaMP6s_m23_d1_001m_002m.mat'], 'segcentroid');
label_positions(:,1) = segcentroid(:,1);
label_positions(:,2) = 240 - segcentroid(:,2);
for v = 1:vars_N
  variable_names{v} = sprintf('%d', v);
end
graph_to_dot(inferred_model.structure, 'filename', '001_s_tree.dot', ...
             'node_label', variable_names, 'positions', label_positions'.*2);

%neato -Tps -n  test_002.dot > test_002.ps; open test_002.ps



return
save(['inferred_291114_luis_opto_ge3_' EXPT '_tree.mat'], 'CLL_0', ...
     'CLL_1');

fprintf('saved: %s\n', ['inferred_291114_luis_opto_ge3_' EXPT '_tree.mat']);

return

%%%%% 





kt_graph_to_dot(inferred_model.structure, 'filename', 'steph_225_tree.dot', ...
             'node_label', variable_names, 'positions', positions'.*2, ...
                'subgraphs', EXPT_IDS, 'colors', colors);

%neato -Tps -n  test_002.dot > test_002.ps; open test_002.ps






fprintf('\nChow-liu test loglike: %f\n', ...
        chowliu_loglike(x_train,x_test));
fprintf('Bernoulli test loglike: %f\n', bernoulli_loglike(x_train, ...
                                                  x_test));


    model = treegmFit(x_train);
    avg_train_loglike = sum(treegmLogprob(model, x_train)) / ...
        size(x_train,1);
    avg_test_loglike = sum(treegmLogprob(model, x_test)) / ...
        size(x_test,1);
