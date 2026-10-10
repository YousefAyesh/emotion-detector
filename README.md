# Emotion Detector

An AI-based web application that detects emotions (anger, disgust, fear, joy, sadness)
in customer feedback text using the Watson NLP EmotionPredict service, deployed with Flask.

## Structure

- `EmotionDetection/` – package exposing `emotion_detector(text_to_analyze)`
- `server.py` – Flask web app (`/` and `/emotionDetector`)
- `test_emotion_detection.py` – unit tests
- `templates/`, `static/` – web interface

## Run

```bash
pip install requests flask
python3 server.py
```

Then open http://localhost:5000.
