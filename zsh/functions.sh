# FUNCTIONS
# =========


# Create and cd to a directory in one go.
# Only takes one argument
mkcd() {
  if [ $# -eq 1 ] ; then
    mkdir -vp "$1" && cd "$1"
  else
    echo "'$@' is not a valid directory name"
  fi
}

# Get current Platform
get-platform() {
  case "$(uname -s)" in
    Darwin)
      echo 'apple'
      ;;

    Linux)
      echo 'linux'
      ;;

    CYGWIN*|MINGW32*|MSYS*)
      echo 'windows'
      ;;

    *)
      echo 'unknown'
      exit 1
      ;;
  esac
}

# prepend text from either stdn or clipboard to file
prepend() {
    local usage_text=$(cat << 'EOF'
Usage: echo 'text to prepend' | prepend filename

e.g.
echo "text to prepend" | prepend filename

e.g.
cat << EOL | prepend .ignored/foo.txt
This is a multi-line
string I want to prepend
to my test file.
EOL
EOF
)

    local input_content

    if [ -t 0 ]; then
        # Try to get clipboard content
        if command -v pbpaste &>/dev/null; then
            # macOS
            input_content=$(pbpaste)
        elif command -v xsel &>/dev/null; then
            # Linux with xsel
            input_content=$(xsel -b)
        elif command -v xclip &>/dev/null; then
            # Linux with xclip
            input_content=$(xclip -selection clipboard -o)
        else
            echo "Error: No input provided through stdin and no clipboard tool available"
            echo "$usage_text"
            return 1
        fi

        if [ -z "$input_content" ]; then
            echo 'Error: No input in stdin or clipboard'
            echo "$usage_text"
            return 1
        fi
    fi

    # Check if filename argument is provided
    if [ -z "$1" ]; then
        echo "Error: No target file specified"
        echo "$usage_text"
        return 1
    fi

    # Check if target file exists
    if [ ! -f "$1" ]; then
        echo "Error: File '$1' does not exist"
        return 1
    fi

    # Perform the prepend operation
    if [ -t 0 ]; then
        # Use clipboard content if stdin is empty
        echo "$input_content" | cat - "$1" > temp && mv temp "$1"
    else
        # Use stdin content
        cat - "$1" > temp && mv temp "$1"
    fi
}



# Pretty Print JSON Curl Responses
# Need to have jq installed
jcurl() {
  curl -s "$@" | jq .
}

# Pretty Print JSON from clipboard
jp() {
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed. Please install jq to use this script."
        return 1
    fi

    # Try clipboard on Mac
    if command -v pbpaste &> /dev/null; then
        json=$(pbpaste)
    # Try xsel on Linux
    elif command -v xsel &> /dev/null; then
        json=$(xsel -b)
    else
        echo "Error: No clipboard tool available"
        return 1
    fi

    # Check if we got any input
    if [ -z "$json" ]; then
        echo "Error: Empty clipboard"
        return 1
    fi

    # Try to format the JSON and color it
    if echo "$json" | jq '.' -C > /dev/null 2>&1; then
        echo "$json" | jq '.' -C
    else
        echo "Error: Invalid JSON in clipboard"
        return 1
    fi
}


# List all of current user's processes
myps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }


# Find CPU and Memory Hogs
cpuhogs() { ps wwaxr -o pid,stat,%cpu,time,command | head -10 ;}
memhogs() { ps wwaxm -o pid,stat,vsize,rss,time,command | head -10; }


