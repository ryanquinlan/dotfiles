# platform check for darwin specifc tweaks
PLATFORM=$(uname)

# constants
BUGZILLA_SERVER=""

# prompt
default_username="ryan"

if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
	export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
	export TERM=xterm-256color
fi

MAGENTA=$(tput setaf 1)
ORANGE=$(tput setaf 3)
GREEN=$(tput setaf 2)
PURPLE=$(tput setaf 5)
BLUE=$(tput setaf 4)
WHITE=$(tput setaf 15)
GRAY=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)

function git_info() {
	# check if we're in a git repo
	git rev-parse --is-inside-work-tree &>/dev/null || return

	# quickest check for what branch we're on
	branch=$(git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||')

	# check if it's dirty (via github.com/sindresorhus/pure)
	dirty=$(git diff --quiet --ignore-submodules HEAD &>/dev/null; [ $? -eq 1 ]&& echo -e "*")

	echo $GRAY" on "$PURPLE$branch$dirty
}

# Only show username/host if not default (override with bogus defult user)
function usernamehost() {
	if [ $USER != $default_username ]; then echo "${MAGENTA}$USER ${GRAY}at ${ORANGE}$HOSTNAME "; fi
}

# docker-machine prompt
source '/usr/bin/docker-machine-prompt.bash'

PS1="$(usernamehost)\[$GREEN\]\w\$(git_info)\[$RESET\]\[$BLUE\]\$(__docker_machine_ps1)\[$GRAY\]\n\$ \[$RESET\]"

#### end prompt ####

export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoredups
export CLICOLOR=1
export EDITOR="Sublime"
export HTMLEDITOR="Espresso"
export BROWSER="Safari"

#aliases
if [ $PLATFORM = Darwin ]; then
	alias ls="ls -A"
else
	alias ls="ls -A --color=auto"
fi

alias rf="rm -R"
alias ll="ls -lht"
alias edit="sublime"
alias md="mkdir"
alias ax="chmod a+x"
alias ip="curl icanhazip.com"
alias bp="edit $HOME/.bash_profile"
alias sshc="edit $HOME/.ssh/config"
alias sshk="edit $HOME/.ssh/known_hosts"
alias hostsc="edit /etc/hosts"
alias mackupc="edit $HOME/.mackup.cfg"
alias uuid="python -c 'import sys,uuid; sys.stdout.write(str(uuid.uuid4()))' | pbcopy && pbpaste && echo"
alias asm="java -jar $HOME/Dropbox/usr/bin/asm.jar &"
alias showhidden="defaults write com.apple.finder AppleShowAllFiles TRUE & killall Finder"
alias unshowhidden="defaults write com.apple.finder AppleShowAllFiles FALSE & killall Finder"
alias fixcam="sudo killall VDCAssistant"
alias nginxc="sublime /usr/local/etc/nginx/nginx.conf"
alias gcloud-dev="dev_appserver.py"
alias gcloud-deploy="appcfg.py"
alias dns="scutil --dns"
alias dnsflush="dscacheutil -flushcache"
alias vlc="/Applications/VLC.app/Contents/MacOS/VLC"
alias bars="vlc $HOME/Dropbox/sync/media/smptebars.mp4 -f"
alias sshlist="cat ~/.ssh/config | grep -E '^host|^####'"
alias pt=papertrail
alias echo_success='echo -e "\033[32m[OK]"'
alias echo_failure='echo -e "\033[31m[Failure]"'
alias gpg=gpg2
alias gpgc="sublime $HOME/.gnupg/gpg-agent.conf"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

alias kc="kitchen create"
alias kl="kitchen list"
alias kv="kitchen verify"
alias kd="kitchen destroy"
alias kcv="kitchen converge"
alias kli="kitchen login"
alias back="cd -"

#helpers
function pb() {
	if [[ -z "$1" ]]; then
		echo "pb requires a file as input. press ctrl+c ..."
	fi
	/bin/cat "$1" | pbcopy
}

function csrdump() {
    openssl req -in "$1" -noout -text
}

function certdump() {
    openssl x509 -text -in "$1"
}

function up() {
	aws s3 cp "$1" s3://iridiumlabs/up/
	echo "http://c.iridiumlabs.net/up/$1" | pbcopy
    echo "Copied to clipboard http://c.iridiumlabs.net/up/$1"
}

function frames() {
    ffmpeg -hide_banner -loglevel warning -stats -i "$1" image-%04d.png
    echo
}

function iframes() {
    ffmpeg -hide_banner -loglevel warning -stats -i "$1" -f image2 -vf "select='eq(pict_type,PICT_TYPE_I)'" -vsync vfr iframe%04d.png
}

function frame2video() {
    ffmpeg -hide_banner -loop 1 -r 30 -i "$1" -t 00:01:00 "$2"
}

function ffcompress() {
    ffmpeg -i "$1" -b:v 2000k -pix_fmt yuv420p -strict -2 "$2"
}

function ffremoveaudio() {
    ffmpeg -i "$1" -vcodec copy -an "$2"
}

function ffstill() {
	ffmpeg -hide_banner -loop 1 -r 30 -i "$1" -f lavfi -i aevalsrc=0 -t 00:01:00 -pix_fmt yuv420p -strict experimental "${1%.*}".mp4
}

function frames-count() {
	ffmpeg -nostats -i "$1" -vcodec copy -f rawvideo -y /dev/null 2>&1 | grep frame | awk '{split($0,a,"fps")}END{print a[1]}' | sed 's/.*= *//'
}

function ddzero() {
	dd if=/dev/zero of="$1" bs=1m count="$2"
}

function ddrandom() {
	dd if=/dev/urandom of="$1" bs=1m count="$2"
}

function server() {
	PORT=$(jot -r 1 8100 8199)
	python -m SimpleHTTPServer $PORT &
	sleep 1
	open http://localhost:$PORT
    fg %1
}

function bugs() {
	open -a $BROWSER http://$BUGZILLA_SERVER/show_bug.cgi?id=$1
}

function server-default() {
	PORT=$(jot -r 1 8100 8199)
	UUID=$(uuid)
	echo "Starting Python SimpleHTTPServer on $PORT with project $UUID"
	SOURCEPATH=$HOME/Dropbox/usr/html/instant-server-base
	PROJECTPATH=$HOME/Dropbox/usr/html/instant-server-active/$UUID
	mkdir $PROJECTPATH
	cp -R $SOURCEPATH/* $PROJECTPATH
	pushd $PROJECTPATH > /dev/null
	python -m SimpleHTTPServer $PORT &
	sleep 1
	open http://localhost:$PORT
	open -a $HTMLEDITOR $PROJECTPATH/css/main.css
	open -a $HTMLEDITOR $PROJECTPATH/css/bootstrap.css
	open -a $HTMLEDITOR $PROJECTPATH/index.html
	popd > /dev/null
    fg %1
}

function server-public() {
	PORT=$(jot -r 1 8100 8199)
	RAND=$(openssl rand -hex 4)
	SUBDOMAIN="ir-$RAND"
    echo "https://$SUBDOMAIN.ngrok.io" | pbcopy
	python -m SimpleHTTPServer $PORT & screen ngrok http -subdomain=$SUBDOMAIN $PORT &
	sleep 2
	open http://localhost:4040
	fg %2
}

function colors() {
	( x=`tput op` y=`printf %$((${COLUMNS}-6))s`;for i in {0..256};do o=00$i;echo -e ${o:${#o}-3:3} `tput setaf $i;tput setab $i`${y// /=}$x;done; )
}

function sethostname() {
	sudo scutil --set HostName $1
}

function ud() {
	local p= i=${1:-1}; while (( i-- )); do p+=../; done; cd "$p$2" && pwd;
}

function chrome-app() {
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --app="$1"
}

# The next line updates PATH for the Google Cloud SDK.
source '/usr/bin/google-cloud-sdk/path.bash.inc'

# The next line enables shell command completion for gcloud.
source '/usr/bin/google-cloud-sdk/completion.bash.inc'

# docker-machine use
source '/usr/bin/docker-machine-wrapper.bash'

# docker command completion
source  '/usr/bin/docker-machine-completion.bash'

# aws completer
complete -C '/usr/local/bin/aws_completer' aws

# ssh completer
complete -o default -o nospace -W "$(grep -i -e '^host ' ~/.ssh/config | awk '{print substr($0, index($0,$2))}' ORS=' ')" ssh scp sftp

# directory jump
. $HOME/Dropbox/usr/bin/z.sh


