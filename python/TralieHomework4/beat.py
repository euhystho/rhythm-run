import numpy as np
import matplotlib.pyplot as plt
from novfn import *
from tempo import *

def get_gt_beats(filename, anno=0):
    """
    Load in the ground truth beats for some clip
    
    Parameters
    ----------
    filename: string
        Path to annotations
    anno: int
        Annotator number
    """
    fin = open(filename)
    lines = fin.readlines()
    fin.close()
    beats = lines[anno]
    beats = np.array([float(x) for x in beats.split()])
    return beats

def plot_beats(novfn, beats, sr, hop_length):
    """
    Plot the location of beats superimposed on an audio novelty
    function

    Parameters
    ----------
    novfn: ndarray(N)
        An audio novelty function
    beats: ndarray(M)
        An array of beat locations, in seconds
    sr: int
        Sample rate
    hop_length: int
        Hop length used in the STFT to construct novfn
    """
    h1 = np.min(novfn)
    h2 = np.max(novfn)
    diff = (h2-h1)
    h2 += 0.3*diff
    h1 -= 0.3*diff
    for b in beats:
        plt.plot([b, b], [h1, h2], linewidth=1)
    ts = np.arange(novfn.size)
    plt.plot(ts*hop_length/sr, novfn, c='C0', linewidth=2)
    plt.xlabel("Time (Sec)")


def sonify_beats(x, sr, beats, blip_len=0.03):
    """
    Put short little 440hz blips at each beat location
    in an audio file

    Parameters
    ----------
    x: ndarray(N)
        Audio samples
    sr: int
        Sample rate of audio
    beats: ndarray(N)
        Beat locations, in seconds, of each beat
    blip_len: float 
        The length, in seconds, of each 440hz cosine blip
    """
    y = np.array(x) # Copy x into an array where the beats will be sonified
    ## TODO: Fill this in and add the blips
    for i in range(len(beats)):
        i1=int(beats[i]*sr)
        i2=int((beats[i]+blip_len)*sr)
        y[i1:i2]+=np.cos(440*2*np.pi*np.arange(i2-i1)/sr)
    return y

def get_beats(novfn, sr, hop_length, tempo, alpha):
    """
    An implementation of dynamic programming beat tracking

    Parameters
    ----------
    novfn: ndarray(N)
        An audio novelty function
    sr: int
        Sample rate
    hop_length: int
        Hop length used in the STFT to construct novfn
    tempo: float
        The estimated tempo, in beats per minute
    alpha: float
        The penalty for tempo deviation
    
    Returns
    -------
    ndarray(B): 
        Beat locations, in seconds, of each beat
    """
    N = len(novfn)
    cscore = np.zeros(N) # Dynamic programming array
    T = int((60*sr/hop_length)/tempo) # Period, in units of novfn samples per beat, of the tempo
    backlink = np.ones(N, dtype=int) # Links for backtracing
    beats = []
    ## TODO: Fill this in
    #Step 1: Construct cscore and backlink 
    for i in range(2*T,len(cscore)):
        # partial sample of cscore from i-2T to i+T/2
        j1=int(i-2*T) # and make the abs log
        j2=int(i-T/2)
        abslog=-alpha*np.abs(np.log((i-np.linspace(j1,j2,j2-j1))/T))**2
        #pscore=cscore[j1:j2] #partial score or you can call it like 
        # previous range score
        # maximum of that range
        j=np.argmax(cscore[j1:j2]+novfn[i]+abslog)
        cscore[i]=cscore[j+j1]+novfn[i]+abslog[j]
        backlink[i]=j+j1
    print(backlink)

    #plot the cscore
    plt.figure(figsize=(10,6))
    plt.subplot(211)
    plt.title("Novfn")
    plt.plot(np.arange(N)/N*(sr/hop_length),novfn)
    plt.xlim((25,30))
    plt.subplot(212)
    plt.title("cscore")
    plt.plot(np.arange(N)/N*(sr/hop_length),cscore)
    #plt.xlim((0,30))
    plt.tight_layout()
    
    # Step2: Extract maximal beat optimal
    cur_idx=np.argmax(cscore)
    while cur_idx>1:
        beats.append((cur_idx*hop_length)*(1/sr))
        cur_idx=backlink[cur_idx]
    return beats[::-1]