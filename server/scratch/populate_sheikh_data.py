import firebase_admin
from firebase_admin import credentials, firestore
import uuid
import datetime
import random

# Initialize Firebase Admin
cred = credentials.Certificate('../serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

def populate_mock_data():
    # 1. Find a user who is a sheikh
    users = db.collection('users').where('isSheikh', '==', True).limit(1).get()
    if not users:
        print("No sheikh found in the database. Please complete the Scholar Onboarding first.")
        return
    
    sheikh = users[0].to_dict()
    sheikh_id = users[0].id
    print(f"Found sheikh: {sheikh.get('name')} ({sheikh_id})")

    # 2. Create 3 mock students
    mock_students = [
        {"name": "Ali Hassan", "email": "ali@example.com"},
        {"name": "Fatima Zahra", "email": "fatima@example.com"},
        {"name": "Omar Farooq", "email": "omar@example.com"}
    ]

    student_ids = []

    for s in mock_students:
        s_id = str(uuid.uuid4())
        student_ids.append(s_id)
        
        db.collection('users').document(s_id).set({
            'uid': s_id,
            'name': s['name'],
            'email': s['email'],
            'sheikhId': sheikh_id,
            'streakDays': random.randint(1, 14),
            'badges': ['First Practice'],
            'isSheikh': False,
            'createdAt': firestore.SERVER_TIMESTAMP
        })
        print(f"Created student: {s['name']} ({s_id})")

    # 3. Update the sheikh's document with these students
    db.collection('sheikhs').document(sheikh_id).update({
        'students': firestore.ArrayUnion(student_ids),
        'currentStudents': len(student_ids)
    })
    print("Updated sheikh's student list.")

    # 4. Create 5 mock pending recordings for these students
    surahs = ["Al-Fatiha", "Al-Baqarah", "Yasin", "Al-Mulk", "Ar-Rahman"]
    
    for i in range(5):
        student_id = random.choice(student_ids)
        rec_id = str(uuid.uuid4())
        surah = random.choice(surahs)
        
        db.collection('recordings').document(rec_id).set({
            'id': rec_id,
            'userId': student_id,
            'sheikhId': sheikh_id,
            'audioUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', # Placeholder audio
            'surahName': surah,
            'ayahReference': f"Ayah {random.randint(1, 10)}",
            'timestamp': datetime.datetime.now() - datetime.timedelta(hours=random.randint(1, 48)),
            'sheikhApproved': False,
            'sheikhFeedback': None,
            'durationSeconds': random.randint(30, 120),
            'mistakesCount': random.randint(0, 3)
        })
        print(f"Created pending recording for student {student_id} (Surah {surah})")

    print("Successfully populated mock data! You can now verify the Sheikh Dashboard in the app.")

if __name__ == "__main__":
    populate_mock_data()
