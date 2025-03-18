# Avia LLM Feature Experiment
This part contains code for running LLM models, fine=tuning LLM models, and a simple speech to text to response to speech pipeline using OpenAi models. 

### Set up
To run the code, make sure you have packages installed. If not, please follow the environment set up:
Before install PyAudio, install portaudio, especially for M2 Mac users.
```bash
brew install portaudio
```
Then
```bash
cd LLM_experiment
conda create --name avia python=3.10
conda activate avia
pip install -r requirements.txt
```

If you cannot install tiktoken using conda, try this:
```bash
conda install conda-forge::tiktoken
```
If there is error on any other package installation, try:
```bash
python -m pip install package_name
```

### Fine_tuning_GPT4
The notebook `Fine_tuning_GPT4.ipynb` and `Fine_tuning_GPT4_for_feedback.ipynb` contains the code to prepare the training data following the OpenAi guidelines and fine-tune a model using the api. 
In order to run the code, you need to use your own OpenAi API Key and repalce all `your_openai_api_key` in the file.

### Speech to Speech pipeline generation
To talk to LLM and get vioce response, run
```bash
python chat_v1.py
```
It will automatically record sounds for 10s and continue process, to change this, look at the parameters at the top of the `chat_v1.py`.