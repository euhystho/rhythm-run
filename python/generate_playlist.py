import sqlite3
import random

def create_sample_db():
    """
    Creates a sample database.
    -------------------------
    FOR TESTING PURPOSES ONLY.
    """
    conn = sqlite3.connect('songs.db')
    c = conn.cursor()

    c.execute("DROP TABLE IF EXISTS songs")
    c.execute("""CREATE TABLE IF NOT EXISTS songs (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT,
                    bpm INTEGER,
                    length REAL)""")

    # name, bpm, length (minutes)
    sample_songs = [
        ("Fast 1", 178, 3.5),
        ("Fast 2", 175, 4.0),
        ("Fast 3", 190, 3.4),
        ("Fast 4", 183, 2.0),
        ("Medium 1", 165, 3.2),
        ("Medium 2", 160, 4.0),
        ("Medium 3", 150, 3.0),
        ("Medium 4", 170, 4.0),
        ("Slow 1", 145, 3.8),
        ("Slow 2", 135, 4.1),
        ("Slow 3", 125, 5.0),
        ("Slow 4", 130, 4.5),
    ]

    for song in sample_songs:
        c.execute("INSERT INTO songs (name, bpm, length) VALUES (?, ?, ?)", song)

    # c.execute("SELECT * FROM songs")
    # print(c.fetchall())
    conn.commit()
    conn.close()

def generate_playlist(xp_lvl, intensity, duration):
    """
    Generates a playlist based on user choices described below.
    
    Parameters
    ----------
    xp_level: string
        experience level (affects BPM), "beginner", "intermediate", or "advanced"
    intensity: string
        intensity level (affects BPM), "low", "medium", or "high"
    duration: string
        length of workout, "short", "medium", or "long"
    """
    conn = sqlite3.connect('songs.db')
    c = conn.cursor()

    # Subranges within each intensity, based on experience level
    ranges = {
        'beginner': {
            'low': (120, 130),
            'medium': (150, 157),
            'high': (170, 177)
        },
        'intermediate': {
            'low': (130, 140),
            'medium': (157, 163),
            'high': (177, 183)
        },
        'advanced': {
            'low': (140, 150),
            'medium': (163, 170),
            'high': (183, 190)
        }
    }

    duration_ranges = {
        'short': (10, 15),
        'medium': (15, 20),
        'long': (20, 25)
    }

    # validate inputs
    if xp_lvl not in ranges or intensity not in ranges[xp_lvl] or duration not in duration_ranges:
        return None

    seen_ids = set()
    step = 2
    total_time = 0.0
    playlist = []

    min_bpm, max_bpm = ranges[xp_lvl][intensity]
    min_dur, max_dur = duration_ranges[duration]

    while total_time < min_dur:
        c.execute("SELECT id, name, bpm, length FROM songs WHERE bpm BETWEEN ? AND ?", (min_bpm, max_bpm))
        matches = [song for song in c.fetchall() if song[0] not in seen_ids]
        random.shuffle(matches) # just so it's not in the order the user uploads in

        for song in matches:
            if total_time + song[3] <= max_dur:
                playlist.append(song)
                total_time += song[3]
                seen_ids.add(song[0])
            if total_time >= min_dur:
                break

        min_bpm -= step
        max_bpm += step

        # stop expanding bpm range if outside of reasonable bpms
        if min_bpm < 60 and max_bpm > 220:
            break

    conn.close()
    return playlist

if __name__ == "__main__":
    create_sample_db()
    playlist = generate_playlist("intermediate", "low", "medium") # exp, intensity, duration
    # playlist = generate_playlist("b", "b", "b")

    if playlist:
        for song in playlist:
            print(f"{song[1]} ({song[2]} BPM, {song[3]} min)")