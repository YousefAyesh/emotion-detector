# Emotion Detector: Final Project

You are a software engineer building an AI-based web application that detects emotions in text using the Watson NLP library (via a REST endpoint). Complete all 8 tasks below in order. Work autonomously, but follow the rules in "Ground rules" exactly.

## Ground rules

1. **Never fabricate output.** Every terminal output saved as evidence must come from a command you actually ran. If something fails, show the real error and fix it.
2. **If the Watson endpoint is unreachable** (connection error, DNS failure, timeout), STOP and tell me. The endpoint usually only works inside the IBM Skills Network lab environment. Do not mock the API to make tests pass unless I explicitly say so.
3. **Do not run `git push` or create remote repos without asking me first.** Local commits are fine.
4. **Do not delete files** outside this project folder.
5. Use `python3.11` if available, otherwise `python3`. Install dependencies with `pip install` as needed (`requests`, `flask`, `pylint`).
6. Save all terminal evidence as plain text in `evidence/` (create it) using `tee`, e.g. `python3 test_emotion_detection.py 2>&1 | tee evidence/task5_tests.txt`.
7. When done with each task, print a one-line status and move on. At the end, print a checklist of what is complete and what I still need to do myself.

## Project structure (final)

```
.
├── CLAUDE.md
├── README.md                  # contains the project name "Emotion Detector"
├── EmotionDetection/
│   ├── __init__.py
│   └── emotion_detection.py
├── templates/
│   └── index.html             # only if not already provided
├── static/                    # only if already provided
├── server.py
├── test_emotion_detection.py
└── evidence/                  # terminal outputs for submission
```

If the project was cloned from the course repo, keep whatever starter files (templates, static, README) already exist and build on them.

## Task 1: Clone the repository

- If this folder is empty or has no git repo, run:
  `git clone https://github.com/ibm-developer-skills-network/oaqjp-final-project-emotion-detector.git`
  and work from inside the cloned folder (or move its contents here).
- Make sure `README.md` exists and includes the project name "Emotion Detector".
- Run `ls -R > evidence/task1_folder_structure.txt` (excluding `.git`) as proof of structure.
- Remind me at the end to push to my own PUBLIC GitHub repo (I will provide the URL).

## Task 2: Create the emotion detection application

Create `emotion_detection.py` with a function `emotion_detector(text_to_analyze)` that POSTs to the Watson NLP EmotionPredict endpoint.

- URL: `https://sn-watson-emotion.labs.skills.network/v1/watson.runtime.nlp.v1/NlpService/EmotionPredict`
- Header: `{"grpc-metadata-mm-model-id": "emotion_aggregated-workflow_lang_en_stock"}`
- Payload: `{"raw_document": {"text": text_to_analyze}}`
- Initially return `response.text`.

Verify by importing and calling it with `"I love this new technology"`. Save the output to `evidence/task2_import_test.txt`.

## Task 3: Format the output

Modify `emotion_detector` so it:
- Parses the JSON response.
- Extracts `emotionPredictions[0]['emotion']` (anger, disgust, fear, joy, sadness).
- Adds a `dominant_emotion` key holding the emotion name with the highest score.
- Returns a dictionary in this format:
  `{'anger': x, 'disgust': x, 'fear': x, 'joy': x, 'sadness': x, 'dominant_emotion': 'joy'}`

Test with `"I love this new technology"` and save the output to `evidence/task3_format_test.txt`.

## Task 4: Package the application

- Create the `EmotionDetection/` folder and move `emotion_detection.py` into it.
- Create `EmotionDetection/__init__.py` containing:
  `from .emotion_detection import emotion_detector`
- Validate with: `from EmotionDetection import emotion_detector; print(emotion_detector("I am so happy I am doing this."))`
- Save the output to `evidence/task4_package_test.txt`.

## Task 5: Unit tests

Create `test_emotion_detection.py` in the project root using `unittest`. Test `emotion_detector` from `EmotionDetection.emotion_detection` for these statements and expected dominant emotions:

| Statement | Expected |
|---|---|
| I am glad this happened | joy |
| I am really mad about this | anger |
| I feel disgusted just hearing about this | disgust |
| I am so sad about this | sadness |
| I am really afraid that this will happen | fear |

Run `python3 test_emotion_detection.py 2>&1 | tee evidence/task5_tests.txt`. All tests must pass. If one fails because of the model's real output, report it to me rather than editing the expected value silently.

## Task 6: Web deployment with Flask

Create or update `server.py`:
- Flask app named `"Emotion Detector"`.
- Route `/emotionDetector` reads `textToAnalyze` from `request.args`, calls `emotion_detector`, and returns:
  `For the given statement, the system response is 'anger': X, 'disgust': X, 'fear': X, 'joy': X and 'sadness': X. The dominant emotion is <dominant_emotion>.`
- Route `/` renders `index.html`.
- Run on `host="0.0.0.0"`, `port=5000`.

Start the server in the background, confirm it responds with
`curl "http://localhost:5000/emotionDetector?textToAnalyze=I%20love%20this%20new%20technology"`
and save that output to `evidence/task6_curl.txt`. Then stop the server.

**I must take the screenshot `6b_deployment_test.png` myself.** Tell me how to run the server so I can capture it.

## Task 7: Error handling

- In `emotion_detector`: if `response.status_code == 400`, return a dict with all five emotions and `dominant_emotion` set to `None`.
- In `server.py`: if `dominant_emotion` is `None`, return `"Invalid text! Please try again!"`.
- Test a blank input:
  `curl "http://localhost:5000/emotionDetector?textToAnalyze="`
  and save the output to `evidence/task7_blank_input.txt`.

**I must take `7c_error_handling_interface.png` myself.** Tell me the steps (submit a blank input in the web interface).

## Task 8: Static code analysis

- Run `pylint server.py 2>&1 | tee evidence/task8_pylint.txt`.
- Fix every message until the score is `10.00/10`: add a module docstring, docstrings on every function, remove unused imports/variables, keep lines at 100 characters or fewer, and use correct naming.
- Re-run until the saved output shows `rated at 10.00/10`.
- Also run pylint on `EmotionDetection/emotion_detection.py` and `test_emotion_detection.py` and fix reasonable issues, but the required score is for `server.py`.

## Final checklist (print this when finished)

Print a table of every rubric activity with status Done / Needs me:

- T1: README.md in public repo (needs my push + URL)
- T2: emotion_detection.py code + import test output
- T3: formatted-output code + output
- T4: `__init__.py` (needs push + URL) + package validation output
- T5: test_emotion_detection.py + passing test output
- T6: server.py + `6b_deployment_test.png` (mine)
- T7: updated emotion_detection.py (400 handling) + server.py blank-input handling + `7c_error_handling_interface.png` (mine)
- T8: server.py + pylint 10/10 output

Finally, list which `evidence/*.txt` file maps to which submission box.
