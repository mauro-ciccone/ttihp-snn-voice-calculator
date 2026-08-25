import torch
import torch.nn as nn
import snntorch as snn

class SpikingNet(nn.Module):
    def __init__(self, n_mels=16, num_hidden=96, num_outputs=9, beta=0.88):
        super().__init__()
        
        # 1. Input routing (Silicon Cochlea to Graph)
        self.fc_in = nn.Linear(n_mels, num_hidden)
        
        # 2. The Recurrent Graph (Hidden to Hidden)
        # This is the "spiderweb" matrix that we will heavily prune
        self.fc_rec = nn.Linear(num_hidden, num_hidden)
        
        # The neurons
        self.lif_hidden = snn.Leaky(beta=beta, learn_beta=True)
        
        # 3. Output routing (Graph to Display)
        self.fc_out = nn.Linear(num_hidden, num_outputs)
        self.lif_out = snn.Leaky(beta=beta)

    def forward(self, x):
        # Clamp beta to safe physical limits using the correct layer name
        with torch.no_grad():
            self.lif_hidden.beta.clamp_(0.60, 0.96)
            
        mem_hidden = self.lif_hidden.init_leaky()
        mem_out = self.lif_out.init_leaky()
        
        # Initialize the recurrent spikes to zero for the first timestep
        spk_hidden = torch.zeros(x.size(0), self.fc_rec.in_features, device=x.device)

        spk_out_rec = []
        for step in range(x.size(1)):
            # Add incoming audio current PLUS recurrent current from the last timestep
            cur_in = self.fc_in(x[:, step, :])
            cur_rec = self.fc_rec(spk_hidden)
            
            spk_hidden, mem_hidden = self.lif_hidden(cur_in + cur_rec, mem_hidden)
            
            cur_out = self.fc_out(spk_hidden)
            spk_out, mem_out = self.lif_out(cur_out, mem_out)
            
            spk_out_rec.append(spk_out)

        return torch.stack(spk_out_rec, dim=1)