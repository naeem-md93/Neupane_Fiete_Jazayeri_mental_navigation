function [out,params]=gc1d_init_oja(Nmodule, LM_module, LM_phase,onlineplots,lr)

%    Nmodule:number of modules
%    LM_module:LM freq matches which module? (in module#)
%    LM_phase: phase where LM recurrs (in deg)

%set up ec modules
params.vis2mental=500000;  % time points when external LM is off
a = 20;                     % base module frequency
params.lr=lr;
params.a = a;
params.Nmodule=Nmodule;
params.LM_module=LM_module;
params.LM_phase=LM_phase;

params.num_neurons = 360;        % number of neurons in a module
width=params.num_neurons;
totalN = Nmodule*width;

for i = 1:Nmodule
    scale(i) = 1.1^(i-Nmodule/2);
    grid = createbump(width,a*scale(i),1);
    ec(i).module = toeplitz(grid);          % the neurons of a module at all time lags
end
w.ec2lm = randn(width,Nmodule)/totalN;      % initial weight
out.initW = reshape(w.ec2lm,[width Nmodule]);
out.ec = ec;
params.scale=scale;
tti=1;

%%
% lm external activity
idx = LM_phase/360*width;                      % phase of landmark
grid = createbump(width,a,1);
lm.ext = circshift(grid,[idx(1) 1]);

% added by sujay for using multiple landmarks
for ii=2:length(idx)
    lm.ext = lm.ext+circshift(grid,[idx(ii) 1]);

end


% total drive
%%
t = 0;
clf
eta = lr;  %0.0000001;                    % learning rate
while t<1000000                     % simulation duration
    t=t+1;
    lm.int=0;
    for i = 1:Nmodule
        ti(i) = round(t/scale(i));  % equivalent phase step for each module
        thisphase(:,i) = ec(i).module(:,mod(ti(i)-1,width)+1);      % pick the right activity phase
        lm.int = lm.int+w.ec2lm(:,i)'*thisphase(:,i);               % compute internal (EC to LM) input
    end

    Iext = lm.ext(mod(ti(LM_module)-1,width)+1);

    if t<params.vis2mental                 % when external landmark goes off
        lm.s = Iext+lm.int;
    else
        lm.s = lm.int;
    end

    w.ec2lm = w.ec2lm + eta*lm.s*(thisphase-lm.s*w.ec2lm);      % Oja
    w.ec2lm = w.ec2lm - repmat(mean(w.ec2lm),[width 1]);        % remove mean independently for each module

    if mod(t,2000)==0
        t
        if onlineplots==1
            imagesc(reshape(w.ec2lm,[width Nmodule]));hold on
            plot(LM_module,idx,'k.','MarkerSize',20);
            set(gca,'XTick',1:Nmodule,'XTickLabel',round(100*scale)/100);
            xlabel('Spatial scale (a.u.)');
            ylabel('Phase (deg)');
            set(gca,'FontSize',15)
            drawnow
            hold off
        end
        if t<params.vis2mental
            out.vis2mental(tti)=0;
            %                  title 'visual: ext. LM on'
        else
            out.vis2mental(tti)=1;
            %                  title 'mental: ext. LM off'
        end

        out.weights(tti,:,:)=reshape(w.ec2lm,[width Nmodule]);tti=tti+1;
    end

end

end
%%
function bump = createbump(d,width,amp)
z = (-d/2:d/2-1);
kernel = normpdf(z, 0, width);
kernel = amp*kernel/ max(kernel);
bump = kernel';
end