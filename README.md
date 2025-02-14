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
[To access our website](https://zoeyyyzheng.github.io/getavia.github.io/team.html)

## App
The App for our project is in `App` folder. Clone this repository and open the code in App folders with Xcode to run the ios App. In order to use the LLM features, you need to replace the `api-key` with your own Openai keys.

## Team Contribution
<table>
    <tr>
        <th>Name</th>
        <th>Contribution</th>
    </tr>
    <tr>
        <td colspan="2;">Sprint 2</td>
    </tr>
    <tr>
        <td>Rana Taki</td>
        <td>Designed and developed the UI/UX for the Avia mobile application, ensuring an intuitive and user-friendly interface.<br>
Built the mobile app prototype and led initial testing to validate core functionalities.</td>
    </tr>
    <tr>
        <td>Xiaoyue Wang</td>
        <td>Developed advanced LLM models (with/without fine-tuning) tailored to aviation-specific contexts.<br>
Implemented speech-to-text and text-to-speech functionalities for real-time voice-guided assistance</td>
    </tr>
    <tr>
        <td>Yiguo Zheng</td>
        <td>Conducted market research to identify challenges in pilot training.<br>
Defined the problem statement, proposed solutions, and validated features through user interviews.</td>
    </tr>
</table>



