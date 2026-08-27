import torch
import torch.nn as nn
import snntorch as snn

class FastSpikingNet(nn.Module):
    def __init__(self, num_inputs=8, num_hidden=128, num_outputs=8, beta=0.88):
        super().__init__()
        self.fc_in = nn.Linear(num_inputs, num_hidden, bias=False)
        self.fc_rec = nn.Linear(num_hidden, num_hidden, bias=False)
        self.lif_hidden = snn.Leaky(beta=beta, learn_beta=True)
        
        self.fc_out = nn.Linear(num_hidden, num_outputs, bias=False)
        self.lif_out = snn.Leaky(beta=beta)

        # Shift the mean to be strictly positive. 
        # This ensures incoming spikes actually add voltage to the membrane.
        with torch.no_grad():
            self.fc_in.weight.data.normal_(mean=0.36, std=0.05)
            self.fc_rec.weight.data.normal_(mean=0.0, std=0.05) # Keep recurrent quiet
            self.fc_out.weight.data.normal_(mean=0.09, std=0.01)

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