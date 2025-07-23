---
title: Command Line Utilities
draft: false
date: 2025-07-23
tags: 
 - digital
---
I have recently been playing around a bit in the CLI, trying to make it more useful for _me_. It is one of my favorite things about Linux: the ability to make a super efficient workflow. 

The best thing: you can do almost anything through scripting, which is easier and more powerful than Python.

## note.zsh
This is a simple ZSH script that simpily makes a .md file, designed for Obsidian, and adds some data.

```zsh
#!/bin/zsh

# Get File Name, Data, and Location
name="$(date +%Y-%m-%d\|%H:%M)"
data=""
template="<Frontmatter>"
output_dir="<Where ever you want the file to go>"

while [[ "$#" -gt 0 ]]
do case $1 in
  -n) name="$2"
      shift 2;;
  -da) name="$name|$2" # "Date Append"
       shift 2;;
  -o) output_dir="$2"
      shift 2;;
  *) data="$1"
     shift;;
esac
done

# Echo Name, Location, and Data
name="$name.md" # Adds ".md" to filename
echo "$output_dir/$name" 
echo "$data"

# Copy Template to Output Dir
cp "$template" "$output_dir/$name"
echo "$data" >> "$output_dir/$name"
```

It is super simple and can just speed things up. This might have taken 30 mins, and most of it was just figuring out what I want and how the hell `date` works.

## rofi-bot.zsh
This one is SUPER nice. It can play music super easily through `yt-dlp` and `mpv`.

```zsh
#!/bin/zsh

rofi_output=$(rofi -dmenu -theme ~/.config/rofi/minimal.rasi)
echo "$rofi_output"

if [[ "$rofi_output" == play* ]]; then
  query="${rofi_output#play }"
  echo "Song Name: \"$query\""

  mpv --no-video "$(yt-dlp -f bestaudio --default-search "ytsearch1" -g "$query OFFICIAL AUDIO")"
  echo "Have a Good Day :)"
else
  echo "Unrecognized Input: \"$rofi_output\""
  exit 1
fi
```

Rofi has to use a custom config. Get mine [here](minimal.rasi). Linked is the raw file :)

This one requires `mpv`, `rofi`, and `yt-dlp`. Be careful with yt-dlp, because it technically could do digital piracy. Don't do that. You wouldn't steal a font.