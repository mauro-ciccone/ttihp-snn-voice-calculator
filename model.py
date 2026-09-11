import torch
import torch.nn as nn
import snntorch as snn
from snntorch import surrogate

class FastSpikingNet(nn.Module):
    def __init__(self, num_inputs=8, num_hidden=80, num_outputs=7, beta=0.88):
        super().__init__()
        
        # --- COMPLETE EXHAUSTIVE HARDWARE DICTIONARY (SHIFTS 0-4) ---
        self.register_buffer("valid_betas", torch.tensor([
            0.0000,  # [0 Gates] Clear (V >> inf)
            0.0625,  # [0 Gates] (V >> 4)
            0.1250,  # [0 Gates] (V >> 3)
            0.1875,  # [1 Gate]  (V >> 3) + (V >> 4)
            0.2500,  # [0 Gates] (V >> 2)
            0.3125,  # [1 Gate]  (V >> 2) + (V >> 4)
            0.3750,  # [1 Gate]  (V >> 2) + (V >> 3)
            0.4375,  # [1 Gate]  (V >> 1) - (V >> 4) 
            0.5000,  # [0 Gates] (V >> 1)
            0.5625,  # [1 Gate]  (V >> 1) + (V >> 4)
            0.6250,  # [1 Gate]  (V >> 1) + (V >> 3)
            0.6875,  # [2 Gates] V - (V >> 2) - (V >> 4)
            0.7500,  # [1 Gate]  V - (V >> 2) 
            0.8125,  # [2 Gates] V - (V >> 3) - (V >> 4)
            0.8750,  # [1 Gate]  V - (V >> 3)
            0.9375,  # [1 Gate]  V - (V >> 4)
            1.0000   # [0 Gates] (V >> 0) 
        ]))

        

        self.fc_in = nn.Linear(num_inputs, num_hidden, bias=False)
        self.fc_rec = nn.Linear(num_hidden, num_hidden, bias=False)
        
        # A gentler slope allows gradients to flow preventing the deadzone disconnect.
        wide_grad = surrogate.fast_sigmoid(slope=25) 

        beta_hid = torch.full((num_hidden,), beta)
        self.lif_hidden = snn.Leaky(beta=beta_hid, spike_grad=wide_grad, learn_beta=True)
        
        self.fc_out = nn.Linear(num_hidden, num_outputs, bias=False)

        beta_out = torch.full((num_outputs,), beta)
        self.lif_out = snn.Leaky(beta=beta_out, spike_grad=wide_grad, learn_beta=True)

        # Shift the mean strictly positive to prevent early network collapse
        with torch.no_grad():
            self.fc_in.weight.data.normal_(mean=0.1418, std=0.149)
            self.fc_rec.weight.data.normal_(mean=-0.0954, std=0.2711) 
            self.fc_out.weight.data.normal_(mean=0.0288, std=0.24) 

    def forward(self, x):
        mem_hidden = self.lif_hidden.init_leaky()
        mem_out = self.lif_out.init_leaky()
        
        spk_hidden = torch.zeros(x.size(0), self.fc_rec.in_features, device=x.device)
        spk_out_rec = []
        spk_hidden_rec = []
        
        for step in range(x.size(1)):
            cur_in = self.fc_in(x[:, step, :])
            cur_rec = self.fc_rec(spk_hidden)
            
            spk_hidden, mem_hidden = self.lif_hidden(cur_in + cur_rec, mem_hidden)
            spk_hidden_rec.append(spk_hidden)
            
            cur_out = self.fc_out(spk_hidden)
            spk_out, mem_out = self.lif_out(cur_out, mem_out)
            spk_out_rec.append(spk_out)
            
        return torch.stack(spk_out_rec, dim=1), torch.stack(spk_hidden_rec, dim=1)

    def hardware_beta_penalty(self):
        """
        Phase 2 Loss: Forces learned betas to snap to the nearest valid hardware shift.
        Returns the mean squared error between current betas and the closest physical shift.
        """
        # Apply sigmoid to constrain the raw learned betas between 0 and 1
        current_hid_betas = torch.sigmoid(self.lif_hidden.beta)
        current_out_betas = torch.sigmoid(self.lif_out.beta)
        
        # Calculate distance to nearest valid hardware beta
        dist_hid = torch.cdist(current_hid_betas.unsqueeze(1), self.valid_betas.unsqueeze(1)) # type: ignore
        dist_out = torch.cdist(current_out_betas.unsqueeze(1), self.valid_betas.unsqueeze(1)) # type: ignore
        
        min_dist_hid, _ = torch.min(dist_hid, dim=1)
        min_dist_out, _ = torch.min(dist_out, dim=1)
        
        return min_dist_hid.mean() + min_dist_out.mean()