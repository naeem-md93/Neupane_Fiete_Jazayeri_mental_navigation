function NN = gc1d_run(NN)

    N = NN.N;
    doplot = NN.plotit;
    makegif = 1;
    
    T = 60;            %length of integration time blocks (s)
    N_t = T/NN.dt;         %number of time points in the simulation

    %speed input -- adjusted so that w/ and w/o landmarks have ~matched mean tp
    if NN.landmarkpresent v_base = NN.wlm_speed; else v_base = NN.wolm_speed; end
    
    wm = NN.wm;  %weber fraction
    v_noise  = v_base*wm*randn;
    NN.noisy_vel_input = v_base+v_noise; %add noise here to get behavioral variability 
    v =  NN.noisy_vel_input*ones(1,N_t);
    NN.wm=wm;
    NN.v_noise = v_noise;
    NN.v_base=v_base;
    %Graphing parameters
    if doplot setplotparams, end
    
   

    landmark_flag=0;
    landmark_centers=NN.landmark_input_loc+3;   %location of landmark centers
    landmark_onset = 500;           %risetime for the landmark
    landmark_tau = 1500;            %decay speed of landmarks
    
    inital_state=NN.inital_state;            %approximate inital phase of the network at onset of timing
    end_state=NN.end_state;              %final phase of the network at the time of prduction
    nn_state = inital_state;    % initialize state
    
     sij = zeros(2*N,N_t);  %Population activity across time
    sij(:,1) =NN.init_state;

    t = 1;

    while nn_state(t)<end_state

        t = t+1;

        %LEFT population
        v_L = (1 - NN.beta_vel*v(t));
        g_LL = NN.W_LL*sij(1:N,t-1);                     %L->L
        g_LR = NN.W_LR*sij(N+1:2*N,t-1);                 %R->L
        G_L = v_L*((g_LL + g_LR) + NN.FF_global);        %input conductance into Left population

        %RIGHT population
        v_R = (1 + NN.beta_vel*v(t));
        g_RR = NN.W_RR*sij(N+1:2*N,t-1);                 %R->R
        g_RL = NN.W_RL*sij(1:N,t-1);                     %L->R
        G_R = v_R*((g_RR + g_RL) + NN.FF_global);        %input conductance into Right population
        
        %Set up landmark inputs depending on the network state
        if NN.landmarkpresent
            
            if NN.landmark_input_external>0
                
                %insert external landmark here
%                 t*NN.dt
                if (t*NN.dt)>NN.landmark_input_external 
                    if landmark_flag==0
                        landmark_flag=1; t1=t;t2=0;t3=0;
                        NN.LM_onset_state=nn_state(t-1);
                        landmark_centers=nn_state(t-1);
                    end
                
                    landmark_amp = 50*exp(-(t-t1-landmark_onset).^2/(2*landmark_tau^2));
                    landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                else
                    landmark_input = landmark(NN,90,5,0);
                    
                end
                
            else
                
                if length(NN.landmark_input_loc)>1
                    
