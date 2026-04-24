import sqlite3
import os

db_path = r'c:\Users\Izaan\.gemini\antigravity\scratch\TajwidCoach\assets\databases\quran.db'

if not os.path.exists(db_path):
    print(f"Error: Database not found at {db_path}")
    exit(1)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

try:
    cursor.execute("SELECT COUNT(*) FROM ayats")
    count = cursor.fetchone()[0]
    print(f"TOTAL_AYATS_COUNT: {count}")
except Exception as e:
    print(f"Error: {e}")

conn.close()
