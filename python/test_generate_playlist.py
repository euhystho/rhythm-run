import pytest
import sys
import os 
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../python')))
import generate_playlist

def test_generate_playlist1():
    playlist = generate_playlist.generate_playlist(0, 0, 0)
    assert playlist == None

def test_generate_playlist2():
    generate_playlist.create_sample_db()
    playlist = generate_playlist.generate_playlist("beginner", "medium", "short")
    sum = 0
    for song in playlist:
        '''for thing in song:
            print(thing)'''
        assert song[2] >= 145 and song[2] <= 160  
        # Normaly the range would be 150-157 but the test data causes 
        # this to expand to 160 in order to fill the playlist
        sum = sum + song[3]
        # tuple of song is id = [0], name = [1], bpm = [2], minutes = [3]
    assert sum >= 10 and sum <= 15

def test_generate_playlist1():
    playlist = generate_playlist.generate_playlist("b", "b", "b")
    assert playlist == None

def test_generate_playlist1():
    playlist = generate_playlist.generate_playlist("", "", "")
    assert playlist == None

def test_generate_playlist5():
    playlist = generate_playlist.generate_playlist("beginner", "medium", "high")
    assert playlist == None
