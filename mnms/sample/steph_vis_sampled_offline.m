if(isempty(which('LoopyModelCollection')))
  addpath(genpath('~/src/crf/fwMatch'));
  exptPath = pwd;
  cd('~/src/crf/fwMatch');
  startup;
  cd(exptPath);
end
dbclear all;


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

if(DEPTH_ID > 0)
  EXPT = ['steph_' num2str(ORIENT) '_' num2str(DEPTH_ID,'%02d') '_tree'];
else
  EXPT = ['steph_' num2str(ORIENT) '_tree'];  
end

%for E = {'002_h', '002_v', '002_l', '002_r', '002_i'}
%EXPT = E{1};

%load([PATH '/model_collection_' EXPT '.mat']);
%best_model = model_collection.get_best_model;
%model = best_model.inference_model;
%vars_N = size(model.x_train,2);
%clear model_collection best_model;

load('~/data/CAM/steph_all_rois.mat');
load('~/data/CAM/steph_all_rois_img.mat');


E_IMG = cell(1,7);

if(DEPTH_ID < 0)
  DEPTHS = 1:7;
else
  DEPTHS = DEPTH_ID;
end


ORIENT_USE = [90, 135];
for DEPTH_ID = 1:7
  d = DEPTH_ID;
  %count = 1;
  E_IMG{d} = zeros(size(ROIS_IMG{d}));

  for o_i = 1:2
    ORIENT = ORIENT_USE(o_i);
    EXPT = ['steph_' num2str(ORIENT) '_' num2str(DEPTH_ID,'%02d') '_tree'];
    load([PATH '/' EXPT  '_gibbs.mat'], 'ave_X');

    vars_N = length(ave_X);
    %vars_in_depth = 1:vars_N; %find(DEPTH_LABELS == d);
    [~, top_neurons] = sort(ave_X, 'descend');
    top_neurons = top_neurons(1:20);

    for n = top_neurons
      %ii = find(ROIS_IMG{d} == n);
      temp = zeros(size(ROIS_IMG{d}));
      temp(ALL_ROIS{d}(n,1), size(ROIS_IMG{d},2)-ALL_ROIS{d}(n,2)) = 1;
      %temp = bwmorph(temp, 'dilate', 12);
      temp = imdilate(temp, strel('disk',10));
      ii = find(temp);
      %figure(11); imagesc(temp); pause(0.5);
      if( nnz(E_IMG{d}(ii)) > length(ii) - 2)
         E_IMG{d}(ii) = 3;
      else
        E_IMG{d}(ii) = o_i;
        %ave_X(vars_in_depth(n));
      end
    end
  end

  cmap = [1,1,1; jet(length(unique(E_IMG{d})) - 1)];
  figure(d); imagesc(E_IMG{d}); colormap(cmap); colorbar;

end %depth

return

load(['~/data/mouse/291114_luis_opto/' ...
      'SPK_REG_C1V1GCaMP6s_m23_d1_001m_002m.mat'], 'segcentroid');
label_positions(:,1) = segcentroid(:,1);
label_positions(:,2) = 240 - segcentroid(:,2);
for v = 1:vars_N
  variable_names{v} = sprintf('%d', v);
end
graph_to_dot(model.structure, 'filename', '001_s_tree.dot', ...
             'node_label', variable_names, 'positions', label_positions'.*2);

%neato -Tps -n  test_002.dot > test_002.ps; open test_002.ps



return
save(['inferred_291114_luis_opto_ge3_' EXPT '_tree.mat'], 'CLL_0', ...
     'CLL_1');

fprintf('saved: %s\n', ['inferred_291114_luis_opto_ge3_' EXPT '_tree.mat']);

return

%%%%% 





kt_graph_to_dot(model.structure, 'filename', 'steph_225_tree.dot', ...
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
