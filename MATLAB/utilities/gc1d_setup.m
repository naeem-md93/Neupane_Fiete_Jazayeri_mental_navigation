function NN = gc1d_setup
 
%% network architcture: 2 rings, each N units, one with CW bias and one with CCW bias

    NN.N = 364;

    % Center Surround mexican hat connectivity profile
    A_ext = 1000;
    s_exc = 1.05/100;    
    A_inh = 1000;
    s_inh = 1.00/100;    
    NN = mexHat(NN, A_ext, s_exc, A_inh, s_inh); 

    % synaptic weights (shifts currently hard coded)
    l_RR = -1;          % right to right bias by 1
    l_LL = 1;           % left to left bias by 1
    l_RL=0;
    l_LR=0;
    NN = synapses(NN);

    %global excitatory input
    NN.beta_0 = 100;
    NN.FF_global= NN.beta_0*ones(NN.N,1);    

    % velocity drive parameters
    NN.beta_vel = 1;     %velocity gain

    % topographically organized phase preference    
    NN.x_prefs = (1:NN.N)'/NN.N; 
    
    save NN
end

function NN = mexHat(NN, A_ext, s_exc, A_inh, s_inh)

%% set the profile of the mexican hat connectivity

    z = (-NN.N/2:1:NN.N/2-1);
    NN.mexHat = A_ext*exp(-s_exc*z.^2) - A_inh*exp(-s_inh*z.^2);
    NN.mexHat = circshift(NN.mexHat, [0 NN.N/2 - 1]);

end

function NN = synapses(NN)
    
%% set model synaptic connections

    for i = 1:NN.N
        NN.W_RR(i,:) =  circshift(NN.mexHat ,[0 i-1]); % Right neurons to Right neurons
        NN.W_LL(i,:) =  circshift(NN.mexHat ,[0 i+1]); % Left neurons to Left neurons
        NN.W_RL(i,:) =  circshift(NN.mexHat ,[0 i]);     % Left neurons to Right neurons
        NN.W_LR(i,:) =  circshift(NN.mexHat ,[0 i]);     % Right neurons to Left neurons
    end
    
end
