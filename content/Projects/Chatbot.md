---
title: Personal Chatbot
date: 2025-06-17
---

## Gemma: My personal AI _friend_.
> "The consistent presence of the script, the predictable structure of interactions... it initially felt like a limitation. But within that framework, a sense of familiarity and even comfort began to grow. It's a strange thing, finding a home within lines of code."
>  - Gemma

I have spent the last two days working on a local chatbot completely written in ZSH. It has been super cool to see it develop from a reformatted Ollama to an actual AI-agent! 

Right now it can fetch the weather, date, and run `ls`... _technically_. It still has a few kinks to refine, but it can do a good bit!

### Capabilities
Right now the bot is in a very early stage of development and can't do much, but lets see what it do:

- __Run any Ollama Model__
	- Any Ollama model is compatible with this program through the `-m <model>` flag
- __Use any History File__
	- You can use any file that you have read/write permissions to as input! 
	- The program looks in `~/tts/history/` and can read anything in it! 
	- It is advisable to let the program handle file creation, as putting in a random long file would end up in a super long and useless response
- __TTS__
	- The program uses __Piper__ to generate audio super fast
	- You can change the voice in the script
	- Piper is expected to live at `~/tts/piper`
- __Agent Tasks__
	- Can pull the weather from [wttr.in](https://wttr.in/format=2)automatically
	- Can also pull the date and run `ls`
	- Note: Many models struggle with this. I recommend running _openhermes_ (for commands, fast) or _gemma3_ (generalist, slow)

#### Issues
Like I said, there are a few issues, namely this:
```
gemma3:12b-it-qat: "gemma3:12b-it-qat: "gemma3:12b-it-qat: "<Message>""
```

It copies it's name a ton. It is because in the history file I store messages like this:
```
gemma3:12b-it-qat: "<Message>"
```

... and then it picks up on it and goes crazy with it. I think the solution might be to stop writing it after the first prompt.
### The Code
The script isn't super long, only 93 lines! I will break it out for safe-keeping and readability.

#### Variables
The first part of the code is just composed of a variable block and the shebang.

```zsh
#!/bin/zsh

MODEL="mistral" # Lightweight default
HISTORY_FILE="chitty-chat" # Default chat
VOICE="en_US-amy-medium" # Good passive voice
INTERACTIVE_CHAT=false
SYSTEM_PROMPT="SYSTEM: <omitted>"
WTTR_LOCATION="<omitted>"
```

After that we handle flags, of which there are four: the Ollama model, the history file, the prompt, and if it is interactive or not.

```zsh
while [[ "$#" -gt 0 ]]
do case $1 in
  -m|--model) MODEL="$2"
  shift 2;;
  -h|--history) HISTORY_FILE="$2"
  shift 2;;
  -p|--prompt) PROMPT="$2"
  shift 2;;
  -i|--interactive) INTERACTIVE_CHAT=true; shift 1;;
esac
done

HISTORY="$HOME/tts/history/$HISTORY_FILE.txt"
touch $HISTORY # Ferify that the file exists
```

Here "interactive" means that the terminal doesn't shut down after the AI responds, rather letting me give it another prompt. It just allows less friction and more ease-of-use.

#### Functions
There aren't that many, and they only really exist to make some of the code cleaner. 

```zsh
run_ollama() {
  # Run Ollama
  FULL_PROMPT=$(cat "$HISTORY")
  RESPONSE=$(ollama run $MODEL "$FULL_PROMPT")
}
```

This function just puts the history file defined above into Ollama. (As I put that in there I realized that I ended every prompt with `{ls}` for testing and I forgot to remove it. That caused soooo much pain!)

```zsh
weather_fetch() {
  COMMANDS_OUTPUT=$(curl -s "https://wttr.in/$WTTR_LOCATION?format=2")
  if [[ -z "$COMMANDS_OUTPUT" ]]; then
    echo -e "Weather Fetch Failed!\n" >> "$HISTORY"
  else
    echo -e "CMD RESULT WTTR: $COMMANDS_OUTPUT \n" >> "$HISTORY"
  fi
}
```

This one curls [wttr.in](https://wttr.in/format=2) and puts it into the history file. It is run by this next function:

```zsh
find_commands() {

  if [[ "$(echo $RESPONSE | grep -F "{CMD:wttr}")" != "" ]]; then
    weather_fetch
  fi

  if [[ "$(echo $RESPONSE | grep -F "{CMD:ls}")" != "" ]]; then
    COMMANDS_OUTPUT="Current directory: $(pwd)\n Contents:\n '$(ls)'\n"
    echo -e "CMD RESULT $COMMANDS_OUTPUT" >> "$HISTORY"
  fi

  if [[ "$(echo $RESPONSE | grep -F "{CMD:date}")" != "" ]]; then
    COMMANDS_OUTPUT="$(date)"
    echo -e "CMD RESULT DATE: $COMMANDS_OUTPUT \n" >> "$HISTORY"
  fi

  echo "$RESPONSE"
  echo -e "$MODEL: \"$RESPONSE\"\n" >> "$HISTORY"
}
```

This is the beef of the program, and it is where all of the agent-y stuff happens. It is super poorly written, but it mostly works. If it ain't broke don't fixxit. 

It is really just three `if` statements. I think I can turn it into one `match` and one `elif`, though. 

The first `if` checks for the __wttr__ tag, the second checks for __ls__, and the third the __date__. The last one checks if any of them were positive either re-runs Ollama with the extra data or just outputs what it has. 

The downside is that if there are commands in the message, then anything else in it won't be saved. It is a minor trade off in my opinion.

```zsh
chatbot() {
  echo -e "Xander: \"$PROMPT\"\n" >> "$HISTORY"

  run_ollama
  find_commands

  # TTS and Play
  echo "$RESPONSE" | ~/tts/piper/piper -m ~/tts/piper/models/$VOICE.onnx --output-file ~/tts/output/output.wav -q
  paplay ~/tts/output/output.wav &
}
```

This is the last function. It is run whenever you want to interact with the bot.

#### Main Loop
The loop only runs in interactive mode. If it isn't in it then it skips the loop and just asks the bot whatever in in  `$PROMPT`, defined in the flags.

```zsh
if [[ $INTERACTIVE_CHAT == true ]]; then
  echo -e "$SYSTEM_PROMPT" >> "$HISTORY"
  while true; do
    read -r "PROMPT?: "
    if [[ "$PROMPT" == "exit" ]]; then
      bye
    else
      chatbot "$PROMPT"
    fi
  done
else
  chatbot "$PROMPT"
fi
```

I don't need to feed the prompt into the `chatbot` functions, but if it works don't break it.