# Search for matching files and directories in the current tree
search() {
  if [[ $# -eq 0 ]] ; then
    echo "no arguments provided"
    echo "usage: search string"
    echo ''
  else
    rg --files $RG_DEFAULT_ARGS | rg -i "$@"
  fi
}


# Search for text within files in current tree
search-in() {
  if [[ $# -eq 0 ]] ; then
    echo "no search expression provided"
    echo "usage: search-in 'some string'"
    echo ""
  else
    rg $RG_DEFAULT_ARGS -i "$@"
  fi
}


# Mass Search-and-Replace in current tree
# Need to have gnused installed on OSX
search-replace() {
  if [[ $# -eq 0 ]] ; then
    echo "no replace regex provided"
    echo "usage: search-replace 's/match_regex/replace_regex/g'"
    echo ''

  else
    if [[ "$(get-platform)" == "linux" ]]; then
      local sed="sed"
    elif [[ "$(get-platform)" == "apple" ]]; then
      local sed="gsed"
    fi

    if [[ "$1" =~ ^s/.+/.+/g$ ]] ; then
      rg --files $RG_DEFAULT_ARGS | xargs $sed -i "$1"
    else
      echo "provide a valid match and replace regex"
      echo "usage: search_replace 's/match_regex/replace_regex/g'"
      echo ''
    fi
  fi
}


# Move files to trash
# Need to have either trash-put or rmtrash installed on the system
del() {
  if hash trash-put 2>/dev/null; then
    trash-put "$@"
  elif hash rmtrash 2>/dev/null; then
    rmtrash "$@"
  else
    echo "Did not find 'trash-cli' or 'rmtrash'"
    return 1
  fi
}


# Search processes
psx() {
  ps aux | grep -i "$@" | grep -v grep
}


# Kill all processes that match string
psxkill() {
  psx "$@" | awk '{ print $2 }' | xargs kill
}


# Do cool stuff with the edit command
edit() {
    if [[ $# -eq 0 ]] ; then
        eval "$EDITOR ."
    else
        eval "$EDITOR $1"
    fi
}

# Use $ as a function
function $ {
  eval "$@"
}


# dotenv local implmentation
dotenv() {
  bash -c "
  path=\$(pwd)
  while [[ \"\$path\" != \"\" && ! -e \"\$path/.env\" ]]; do
    path=\${path%/*}
  done


  if [[ -e \"\$path/.env\" ]]; then
    set -a
    source \"\$path/.env\"
    set +a
    exec $*
  else
    echo \"Error: .env not found!\"
    exit 1
  fi
  "
}



# Extract all archives with a single command
extract () {
  if [ $# -eq 1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


# Disposable File Hosting - http://transfer.sh/
transfer() {
    # check arguments
    if [ $# -eq 0 ];
    then
        echo "No arguments specified. Usage:\ntransfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    fi

    # get temporarily filename, output is written to this file show progress can be showed
    tmpfile=$( mktemp -t transferXXX )

    # upload stdin or file
    file=$1

    if tty -s;
    then
        basefile=$(basename "$file" | sed -e 's/[^a-zA-Z0-9._-]/-/g')

        if [ ! -e $file ];
        then
            echo "File $file doesn't exists."
            return 1
        fi

        if [ -d $file ];
        then
            # zip directory and transfer
            zipfile=$( mktemp -t transferXXX.zip )
            cd $(dirname $file) && zip -r -q - $(basename $file) >> $zipfile
            curl --progress-bar --upload-file "$zipfile" "https://transfer.sh/$basefile.zip" >> $tmpfile
            \rm -f $zipfile
        else
            # transfer file
            curl --progress-bar --upload-file "$file" "https://transfer.sh/$basefile" >> $tmpfile
        fi
      else
        # transfer pipe
        curl --progress-bar --upload-file "-" "https://transfer.sh/$file" >> $tmpfile
    fi

    # cat output link
    cat $tmpfile

    # cleanup
    \rm -f $tmpfile
}

# ---------------------------------------------------------------------------
# ff – Open a URL in Firefox Developer Edition
#        1) If an argument is passed, use it as the URL.
#        2) Otherwise pull a URL candidate from the clipboard.
#           (Supports macOS `pbpaste`, Linux `xclip` or `xsel`).
#     - A minimal check ensures the URL starts with http:// or https://
# ---------------------------------------------------------------------------
goto () {
    local url

    # 1. Argument takes precedence
    if [[ -n "$1" ]]; then
        url="$1"
    else
        # 2. Fallback to clipboard depending on platform / tool availability
        if command -v pbpaste >/dev/null 2>&1; then
            url="$(pbpaste)"
        elif command -v xclip >/dev/null 2>&1; then
            url="$(xclip -o -selection clipboard)"
        elif command -v xsel >/dev/null 2>&1; then
            url="$(xsel -b)"
        else
            echo "goto: no clipboard utility found (pbpaste/xclip/xsel)" >&2
            return 1
        fi
    fi

    # Basic validation – must begin with http:// or https://
    if [[ ! "$url" =~ ^https?:// ]]; then
        echo "goto: no valid URL supplied or found in clipboard" >&2
        return 1
    fi

    # Try to launch Firefox Developer Edition (cross-platform best-effort)
    if command -v firefox-developer-edition >/dev/null 2>&1; then
        firefox-developer-edition "$url" &
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: open the specific app bundle if it exists
        if [ -d "/Applications/Choosy.app" ] || \
           [ -d "$HOME/Applications/Firefox Developer Edition.app" ]; then
            open -a "Choosy" "$url" &
        else
            echo "goto: Choosy not found in /Applications" >&2
            return 1
        fi
    elif command -v choosy >/dev/null 2>&1; then
        choosy "$url" &
    else
        echo "goto: Choosy not installed" >&2
        return 1
    fi
}

