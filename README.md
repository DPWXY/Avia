# Avia
## Project Idea

## LLM Experiments
To run our current LLM related models and experiments, go to `LLM_experiment` folder and run the set up code to install neccessary environment and paste your `your_openai_api_key` in the code to run the Openai api.
### Set up
```bash
conda create --name avia python=3.10
conda activate avia
pip install -r LLM_experiment/requirement.txt
```

If you cannot install tiktoken using conda, try this:
```bash
conda install conda-forge::tiktoken
```
If there is error on any other package installation, try:
```bash
python -m pip install package_name
```

### Website
The website for our project is in `Website` folder.

### App
The App for our project is in `App` folder.
