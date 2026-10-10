#!/usr/bin/env bash
# Run this INSIDE the IBM Skills Network lab terminal, from the project root.
# It produces the evidence files that need the Watson endpoint (tasks 2-7)
# and re-runs pylint (task 8). Every file is real output from this run.
set -u
cd "$(dirname "$0")"
mkdir -p evidence
python3 -m pip install -q requests flask pylint

STAGES="$(mktemp -d)"

# ---- Task 2: initial version, returns response.text ----
mkdir -p "$STAGES/t2"
cat > "$STAGES/t2/emotion_detection.py" <<'EOF'
import requests

def emotion_detector(text_to_analyze):
    url = 'https://sn-watson-emotion.labs.skills.network/v1/watson.runtime.nlp.v1/NlpService/EmotionPredict'
    header = {"grpc-metadata-mm-model-id": "emotion_aggregated-workflow_lang_en_stock"}
    myobj = {"raw_document": {"text": text_to_analyze}}
    response = requests.post(url, json=myobj, headers=header)
    return response.text
EOF
(cd "$STAGES/t2" && python3 -c "from emotion_detection import emotion_detector; print(emotion_detector('I love this new technology'))") \
  2>&1 | tee evidence/task2_import_test.txt

# ---- Task 3: formatted output (dict + dominant_emotion) ----
mkdir -p "$STAGES/t3"
cat > "$STAGES/t3/emotion_detection.py" <<'EOF'
import json
import requests

def emotion_detector(text_to_analyze):
    url = 'https://sn-watson-emotion.labs.skills.network/v1/watson.runtime.nlp.v1/NlpService/EmotionPredict'
    header = {"grpc-metadata-mm-model-id": "emotion_aggregated-workflow_lang_en_stock"}
    myobj = {"raw_document": {"text": text_to_analyze}}
    response = requests.post(url, json=myobj, headers=header)
    emotions = json.loads(response.text)['emotionPredictions'][0]['emotion']
    result = {k: emotions[k] for k in ('anger', 'disgust', 'fear', 'joy', 'sadness')}
    result['dominant_emotion'] = max(result, key=result.get)
    return result
EOF
(cd "$STAGES/t3" && python3 -c "from emotion_detection import emotion_detector; print(emotion_detector('I love this new technology'))") \
  2>&1 | tee evidence/task3_format_test.txt

# ---- Task 4: package validation (final package) ----
python3 -c 'from EmotionDetection import emotion_detector; print(emotion_detector("I am so happy I am doing this."))' \
  2>&1 | tee evidence/task4_package_test.txt

# ---- Task 5: unit tests ----
python3 test_emotion_detection.py 2>&1 | tee evidence/task5_tests.txt

# ---- Tasks 6 & 7: Flask server + curl ----
python3 server.py > "$STAGES/server.log" 2>&1 &
SERVER_PID=$!
for _ in $(seq 1 20); do curl -s -o /dev/null http://localhost:5000/ && break; sleep 0.5; done
curl -s "http://localhost:5000/emotionDetector?textToAnalyze=I%20love%20this%20new%20technology" \
  2>&1 | tee evidence/task6_curl.txt; echo
curl -s "http://localhost:5000/emotionDetector?textToAnalyze=" \
  2>&1 | tee evidence/task7_blank_input.txt; echo
kill "$SERVER_PID"

# ---- Task 8: static code analysis ----
python3 -m pylint server.py 2>&1 | tee evidence/task8_pylint.txt

# ---- Task 1: final folder structure ----
ls -R > evidence/task1_folder_structure.txt

rm -rf "$STAGES"
echo "Done. Evidence files:"; ls evidence
