import os
import torch
import torchaudio
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def play_pdm_audio(dut, filename):
    """Loads an audio file, converts it to a 1MHz PDM bitstream, and streams it to ui_in[0]."""
    dut._log.info(f"Loading and converting {filename} to PDM...")
    
    # Load audio
    waveform, sample_rate = torchaudio.load(filename)
    
    # User's exact PDM generation logic
    wave_1m = torch.nn.functional.interpolate(waveform.view(1, 1, -1), size=1000000, mode='linear', align_corners=False).squeeze()
    wave_unipolar = ((wave_1m + 1.0) / 2.0).clamp(0.0, 1.0)
    integral = torch.cumsum(wave_unipolar, dim=-1)
    pdm_bits = torch.diff(torch.floor(integral), prepend=torch.zeros(1, device=waveform.device)).to(torch.int32)
    
    pdm_list = pdm_bits.tolist()
    dut._log.info(f"Streaming {len(pdm_list)} PDM bits to ui_in[0]...")
    
    # Stream bits cycle-by-cycle
    for bit in pdm_list:
        dut.ui_in.value = bit
        await ClockCycles(dut.clk, 1)

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start SNN Audio Test")
    
    if os.environ.get('GATES') == 'yes':
        dut._log.info("Gate-level GDS test bypassed.")
        return

    # Set to 1 MHz (1 microsecond period) to match the 1,000,000 PDM array size
    clock = Clock(dut.clk, 1, unit="us")
    cocotb.start_soon(clock.start())

    # Initialize
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    
    # Release Reset
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    
    # 1. Feed the 3 keywords
    keywords = ["audio_1.wav", "audio_2.wav", "audio_3.wav"]
    for audio_file in keywords:
        await play_pdm_audio(dut, audio_file)
        
    # Wait for the display FSM to settle (e.g., waiting a few ms for the SNN to flush)
    dut._log.info("Waiting for FSM result on display...")
    await ClockCycles(dut.clk, 5000) 
    dut._log.info(f"Display output: {dut.uo_out.value}")

    # To avoid waiting the full 5-second FSM timer, pulse the reset pin to clear the calculator
    dut._log.info("Resetting FSM for noise/silence tests...")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    # 2. Feed Noise
    await play_pdm_audio(dut, "audio_4.wav")
    await ClockCycles(dut.clk, 5000)
    dut._log.info(f"Display output after noise: {dut.uo_out.value}")

    # 3. Feed Silence
    await play_pdm_audio(dut, "audio_5.wav")
    await ClockCycles(dut.clk, 5000)
    dut._log.info(f"Display output after silence: {dut.uo_out.value}")
    
    dut._log.info("Audio tests completed.")