function kt_graph_to_dot(adj, varargin)
%GRAPH_TO_DOT  Makes a GraphViz (AT&T) file representing an adjacency matrix
% graph_to_dot(adj, ...) writes to the specified filename.
%
% Optional arguments can be passed as name/value pairs: [default]
%
% 'filename' - if omitted, writes to 'tmp.dot'
% 'arc_label' - arc_label{i,j} is a string attached to the i-j arc [""]
% 'node_label' - node_label{i} is a string attached to the node i ["i"]
% 'width'     - width in inches [10]
% 'height'    - height in inches [10]
% 'leftright' - 1 means layout left-to-right, 0 means top-to-bottom [0]
% 'directed'  - 1 means use directed arcs, 0 means undirected [1]
% See also dot_to_graph and draw_dot.

% First version written by Kevin Murphy 2002.
% Modified by Leon Peshkin, Jan 2004.
% Bugfix by Tom Minka, Mar 2004.
                   
node_label = [];   arc_label = [];   % set default args
width = 10;        height = 10;
leftright = 0;     directed = 0;     filename = 'tmp.dot';
%kate:
positions = [];
for i = 1:2:nargin-1                    % get optional args
  switch varargin{i}
    case 'filename', filename = varargin{i+1};
    case 'node_label', node_label = varargin{i+1};
    case 'arc_label', arc_label = varargin{i+1};
    case 'width', width = varargin{i+1};
    case 'height', height = varargin{i+1};
    case 'leftright', leftright = varargin{i+1};
    case 'directed', directed = varargin{i+1};
    case 'positions', positions = varargin{i+1}; %kate
    case 'subgraphs', subgraphs = varargin{i+1}; %kate
    case 'colors', colors = varargin{i+1}; %kate
  end
end
% minka
if ~directed
  adj = triu(adj | adj');
end

if(isempty(who('colors')))
  colors = repmat({'white'}, 1, size(adj,1));
end
if(isempty(who('subgraphs')))
  subgraphs = zeros(1, size(adj,1));
end

fid = fopen(filename, 'w');
if directed
  fprintf(fid, 'digraph G {\n');
  arctxt = '->'; 
  if isempty(arc_label)
    labeltxt = '';
  else
    labeltxt = '[label="%s"]';
  end
else
  fprintf(fid, 'graph G {\n');
  arctxt = '--'; 
  if isempty(arc_label)
    labeltxt = '[dir=none]';
  else
    labeltext = '[label="%s",dir=none]';
  end
end
edgeformat = strcat(['%d ',arctxt,' %d ',labeltxt,';\n']);
fprintf(fid, 'center = 1;\n');
fprintf(fid, 'size=\"%d,%d\";\n', width, height);
if leftright
  fprintf(fid, 'rankdir=LR;\n');
end
Nnds = length(adj);
prev_subgraph = 0;
for node = 1:Nnds               %  process nodes 
  if(prev_subgraph ~= subgraphs(node))
     fprintf(fid, '\n}\nsubgraph cluster_%d\n{\n', subgraphs(node));
     prev_subgraph = subgraphs(node);
  end

  if isempty(node_label)
    fprintf(fid, '%d;\n', node);
  else
    if(isempty(positions))
      fprintf(fid, '%d [ label = "%s" ];\n', node, node_label{node});
    else
      %Kate:
      fprintf(fid, ['%d [ label = "%s", pos = \"%f,%f!\", width=0.1, ' ...
                    'height=0.1, color=%s ];\n'], node, ...
              node_label{node}, positions(1,node), positions(2,node), ...
              colors{node});
    end
  end
if(0)
  arcs = find(adj(node,:));         % children(adj, node);
  for node2 = arcs
    if  ~isempty(arc_label)
      fprintf(fid, edgeformat,node,node2,arc_label{node,node2});
    else
      fprintf(fid, edgeformat, node, node2);    
    end    
  end
end

end
if(1)
for node1 = 1:Nnds   % process edges
  arcs = find(adj(node1,:));         % children(adj, node);
  for node2 = arcs
    if  ~isempty(arc_label)
      fprintf(fid, edgeformat,node1,node2,arc_label{node1,node2});
    else
      fprintf(fid, edgeformat, node1, node2);    
    end    
  end
end
end

%for the subgraphs:
fprintf(fid, '}');

fprintf(fid, '}');
fclose(fid);