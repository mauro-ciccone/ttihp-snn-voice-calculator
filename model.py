import torch
import torch.nn as nn
import snntorch as snn

class SpikingNet(nn.Module):
    def __init__(self, n_mels=16, num_hidden=256, num_outputs=9, beta=0.88):
        super().__init__()
        # Flatten the 16 mel bands
        self.fc1 = nn.Linear(n_mels, num_hidden)
        # We add learn_beta=True so PyTorch optimizes the leak rates for the hardware!
        self.lif1 = snn.Leaky(beta=beta, learn_beta=True)
        self.fc2 = nn.Linear(num_hidden, num_outputs)
        self.lif2 = snn.Leaky(beta=beta)

    def forward(self, x):
        # x shape: [batch, time, n_mels]
        mem1 = self.lif1.init_leaky()
        mem2 = self.lif2.init_leaky()

        spk2_rec = []
        for step in range(x.size(1)):
            cur1 = self.fc1(x[:, step, :])
            spk1, mem1 = self.lif1(cur1, mem1)
            cur2 = self.fc2(spk1)
            spk2, mem2 = self.lif2(cur2, mem2)
            spk2_rec.append(spk2)

        return torch.stack(spk2_rec, dim=1)