import traceback
import cloudscraper, requests
import urllib.parse
from ratelimit import limits, sleep_and_retry, RateLimitException
from difflib import SequenceMatcher
from dotenv import load_dotenv
import sys
import json
import os

## NOTE: RECEIVE AND MAKE THE FUNCTION CALL
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


class BPMAnalysis:
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
                # track_uri = track.get('id')
                bpm = round(track.get('b', 0))
                
                # Track Name and Artist Name(s) from Tunebat API
                track_name_tb = track.get('n', '').lower()
                artist_names_tb = [artist.lower() for artist in track.get('as', [])]
                
                # Check for direct match
                is_same_song = (track_name_tb == track_name.lower() and artist_name.lower() in artist_names_tb)
                
                if is_same_song:
                    # Save direct match
                    if bpm is not None:
                        #self.database.save_song(artist_name, track_name, bpm)
                        # instead put the response and sent to dart file
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
                    #self.database.save_song(artist_name, track_name, bpm)
                    return bpm
            
            # No good match found
            return 1
            
        except RateLimitException as e:
            raise TuneBatError(e)

if __name__ == "__main__":
    odata = {
        "artists": [],
        "tracks": [],
        "bpms": []
    }
    
    try:
        # Read all input from stdin (important for large data)
        input_json = sys.stdin.read()
        
        # Parse input data
        idata = json.loads(input_json)
        artist_list = idata.get("artists", [])
        track_list = idata.get("tracks", [])
        
        # Validate input
        if len(artist_list) != len(track_list):
            raise ValueError("Artists and tracks lists must be of equal length")
            
        if not artist_list or not track_list:
            raise ValueError("Empty artists or tracks list provided")
        
        # Process data
        analysis = BPMAnalysis()
        for artist, track in zip(artist_list, track_list):
            bpm = analysis.getBPM(artist, track)
            #print(f"{track} by {artist} has a BPM of {bpm}", file=sys.stderr)
            odata["artists"].append(artist)
            odata["tracks"].append(track)
            odata["bpms"].append(bpm)
        out=json.dumps(odata,ensure_ascii=False)
        sys.stdout.write(out+"\n")
        sys.stdout.flush()
    except Exception as e:
        error_message={"error":str(e)}
        sys.stdout.write(json.dums(error_message)+"\n")
        sys.stdout.flush()
    finally:
        # Ensure output is properly flushed
        sys.stdout.close()
        
        
    

    
