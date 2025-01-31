# Avia
## Project Idea
Avia is an AI-powered voice assistant designed to revolutionize flight training.  
It provides:  
- Real-time voice-guided assistance.  
- Personalized learning tools.  
- Cost-effective training solutions.  

Our goal is to:  
- Make pilot training more efficient and accessible.  
- Help student pilots overcome challenges like multitasking under pressure.  
- Offer real-time guidance to enhance decision-making and safety.

  
## Team Contributions
Rana:

Designed and developed the UI/UX for the Avia mobile application, ensuring an intuitive and user-friendly interface.
Built the mobile app prototype and led initial testing to validate core functionalities.
Zoey:

Conducted market research to identify challenges in pilot training.
Defined the problem statement, proposed solutions, and validated features through user interviews.
Xiaoyue:

Developed advanced LLM models tailored to aviation-specific contexts.
Implemented speech-to-text and text-to-speech functionalities for real-time voice-guided assistance.



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

## Website
https://ranataki.github.io/avia.github.io/

## App
The App for our project is in `App` folder.

## Team Contribution
<table>
    <tr>
        <th>Name</th>
        <th>Contribution</th>
    </tr>
    <tr>
        <td colspan="2;">Sprint 1</td>
    </tr>
    <tr>
        <td>Rana Taki</td>
        <td>TODO</td>
    </tr>
    <tr>
        <td>Xiaoyue Wang</td>
        <td>Training Data preperation, LLM model implementaion<br>Openai gpt-4o-mini fintuning and chat completion<br>Openai Speech-to-text and text-to-speech experiments</td>
    </tr>
    <tr>
        <td>Yiguo Zheng</td>
        <td>TODO</td>
    </tr>
</table>



