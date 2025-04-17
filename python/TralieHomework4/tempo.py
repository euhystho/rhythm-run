import numpy as np
import matplotlib.pyplot as plt
import glob
import os
from novfn import *

def autocorr(x):
    """
    Fast autocorrelation based on the Wiener-Khinchin Theorem, which allows us
    to use the fast fourier transform of the input to compute the autocorrelation

    Parameters
    ----------
    x: ndarray(N)
        Array on which to compute the autocorrelation
    
    Returns
    -------
    ndarray(N): The autocorrelation
    """
    N = len(x)
    xpad = np.zeros(N*2)
    xpad[0:N] = x
    F = np.fft.fft(xpad)
    FConv = np.real(F)**2 + np.imag(F)**2 # Fourier transform of the convolution of x and its reverse
    return np.real(np.fft.ifft(FConv)[0:N])


def get_fourier_tempo(novfn, hop_length, sr):
    """
    Parameters
    ----------
    novfn: ndarray(N)
        The novelty function
    hop_length: int
        Hop length, in audio samples, between the samples in the audio
        novelty function
    sr: int
        Sample rate of the audio
    
    Returns
    -------
    float: Estimate, in beats per minute, of the tempo
    """
    ## TODO: Fill this in
    N=len(novfn)
    novfn-=np.mean(novfn)
    F=np.abs(np.fft.fft(novfn))
    F[N//2:]=0
    i=np.argmax(F)
    return (i/N)*(sr/hop_length)*60


def get_acf_dft_tempo(novfn, hop_length, sr):
    """
    Estimate the tempo, in bpm, based on a combination of a warped
    DFT and the autocorrelation of a novelty function, as described in 
    section 3.1.1 of [1]
    [1] "Template-Based Estimation of Time-Varying Tempo." Geoffroy Peeters.
            EURASIP Journal on Advances in Signal Processing

    Parameters
    ----------
    novfn: ndarray(N)
        The novelty function
    hop_length: int
        Hop length, in audio samples, between the samples in the audio
        novelty function
    sr: int
        Sample rate of the audio
    
    Returns
    -------
    float: Estimate, in beats per minute, of the tempo
    """
    ## TODO: Fill this in to use the product of warped fourier and 
    ## autocorrelation
    novfn-=np.mean(novfn)
    dft=np.abs(np.fft.fft(novfn))
    N=len(dft)
    au=autocorr(novfn)
    Ts=len(au)
    #print(Ts)
    dftw=np.zeros(Ts)
    for T in range(1,Ts):
        i1=min(int(np.floor(N/T)),N-1)
        i2=min(int(np.ceil(N/T)),N-1)
        dftw[T]=(N/T-i1)*dft[i2]+(i2-N/T)*dft[i1]
    plt.figure(figsize=(10, 6))
    plt.subplot(411)
    plt.plot(np.arange(Ts)[:400], au[:400])
    plt.title("Auto corelation Function")
    plt.xlabel("Shift (Period Index)")
    plt.ylabel("dotprod")
    
    plt.subplot(412)
    plt.plot(np.arange(N)[:400], (dft[:400]))
    plt.title("Maginitude DFT")
    plt.xlabel("Freq Index")
    #plt.ylim((0,20000))
    plt.ylabel("Mag>0")

    plt.subplot(413)
    plt.plot(np.arange(Ts)[:400],np.abs(dftw[:400]))
    plt.title("Domain DFTW")
    plt.xlabel("Shift (Period Index)")
    #plt.ylim((0,6000))
    plt.ylabel("Mag>0")

    plt.subplot(414)
    plt.plot(np.arange(Ts)[:400],(au*dftw)[:400])
    plt.title("Product ACT and DFTW")
    plt.xlabel("Shift (Period Index)")
    plt.ylabel("Mag>0") 
    plt.tight_layout()
    idx=np.argmax(au*dftw)
    return (1/hop_length)*(1/idx)*sr*60

def evaluate_tempos(f_novfn, f_tempofn, hop_length, tol = 0.08):
    """
    Evaluate the example dataset of 20 clips from MIREX
    https://www.music-ir.org/mirex/wiki/2019:Audio_Tempo_Estimation
    based on a particular novelty function and tempo function working together

    Parameters
    ----------
    f_novfn: (x, sr) -> ndarray(N)
        A function from audio samples and their sample rate to an audio novelty function
    f_tempofn: (novfn, hop_length, sr) -> float
        A function to estimate the tempo from an audio novelty function.  The hop
        length and sample rate are needed to infer absolute beats per minute
    hop_length: int
        The hop length, in audio samples, between the samples of the audio novelty
        function
    tol: float
        The fraction of error tolerated between ground truth tempos to declare
        success on a particular track
    
    Returns
    -------
    A pandas dataframe with the filename, 
    """
    from scipy.io import wavfile
    import pandas as pd
    from collections import OrderedDict
    files = glob.glob("Testing/Tempo/*.txt")
    num_close = 0
    names = []
    gt_tempos = []
    est_tempos = []
    close_enough = []
    for f in files:
        fin = open(f)
        tempos = [float(x) for x in fin.readlines()[0].split()][0:2]
        f = os.path.join("Testing", "Audio", f.split(".txt")[0].split(os.path.sep)[-1] + ".wav")
        sr, x = wavfile.read(f)
        novfn = f_novfn(x, hop_length, sr)
        tempo = f_tempofn(novfn, hop_length, sr)
        close = np.abs(tempo-tempos[0])/tempos[0] < tol
        close = close or np.abs(tempo-tempos[1])/tempos[1] < tol
        close_enough.append(close)
        names.append(f.split(os.path.sep)[-1])
        gt_tempos.append(tempos)
        est_tempos.append(tempo)
        if close:
            num_close += 1
    nums = np.array([int(s.split(".wav")[0].split("train")[-1]) for s in names])
    idx = np.argsort(nums)
    names = [names[i] for i in idx]
    gt_tempos = [gt_tempos[i] for i in idx]
    est_tempos = [est_tempos[i] for i in idx]
    close_enough = [close_enough[i] for i in idx]
    df = pd.DataFrame(OrderedDict([("names", names), ("Ground-Truth Tempos", gt_tempos), \
                                    ("Estimated Tempos", est_tempos), ("Close Enough", close_enough)]))
    print("{} / {}".format(num_close, len(files)))
    return df
