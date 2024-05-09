#!/bin/sh

# https://github.com/leleliu008/oh-my-vim


COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;94m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

echo() {
    printf '%b\n' "$*"
}

success() {
    printf '%b\n' "${COLOR_GREEN}[✔] $*${COLOR_OFF}" >&2
}

abort() {
    EXIT_STATUS_CODE="$1"
    shift
    printf '%b\n' "${COLOR_RED}💔  $*${COLOR_OFF}" >&2
    exit "$EXIT_STATUS_CODE"
}

run() {
    if [ "$RUN_SILENT" != 1 ] ; then
        echo "${COLOR_PURPLE}==>${COLOR_OFF} ${COLOR_GREEN}$@${COLOR_OFF}"
    fi

    eval "$@"
}

wfetch() {
    [ -z "$1" ] && abort 1 "wfetch <URL> , <URL> must be non-empty."

    ####################################################################

    for FETCH_TOOL in curl wget http lynx aria2c axel
    do
        if command -v "$FETCH_TOOL" > /dev/null ; then
            break
        else
            unset FETCH_TOOL
        fi
    done

    if [ -z "$FETCH_TOOL" ] ; then
        abort 1 "none of curl wget http lynx aria2c axel was found, please install one of them, then try again."
    fi

    ####################################################################

    unset FETCH_URL

    if [ "$CHINA" = 1 ] ; then
		case $1 in
			https://raw.githubusercontent.com/*)
				FETCH_URL="https://mirror.ghproxy.com/$1"
				;;
			https://github.com/*)
				FETCH_URL="https://mirror.ghproxy.com/$1"
				;;
		esac
    fi

    if [ -z "$FETCH_URL" ] ; then
        FETCH_URL="$1"
    fi

    ####################################################################

    FETCH_PATH="${FETCH_URL##*/}"

    ####################################################################

    case $FETCH_TOOL in
        curl)
            run "curl --fail --retry 20 --retry-delay 30 --location -o '$FETCH_PATH' '$FETCH_URL'"
            ;;
        wget)
            run "wget --timeout=60 -O '$FETCH_PATH' '$FETCH_URL'"
            ;;
        http)
            run "http --timeout=60 -o '$FETCH_PATH' '$FETCH_URL'"
            ;;
        lynx)
            run "lynx -source '$FETCH_URL' > '$FETCH_PATH'"
            ;;
        aria2c)
            run "aria2c -o '$FETCH_PATH' '$FETCH_URL'"
            ;;
        axel)
            run "axel -o '$FETCH_PATH' '$FETCH_URL'"
            ;;
    esac
}

####################################################################

set -e

# If IFS is not set, the default value will be <space><tab><newline>
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_05_03
unset IFS

VERSION=1.0.0

####################################################################

case $1 in
    --help|-h)
    	printf '%b\n' "
${COLOR_GREEN}Vim setup helper${COLOR_OFF}

${COLOR_GREEN}$0 --help${COLOR_OFF}
${COLOR_GREEN}$0 -h${COLOR_OFF}
    show help of this command.

${COLOR_GREEN}$0 --version${COLOR_OFF}
${COLOR_GREEN}$0 -V${COLOR_OFF}
    show version of this command.

${COLOR_GREEN}$0 [--china]${COLOR_OFF}
	setup vim
"
        exit
        ;;
    --version|-V)
        printf '%s\n' "$VERSION"
        exit
        ;;
esac

####################################################################

unset CHINA

while [ -n "$1" ]
do
	case $1 in
		-x)      set -x ;;
		--china) CHINA=1 ;;
		*)       abort 1 "unrecognized argument: $1"
	esac
	shift
done

####################################################################

[ -z "$HOME" ] && abort 1 "HOME environment variable is not set."
[ -z "$PATH" ] && abort 1 "PATH environment variable is not set."

####################################################################

# https://www.real-world-systems.com/docs/xcrun.1.html
# do not use this environment variable
unset SDKROOT

unset CC
unset CXX
unset OBJC
unset SYSROOT

if [ "$(uname -s)" = darwin ] ; then
     CC="$(xcrun --sdk macosx --find clang)"
    CXX="$(xcrun --sdk macosx --find clang++)"
SYSROOT="$(xcrun --sdk macosx --show-sdk-path)"
else
     CC="$(command -v cc  || command -v clang   || command -v gcc)" || abort 1 "C Compiler not found."
    CXX="$(command -v c++ || command -v clang++ || command -v g++)" || abort 1 "C++ Compiler not found."
fi

export PROXIED_CC="$CC"
export PROXIED_CXX="$CXX"

if [ -n  "$SYSROOT" ] ; then
    export SYSROOT
fi

####################################################################

SESSION_DIR="$HOME/.ycm-installer"

run install -d "$SESSION_DIR"

run cd "$SESSION_DIR"

####################################################################

if [ "$CHINA" = 1 ] ; then
    cat > url-transform <<EOF
#!/bin/sh

