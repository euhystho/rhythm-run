import pytest
import sys
sys.path.append('..')
import generate_playlist

def test_generate_playlist1():
    playlist = generate_playlist.generate_playlist(0, 0, 0)
    assert playlist == None

#def test_generate_playlist2():
    #playlist = generate_playlist.generate_playlist("beginner", "medium", "short")
    #assert playlist == [check playlist falls into range corresponding to given parameters]

def test_generate_playlist1():
    playlist = generate_playlist.generate_playlist("b", "b", "b")
    assert playlist == None

def test_generate_playlist1():
    playlist = generate_playlist.generate_playlist("", "", "")
    assert playlist == None

#def test_generate_playlist5():
    #playlist = generate_playlist.generate_playlist("beginner", "medium", "high")
    #assert 1 == 1
