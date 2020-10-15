function graph = makeConnectivityCircle(hmm,labels,...
    centergraphs,scalegraphs,partialcorr,threshold)
% Plot HMM connectomes in connectivity circle format
%
% hmm: hmm struct as comes out of hmmmar
% labels : names of the regions
% centermaps: whether to center the maps according to the across-map average
% scalemaps: whether to scale the maps so that each voxel has variance
%       equal 1 across maps
% partialcorr: whether to use a partial correlation matrix or a correlation
%   matrix (default: 0)
% threshold: proportion threshold above which graph connections are
%       displayed (between 0 and 1, the higher the fewer displayed connections)
%
% Notes:
% It needs the circularGraph toolbox from Matlab in the path: 
%   https://github.com/paul-kassebaum-mathworks/circularGraph
%
% Diego Vidaurre (2020)

if nargin < 3 || isempty(centergraphs), centergraphs = 0; end
if nargin < 4 || isempty(scalegraphs), scalegraphs = 0; end
if nargin < 5 || isempty(partialcorr), partialcorr = 0; end
if nargin < 6 || isempty(threshold), threshold = 0.95; end

do_HMM_pca = strcmpi(hmm.train.covtype,'pca');
if ~do_HMM_pca && ~strcmp(hmm.train.covtype,'full')
    error('Cannot great a brain graph because the states do not contain any functional connectivity')
end

K = length(hmm.state);
if do_HMM_pca
    ndim = size(hmm.state(1).W.Mu_W,1);
else
    ndim = size(hmm.state(1).Omega.Gam_rate,1);
end

if nargin < 2 || isempty(labels)
    labels = cell(ndim,1);
    for j = 1:ndim
       labels{j} = ['Parcel ' num2str(j)];
    end
end


graph = zeros(ndim,ndim,K);

for k = 1:length(hmm.state)
    if partialcorr
        [~,~,~,C] = getFuncConn(hmm,k,1);
    else
        [~,C,] = getFuncConn(hmm,k,1);
    end
    C(eye(ndim)==1) = 0;
    graph(:,:,k) = C;
end

if centergraphs
    graph = graph - repmat(mean(graph,3),[1 1 K]);
end
if scalegraphs
    graph = graph ./ repmat(std(graph,[],3),[1 1 K]);
end

for k = 1:length(hmm.state)
    C = graph(:,:,k);
    c = C(triu(true(ndim),1)==1); c = sort(c); c = c(end-1:-1:1);
    th = c(round(length(c)*(1-threshold)));
    C(C<th) = 0;
    try
        figure(k+200)
        circularGraph(C,'Label',labels);
    catch
        error('Please get the Matlab circularGraph toolbox first')
    end
end

% end
% 
% 
% 
% function nets_netweb_2(netF,netP,sumpics,outputdir)
% % borrowed from Steve's fslnets
% 
% % replicate functionality from nets_hierarchy
% grot=prctile(abs(netF(:)),99); netmatL=netF/grot; netmatH=netP/grot;
% usenet=netmatL;  usenet(usenet<0)=0;
% N=size(netmatL,1);  grot=prctile(abs(usenet(:)),99); usenet=max(min(usenet/grot,1),-1)/2;
% DD = 1:N;
% for J = 1:N, for I = 1:J-1,   y((I-1)*(N-I/2)+J-I) = 0.5 - usenet(I,J);  end; end;
% linkages=linkage(y,'ward');
% set(0,'DefaultFigureVisible','off');
% figure;[~,~,hier]=dendrogram(linkages,0,'colorthreshold',0.75);
% close;set(0,'DefaultFigureVisible','on');
% clusters=cluster(linkages,'maxclust',10)';
% 
% mkdir(outputdir)
% netjs = [fileparts(which('makeConnectivityCircle')) '/netjs'];
% copyfile(netjs,outputdir) % copy javascript stuff into place
% NP=sprintf('%s/data/dataset1',outputdir);
% save(sprintf('%s/Znet1.txt',NP),'netF','-ascii');
% save(sprintf('%s/Znet2.txt',NP),'netP','-ascii');
% save(sprintf('%s/hier.txt',NP),'hier','-ascii');
% save(sprintf('%s/linkages.txt',NP),'linkages','-ascii');
% save(sprintf('%s/clusters.txt',NP),'clusters','-ascii');
% mkdir(sprintf('%s/melodic_IC_sum.sum',NP));
% for i=1:length(DD)
%   system(sprintf('/bin/cp %s.sum/%.4d.png %s/melodic_IC_sum.sum/%.4d.png',sumpics,DD(i)-1,NP,i-1));
% end
% 
% end
% 






