import sqlite3
import cloudscraper, requests
import urllib.parse
from ratelimit import limits, sleep_and_retry, RateLimitException
from difflib import SequenceMatcher
from dotenv import load_dotenv
import os

load_dotenv()

API_KEY = os.environ.get('BPM_API_KEY')

OK_STATUS = 200
TOO_MANY_REQUESTS = 429
CLOUDFLARE_BLOCK = 403

MINUTE = 60
HOUR = 3600

class TuneBatError(Exception):
    def __init__(self, message, file=None, title=None, artist=None, score=None):
        super().__init__(message)
        self.name = "TuneBatError"
        self.file = file
        self.title = title
        self.artist = artist
        self.score = score

class SongDatabase:
    
    def __init__(self, db_name="analyzed_songs.db"):
        """
        Initialize the database connection and create the table if it doesn't exist.
        """
        self.db_name = db_name
        self._create_table()

    def _create_table(self):
        """
        Create the songs table 
        
        Column:
            ArtistName: Musical Artist's Name
            TrackName: Song/Track Name
            BPM: Beats Per Minute of the Song
        """
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS songs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ArtistName TEXT,
                TrackName TEXT UNIQUE,
                BPM INTEGER
            )
        """)
        conn.commit()
        conn.close()

    def save_song(self, artistName, trackName, BPM):
        """
        Save a song's data to the database.
        Parameters:
            artistName (string): Artist's Name
            trackName (string): Track's Name
            BPM (integer): Beats Per Minute
        """
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO songs (ArtistName, TrackName, BPM)
            VALUES (?, ?, ?)
        """, (artistName, trackName, BPM))
        conn.commit()
        conn.close()

    def fetch_all_songs(self):
        """
        Fetch all songs from the database.
        """
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM songs")
        rows = cursor.fetchall()
        conn.close()
        return rows

    def fetch_song(self, artistName, trackName):
        """
        Fetch a specific song by artist and track name.
        Args:
            artistName (string): Artist's Name
            trackName (string): Track's Name
        """
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        cursor.execute("""
            SELECT * FROM songs WHERE artistName = ? AND trackName = ?
        """, (artistName, trackName))
        row = cursor.fetchone()
        conn.close()
        return row

