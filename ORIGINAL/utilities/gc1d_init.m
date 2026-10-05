function NN = gc1d_init(NN)

N = NN.N;
NN.dt = 1/2000;        %step size of numerical integration (s)
NN.tau_s = 40/1000;    %synaptic time constant (s)

T = 10;            %length of initialization blocks (s)
N_t = T/NN.dt;         %number of time points in the simulation

% in itial speed input = low-amp white noise 
v_base = 0;
weber_frac = 0.01;
v_noise  = weber_frac*randn;
v= (v_base+v_noise)*ones(1,N_t);

%Graphing parameters
doplot = 0;
if doplot
    close all
    bins = linspace(0+.01,1-.01,50);
    scrsz = get(0,'ScreenSize');
    figure('Position',[10 scrsz(4)/2 scrsz(3)*(1/3) scrsz(4)/1.5])
end

landmark_input = landmark(NN,0,30,3);

sij = zeros(2*N,N_t);  %Population activity across time

for t = 2:N_t

        %LEFT population
        v_L = (1 - NN.beta_vel*v(t));
        g_LL = NN.W_LL*sij(1:N,t-1);                     %L->L
        g_LR = NN.W_LR*sij(N+1:2*N,t-1);                 %R->L
        G_L = v_L*((g_LL + g_LR) + NN.FF_global);              %input conductance into Left population

        %RIGHT population
        v_R = (1 + NN.beta_vel*v(t));
        g_RR = NN.W_RR*sij(N+1:2*N,t-1);                 %R->R
        g_RL = NN.W_RL*sij(1:N,t-1);                     %L->R
        G_R = v_R*((g_RR + g_RL) + NN.FF_global);              %input conductance into Right population

        G_L = G_L + landmark_input;
        G_R = G_R + landmark_input;
        
        G = [G_L;G_R];
        F = G.*(G>=0);   %RelU
        
        %update population activity
        sij(:,t) = sij(:,t-1)+ (F - sij(:,t-1))*NN.dt/NN.tau_s;
        
        doplot=0;
        if (mod(t,500)==0 & doplot)%plot every 100 steps
            clf
            z = sij(1:N,t);
%             TF = islocalmax(z);
%             peakidx = find(TF);
            hold on
            plot(landmark_input,'k','LineWidth',5);
            plot(z,'b');
%             plot(peakidx,z(peakidx),'b.','Markersize',20); 
%             localfreq = diff(peakidx);
            set(gca,'YTick', [], 'XTick', [0:45:360])
            xlabel('Phase over ring (deg)');
            hold off;
            xlim([-5 370]);
            drawnow
        end
end

NN.init_state =sij(:,end);

end

function landmark_input = landmark(NN,landmark_mean, landmark_std, landmark_gain)
    x = [1:NN.N]';
    landmark_input = exp(-(x-landmark_mean ).^2/(2*landmark_std ^2));
    landmark_input = landmark_input / max(landmark_input);
    landmark_input = landmark_gain*landmark_input;
end

