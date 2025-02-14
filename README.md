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


## Sprint 2 Updates  

### Prompt Engineering Improvements  
In **Sprint 2**, we focused on refining **prompt engineering** to enhance the voice assistant’s ability to handle **incomplete or unclear inputs** from pilots, particularly in **high-stress situations**. Key improvements include:  
- Better interpretation of **fragmented or disordered speech** to extract essential intent.  
- Enhanced robustness against **emergency-induced communication challenges**.  

### Bluetooth Connectivity & Noise Handling  
- Integrated **Bluetooth connectivity** for smoother real-time interactions.  
- Addressed prior **aircraft noise issues**, improving model response time in **high-noise environments**.  
- Optimized **speech recognition speed**, reducing the processing lag experienced in Sprint 1.  

### Next Steps  
- Further enhance **mixed-language processing** (e.g., English + aviation terminology).  
- Improve **stability in extreme noise conditions**.  
- Optimize **real-time decision-making support** for pilots.  


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
        <td>Refined the UI/UX for a more seamless user experience.<br>
Led mobile app updates and incorporated feedback from early testing.</td>
    </tr>
    <tr>
        <td>Xiaoyue Wang</td>
        <td>Enhanced LLM adaptability to process fragmented commands.<br>
Optimized the speech-to-text pipeline for faster response times in high-noise conditions.</td>
    </tr>
    <tr>
        <td>Yiguo Zheng</td>
        <td>Conducted user research to analyze real-world pilot communication challenges.<br>
Led VC applications and built pilot communities in Palo Alto.</td>
    </tr>
</table>



