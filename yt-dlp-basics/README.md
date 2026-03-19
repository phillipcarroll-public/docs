# yt-dlp Basic Usage

I have a general use venv I place any tools into, we need to activate that environment:

```bash
source ~/venv/cpu/bin/activate.fish
```

Important tags:

- `-P "~/Videos"` set your download folder
- `-o "%(channel)s/%(playlist)s/%(title)s.%(ext)s"`
    - Sets Channel/Playlist/Title/Extension folders
    - `%(autonumber)03d` Creates an auto incrementing number starting at 001
    - `%(upload_date)s` adds the upload data to the filename
- `-o "%(channel)s - %(title)s.%(ext)s"`
- `-r 1M` set the rate limiter for downloads in K or M per second
- `-x` download audio only
    - `-x --audio-format mp3` set the format of the audio
- `-w` skip if the downloaded file/format exists
- `-q` set to quiet mode to reduce chatty output
- `--no-warnings` this will remove any non-critical errors from output
- `-S "res:1080,fps:60"` to set a maximum allowed resolution and framerate for video downloads
    - If a video only has 480p30fps it will grab this max available quality version
    - If a video has 2160p120fps it will grab only up to the set 1080p60fps limit
- Set your video output
    - `--remux-video mkv` for MKV
    - `--remux-video mp4` for MP4 which is more compatible for older devices


Grab Audio/Music Singleton

This will grab a song, give it the title, download only the audio, set MP3 format, rate limit to 3Mbyte/sec download and put it in ~/Music. This will also skip if the file exists. If successful no output in cli will be generated.

```bash
yt-dlp -q --no-warnings -w -P "~/Music" -o "%(title)s.%(ext)s" -r 3M -x --audio-format mp3 "https://www.youtube.com/watch?v=yUi_S6YWjZw"
```

Grab Playlist of Audio

Same as above but we will want to create a folder with the channel and playlist name.

```bash
yt-dlp -q --no-warnings -w -P "~/Music" -o "%(channel)s/%(playlist)s/%(title)s.%(ext)s" -r 3M -x --audio-format mp3 "https://www.youtube.com/playlist?list=PLdBdsUAZaik8Fp5IkIlDmIc2TEYxvrJB0"
```

Grab Video Singleton

This will be very similar to the audio example except we will omit `-x --audio-format mp3` and add the tag for downloading a specific max res/framerate. You can set the video out to several types.

```bash
yt-dlp -q --no-warnings -w -P "~/Videos" -o "%(channel)s/%(title)s.%(ext)s" -r 3M -S "res:1080,fps:60" --remux-video mkv https://www.youtube.com/watch?v=LHoJV-Nat40
```

Grab Playlist of Videos

This is the same as a Video Singleton except we will slide a playlist foldername in the -o tag

```bash
yt-dlp -q --no-warnings -w -P "~/Videos" -o "%(channel)s/%(playlist)s/%(title)s.%(ext)s" -r 3M -S "res:1080,fps:60" --remux-video mkv https://www.youtube.com/playlist?list=PL97nvoRkKCvnMFOpWKah4rm91ASUSTNOU
```

Download an Entire Channel's Videos

We just use the channel ID to download all the videos. However we will want to add the upload date to the name of the video depending on the channel. Otherwise it is just a dump and if you planed on watching chronologically it maybe difficult. I am also adding an auto incremember number at the beginning of the files.

You will end up with a video filename of: `001-20251220-vim tricks I'm almost certain you don't know yet.mkv`

**NOTE:** This will not download the live streams, only the uploaded videos.

```bash
yt-dlp -q --no-warnings -w -P "/mnt/stor/YT-DLP/Video/" -o "%(channel)s/%(autonumber)03d-%(upload_date)s-%(title)s.%(ext)s" -r 3M -S "res:1080,fps:60" --remux-video mkv https://www.youtube.com/@BreadOnPenguins
```

```bash
yt-dlp -q --no-warnings -w -P "/mnt/stor/YT-DLP/Video/" -o "%(channel)s/%(autonumber)03d-%(upload_date)s-%(title)s.%(ext)s" -r 3M -S "res:1080,fps:60" --remux-video mkv https://www.youtube.com/@CyberGizmo
```

