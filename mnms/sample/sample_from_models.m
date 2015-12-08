addpath(genpath('~/src/crf/fwMatch'));
exptPath = pwd;
cd('~/src/crf/fwMatch');
startup;
cd(exptPath);

if(isempty(who('PATH')))
  warning('SET PATH!!!!!');
  PATH = '~/data/mouse/291114_luis_opto/ge3/';
end

if(isempty(who('EXPT')))
  warning('SET EXPT!!!!!');
  EXPT = '002_h';
end

%for E = {'002_h', '002_v', '002_l', '002_r', '002_i'}
%EXPT = E{1};

load([PATH '/model_collection_' EXPT '.mat']);

best_model = model_collection.get_best_model;
inferred_model = best_model.inference_model;
vars_N = size(inferred_model.x_train,2);


%load ~/data/mouse/291114_luis_opto/ge3/ ...
%     model_collection_001_s_tree.mat;


node_potentials = inferred_model.theta.node_potentials;
edge_potentials = inferred_model.theta.edge_potentials;
vars_N = size(inferred_model.x_train,2);
sample_count = 50000;
burn_in = 40000;
sample_interval = 200;
random_seed = 1;

[X, log_like] = gibbs_fast_sampler(node_potentials, edge_potentials, ...
                                   vars_N, sample_count, burn_in, ...
                                   sample_interval, random_seed);
marginals = sum(X)/sample_count;
%plot(log_like);
X = logical(X);
log_like = single(log_like(vars_N*burn_in+1:end));


%%%%
sampled_X = X(burn_in+1:end,:);
%ROIs:
%load('~/data/mouse/291114_luis_opto/icaROIs_REG_C1V1GCaMP6s_m23_d1_001m_002m.mat');
load('~/data/mouse/291114_luis_opto/icaROIs_REG_to001m_002m_AVE_C1V1GCaMP6s_m23_d1_1_2_3_4_5_7_11_1K.mat');

ave_X = sum(sampled_X,1)./size(sampled_X,1);
ave_X = ave_X./max(ave_X);

E_IMG = zeros(size(ROIs));
for n = 1:vars_N
    ii = find(ROIs == n);
    E_IMG(ii) = ave_X(n);
end


save([PATH '/' EXPT  '_gibbs.mat'], 'X', ...
     'sample_count', 'burn_in', 'sample_interval', 'random_seed', ...
     'log_like', 'E_IMG', 'ave_X');

fprintf('Phew.\nSAVED: %s\n', [PATH '/' EXPT '_gibbs.mat']);

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

fprintf('\nChow-liu test loglike: %f\n', ...
        chowliu_loglike(x_train,x_test));
fprintf('Bernoulli test loglike: %f\n', bernoulli_loglike(x_train, ...
                                                  x_test));


    model = treegmFit(x_train);
    avg_train_loglike = sum(treegmLogprob(model, x_train)) / ...
        size(x_train,1);
    avg_test_loglike = sum(treegmLogprob(model, x_test)) / ...
        size(x_test,1);
