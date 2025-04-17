import numpy as np
import matplotlib.pyplot as plt
from scipy.ndimage import maximum_filter

def blackman_harris_window(N):
    """
    Create a Blackman-Harris Window
    
    Parameters
    ----------
    N: int
        Length of window
    
    Returns
    -------
    ndarray(N): Samples of the window
    """
    a0 = 0.35875
    a1 = 0.48829
    a2 = 0.14128
    a3 = 0.01168
    t = np.arange(N)/N
    return a0 - a1*np.cos(2*np.pi*t) + a2*np.cos(4*np.pi*t) - a3*np.cos(6*np.pi*t)

def stft(x, w, h, win_fn):
    """
    Compute the complex Short-Time Fourier Transform (STFT)
    Parameters
    ----------
    x: ndarray(N)
        Full audio clip of N samples
    w: int
        Window length
    h: int
        Hop length
    win_fn: int -> ndarray(N)
        Window function
    
    Returns
    -------
    ndarray(w, nwindows, dtype=np.complex) STFT
    """
    N = len(x)
    nwin = int(np.ceil((N-w)/h))+1
    # Make a 2D array
    # The rows correspond to frequency bins
    # The columns correspond to windows moved forward in time
    S = np.zeros((w, nwin), dtype=complex)
    # Loop through all of the windows, and put the fourier
    # transform amplitudes of each window in its own column
    for j in range(nwin):
        # Pull out the audio in the jth window
        xj = x[h*j:h*j+w]
        # Zeropad if necessary
        if len(xj) < w:
            xj = np.concatenate((xj, np.zeros(w-len(xj))))
        # Apply window function
        xj = win_fn(w)*xj
        # Put the fourier transform into S
        S[:, j] = np.fft.fft(xj)
    return S

def sonify_novfn(novfn, hop_length):
    """
    Shape noise according to a novelty function

    Parameters
    ----------
    novfn: ndarray(N)
        A novelty function with N samples
    hop_length: int
        The hop length, in audio samples, between each novelty function sample
    
    Returns
    -------
    ndarray(N*hop_length)
        Shaped noise according to the audio novelty function
    """
    x = np.random.randn(len(novfn)*hop_length)
    for i in range(len(novfn)):
        x[i*hop_length:(i+1)*hop_length] *= novfn[i]
    return x

def amplitude_to_db(S, amin=1e-10, ref=1):
    """
    Convert an amplitude spectrogram to be expressed in decibels
    
    Parameters
    ----------
    S: ndarray(win, T)
        Amplitude spectrogram
    amin: float
        Minimum accepted value for the spectrogram
    ref: int
        0dB reference amplitude
        
    Returns
    -------
    ndarray(win, T)
        The dB spectrogram
    """
    SLog = 20.0*np.log10(np.maximum(amin, S))
    SLog -= 20.0*np.log10(np.maximum(amin, ref))
    return SLog

def get_novfn(x, sr, hop_length=512, win_length=1024):
    """
    Our vanilla audio novelty function from module 16
    https://ursinus-cs372-s2023.github.io/Modules/Module16/Video1

    Parameters
    ----------
    x: ndarray(N)
        Audio samples
    sr: int
        Sample rate
    hop_length: int
        Hop length between frames in the stft
    win_length: int
        Window length between frames in the stft
    """
    S = stft(x, win_length, hop_length, blackman_harris_window)
    S = np.abs(S)
    S = S[0:win_length//2+1, :]
    Sdb = amplitude_to_db(S)
    N = Sdb.shape[0]
    novfn = np.zeros(N-1) # Pre-allocate space to hold some kind of difference between columns
    diff = Sdb[:, 1::] - Sdb[:, 0:-1]
    diff[diff < 0] = 0 # Cut out the differences that are less than 0
    novfn = np.sum(diff, axis=0)
    return novfn

def get_mel_filterbank(K, win_length, sr, min_freq, max_freq, n_bins):
    """
    Compute a mel-spaced filterbank and place it in a matrix
    
    Parameters
    ----------
    win_length: int
        Window length
    K: int
        Number of frequency bins
    sr: int
        The sample rate used to generate sdb
    min_freq: int
        The center of the minimum mel bin, in hz
    max_freq: int
        The center of the maximum mel bin, in hz
    n_bins: int
        The number of mel bins to use
    
    Returns
    -------
    ndarray(n_bins, n_win)
        The mel-spaced spectrogram
    """
    # Space bin centers exponentially between min_freq and max_freq
    bins = np.logspace(np.log10(min_freq), np.log10(max_freq), n_bins+2)*win_length/sr
    bins = np.array(np.round(bins), dtype=int)
    Mel = np.zeros((n_bins, K))
    for i in range(n_bins):
        i1 = bins[i]
        i2 = bins[i+1]
        if i1 == i2:
            i2 += 1
        i3 = bins[i+2]
        if i3 <= i2:
            i3 = i2+1
        tri = np.zeros(K)
        ## TODO: Create a triangle in the tri array which
        ## goes from 0 to 1 between index i1 and i2
        ## and from 1 to 0 between index i2 and i3.
        ## Then, place this triangle at row i of the Mel matrix
        tri[i1:i2]=np.linspace(0,1,int(i2-i1))
        tri[i2:i3]=np.linspace(1,0,int(i3-i2))
        Mel[i,:]=tri
    return Mel
 
def get_superflux_novfn(x, sr, hop_length=512, win_length=1024, max_win = 1, mu=1, Gamma=10):
    """
    Implement the superflux audio novelty function, as described in [1]
    [1] "Maximum Filter Vibrato Suppresion for Onset Detection," 
            Sebastian Boeck, Gerhard Widmer, DAFX 2013

    Parameters
    ----------
    x: ndarray(N)
        Audio samples
    sr: int
        Sample rate
    hop_length: int
        Hop length between frames in the stft
    win_length: int
        Window length between frames in the stft
    max_win: int
        Amount by which to apply a maximum filter
    mu: int
        The gap between windows to compare
    Gamma: float
        An offset to add to the log spectrogram; log10(|S| + Gamma)
    """
    S = stft(x, win_length, hop_length, blackman_harris_window)
    S = np.abs(S)
    S = S[0:S.shape[0]//2+1, :] # Keep only non-redundant frequency bins
    ## TODO: Fill this in
    #Step 2: Convert the spectrogram to a mel spectrogram
    Mel=get_mel_filterbank(S.shape[0],win_length,sr,27.5,16000,138)
    #Step 3: Convert every element of the magnitude Mel-spectrogram 
    #MS to a log magnitude scale
    MS = np.log10(Mel.dot(S)+Gamma)
    #Perform a maximum filter
    MF=maximum_filter(MS,(max_win,1))
    #Step 4: Take the sum of positive differences of amplitudes across all
    #frequency bins from a window to a window in the future
    MF=amplitude_to_db(MF)
    diff=MF[:,mu::]-MF[:,0:-mu:]
    diff[diff<0]=0
    return np.sum(diff,axis=0)

    