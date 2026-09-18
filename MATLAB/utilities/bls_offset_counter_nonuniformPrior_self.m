function [tp_gen,mdl]=bls_offset_counter_nonuniformPrior_self(ts,modelparams,tp,gen_model_type,savefolder)
mdl.type = 'counter';
if isempty(tp)
    %generate data
    wm = modelparams(1); wp = modelparams(2);offset=modelparams(3);
    
    tm = normrnd(ts, wm*sqrt(ts));
    te = fbls(ts, tm, wm);
    tp_gen = normrnd(te, wp*sqrt(te))+offset;
    mdl=[];
    return
end

% else fit data
 

mdl.gen_model_type = gen_model_type;


opts = optimset('fminsearch');
opts.Display = 'final';
ints = min(ts):.1:max(ts); %integration limits
w_init = [0.5, 0.5, 0];
[wopt, neglogL_opt] = fminsearch(@(w) NegLogLike(ts, tp, w, ints), w_init, opts);
disp(wopt)

mdl.aic = 2*length(wopt) + 2*neglogL_opt;
mdl.bic = log(length(ts))*length(wopt) + 2*neglogL_opt;
mdl.w = wopt;
mdl.negloglik = neglogL_opt;

%% generative model for tp

wmopt = wopt(1); wpopt = wopt(2);w_offset=wopt(3);
tm = normrnd(ts, wmopt*sqrt(ts));
te = fbls(ts, tm, wmopt);
tp_gen = normrnd(te, wpopt*sqrt(te))+w_offset;


idx=1;
for dd = unique(ts)
    
    
    gd=find(ts==dd );
    tp_mean_data(idx) = mean(tp(gd));
    
    gg=find(ts==dd );
    tp_mean_gen(idx) = nanmean(tp_gen(gg));
    
    tm_mean(idx)=nanmean(tm(gg));
    te_mean(idx)=nanmean(te(gg));
    
    tpdat{idx}=tp(gd);
    tpgen{idx}=tp_gen(gg);
    tmgen{idx} = tm(gg);
    tegen{idx} = te(gg);
    
    
    
    bias(idx,:) = [tp_mean_data(idx)-dd tp_mean_gen(idx)-dd];
    varnc(idx,:)= [var(tp(gd)) var(tp_gen(gg))];
    
    varte(idx)=var(te(gg));
    biaste(idx)=te_mean(idx)-dd;
    data_size(idx)=length(gd);
     
     
    idx=idx+1;
end
mdl.bias_data=bias(:,1);mdl.bias_model=bias(:,2);
mdl.var_data=varnc(:,1);mdl.var_model=varnc(:,2);


%plot fit results
figure('Position',[334         106        1234         844]);
subplot(2,2,3);
plot(bias(:,1),bias(:,2),'or');hold on
plot(sqrt(varnc(:,1)),sqrt(varnc(:,2)),'sqk');
axis square
plot([-.8 .8],[-.8 .8],'-k');title 'bias(circle) SD(square)'
axis([-1 1 -1 1])
xlabel model
ylabel data
set(gca,'FontSize',15);
grid on

subplot(2,2,1);hold on;
plot([0 4],[0 4],'k--');
a=-.05;b=.05;rn=length(ts);
jitt2 = a + (b-a).*rand(1,rn);

plot(ts+jitt2,tp_gen, '.g', 'MarkerSize', 5);
h1 = plot(unique(ts), tp_mean_data, 'r*');
h2 = plot(unique(ts), tp_mean_gen, 'bo', 'MarkerSize', 8);
h3=plot(tm,te, 'b.', 'MarkerSize', 5);

title(mdl.type)
axis square
axis([0 4 0 4]);

legend([h1, h2, h3], {'data','model' ,'BLS(te)'},'Location','NorthWest')
ylabel 'produced interval: tp (sec)'
xlabel([wopt])
grid on
set(gca,'FontSize',15);

axes('position', [0.55 0.6 0.1 0.1]);
plot(unique(ts),bias(:,1),'-*r');hold on
plot(unique(ts),bias(:,2),'-ob');title bias(tp)
grid on

axes('position', [0.7 0.6 0.1 0.1]);
plot(unique(ts),sqrt(varnc(:,1)),'-*r');hold on
plot(unique(ts),sqrt(varnc(:,2)),'-ob');title SD(tp)
grid on

mdl.mse = 1/length(tp)*sum((tp-tp_gen).^2);
mdl.mse_bias_var = abs(sum(bias(:,1).^2+varnc(:,1))-sum(bias(:,2).^2+varnc(:,2)));

cd (savefolder)
saveas(gcf,['BLS_model_' mdl.type ' gen_model_' mdl.gen_model_type '.png']);

end

%% functions

%fit params
function out = NegLogLike(ts_exp, tp_exp, params, ints)

wm = params(1); wp = params(2); offset = params(3);
out = -sum(log(Ptp(tp_exp-offset, ts_exp, wm, wp, ints)));
if wm < 0 || wp <0
    out = out +1000;
end


end

%%%%%%%% Low-level functions: calculating probabilities

function p = Ptp(tp, ts, wm, wp, ints)
% Calculate p(tp|ts,wm,wp)
lower = 0;
upper = max(ints)*2;
fun = @(x) Ptpte(fbls(ts, x, wm), tp, wp).*Ptmts(ts, x, wm);
p = integral(fun, lower, upper, 'ArrayValued', true);
end

function te = fbls(ts, tm, wm)
c = .5846;
m= -0.1026;

   numer = integral(@(ts)(c+m*ts).*ts.*Ptmts(ts, tm, wm), min(ts), max(ts), 'ArrayValued', true);
   denom = integral(@(ts)(c+m*ts).*Ptmts(ts, tm, wm), min(ts), max(ts), 'ArrayValued', true);
% numer = integral(@(ts)ts.*Ptmts(ts, tm, wm), min(ts), max(ts), 'ArrayValued', true);
% denom = integral(@(ts)Ptmts(ts, tm, wm), min(ts), max(ts), 'ArrayValued', true);

te = numer./denom;

end

function p = Ptmts(ts, tm, wm)
% Calculate p(tm|ts,wm)
x = (ts-tm).^2;
%   wmts2 = (wm*ts).^2;
wmts2 = (wm*sqrt(ts)).^2;
p = 1./sqrt(2*pi*wmts2).*exp(-0.5*x./wmts2);

end

function p = Ptpte(te, tp, wp)
% Calculate p(tp|te,wp)
x = (te-tp).^2;
%   wpte2 = (wp*te).^2;
wpte2 = (wp*sqrt(te)).^2;
p = 1./sqrt(2*pi*wpte2).*exp(-0.5*x./wpte2);

end

 