%                     if nn_state(t-1)<NN.landmark_input_loc(1)
%                         landmark_input = landmark(NN,90,5,0);
%                     elseif nn_state(t-1)<NN.landmark_input_loc(2)
%                         if landmark_flag==0 landmark_flag=1; t1=t; end
%                         landmark_amp = 50*exp(-(t-t1-landmark_onset).^2/(2*landmark_tau^2));
%                         landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
%                     elseif nn_state(t-1)<NN.landmark_input_loc(3)
%                         if landmark_flag==1 landmark_flag=2; t2=t; end
%                         landmark_amp = 50*exp(-(t-t2-landmark_onset).^2/(2*landmark_tau^2));
%                         landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
%                     else
%                         if landmark_flag==2 landmark_flag=3; t3=t; end
%                         landmark_amp = 50*exp(-(t-t3-landmark_onset).^2/(2*landmark_tau^2));
%                         landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
%                     end
                    
                  
                     if nn_state(t-1)<NN.landmark_input_loc(1)
                        landmark_input = landmark(NN,90,5,0);
                    elseif nn_state(t-1)<NN.landmark_input_loc(2)
                        if landmark_flag==0 landmark_flag=1; t1=t; end
                        landmark_amp = 50*exp(-(t-t1-landmark_onset).^2/(2*landmark_tau^2));
                        landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                    elseif nn_state(t-1)<NN.landmark_input_loc(3)
                        if landmark_flag==1 landmark_flag=2; t2=t; end
                        landmark_amp = 50*exp(-(t-t2-landmark_onset).^2/(2*landmark_tau^2));
                        landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                     elseif nn_state(t-1)<NN.landmark_input_loc(4)
                        if landmark_flag==2 landmark_flag=3; t3=t; end
                        landmark_amp = 50*exp(-(t-t3-landmark_onset).^2/(2*landmark_tau^2));
                        landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                     elseif nn_state(t-1)<NN.landmark_input_loc(5)
                        if landmark_flag==3 landmark_flag=4; t4=t; end
                        landmark_amp = 50*exp(-(t-t4-landmark_onset).^2/(2*landmark_tau^2));
                        landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                     else
                         if landmark_flag==4 landmark_flag=5; t5=t; end
                        landmark_amp = 50*exp(-(t-t5-landmark_onset).^2/(2*landmark_tau^2));
                        landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                    end
                    
                        
                else
                    
                    if nn_state(t-1)<NN.landmark_input_loc(1)
                        landmark_input = landmark(NN,90,5,0);
                    else% nn_state(t-1)<NN.landmark_input_loc(2)
                        if landmark_flag==0 landmark_flag=1; t1=t; t2=0;t3=0;end
                        landmark_amp = 50*exp(-(t-t1-landmark_onset).^2/(2*landmark_tau^2));
                        landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                        %                 elseif nn_state(t-1)<NN.landmark_input_loc(3)
                        %                     if landmark_flag==1 landmark_flag=2; t2=t; end
                        %                     landmark_amp = 50*exp(-(t-t2-landmark_onset).^2/(2*landmark_tau^2));
                        %                     landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                        %                 else
                        %                     if landmark_flag==2 landmark_flag=3; t3=t; end
                        %                     landmark_amp = 50*exp(-(t-t3-landmark_onset).^2/(2*landmark_tau^2));
                        %                     landmark_input = landmark(NN,landmark_centers,5,landmark_amp);
                    end
                    
                end
                
            end
            
            
        else
            landmark_input = landmark(NN,90,5,0);
        end
        
        % add landmark to both directions
        G_L = G_L + landmark_input;
        G_R = G_R + landmark_input;
        
        G = [G_L;G_R];
        F = G.*(G>=0);   %RelU
        
        %update population activity
        sij(:,t) = sij(:,t-1)+ (F - sij(:,t-1))*NN.dt/NN.tau_s;

        % find the local maximum to track the nn state
        z = sij(1:N,t);
        [~,TF] = findpeaks(z(nn_state(end)-10:end));
        nn_state = [nn_state TF(1)+nn_state(end)-11];
%         nn_state(t)
       
        %plot moment by moment progression
        if doplot plotsim(t, landmark_input, z, nn_state,makegif), end
        NN.grid_statesR(:,t) = sij(1:N,t);
        NN.grid_statesL(:,t) = sij(N+1:end,t);
    end
    NN.nn_state = nn_state(2:end);
    if NN.landmarkpresent
        NN.lm_onset_times = [t1 t2 t3 t4 t5];
        
    end
%     NN.lm_offset_times = [t1off t2off t3off];

end

%% 
% Compute the landmark inputs 
function landmark_input = landmark(NN,landmark_mean, landmark_std, landmark_gain)
    x = [1:NN.N]';
    for nmodes=1:length(landmark_mean)
        landmark_i(nmodes,:) = landmark_gain*exp(-(x-landmark_mean(nmodes) ).^2/(2*landmark_std ^2));
    end
    landmark_input = sum(landmark_i,1)';
end

%% 
% Set plotting parameters
function setplotparams
    bins = linspace(0+.01,1-.01,50);
%     scrsz = get(0,'ScreenSize');
%     figure('Position',[10 scrsz(4)/2 scrsz(3)*(1/3) scrsz(4)/1.5])
%     
end

%%
% Plot moment-by-moment network activity
function plotsim(t, landmark_input, z, nn_state, makegif)
    if (mod(t,200)==0)%plot every 100 steps
              subplot 211
                               cla; 

            hold on

        set(gca,'YTick', [], 'XTick', [0:45:360],'FontSize',15)
        plot(landmark_input/10,'k','LineWidth',5);
        plot(z,'b');
        plot(nn_state(t),5,'r.','Markersize',30); 
        xlabel('Neurons @ phase (deg)');ylabel Activation
        hold off;
        xlim([-5 370]);
        ylim([0 20]);
        
         subplot 212
         hold on
        plot([1:length(nn_state)]/2000,nn_state,'k');
        xlabel time(s); ylabel ('distance(deg)')
        set(gca,'FontSize',15)

        drawnow
        
        if makegif
            frame = getframe(gcf);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if t==200
                imwrite(imind,cm,'step2lm.gif','gif', 'Loopcount',inf);
            else
                imwrite(imind,cm,'step2lm.gif','gif','WriteMode','append');
            end
        end
        
%         clf
        
 

    end
    
end


