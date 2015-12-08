%models = {'001_s', ...
%          '002_h', ...
%          '002_i', ...
%          '002_l', ...
%          '002_r', ...
%          '002_v'};

%models = {'steph_135_01_loopy', 'steph_135_02_loopy', 'steph_45_01_loopy', ...
%          'steph_90_01_loopy', 'steph_90_02_loopy'};

MODEL_TYPE = 'loopy';
models = {};

n = 1;
for o = [0,45,90,135,180,225]
  for d = [1,2]
    models{n} = sprintf('steph_%d_%02d_%s', o, d, MODEL_TYPE);
    n = n + 1;
  end
end
 

THISexptPath = pwd;
%SAVE_SUFFIX = 'loopy';
M = length(models);
for m = 1:M
  cd(models{m});
  dd = dir('results/');
  if( (length(dd) < 22 && strcmp(MODEL_TYPE, 'tree') == 1 ) || ...
      (length(dd) < 32 && strcmp(MODEL_TYPE, 'loopy') == 1 ))
    warning('not all files computed for %s!!!', models{m});
    cd(THISexptPath);
    continue;
  end

  disp(pwd);
  merge_all_models
  clear model_collection;
  cd(THISexptPath);
end