# https://ghps.cc
case \$1 in
    *githubusercontent.com/*)
        printf 'https://mirror.ghproxy.com/%s\n' "\$1"
        ;;
    https://github.com/*)
        printf 'https://mirror.ghproxy.com/%s\n' "\$1"
        ;;
    '') printf '%s\n' "\$0 <URL>, <URL> is unspecified." >&2 ; exit 1 ;;
    *)  printf '%s\n' "\$1"
esac
EOF

    chmod +x url-transform

    export PPKG_URL_TRANSFORM="$PWD/url-transform"
fi

####################################################################

export PPKG_HOME="$PWD/ppkg-home"

wfetch https://raw.githubusercontent.com/leleliu008/ppkg/master/ppkg
run chmod a+x ppkg

run ./ppkg env
run ./ppkg setup
run ./ppkg update
run ./ppkg install python3
run ./ppkg uppm install golang jdk17 -v

####################################################################

PYTHON_INSTALLED_DIR="$(./ppkg info-installed python3 installed-dir)"
PYTHON="$PYTHON_INSTALLED_DIR/bin/python3"

####################################################################

for item in $(./ppkg uppm ls-installed)
do
    if [ -d  "$PPKG_HOME/uppm/installed/$item/bin" ] ; then
        PATH="$PPKG_HOME/uppm/installed/$item/bin:$PATH"
    fi
done

####################################################################

printf 'PATH=>\n'
printf '%s\n' "$PATH" | tr ':' '\n'

####################################################################

export SSL_CERT_FILE="$PPKG_HOME/core/cacert.pem"

export GIT_EXEC_PATH="$PPKG_HOME/uppm/installed/git/libexec/git-core"
export GIT_TEMPLATE_DIR="$PPKG_HOME/uppm/installed/git/share/git-core/templates"
export GIT_CONFIG_NOSYSTEM=1

####################################################################

command -v npm  > /dev/null || {
    command -v nvm > /dev/null || {
        #wfetch https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh
        #run bash installer.sh

        wfetch https://get.volta.sh
        run bash get.volta.sh
    }

    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"

    run volta install node@20.11.0
}

if [ "$CHINA" = 1 ] && [ "$(npm config get registry)" = "https://registry.npmjs.org/" ] ; then
    run npm config set registry "https://registry.npm.taobao.org/"
fi

####################################################################

if [ -d ~/.vim/bundle/YouCompleteMe ] ; then
    run chmod -R +w ~/.vim/bundle/YouCompleteMe
    run rm -rf      ~/.vim/bundle/YouCompleteMe
fi

run install -d ~/.vim/bundle/YouCompleteMe
run         cd ~/.vim/bundle/YouCompleteMe

GIT_FETCH_URL='https://github.com/ycm-core/YouCompleteMe'

if [ "$CHINA" = 1 ] ; then
    GIT_FETCH_URL="https://mirror.ghproxy.com/$GIT_FETCH_URL"
fi

run git -c init.defaultBranch=master init
run git remote add origin "$GIT_FETCH_URL"
run git -c protocol.version=2 fetch --progress --depth=1 origin HEAD:refs/remotes/origin/master
run git checkout --progress --force -B master refs/remotes/origin/master

if [ "$CHINA" = 1 ] ; then
    sed -i 's|github\.com|mirror.ghproxy.com/github.com|g' .gitmodules
fi

run git submodule update --init

cd third_party/ycmd

if [ "$CHINA" = 1 ] ; then
    sed -i 's|github\.com|mirror.ghproxy.com/github.com|g' .gitmodules
fi

run git submodule update --init

cd -

####################################################################

if [        -d third_party/python-future/docs/notebooks/ ] ; then
    run rm -rf third_party/python-future/docs/notebooks/
fi

if [        -d third_party/ycmd/third_party/python-future/docs/notebooks/ ] ; then
    run rm -rf third_party/ycmd/third_party/python-future/docs/notebooks/
fi

####################################################################

#sed -i '/java_binary_path/c \"java_binary_path\": \"$PPKG_HOME/uppm/installed/jdk17/bin/java\"" third_party/ycmd/ycmd/default_settings.json

####################################################################

if [ "$CHINA" = 1 ] ; then
    sed -i 's|github\.com|mirror.ghproxy.com/github.com|g' $(grep 'github\.com' -rl .)
    sed -i "s@download.eclipse.org@mirrors.ustc.edu.cn/eclipse@g" third_party/ycmd/build.py
fi

####################################################################

export GOPATH="$PWD/go"
export GO111MODULE=oN

if [ "$CHINA" = 1 ] ; then
    export GOPROXY='https://goproxy.io'
fi

####################################################################

YCM_INSTALL_ARGS='--ninja'

ENABLE_TS=1
ENABLE_GO=1
ENABLE_JAVA=1
ENABLE_CLANG=1

[ "$ENABLE_TS"    = 1 ] && YCM_INSTALL_ARGS="$YCM_INSTALL_ARGS --ts-completer"
[ "$ENABLE_GO"    = 1 ] && YCM_INSTALL_ARGS="$YCM_INSTALL_ARGS --go-completer"
[ "$ENABLE_JAVA"  = 1 ] && YCM_INSTALL_ARGS="$YCM_INSTALL_ARGS --java-completer"
[ "$ENABLE_CLANG" = 1 ] && YCM_INSTALL_ARGS="$YCM_INSTALL_ARGS --clang-completer"

run "$PYTHON install.py $YCM_INSTALL_ARGS"

####################################################################

[ -e ~/.ycm_extra_conf.py ] || run cp third_party/ycmd/.ycm_extra_conf.py ~/.ycm_extra_conf.py

####################################################################

cd -

unset SUCCESS

onexit() {
    if [ "$SUCCESS" != 1 ] && [ -e vimrc.bak ] ; then
        run mv vimrc.bak ~/.vimrc
    fi
}

trap onexit EXIT

[ -e ~/.vimrc ] && run mv ~/.vimrc vimrc.bak

####################################################################

wfetch https://raw.githubusercontent.com/leleliu008/oh-my-vim/master/vimrc
sed -i "s|/usr/local/bin/python|$PYTHON|g" vimrc
run mv vimrc ~/.vimrc

####################################################################

wfetch https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
run install -d  ~/.vim/autoload/
run mv plug.vim ~/.vim/autoload/

####################################################################

SUCCESS=1

success "All Done. open vim and run :PlugInstall command to install vim plugins!"
