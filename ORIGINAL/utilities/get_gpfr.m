function [gpfr,kernel_fun]=get_gpfr(fr,xx )

%given a matrix of firing rate (num trials x time) and time samples, this function creates a
%gaussian process surrogate data of same size as fr with mean at global
%mean of fr, tau of 100ms and sigma of 1. 
%tutorial for GP: https://peterroelants.github.io/posts/gaussian-process-tutorial/



binwidth=xx(5)-xx(4);
%params for GP surrogate data:
tau=100*binwidth; %100ms in order to match the gaussing smoothing applied to real psth
sigm=1;

numtr=size(fr,1);
gpmean = nanmean(fr(:))+zeros(size(xx));
for tii=1:length(xx)
    for tjj=1:length(xx)
        ti=xx(tii);
        tj=xx(tjj);
        kernel_fun(tii,tjj) = sigm^2*exp(-(ti-tj)^2/(2*tau^2));
    end
end

gpfr = mvnrnd(gpmean,kernel_fun(:,:),numtr);

% % visualize your surrogate data:
% subplot(2,2,1);plot(xx,gpfr');title 'GP time course for each trial'
% subplot(2,2,2);imagesc(xx,1:numtr,gpfr); xlabel time; ylabel trials; title GP
% subplot(2,2,3);imagesc(kernel_fun); title 'covariance matrix'
end