class BPMAnalysis:
    
    def __init__(self, database):
        self.database = database

    def findExistingSong(self, artist_name, track_name):
        # Check if the song is in the database:
        existing_song = self.database.fetch_song(artist_name, track_name)
        
        if existing_song:
            return existing_song[3]
        return None
    
    def getBPM(self, artist_name, track_name):
        first_run = self.getBPMfromSongBPM(artist_name, track_name)
        if first_run:
            return first_run
        else:
            return self.getBPMFromTuneBat(artist_name,track_name)
    
    @sleep_and_retry
    @limits(calls=15, period=MINUTE)
    def searchTuneBat(self, artist_name, track_name):
        """
        Makes a search request to the Tunebat API with rate limiting handling
        
        Args:
            artist_name (string): The artist's name
            track_name (string): The song's name
            
        Returns:
            json: a list of searched tracks or raise an error
        """
        
        # Search Term concatenates the artist and track
        search_term = f"{artist_name} {track_name}"
        
        # URL-encode the search term
        encoded_term = urllib.parse.quote_plus(search_term)
        
        # Construct the API URL
        url = f"https://api.tunebat.com/api/tracks/search?term={encoded_term}"
        
        # Create a Cloudscraper instance
        scraper = cloudscraper.create_scraper()

        # Make a GET Request
        response = scraper.get(url)
        
        # Check if the response code is OK!
        if response.status_code != OK_STATUS:
            if response.status_code == CLOUDFLARE_BLOCK:
                raise Exception('Cloudflare is blocking you from making more requests!')
            raise Exception('API Response {}'.format(response.status_code))

        return response.json()

    @limits(calls=3000, period=HOUR)
    def searchGetSongBPM(self, artist_name, track_name):
        """
        Makes a search request to the GetSongBPM.com API with rate limiting handling
        
        Args:
            artist_name (string): The artist's name
            track_name (string): The song's name
            
        Returns:
            json: a list of searched tracks or raise an error
        """
        lookup = f"song:{track_name} artist:{artist_name}"
        
        url = "https://api.getsong.co/search/"
        
        params = {
            "api_key": API_KEY,
            "type": "both",
            "lookup": lookup
        }
        
        response = requests.get(url, params=params)
        
        if response.status_code != OK_STATUS:
            raise Exception('API Response {}'.format(response.status_code))
        return response.json()
        
    def getBPMfromSongBPM(self, artist_name, track_name):
        """
        Gets the BPM given an artist name and a song name, then
        returns the BPM from the GetSongBPM API with error handling
        
        Args:
            artist_name (string): The artist's name
            track_name (string): The song's name
        Returns:
            int: BPM
        """
        # Check if the song is in the database:
        existing_bpm = self.findExistingSong(artist_name, track_name)
        
        if existing_bpm:
            return existing_bpm
        try:
            data = self.searchGetSongBPM(artist_name, track_name)
            search_results = data.get("search")
            # Check if the results are in a list format
            if isinstance(search_results, list) and search_results: 
                song = search_results[0]
                bpm = song.get("tempo", "Unknown")
                return bpm
            # Else, no results were found inside the results
            elif search_results:  
                return None
            else:
                raise KeyError("Unexpected response format or error in search response.")
        except requests.exceptions.RequestException as e:
            print(f"Error: {e}")
        except (ValueError, KeyError) as ve:
            print(f"Error: {ve}")
        
    def getBPMFromTuneBat(self, artist_name, track_name):
        """
        Gets the BPM given an artist name and a song name, then
        returns the BPM from the TuneBat API with error handling
        
        Args:
            artist_name (string): The artist's name
            track_name (string): The song's name
        Returns:
            int: BPM
        """
        # Check if the song is in the database:
        existing_bpm = self.findExistingSong(artist_name, track_name)
        
        if existing_bpm:
            return existing_bpm
        
        try:
            # Get tracks using our enhanced search function
            data = self.searchTuneBat(artist_name, track_name)
            tracks = data['data']['items']
        # The tracks data should look something like this:
            # {
                # id: "Spotify ID" (URI)
                # n: "Track Title"
                # as: ["Artists"]
                # l: ---
                # an: "Album"
                # rd: “Release Date” (YYYY-DD-MM)
                # is: isSingle (not entirely sure)
                # ie: isExplicit
                # d: "Milliseconds"
                # p: “Popularity” Higher means more popular
                # k: "Key Signature"
                # kv: Pitch Class Integer Value
                # c: "Camelot Key"
                # b: "BPM"
            # The below percents have a range of zero to one  inclusive (0 - 1)
                # ac: "Acousticness percent"
                # da: "Danceability percent"
                # e: "Energy percent"
                # h: "Happiness percent"
                # i: "Instrumentalness percent" 
                # li: "Liveness percent"
                # lo: "Loudness dB"
                # s: "Speechiness percent" (>= 66 means track is in mostly spoken words, 33 to 66 means both music and speech, < 33 means mostly music with no spoken worlds)
                # ci: [{album covers}]
                # cr: ---
                # r: [---]
                # er: [---]
            # }
        
            
            if not tracks:
                return None
                
            # Track similarity scoring 
            best_match = {"track": None, "score": 0}
            
            for track in tracks:
                track_uri = track.get('id')
                bpm = round(track.get('b', 0))
                
                # Track Name and Artist Name(s) from Tunebat API
                track_name_tb = track.get('n', '').lower()
                artist_names_tb = [artist.lower() for artist in track.get('as', [])]
                
                # Check for direct match
                is_same_song = (track_name_tb == track_name.lower() and artist_name.lower() in artist_names_tb)
                
                if is_same_song:
                    # Save direct match
                    if bpm is not None:
                        self.database.save_song(artist_name, track_name, bpm)
                        return bpm
                
                # Calculate similarity score for fuzzy matching
                if artist_name.lower() in artist_names_tb or not artist_name:
                    score = SequenceMatcher(None, track_name_tb, track_name.lower()).ratio()
                    if score > best_match["score"]:
                        best_match = {"track": track, "score": score}
            
            # If we have a good fuzzy match above threshold
            threshold = 0.8 
            if best_match["score"] >= threshold and best_match["track"]:
                track = best_match["track"]
                bpm = round(track.get('b', 0))
                
                if bpm is not None:
                    self.database.save_song(artist_name, track_name, bpm)
                    return bpm
            
            # No good match found
            return 1
            
        except RateLimitException as e:
            raise TuneBatError(e)

if __name__ == "__main__":
    songs = SongDatabase()
    analysis = BPMAnalysis(songs)
    artist_list = ["Lady Gaga"] * 16
    track_list = ["Disease", "Abracadabra", "Garden of Eden", "Perfect Celebrity", "Vanish Into You",
                   "Killah (feat. Gesaffelstein)", "Zombieboy", "LoveDrug", "How Bad Do U Want Me", "Don't Call Tonight", 
                   "Shadow of a Man", "The Beast", "Blade of Grass", "Die With A Smile", "LoveGame", "Applause"]
    song_URI = "7DX4dnqhCQpykHwzLrmA6O"
    is_spotify = False
    
    
    for artist, track in zip(artist_list, track_list):
        bpm = analysis.getBPM(artist, track)
        print(f"{track} by {artist} has a BPM of {bpm}")

    for row in songs.fetch_all_songs():
        print(row)
