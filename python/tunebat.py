import sqlite3
import cloudscraper, urllib.parse
from difflib import SequenceMatcher
import time, sys

# HTML Responses:
OK_STATUS = 200
TOO_MANY_REQUESTS = 429
CLOUDFLARE_BLOCK = 403

class TuneBatError(Exception):
    def __init__(self, message, file=None, title=None, artist=None, score=None):
        super().__init__(message)
        self.name = "TuneBatError"
        self.file = file
        self.title = title
        self.artist = artist
        self.score = score

class SongDatabase:
    
    def __init__(self, db_name="songs.db"):
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
            EnergyLevel: Explained by Spotify's Audio Feature Documentation:
                Energy is a measure from 0.0 to 1.0 and represents a perceptual measure
                of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy.
                For example, death metal has high energy, while a Bach prelude scores low on the scale.
                Perceptual features contributing to this attribute include dynamic range,
                perceived loudness, timbre, onset rate, and general entropy.
        """
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS songs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ArtistName TEXT,
                TrackName TEXT UNIQUE,
                BPM INTEGER,
                EnergyLevel REAL
            )
        """)
        conn.commit()
        conn.close()

    def save_song(self, artistName, trackName, BPM, energy):
        """
        Save a song's data to the database.
        Parameters:
            artistName (string): Artist's Name
            trackName (string): Track's Name
            BPM (integer): Beats Per Minute
            energy (float): Defined by Spotify's Audio Features 
        """
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO songs (ArtistName, TrackName, BPM, EnergyLevel)
            VALUES (?, ?, ?, ?)
        """, (artistName, trackName, BPM, energy))
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

class TuneBatBPMAnalysis:
# These variables are if CloudFlare throttles you :)
    throttle_active = False
    throttle_end_time = 0
    
    def __init__(self, database):
        self.database = database

    def search(self, artist_name, track_name):
        """
        Makes a search request to the Tunebat API with rate limiting handling
        
        Args:
            artist_name (string): The artist's name
            track_name (string): The song's name
            
        Returns:
            list: The search results or None on error
        """
        
        # Search Term concatenates the artist and track
        search_term = f"{artist_name} {track_name}"
        
        # URL-encode the search term
        encoded_term = urllib.parse.quote_plus(search_term)
        
        # Construct the API URL
        url = f"https://api.tunebat.com/api/tracks/search?term={encoded_term}"
        
        # Wait if we're currently throttled (CHANGE TO SOMETHING TO COMMUNICATE WITH DART)
        if self.throttle_active:
            remaining = max(0, self.throttle_end_time - time.time())
            if remaining > 0:
                # Create visual countdown like in the JS version
                for i in range(int(remaining), 0, -1):
                    sys.stdout.write(f"\rThrottled. Waiting {i} seconds...  ")
                    sys.stdout.flush()
                    time.sleep(1)
                sys.stdout.write("\r" + " " * 40 + "\r")  # Clear the line
            self.throttle_active = False
        
        # Create a Cloudscraper instance
        scraper = cloudscraper.create_scraper()
        
        try:
            response = scraper.get(url)
            
            # Check for rate limiting (429)
            if response.status_code == TOO_MANY_REQUESTS:
                # Get retry-after header, or default to 60 seconds
                retry_after = int(response.headers.get('retry-after', 60)) + 5
                self.throttle_active = True
                self.throttle_end_time = time.time() + retry_after
                print(f"Rate limited. Will retry in {retry_after} seconds.")
                # Recursive call after waiting
                return self.search(artist_name, track_name)
                
            # Check for Cloudflare blocking (403)
            if response.status_code == CLOUDFLARE_BLOCK:
                print("Cloudflare has blocked API requests for now, need to wait a while...")
                return None
                
            # Check if the request succeeded
            if response.status_code != OK_STATUS:
                print(f"Error: API returned status code {response.status_code}")
                return None
                
            # Parse the JSON response
            data = response.json()
            
            return data['data']['items']
            
        except Exception as e:
            print(f"Error during search: {e}")
            return None

    def getBPM(self, artist_name, track_name, song_uri, is_spotify):
        """
        Gets the BPM given an artist name and a song name, then
        returns the BPM and energy level from the TuneBat API with enhanced error handling
        
        Args:
            artist_name (string): The artist's name
            track_name (string): The song's name
            song_uri (string): Spotify's proprietary song URI
            is_spotify (bool): True if Spotify URI is used, False otherwise
            
        Returns:
            tuple: (BPM, energy level), success flag
        """
        # Check if the song is in the database:
        existing_song = self.database.fetch_song(artist_name, track_name)
        
        if existing_song:
            return (existing_song[3],existing_song[4]), True
        
        try:
            # Get tracks using our enhanced search function
            tracks = self.search(artist_name, track_name)
            
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
                return None, False
                
            # Track similarity scoring 
            best_match = {"track": None, "score": 0}
            
            for track in tracks:
                track_uri = track.get('id')
                bpm = round(track.get('b', 0))
                nrg = track.get('e', 0)
                
                # Track Name and Artist Name(s) from Tunebat API
                track_name_tb = track.get('n', '').lower()
                artist_names_tb = [artist.lower() for artist in track.get('as', [])]
                
                # Check for direct match
                is_uri_match = (track_uri == song_uri and is_spotify)
                is_same_song = (track_name_tb == track_name.lower() and artist_name.lower() in artist_names_tb)
                
                if is_uri_match or is_same_song:
                    # Save direct match
                    if bpm is not None:
                        self.database.save_song(artist_name, track_name, bpm, nrg)
                        return (bpm, nrg), True
                
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
                nrg = track.get('e', 0)
                
                if bpm is not None:
                    self.database.save_song(artist_name, track_name, bpm, nrg)
                    return (bpm, nrg), True
            
            # No good match found
            return None, False
            
        except Exception as e:
            print(f"Error in getBPM: {e}")
            return None, False

if __name__ == "__main__":
    songs = SongDatabase()
    tunebat = TuneBatBPMAnalysis(songs)
    artist_list = ["Lady Gaga"] * 14
    mayhem_list = ["Disease", "Abracadabra", "Garden of Eden", "Perfect Celebrity", "Vanish Into You",
                   "Killah (feat. Gesaffelstein)", "Zombieboy", "LoveDrug", "How Bad Do U Want Me", "Don't Call Tonight", 
                   "Shadow of a Man", "The Beast", "Blade of Grass", "Die With A Smile"]
    song_URI = "7DX4dnqhCQpykHwzLrmA6O"
    is_spotify = False
    
    
    for artist, track in zip(artist_list, mayhem_list):
        bpm_nrg_tuple = tunebat.getBPM(artist, track, song_URI, is_spotify)
        print(f"{track} by {artist} has a (BPM, Energy Level) of {bpm_nrg_tuple[0]}")

    for row in songs.fetch_all_songs():
        print(row)

# Flask API, mongoDB?