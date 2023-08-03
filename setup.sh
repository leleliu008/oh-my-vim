#!/bin/sh

# https://github.com/leleliu008/oh-my-vim



_0=$0

unset CURRENT_SCRIPT_DIR
unset CURRENT_SCRIPT_FILENAME
unset CURRENT_SCRIPT_FILEPATH

CURRENT_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd) || exit 1
CURRENT_SCRIPT_FILENAME=$(basename "$0")
CURRENT_SCRIPT_FILEPATH="$CURRENT_SCRIPT_DIR/$CURRENT_SCRIPT_FILENAME"


COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;94m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

print() {
    printf "%b" "$*"
}

echo() {
    print "$*\n"
}

info() {
    print "💠  $*\n"
}

note() {
    print "${COLOR_YELLOW}🔔  $*${COLOR_OFF}\n" >&2
}

warn() {
    print "${COLOR_YELLOW}🔥  $*${COLOR_OFF}\n" >&2
}

success() {
    print "${COLOR_GREEN}[✔] $*${COLOR_OFF}\n"
}

error() {
    print "${COLOR_RED}💔  $*${COLOR_OFF}\n" >&2
}

die() {
    print "${COLOR_RED}💔  $*${COLOR_OFF}\n" >&2
    exit 1
}

# check if file exists
# $1 FILEPATH
file_exists() {
    [ -n "$1" ] && [ -e "$1" ]
}

# check if command exists in filesystem
# $1 command name or path
command_exists_in_filesystem() {
    case $1 in
        '') return 1 ;;
        */*)
            case $(uname | tr A-Z a-z) in
                cygwin*)
                    case $1 in
                        /cygdrive/*/choco) executable "$1" ;;
                        /cygdrive/*) return 1 ;;
                        *) executable "$1" ;;
                    esac
                    ;;
                *) executable "$1" ;;
            esac
            ;;
        *)  command_exists_in_filesystem $(command -v "$1" || true)
    esac
}

executable() {
    file_exists "$1" && [ -x "$1" ]
}

die_if_file_is_not_exist() {
    file_exists "$1" || die "$1 is not exist."
}

die_if_not_executable() {
    executable "$1" || die "$1 is not executable."
}

step() {
    STEP_NUM=$(expr ${STEP_NUM-0} + 1)
    STEP_MESSAGE="$@"
    echo
    echo "${COLOR_PURPLE}=>> STEP ${STEP_NUM} : ${STEP_MESSAGE} ${COLOR_OFF}"
}

step2() {
    STEP2_NUM=$(expr ${STEP2_NUM-0} + 1)
    STEP2_MESSAGE="$@"
    echo
    echo "${COLOR_BLUE}>>> STEP ${STEP_NUM}.${STEP2_NUM} : ${STEP2_MESSAGE} ${COLOR_OFF}"
}

run() {
    echo "$COLOR_PURPLE==>$COLOR_OFF $COLOR_GREEN$@$COLOR_OFF"
    eval "$*"
}

list() {
    for item in $@
    do
        echo "$item"
    done
}

list_length() {
    echo $#
}

shiftn() {
    shift "$1" && shift && echo "$@"
}

sed_in_place() {
    if command -v gsed > /dev/null ; then
        unset SED_IN_PLACE_ACTION
        SED_IN_PLACE_ACTION="$1"
        shift
        # contains ' but not contains \'
        if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
            run gsed -i "\"$SED_IN_PLACE_ACTION\"" $@
        else
            run gsed -i "'$SED_IN_PLACE_ACTION'" $@
        fi
    elif command -v sed  > /dev/null ; then
        if sed -i 's/a/b/g' $(mktemp) 2> /dev/null ; then
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i "'$SED_IN_PLACE_ACTION'" $@
            fi
        else
            unset SED_IN_PLACE_ACTION
            SED_IN_PLACE_ACTION="$1"
            shift
            if printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" " "' | grep -q 27 && ! printf "$SED_IN_PLACE_ACTION" | hexdump -v -e '1/1 "%02X" ""' | grep -q '5C 27' ; then
                run sed -i '""' "\"$SED_IN_PLACE_ACTION\"" $@
            else
                run sed -i '""' "'$SED_IN_PLACE_ACTION'" $@
            fi
        fi
    else
        die "please install sed utility."
    fi
}

getvalue() {
    if [ $# -eq 0 ] ; then
        cut -d= -f2
    else
        echo "$1" | cut -d= -f2
    fi
}

trim() {
    if [ $# -eq 0 ] ; then
        sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
    else
        if [ -n "$*" ] ; then
            echo "$*" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
        fi
    fi
}

tolower() {
    if [ $# -eq 0 ] ; then
        if command -v tr > /dev/null ; then
            tr A-Z a-z
        elif command -v  awk > /dev/null ; then
            awk '{print(tolower($0))}'
        elif command -v gawk > /dev/null ; then
            gawk '{print(tolower($0))}'
        else
            die "please install GNU CoreUtils or awk."
        fi
    else
        if [ -z "$*" ] ; then
            return 0
        fi
        if command -v tr > /dev/null ; then
            echo "$*" | tr A-Z a-z
        elif command -v  awk > /dev/null ; then
            echo "$*" | awk '{print(tolower($0))}'
        elif command -v gawk > /dev/null ; then
            echo "$*" | gawk '{print(tolower($0))}'
        elif command -v python > /dev/null ; then
            python  -c 'import sys; print(sys.argv[1].lower());' "$*"
        elif command -v python3 > /dev/null ; then
            python3 -c 'import sys; print(sys.argv[1].lower());' "$*"
        elif command -v python2 > /dev/null ; then
            python2 -c 'import sys; print(sys.argv[1].lower());' "$*"
        elif command -v perl > /dev/null ; then
            perl -e 'print @ARGV[0],"\n"' "$1"
        elif command -v node > /dev/null ; then
            node -e 'console.log(process.argv[2].toLowerCase())' - "$*"
        else
            die "please install GNU CoreUtils or awk."
        fi
    fi
}

own() {
    if command -v awk > /dev/null ; then
        ls -ld "$1" | awk '{print $3":"$4}'
    else
        ls -ld "$1" | cut -d ' ' -f4,6 | tr ' ' ':'
    fi
}

is_integer () {
    case "${1#[+-]}" in
        (*[!0123456789]*) return 1 ;;
        ('')              return 1 ;;
        (*)               return 0 ;;
    esac
}

format_unix_timestamp() {
   date -jf "%s" "$1" "$2" 2> /dev/null ||
   date -d      "@$1" "$2"
}

# }}}
##############################################################################
# {{{ md5sum

#examples:
# printf ss | md5sum
# cat FILE  | md5sum
# md5sum < FILE
md5sum() {
    if [ $# -eq 0 ] ; then
        if echo | command md5sum > /dev/null 2>&1 ; then
             command md5sum | cut -d ' ' -f1
        elif command -v openssl > /dev/null ; then
             openssl md5 | rev | cut -d ' ' -f1 | rev
        else
            return 1
        fi
    else
        if command -v openssl > /dev/null ; then
             openssl md5    "$1" | cut -d ' ' -f2
        elif echo | command md5sum > /dev/null 2>&1 ; then
             command md5sum "$1" | cut -d ' ' -f1
        else
            die "please install openssl or GNU CoreUtils."
        fi
    fi
}

# }}}
##############################################################################
# {{{ sha256sum

#examples:
# printf ss | sha256sum
# cat FILE  | sha256sum
# sha256sum < FILE
sha256sum() {
    if [ $# -eq 0 ] ; then
        if echo | command sha256sum > /dev/null 2>&1 ; then
             command sha256sum | cut -d ' ' -f1
        elif command -v openssl > /dev/null ; then
             openssl sha256 | rev | cut -d ' ' -f1 | rev
        else
            return 1
        fi
    else
        die_if_file_is_not_exist "$1"
        if command -v openssl > /dev/null ; then
             openssl sha256    "$1" | cut -d ' ' -f2
        elif echo | command sha256sum > /dev/null 2>&1 ; then
             command sha256sum "$1" | cut -d ' ' -f1
        else
            die "please install openssl or GNU CoreUtils."
        fi
    fi
}

# $1 FILEPATH
# $2 expect sha256sum
file_exists_and_sha256sum_matched() {
    die_if_file_is_not_exist "$1"
    if [ -z "$2" ] ; then
        die "please specify expected sha256sum."
    fi

    [ "$(sha256sum $1)" = "$2" ]
}

# $1 FILEPATH
# $2 expect sha256sum
die_if_sha256sum_mismatch() {
    file_exists_and_sha256sum_matched "$1" "$2" || die "sha256sum mismatch.\n    expect : $2\n    actual : $(sha256sum $1)"
}

# }}}
##############################################################################
# {{{ map

# $1 map_name
__map_name_ref() {
    printf "map_%s\n" "$(printf '%s' "$1" | md5sum)"
}

# $1 map_name
# $2 key
__map_key_ref() {
    printf "%s_key_%s\n" "$(__map_name_ref "$1")" "$(printf '%s' "$2" | md5sum)"
}

# $1 map_name
# $2 key
map_contains() {
    die_if_map_name_is_not_specified "$1"
    die_if_map_key__is_not_specified "$2"
    for item in $(eval echo \$$(__map_name_ref "$1"))
    do
        if [ "$item" = "$2" ] ; then
            return 0
        fi
    done
    return 1
}

# $1 map_name
# $2 key
# $3 value
map_set() {
    if ! map_contains "$1" "$2" ; then
        unset __MAP_NAME_REF__
        __MAP_NAME_REF__="$(__map_name_ref "$1")"
        __MAP_NAME_REF_VALUE__="$(eval echo \$$__MAP_NAME_REF__)"
        eval "$__MAP_NAME_REF__=\"$__MAP_NAME_REF_VALUE__ $2\""
    fi
    eval "$(__map_key_ref "$1" "$2")=$3"
}

# $1 map_name
# $2 key
# output: value
map_get() {
    die_if_map_name_is_not_specified "$1"
    die_if_map_key__is_not_specified "$2"
    eval echo "\$$(__map_key_ref "$1" "$2")"
}

# $1 map_name
# $2 key
# output: value
map_remove() {
    die_if_map_name_is_not_specified "$1"
    die_if_map_key__is_not_specified "$2"

    unset __MAP_NAME_REF__
    __MAP_NAME_REF__="$(__map_name_ref "$1")"

    unset __MAP_KEYS__
    __MAP_KEYS__="$(map_keys "$1")"

    unset $__MAP_NAME_REF__

    for item in $__MAP_KEYS__
    do
        if [ "$item" = "$2" ] ; then
            continue
        else
            eval "$__MAP_NAME_REF__='$(eval echo \$$__MAP_NAME_REF__) $item'"
        fi
    done
    eval "unset $(__map_key_ref "$1" "$2")"
}

# $1 map_name
map_clear() {
    die_if_map_name_is_not_specified "$1"

    unset __MAP_NAME_REF__
    __MAP_NAME_REF__="$(__map_name_ref "$1")"

    for item in $(eval echo "\$$__MAP_NAME_REF__")
    do
        eval "unset $(__map_key_ref "$1" "$item")"
    done
    eval "unset $__MAP_NAME_REF__"
}

# $1 map_name
# output: key list
map_keys() {
    die_if_map_name_is_not_specified "$1"
    eval echo "\$$(__map_name_ref "$1")"
}

# $1 map_name
# output: key list length
map_size() {
    die_if_map_name_is_not_specified "$1"
    list_length $(map_keys "$1")
}

# $1 map_name
die_if_map_name_is_not_specified() {
    if [ -z "$1" ] ; then
        die "please specify a map name."
    fi
}

# $1 key
die_if_map_key__is_not_specified() {
    if [ -z "$1" ] ; then
        die "please specify a map key."
    fi
}

# }}}
##############################################################################
# {{{ fetch

# fetch <URL> [--sha256=SHA256] <--output-path=PATH>
# fetch <URL> [--sha256=SHA256] <--output-dir=DIR> <--output-name=NAME>
# fetch <URL> [--sha256=SHA256] <--output-dir=DIR> [--output-name=NAME]
# fetch <URL> [--sha256=SHA256] [--output-dir=DIR] <--output-name=NAME>
fetch() {
    unset FETCH_URL
    unset FETCH_SHA256
    unset FETCH_OUTPUT_DIR
    unset FETCH_OUTPUT_NAME
    unset FETCH_OUTPUT_PATH
    unset FETCH_PIPE_TO_CMD

    if [ -z "$1" ] ; then
        die "fetch() please specify a url."
    else
        FETCH_URL="$1"
    fi

    shift

    while [ -n "$1" ]
    do
        case $1 in
            --sha256=*)
                FETCH_SHA256=$(getvalue "$1")
                ;;
            --output-dir=*)
                FETCH_OUTPUT_DIR=$(getvalue "$1")
                if [ -z "$FETCH_OUTPUT_DIR" ] ; then
                    die "fetch() --output-dir argument's value must not be empty."
                fi
                ;;
            --output-name=*)
                FETCH_OUTPUT_NAME=$(getvalue "$1")
                if [ -z "$FETCH_OUTPUT_NAME" ] ; then
                    die "fetch() --output-name argument's value must not be empty."
                fi
                ;;
            --output-path=*)
                FETCH_OUTPUT_PATH=$(getvalue "$1")
                if [ -z "$FETCH_OUTPUT_PATH" ] ; then
                    die "fetch() --output-path argument's value must not be empty."
                fi
                ;;
            --pipe=*)
                FETCH_PIPE_TO_CMD=$(getvalue "$1")
                if [ -z "$FETCH_PIPE_TO_CMD" ] ; then
                    die "fetch() --pipe=CMD argument's value must not be empty."
                fi
        esac
        shift
    done

    if [ -z "$FETCH_OUTPUT_PATH" ] ; then
        if [ -z "$FETCH_OUTPUT_DIR" ] && [ -z "$FETCH_OUTPUT_NAME" ] ; then
            FETCH_OUTPUT_PATH='-'
        else
            if [ -z "$FETCH_OUTPUT_DIR" ] ; then
                FETCH_OUTPUT_DIR="$PWD"
            fi
            if [ -z "$FETCH_OUTPUT_NAME" ] ; then
                FETCH_OUTPUT_NAME=$(basename "$FETCH_URL")
            fi
            FETCH_OUTPUT_PATH="$FETCH_OUTPUT_DIR/$FETCH_OUTPUT_NAME"
            if [ ! -d "$FETCH_OUTPUT_DIR" ] ; then
                run install -d "$FETCH_OUTPUT_DIR"
            fi
        fi
    elif [ "$FETCH_OUTPUT_PATH" = '-' ] ; then
        unset FETCH_OUTPUT_DIR
        unset FETCH_OUTPUT_NAME
    else
        FETCH_OUTPUT_DIR="$(dirname $FETCH_OUTPUT_PATH)"
        FETCH_OUTPUT_NAME="$(basename $FETCH_OUTPUT_PATH)"
        if [ ! -d "$FETCH_OUTPUT_DIR" ] ; then
            run install -d "$FETCH_OUTPUT_DIR"
        fi
    fi

    case $FETCH_URL in
        *.git)
            if [ -d "$FETCH_OUTPUT_PATH" ] ; then
                run cd  "$FETCH_OUTPUT_PATH" || return 1
                if      git rev-parse 2> /dev/null ; then
                    run git pull &&
                    run git submodule update --recursive
                else
                    run cd .. &&
                    run rm -rf "$FETCH_OUTPUT_NAME" &&
                    run git clone --recursive "$FETCH_URL" "$FETCH_OUTPUT_NAME"
                fi
            else
                if [ ! -d "$FETCH_OUTPUT_DIR" ] ; then
                    run install -d "$FETCH_OUTPUT_DIR" || return 1
                fi
                run cd "$FETCH_OUTPUT_DIR" || return 1
                run git clone --recursive "$FETCH_URL" "$FETCH_OUTPUT_NAME"
            fi
            ;;
        *)
            if [ "$FETCH_OUTPUT_PATH" != '-' ] && [ -f "$FETCH_OUTPUT_PATH" ] ; then
                if [ -n "$FETCH_SHA256" ] ; then
                    if file_exists_and_sha256sum_matched "$FETCH_OUTPUT_PATH" "$FETCH_SHA256" ; then
                        success "$FETCH_OUTPUT_PATH already have been downloaded."
                        return 0
                    fi
                fi
                rm -f "$FETCH_OUTPUT_PATH"
            fi

            for FETCH_TOOL in curl wget http lynx aria2c axel
            do
                if command_exists_in_filesystem "$FETCH_TOOL" ; then
                    break
                else
                    unset FETCH_TOOL
                fi
            done

            if [ -z "$FETCH_TOOL" ] ; then
                handle_dependency required exe curl
                FETCH_TOOL=curl
            fi

            case $FETCH_TOOL in
                curl)
                    if [ -z "$FETCH_PIPE_TO_CMD" ] ; then
                        run "curl --fail --retry 20 --retry-delay 30 --location -o '$FETCH_OUTPUT_PATH' '$FETCH_URL'"
                    else
                        run "curl --fail --retry 20 --retry-delay 30 --location -o '$FETCH_OUTPUT_PATH' '$FETCH_URL' | $FETCH_PIPE_TO_CMD"
                    fi
                    ;;
                wget)
                    if [ -z "$FETCH_PIPE_TO_CMD" ] ; then
                        run "wget --timeout=60 -O '$FETCH_OUTPUT_PATH' '$FETCH_URL'"
                    else
                        run "wget --timeout=60 -O '$FETCH_OUTPUT_PATH' '$FETCH_URL' | $FETCH_PIPE_TO_CMD"
                    fi
                    ;;
                http)
                    if [ -z "$FETCH_PIPE_TO_CMD" ] ; then
                        run "http --timeout=60 -o '$FETCH_OUTPUT_PATH' '$FETCH_URL'"
                    else
                        run "http --timeout=60 -o '$FETCH_OUTPUT_PATH' '$FETCH_URL' | $FETCH_PIPE_TO_CMD"
                    fi
                    ;;
                lynx)
                    if [ -z "$FETCH_PIPE_TO_CMD" ] ; then
                        run "lynx -source '$FETCH_URL' > '$FETCH_OUTPUT_PATH'"
                    else
                        run "lynx -source '$FETCH_URL' | $FETCH_PIPE_TO_CMD"
                    fi
                    ;;
                aria2c)
                    if [ -z "$FETCH_PIPE_TO_CMD" ] ; then
                        run "aria2c -d '$FETCH_OUTPUT_DIR' -o '$FETCH_OUTPUT_NAME' '$FETCH_URL'"
                    else
                        run "aria2c -d '$FETCH_OUTPUT_DIR' -o '$FETCH_OUTPUT_NAME' '$FETCH_URL' | $FETCH_PIPE_TO_CMD"
                    fi
                    ;;
                axel)
                    if [ -z "$FETCH_PIPE_TO_CMD" ] ; then
                        run "axel -o '$FETCH_OUTPUT_PATH' '$FETCH_URL'"
                    else
                        run "axel -o '$FETCH_OUTPUT_PATH' '$FETCH_URL' | $FETCH_PIPE_TO_CMD"
                    fi
                    ;;
                *)  die "fetch() unimplementation: $FETCH_TOOL"
                    ;;
            esac

            [ $? -eq 0 ] || return 1

            if [ "$FETCH_OUTPUT_PATH" != '-' ] && [ -n "$FETCH_SHA256" ] ; then
                die_if_sha256sum_mismatch "$FETCH_OUTPUT_PATH" "$FETCH_SHA256"
            fi
    esac
}

install_ca_certificates_on_netbsd() {
    # https://www.cambus.net/installing-ca-certificates-on-netbsd/
    if [ "$(uname)" = NetBSD ] ; then
        command -v mozilla-rootcerts > /dev/null || {
            if command -v pkgin > /dev/null ; then
                run $([ "$(whoami)" = root ] || printf 'sudo\n') pkgin -y install mozilla-rootcerts || return 1
            fi
        }
        run mozilla-rootcerts install || true
    fi
}

# }}}
##############################################################################
# {{{ get_china_mirror_url

contains_china_argument() {
    for arg in $@
    do
        case $arg in
            --china) return 0
        esac
    done
    return 1
}

# get_china_mirror_url <ORIGIN_URL> [--china]
get_china_mirror_url() {
    if [ -z "$1" ] ; then
        die "get_china_mirror_url() please specify a url."
    fi

    if contains_china_argument $@ ; then
        case $1 in
            *githubusercontent.com*)
                printf "%s" "$1" | sed 's@githubusercontent.com@githubusercontents.com@'
                ;;
            *github.com*)
                printf 'https://ghproxy.com/%s\n' "$1"
                ;;
        esac
    else
        printf "%s" "$1"
    fi
}

# }}}
##############################################################################
# {{{ __upgrade_self

# __upgrade_self <UPGRAGE_URL> [-x | --china]
__upgrade_self() {
    set -e

    if [ -z "$1" ] ; then
        die "__upgrade_self() please specify a url."
    fi

    for arg in $@
    do
        case $arg in
            -x) set -x ; break
        esac
    done

    unset CURRENT_SCRIPT_REALPATH

    # if file exists and is a symbolic link
    if [ -L "$CURRENT_SCRIPT_FILEPATH" ] ; then
        # https://unix.stackexchange.com/questions/136494/whats-the-difference-between-realpath-and-readlink-f#:~:text=GNU%20coreutils%20introduced%20a%20realpath,in%20common%20with%20GNU%20readlink%20.
        if command -v realpath > /dev/null ; then
            CURRENT_SCRIPT_REALPATH=$(realpath $CURRENT_SCRIPT_FILEPATH)
        elif command -v readlink > /dev/null && readlink -f xx > /dev/null 2>&1 ; then
            CURRENT_SCRIPT_REALPATH=$(readlink -f $CURRENT_SCRIPT_FILEPATH)
        else
            handle_dependency required exe realpath
            CURRENT_SCRIPT_REALPATH=$(realpath $CURRENT_SCRIPT_FILEPATH)
        fi
    else
        CURRENT_SCRIPT_REALPATH="$CURRENT_SCRIPT_FILEPATH"
    fi

    echo "$COLOR_PURPLE==>$COLOR_OFF ${COLOR_GREEN}mktemp -d$COLOR_OFF"
    WORK_DIR=$(mktemp -d)

    run cd $WORK_DIR

    fetch "$(get_china_mirror_url $@)" --output-path="$WORK_DIR/self"

    __upgrade_self_exit() {
        if [ -w "$CURRENT_SCRIPT_REALPATH" ] ; then
            run      install -m 755 self "$CURRENT_SCRIPT_REALPATH"
        else
            run sudo install -m 755 self "$CURRENT_SCRIPT_REALPATH"
        fi

        run rm -rf $WORK_DIR
    }

    trap __upgrade_self_exit EXIT
}

# }}}
##############################################################################
# {{{ __integrate_zsh_completions

# __integrate_zsh_completions <ZSH_COMPLETIONS_SCRIPT_URL> [-x | --china]
__integrate_zsh_completions() {
    set -e

    if [ -z "$1" ] ; then
        die "__integrate_zsh_completions() please specify a url."
    fi

    for arg in $@
    do
        case $arg in
            -x) set -x ; break
        esac
    done

    ZSH_COMPLETIONS_SCRIPT_FILENAME="_$CURRENT_SCRIPT_FILENAME"

    if [ "$(uname)" = Linux ] && command -v termux-info > /dev/null && [ "$HOME" = '/data/data/com.termux/files/home' ] ; then
        ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH="/data/data/com.termux/files/usr/share/zsh/site-functions/$ZSH_COMPLETIONS_SCRIPT_FILENAME"
    else
        ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH="/usr/local/share/zsh/site-functions/$ZSH_COMPLETIONS_SCRIPT_FILENAME"
    fi

    # if file exists and is a symbolic link
    if [ -L "$ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH" ] ; then
        # https://unix.stackexchange.com/questions/136494/whats-the-difference-between-realpath-and-readlink-f#:~:text=GNU%20coreutils%20introduced%20a%20realpath,in%20common%20with%20GNU%20readlink%20.
        if command -v realpath > /dev/null ; then
            ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH=$(realpath $ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH)
        elif command -v readlink > /dev/null && readlink -f xx > /dev/null 2>&1 ; then
            ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH=$(readlink -f $ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH)
        else
            handle_dependency required exe realpath
            ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH=$(realpath $ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH)
        fi
    fi

    echo "$COLOR_PURPLE==>$COLOR_OFF ${COLOR_GREEN}mktemp -d$COLOR_OFF"
    WORK_DIR=$(mktemp -d)

    run cd $WORK_DIR

    fetch "$(get_china_mirror_url $@)" --output-path="$WORK_DIR/$ZSH_COMPLETIONS_SCRIPT_FILENAME"

    if [ -f "$ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH" ] ; then
        if [ -w "$ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH" ] ; then
            run      install -m 644 "$ZSH_COMPLETIONS_SCRIPT_FILENAME" "$ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH"
        else
            run sudo install -m 644 "$ZSH_COMPLETIONS_SCRIPT_FILENAME" "$ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH"
        fi
    else
        ZSH_COMPLETIONS_SCRIPT_OUT_DIR="$(dirname "$ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH")"
        if [ ! -d "$ZSH_COMPLETIONS_SCRIPT_OUT_DIR" ] ; then
            run install -d "$ZSH_COMPLETIONS_SCRIPT_OUT_DIR" || run sudo install -d "$ZSH_COMPLETIONS_SCRIPT_OUT_DIR"
        fi
        if [ -w "$ZSH_COMPLETIONS_SCRIPT_OUT_DIR" ] ; then
            run      install -m 644 "$ZSH_COMPLETIONS_SCRIPT_FILENAME" "$ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH"
        else
            run sudo install -m 644 "$ZSH_COMPLETIONS_SCRIPT_FILENAME" "$ZSH_COMPLETIONS_SCRIPT_OUT_FILEPATH"
        fi
    fi

    run rm -rf $WORK_DIR

    echo '\n'
    note "${COLOR_YELLOW}you need to run command${COLOR_RED} ${COLOR_GREEN}autoload -U compinit && compinit${COLOR_OFF} ${COLOR_YELLOW}in zsh to make it work.${COLOR_OFF}"
}

# }}}
##############################################################################
# {{{ os

__get_os_kind_from_uname() {
    case $1 in
        msys*)    printf '%s\n' 'windows' ;;
        mingw32*) printf '%s\n' 'windows' ;;
        mingw64*) printf '%s\n' 'windows' ;;
        cygwin*)  printf '%s\n' 'windows' ;;
        *)        printf '%s\n' "$1"
    esac
}

__get_os_type_from_uname_a() {
    if [ $# -eq 0 ] ; then
        if command -v uname > /dev/null ; then
            __get_os_type_from_uname_a "$(uname -a | cut -d ' ' -f2)"
        else
            return 1
        fi
    else
        case $1 in
            opensuse*) return 1 ;;
            *-*) printf '%s\n' "$1" | cut -d- -f1 | tr A-Z a-z ;;
            *)   return 1
        esac
    fi
}

__get_os_version_from_uname_a() {
    if [ $# -eq 0 ] ; then
        if command -v uname > /dev/null ; then
            __get_os_version_from_uname_a "$(uname -a | cut -d ' ' -f2)"
        else
            return 1
        fi
    else
        case $1 in
            opensuse*) return 1 ;;
            *-*) printf '%s\n' "$1" | cut -d- -f2 ;;
            *)   return 1
        esac
    fi
}

# https://www.freedesktop.org/software/systemd/man/os-release.html
__get_os_type_from_etc_os_release() {
    if [ -e /etc/os-release ] ; then
        (
            . /etc/os-release || return 1
            if [ -z "$ID" ] ; then
                return 1
            else
                printf '%s\n' "$ID" | tr A-Z a-z
            fi
        )
    else
        return 1
    fi
}

__get_os_version_from_etc_os_release() {
    if [ -f /etc/os-release ] ; then
        (
            . /etc/os-release || return 1
            if [ -z "$VERSION_ID" ] ; then
                printf '%s\n' 'rolling'
            else
                printf '%s\n' "$VERSION_ID"
            fi
        )
    else
        return 1
    fi
}

# https://refspecs.linuxfoundation.org/LSB_3.0.0/LSB-PDA/LSB-PDA/lsbrelease.html
__get_os_type_from_lsb_release() {
    if command -v lsb_release > /dev/null ; then
        lsb_release --id | cut -f2 | tr A-Z a-z
    else
        return 1
    fi
}

__get_os_version_from_lsb_release() {
    if command -v lsb_release > /dev/null ; then
        lsb_release --release | cut -f2
    else
        return 1
    fi
}

__get_os_type_from_etc_redhat_release() {
    if [ $# -eq 0 ] ; then
        if [ -e /etc/redhat-release ] ; then
            __get_os_type_from_etc_redhat_release "$(cat /etc/redhat-release)"
        else
            return 1
        fi
    else
        case $1 in
            'Red Hat Enterprise Linux release'*)
                printf '%s\n' rhel
                ;;
            'Fedora release'*)
                printf '%s\n' fedora
                ;;
            'CentOS release'*)
                printf '%s\n' centos
                ;;
            'CentOS Linux release'*)
                printf '%s\n' centos
                ;;
            *)  printf '%s\n' "$1" | cut -d ' ' -f1 | tr A-Z a-z
        esac
    fi
}

__get_os_version_from_etc_redhat_release() {
    if [ $# -eq 0 ] ; then
        if [ -e /etc/redhat-release ] ; then
            __get_os_version_from_etc_redhat_release $(cat /etc/redhat-release)
        else
            return 1
        fi
    else
        while [ -n "$1" ]
        do
            case $1 in
                [1-9]*) printf '%s\n' "$1"; return 0
            esac
            shift
        done
        return 1
    fi
}

__get_os_version_from_getprop() {
    if command -v getprop > /dev/null ; then
        getprop ro.build.version.release
    else
        return 1
    fi
}

__get_os_arch_from_uname() {
    if command -v uname > /dev/null ; then
        uname -m 2> /dev/null
    else
        return 1
    fi
}

__get_os_arch_from_arch() {
    if command -v arch > /dev/null ; then
        arch
    else
        return 1
    fi
}

__get_os_type_from_os_kind() {
    case $1 in
        darwin)  printf '%s\n' macos ;;
        linux)
            if [ "$(uname -o 2>/dev/null)" = Android ] ; then
                printf '%s\n' android
            else
                __get_os_type_from_etc_redhat_release ||
                __get_os_type_from_etc_os_release ||
                __get_os_type_from_lsb_release ||
                __get_os_type_from_uname_a
            fi
            ;;
        *) printf '%s\n' "$1"
    esac
}

__get_os_name_from_os_type() {
    case $1 in
        debian)  printf '%s\n' 'Debian' ;;
        ubuntu)  printf '%s\n' 'Ubuntu' ;;
        linuxmint) printf '%s\n' 'LinuxMint' ;;
        centos)  printf '%s\n' 'CentOS' ;;
        fedora)  printf '%s\n' 'Fedora' ;;
        rhel)    printf '%s\n' 'RHEL' ;;
        opensuse-leap)
                 printf '%s\n' 'openSUSE-Leap' ;;
        gentoo)  printf '%s\n' 'Gentoo' ;;
        manjaro) printf '%s\n' 'Manjaro' ;;
        alpine)  printf '%s\n' 'AlpineLinux' ;;
        arch)    printf '%s\n' 'ArchLinux' ;;
        void)    printf '%s\n' 'VoidLinux' ;;
        freebsd) printf '%s\n' 'FreeBSD' ;;
        netbsd)  printf '%s\n' 'NetBSD' ;;
        openbsd) printf '%s\n' 'OpenBSD' ;;
        macos)   printf '%s\n' 'macOS' ;;
        android) printf '%s\n' 'Android' ;;
        windows)
            systeminfo | grep 'OS Name:' | cut -d: -f2 | head -n 1 | sed 's/^[[:space:]]*//'
            ;;
        *) printf '%s\n' "$1"
    esac
}

__get_os_version_from_os_kind() {
    case $1 in
        freebsd) freebsd-version ;;
        openbsd) uname -r ;;
        netbsd)  uname -r ;;
        darwin)  sw_vers -productVersion ;;
        linux)
            __get_os_version_from_etc_redhat_release ||
            __get_os_version_from_etc_os_release ||
            __get_os_version_from_lsb_release ||
            __get_os_version_from_getprop ||
            __get_os_version_from_uname_a
            ;;
        windows)
            systeminfo | grep 'OS Version:' | cut -d: -f2 | head -n 1 | sed 's/^[[:space:]]*//' | cut -d ' ' -f1
            ;;
    esac
}

__get_os_sub_system() {
    case $(uname | tr A-Z a-z) in
        msys*)    printf '%s\n' "msys"    ;;
        mingw32*) printf '%s\n' "mingw32" ;;
        mingw64*) printf '%s\n' "mingw64" ;;
        cygwin*)  printf '%s\n' 'cygwin'  ;;
        *)
            if [ "$(uname -o 2>/dev/null)" = Android ] ; then
                if [ -n "$TERMUX_VERSION" ] ; then
                    printf '%s\n' termux
                fi
            fi
    esac
}

__get_os_arch() {
    __get_os_arch_from_uname ||
    __get_os_arch_from_arch
}

__get_os_libc_from_os_kind() {
    case $1 in
        linux)
            if [ "$(uname -o 2>/dev/null)" = Android ] ; then
                printf '%s\n' bionic
                return 0
            fi
            # https://pubs.opengroup.org/onlinepubs/7908799/xcu/getconf.html
            if command -v getconf > /dev/null ; then
                if getconf GNU_LIBC_VERSION > /dev/null 2>&1 ; then
                    printf '%s\n' glibc
                    return 0
                fi
            fi
            if command -v ldd > /dev/null ; then
                if ldd --version 2>&1 | head -n 1 | grep -q GLIBC ; then
                    printf '%s\n' glibc
                    return 0
                fi
                if ldd --version 2>&1 | head -n 1 | grep -q musl ; then
                    printf '%s\n' musl
                    return 0
                fi
            fi
            return 1
    esac
}

# https://stackoverflow.com/questions/45181115/portable-way-to-find-the-number-of-processors-cpus-in-a-shell-script
__get_os_ncpu() {
    case "$(uname)" in
        Darwin) sysctl -n machdep.cpu.thread_count ;;
        *BSD)   sysctl -n hw.ncpu ;;
        *)  if command nproc --version > /dev/null 2>&1 ; then
                command nproc
            elif test -f /proc/cpuinfo ; then
                grep -c processor /proc/cpuinfo
            else
                echo 4
            fi
    esac
}

os() {
    if [ $# -eq 0 ] ; then
        printf "current-machine-os-kind : %s\n" "$(os kind)"
        printf "current-machine-os-type : %s\n" "$(os type)"
        printf "current-machine-os-name : %s\n" "$(os name)"
        printf "current-machine-os-vers : %s\n" "$(os vers)"
        printf "current-machine-os-arch : %s\n" "$(os arch)"
        printf "current-machine-os-ncpu : %s\n" "$(os ncpu)"
        printf "current-machine-os-euid : %s\n" "$(os euid)"
        printf "current-machine-os-libc : %s\n" "$(os libc)"
        printf "current-machine-os-subs : %s\n" "$(os subs)"
    elif [ $# -eq 1 ] ; then
        case $1 in
            -h|--help)
                cat <<'EOF'
os -h | --help
os -V | --version
os kind
os type
os name
os vers
os arch
os ncpu
os euid
os libc
os subs
EOF
                ;;
            -V|--version)
                printf "%s\n" '2021.10.01.03'
                ;;
            kind)
                __get_os_kind_from_uname $(uname | tr A-Z a-z)
                ;;
            type)
                __get_os_type_from_os_kind $(os kind)
                ;;
            name)
                __get_os_name_from_os_type $(os type)
                ;;
            vers)
                __get_os_version_from_os_kind $(os kind)
                ;;
            subs)
                __get_os_sub_system
                ;;
            arch)
                __get_os_arch
                ;;
            ncpu)
                __get_os_ncpu
                ;;
            euid)
                id -u
                ;;
            libc)
                __get_os_libc_from_os_kind $(os kind)
                ;;
            *)  printf '%s\n' "unrecognized argument: $1" >&2; return 1
        esac
    else
        printf '%s\n' "os command only support one argument." >&2; return 1
    fi
}

# }}}
##############################################################################
# {{{ version

version_of_python_module() {
    unset PIP_COMMAND
    PIP_COMMAND=$(command -v pip3 || command -v pip)
    if [ -z "$PIP_COMMAND" ] ; then
        die "can't found pip command."
    else
        "$PIP_COMMAND" show $1 | grep 'Version:' | cut -d ' ' -f2
    fi
}

# retrive the version of a command from it's name or path
version_of_command() {
    case $(basename "$1") in
        cmake) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
         make) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
        gmake) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
       rustup) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        cargo) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
           go) "$1"   version | cut -d ' ' -f3 | cut -c3- ;;
         tree) "$1" --version | cut -d ' ' -f2 | cut -c2- ;;
   pkg-config) "$1" --version 2> /dev/null | head -n 1 ;;
       m4|gm4) "$1" --version 2> /dev/null | head -n 1 | awk '{print($NF)}';;
    autopoint) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
     automake|aclocal)
               "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
     autoconf|autoheader|autom4te|autoreconf|autoscan|autoupdate|ifnames)
               "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
      libtool) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
   libtoolize|glibtoolize)
               "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
      objcopy) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f5 ;;
         flex) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        bison) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
         yacc) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
         nasm) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
         yasm) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        patch) "$1" --version 2> /dev/null | head -n 1 | awk '{print($NF)}' ;;
        gperf) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
        groff) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
     help2man) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
 sphinx-build) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         file) "$1" --version 2> /dev/null | head -n 1 | cut -d '-' -f2 ;;
      itstool) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
       protoc) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        xmlto) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
      xmllint) ;;
     xsltproc) ;;
     rst2man|rst2man.py|rst2man-3|rst2man-3.6|rst2man-3.7|rst2man-3.8|rst2man-3.9)
               "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
         gzip) "$1" --version 2>&1 | head -n 1 | awk '{print($NF)}' ;;
         lzip) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
           xz) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
          zip) "$1" --version 2> /dev/null | sed -n '2p' | cut -d ' ' -f4 ;;
        unzip) "$1" -v        2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
        bzip2) "$1" --help 2>&1 | head -n 1 | cut -d ' ' -f8 | cut -d ',' -f1 ;;
          tar)
            VERSION_MSG=$("$1" --version 2> /dev/null | head -n 1)
            case $VERSION_MSG in
                  tar*) echo "$VERSION_MSG" | cut -d ' ' -f4 ;;
               bsdtar*) echo "$VERSION_MSG" | cut -d ' ' -f2 ;;
            esac
            ;;
          git) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 ;;
         curl) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
     awk|gawk) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f3 | tr , ' ' ;;
     sed|gsed) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
         cpan) ;;
         find) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
         diff) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
         grep) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 | cut -d '-' -f1 ;;
         ruby) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         perl) "$1" -v | sed -n '2p' | sed 's/.*v\([0-9]\.[0-9][0-9]\.[0-9]\).*/\1/' ;;
    python|python2|python3)
               "$1" --version 2>&1 | head -n 1 | cut -d ' ' -f2 ;;
         pip)  "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         pip3) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         node) "$1" --version 2> /dev/null | head -n 1 | cut -d 'v' -f2 ;;
          zsh) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f2 ;;
         bash) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 | cut -d '(' -f1 ;;
       base64) "$1" --version 2> /dev/null | head -n 1 | cut -d ' ' -f4 ;;
            *) "$1" --version 2> /dev/null | head -n 1
    esac
}

# retrive the major part of the version of the given command
# Note: the version of the given command must have form: major.minor.patch
version_major_of_command() {
    version_of_command "$1" | cut -d. -f1
}

# retrive the minor part of the version of the given command
# Note: the version of the given command must have form: major.minor.patch
version_minor_of_command() {
    version_of_command "$1" | cut -d. -f2
}

# retrive the major part of the given version
# Note: the given version must have form: major.minor.patch
version_major_of_version() {
    echo "$1" | cut -d. -f1
}

# retrive the minor part of the given version
# Note: the given version must have form: major.minor.patch
version_minor_of_version() {
    echo "$1" | cut -d. -f2
}

version_sort() {
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sort.html
    # https://man.netbsd.org/NetBSD-8.1/i386/sort.1
    #
    # sort: unrecognized option: V
    # BusyBox v1.29.3 (2019-01-24 07:45:07 UTC) multi-call binary.
    # Usage: sort [-nrugMcszbdfiokt] [-o FILE] [-k start[.offset][opts][,end[.offset][opts]] [-t CHAR] [FILE]...
    if  echo | (sort -V > /dev/null 2>&1) ; then
        echo "$@" | tr ' ' '\n' | sort -V
    else
        echo "$@" | tr ' ' '\n' | sort -t. -n -k1,1 -k2,2 -k3,3 -k4,4
    fi
}

# check if match the condition
#
# condition:
# eq  equal
# ne  not equal
# gt  greater than
# lt  less than
# ge  greater than or equal
# le  less than or equal
#
# examples:
# version_match 1.15.3 eq 1.16.0
# version_match 1.15.3 lt 1.16.0
# version_match 1.15.3 gt 1.16.0
# version_match 1.15.3 le 1.16.0
# version_match 1.15.3 ge 1.16.0
version_match() {
    case $2 in
        eq)  [ "$1"  = "$3" ] ;;
        ne)  [ "$1" != "$3" ] ;;
        le)
            if [ "$1" = "$3" ] ; then
                return 0
            fi
            [ "$1" = "$(version_sort "$1" "$3" | head -n 1)" ]
            ;;
        ge)
            if [ "$1" = "$3" ] ; then
                return 0
            fi
            [ "$1" = "$(version_sort "$1" "$3" | tail -n 1)" ]
            ;;
        lt)
            if [ "$1" = "$3" ] ; then
                return 1
            fi
            [ "$1" = "$(version_sort "$1" "$3" | head -n 1)" ]
            ;;
        gt)
            if [ "$1" = "$3" ] ; then
                return 1
            fi
            [ "$1" = "$(version_sort "$1" "$3" | tail -n 1)" ]
            ;;
        *)  die "version_compare: $2: not supported operator."
    esac
}

# check if the version of give installed command match the condition
#
# condition:
# eq  equal
# ne  not equal
# gt  greater than
# lt  less than
# ge  greater than or equal
# le  less than or equal
#
# examples:
# command_exists_in_filesystem_and_version_matched automake eq 1.16.0
# command_exists_in_filesystem_and_version_matched automake lt 1.16.0
# command_exists_in_filesystem_and_version_matched automake gt 1.16.0
# command_exists_in_filesystem_and_version_matched automake le 1.16.0
# command_exists_in_filesystem_and_version_matched automake ge 1.16.0
# command_exists_in_filesystem_and_version_matched automake
command_exists_in_filesystem_and_version_matched() {
    if command_exists_in_filesystem "$1" ; then
        if [ $# -eq 3 ] ; then
            version_match "$(version_of_command "$1")" "$2" "$3"
        fi
    else
        return 1
    fi
}

# }}}
##############################################################################
# {{{ package manager wrapper, aka pmw

# check if the give package specification is available in specified package manager's repo
#
# package specification's form: <PKG> [OP VERSION]
#
# OP:
# eq  equal
# ne  not equal
# gt  greater than
# lt  less than
# ge  greater than or equal
# le  less than or equal
#
# __pmw_is_package_available <PM> <PKG> [OP VERSION]
#
# __pmw_is_package_available apt automake eq 1.16.0
# __pmw_is_package_available apt automake lt 1.16.0
# __pmw_is_package_available apt automake gt 1.16.0
# __pmw_is_package_available apt automake le 1.16.0
# __pmw_is_package_available apt automake ge 1.16.0
# __pmw_is_package_available apt automake
__pmw_is_package_available() {
    if [ $# -eq 2 ] ; then
        case $1 in
            pkg) pkg show "$2" > /dev/null 2>&1 ;;
            apt) apt show "$2" > /dev/null 2>&1 ;;
            apk) apk info "$2" > /dev/null 2>&1 ;;
            yum) yum info "$2" > /dev/null 2>&1 ;;
            dnf) dnf info "$2" > /dev/null 2>&1 ;;
            brew) brew info "$2" > /dev/null 2>&1 ;;
            xbps) xbps-query -R "$2" > /dev/null 2>&1 ;;
            pacman) pacman -Ss "^$2$" > /dev/null 2>&1 ;;
            zypper) [ "$(zypper info "$2" 2>&1 | tail -n 1)" != "package '$2' not found." ] ;;
            emerge)
                case $2 in
                    */*) [ "$(emerge -s "%@^$2$" 2>&1 | tail -n 2 | head -n 1)" != '\[ Applications found : 0 \]' ] ;;
                    *)   [ "$(emerge -s "%^$2$"  2>&1 | tail -n 2 | head -n 1)" != '\[ Applications found : 0 \]' ]
                esac
                ;;
        esac
    elif [ $# -eq 4 ] ; then
        __pmw_is_package_available "$1" "$2" && version_match "$(__pmw_get_available_package_version_by_package_name "$1" "$2")" "$3" "$4"
    else
        die "USAGE:  __pmw_is_package_available <PM> <PKG> [OP VERSION]\nACTUAL: __pmw_is_package_available $@"
    fi
}

# __pmw_get_available_package_version_by_package_name <PM> <PKG>
# __pmw_get_available_package_version_by_package_name apt automake
__pmw_get_available_package_version_by_package_name() {
    case $1 in
        pkg) pkg show "$2" 2> /dev/null | grep 'Version: '      | head -n 1 | cut -d ' ' -f2 | cut -d- -f1 ;;
        apt) apt show "$2" 2> /dev/null | grep 'Version: '      | head -n 1 | cut -d ' ' -f2 | cut -d- -f1 ;;
        apk) apk info "$2" 2> /dev/null | head -n 1 | cut -d ' ' -f1 | cut -d- -f2 ;;
        yum) yum info "$2" 2> /dev/null | grep 'Version     :'  | head -n 1 | cut -d : -f2 | sed 's/^[[:space:]]//' ;;
        dnf) dnf info "$2" 2> /dev/null | grep 'Version      :' | head -n 1 | cut -d : -f2 | sed 's/^[[:space:]]//' ;;
        brew) brew info "$2" 2> /dev/null | grep "$2: " | cut -d ' ' -f3 ;;
        xbps) xbps-query -R --property=pkgver "$2" | cut -d- -f2 | cut -d_ -f1 ;;
        pacman) pacman -Ss "^$2$" 2> /dev/null | head -n 1 | cut -d ' ' -f2 | cut -d- -f1 ;;
        zyyper) zyyper info "$2" 2> /dev/null | sed -n '/Version        :/p' | sed 's/Version        : \(.*\)/\1/' | cut -d- -f1 ;;
        emerge)
            case $2 in
                */*) emerge -s "%@^$2$" 2> /dev/null | sed -n '/Latest version available:/p' | cut -d: -f2 ;;
                *)   emerge -s "%^$2$"  2> /dev/null | sed -n '/Latest version available:/p' | cut -d: -f2 ;;
            esac
    esac
}

# }}}
##############################################################################
# {{{ __pmw_get_available_package_name_by_command_name_XX

# https://cygwin.com/packages/package_list.html
__pmw_get_available_package_name_by_command_name_choco() {
    case $1 in
          go) echo 'golang' ;;
      cc|gcc|c++|g++)
              echo 'gcc-g++';;
       gmake) echo 'make'   ;;
         gm4) echo 'm4'     ;;
        gsed) echo 'gnu-sed';;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo 'python38-sphinx' ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_pkg_add() {
    case $1 in
          go) echo 'golang';;
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        make) echo 'gmake' ;;
        perl) echo 'perl5' ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
    realpath) echo 'coreutils';;
     objcopy) echo 'binutils' ;;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    pip3|pip) echo 'py3-pip' ;;
    libtool|libtoolize|glibtool|glibtoolize)
              echo "libtool" ;;
    autoreconf|autoconf|autoreconf-2.69|autoconf-2.69)
              echo "autoconf-2.69p3" ;;
    automake|autoheader|automake-1.16|autoheader-1.16)
            if [ "$NATIVE_OS_VERS" = '6.9' ] ; then
                echo "automake-1.16.3"
            else
                echo "automake-1.16.2"
            fi
            ;;
    autopoint) echo "gettext" ;;
    pkg-config) echo "pkgconf" ;;
        *) echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_pkgin() {
    case $1 in
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        make) echo 'gmake' ;;
        perl) echo 'perl5' ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
    realpath) echo 'coreutils';;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    pip3|pip) echo 'py38-pip'  ;;
    python3)  echo 'python38' ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_pkg() {
    case $1 in
          go) echo 'golang';;
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        make) echo 'gmake' ;;
        perl) echo 'perl5' ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    pip3|pip) echo 'py38-pip' ;;
    libtool|libtoolize|glibtool|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_emerge() {
    case $1 in
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
      xz)     echo 'xz-utils' ;;
      tree)   echo 'app-text/tree' ;;
      rst2man|rst2html)
              echo "docutils" ;;
    sphinx-build)
              echo "sphinx" ;;
    pip3|pip) echo "dev-python/pip" ;;
    libtool|libtoolize|glibtool|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_pacman() {
    case $1 in
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
      rst2man|rst2html)
              echo "python-docutils" ;;
    sphinx-build)
              echo "python-sphinx" ;;
    pip3|pip) echo "python-pip" ;;
    libtool|libtoolize|glibtool|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

__mingw_w64_i686() {
    if pacman -S -i "mingw-w64-i686-$1" > /dev/null 2>&1 ; then
        echo "mingw-w64-i686-$1"
    else
        echo "$1"
    fi
}

__mingw_w64_x86_64() {
    if pacman -S -i "mingw-w64-x86_64-$1" > /dev/null 2>&1 ; then
        echo "mingw-w64-x86_64-$1"
    else
        echo "$1"
    fi
}

__pmw_get_available_package_name_by_command_name_pacman() {
    if [ "$1" = 'make' ] || [ "$1" = 'gmake' ] ; then
        echo make
    fi
    case $NATIVE_OS_SUBS in
        mingw32) __mingw_w64_i686   $(__pmw_get_available_package_name_by_command_name_pacman "$1") ;;
        mingw64) __mingw_w64_x86_64 $(__pmw_get_available_package_name_by_command_name_pacman "$1") ;;
        *) __pmw_get_available_package_name_by_command_name_pacman "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_xbps() {
    case $1 in
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
    realpath) echo 'coreutils';;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    pip|pip3) echo "python3-pip" ;;
    rst2man|rst2html)
              echo "python3-docutils" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_apk() {
    case $1 in
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
    realpath) echo 'coreutils';;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    pip3|pip) echo 'py3-pip' ;;
    rst2man|rst2html)
              echo "py3-docutils" ;;
    sphinx-build)
              echo "sphinx"  ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    pkg-config) echo "pkgconf"  ;;
        *) echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_zypper() {
    case $1 in
          cc) echo 'gcc'   ;;
         c++) echo 'gcc-g++';;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
    realpath) echo 'coreutils';;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
      rst2man|rst2html)
              echo "python3-docutils" ;;
    sphinx-build)
              echo "python3-Sphinx" ;;
    pip3|pip) echo "python3-pip" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_dnf() {
    case $1 in
          go) echo 'golang';;
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
    realpath) echo 'coreutils';;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
      rst2man|rst2html)
              echo "python3-docutils" ;;
    sphinx-build)
              echo "python3-sphinx" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_yum() {
    case $1 in
          go) echo 'golang';;
          cc) echo 'gcc'   ;;
         c++) echo 'gcc-g++';;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
    realpath) echo 'coreutils';;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    sphinx-build) echo "python-sphinx" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_apt_get() {
    __pmw_get_available_package_name_by_command_name_apt $@
}

__pmw_get_available_package_name_by_command_name_apt() {
    case $1 in
          go) echo 'golang';;
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
        xz)   echo 'xz-utils' ;;
     objcopy) echo 'binutils' ;;
    realpath) echo 'coreutils';;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
    pip3|pip) echo "python3-pip" ;;
    rst2man|rst2html)
              echo "python3-docutils" ;;
    sphinx-build)
              echo "python3-sphinx" ;;
    grpc_cpp_plugin)
              echo "libgrpc" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
        ninja)
            if [ "$NATIVE_OS_SUBS" = termux ] ; then
                echo ninja
            else
                echo ninja-build
            fi
            ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_brew() {
    case $1 in
          cc) echo 'gcc'   ;;
         c++) echo 'g++'   ;;
     clang++) echo 'clang' ;;
         gm4) echo 'm4'    ;;
        gsed) echo 'gnu-sed'  ;;
        find) echo 'findutils';;
        diff) echo 'diffutils';;
     objcopy) echo 'binutils' ;;
    realpath) echo 'coreutils';;
  7z|7za|7zr) echo 'p7zip' ;;
      protoc) echo 'protobuf' ;;
      ps2pdf) echo "ghostscript" ;;
     rst2man.py|rst2html.py)
              echo "docutils" ;;
    grpc_cpp_plugin)
                echo "grpc" ;;
    glibtool|libtoolize|glibtoolize)
                echo "libtool"  ;;
    autoreconf) echo "autoconf" ;;
    autoheader) echo "automake" ;;
    autopoint)  echo "gettext"  ;;
    python|python3)
                echo 'python@3.9' ;;
        *)      echo "$1"
    esac
}

__pmw_get_available_package_name_by_command_name_pip3() {
    __pmw_get_available_package_name_by_command_name_pip $@
}

__pmw_get_available_package_name_by_command_name_pip() {
    case $1 in
        sphinx-build) echo "sphinx"   ;;
        rst2man.py)   echo "docutils" ;;
        meson)        echo "meson" ;;
    esac
}

__pmw_get_available_pm_list() {
    for pm in brew pkg apt apt-get dnf yum zypper apk xbps emerge pacman choco pkgin pkg_add
    do
        case $pm in
            apt)
                if command_exists_in_filesystem apt && apt show apt > /dev/null 2>&1 ; then
                    printf '%s\n' apt
                fi
                ;;
            xbps)
                if command_exists_in_filesystem xbps-install ; then
                    printf '%s\n' xbps
                fi
                ;;
            *)
                if command_exists_in_filesystem "$pm" ; then
                    printf '%s\n' "$pm"
                fi
        esac
    done
}

# __pmw_install_the_given_package <PM> <PKG> [OP VERSION]
# __pmw_install_the_given_package apt make ge 3.80
# __pmw_install_the_given_package apt make
__pmw_install_the_given_package() {
    if [ -z "$2" ] ; then
        return 1
    fi

    __pmw_is_package_available $@ || return 1

    case $1 in
        pip3)
            case $NATIVE_OS_KIND in
                *bsd|linux) run pip3 install --user -U "$2" ;;
                *)          run pip3 install        -U "$2"
            esac
            ;;
        pip)
            case $NATIVE_OS_KIND in
                *bsd|linux) run pip  install --user -U "$2" ;;
                *)          run pip  install        -U "$2"
            esac
            ;;
        brew)
            if run brew install "$2" ; then
                if [ "$(brew info --json=v2 "$2" | grep keg_only | sed 's/ //g' | cut -d: -f2 | sed 's/,//')" = 'true' ] ; then
                    if [ -d "$(brew --prefix "$2")/bin" ] ; then
                        export PATH="$(brew --prefix "$2")/bin:$PATH"
                    fi
                fi
            else
                return 1
            fi
            ;;
        pkg)     run $sudo pkg install -y "$2" ;;
        pkgin)   run $sudo pkgin -y install "$2" ;;
        pkg_add) run $sudo pkg_add "$2" ;;
        apt)     run $sudo apt     -y install "$2" ;;
        apt-get) run $sudo apt-get -y install "$2" ;;
        dnf)     run $sudo dnf -y install "$2" ;;
        yum)     run $sudo yum -y install "$2" ;;
        zypper)  run $sudo zypper install -y "$2" ;;
        apk)     run $sudo apk add "$2" ;;
        xbps)    run $sudo xbps-install -Sy "$2" ;;
        emerge)  run $sudo emerge "$2" ;;
        pacman)  run $sudo pacman -Syy --noconfirm && run $sudo pacman -S --noconfirm "$2" ;;
        choco)   run choco install -y --source cygwin "$2" ;;
    esac
    echo
}

# __pmw_install_the_given_command <PM> <PKG> <CMD> [OP VERSION]
# __pmw_install_the_given_command apt make make ge 3.80
# __pmw_install_the_given_command apt make make
__pmw_install_the_given_command() {
    if [ "$1" = available ] ; then
        if command_exists_in_filesystem_and_version_matched $3 $4 $5 ; then
            return 0
        fi

        if [ -z "$AVAILABLE_PACKAGE_MANAGER_LIST" ] ; then
            AVAILABLE_PACKAGE_MANAGER_LIST=$(__pmw_get_available_pm_list | tr '\n' ' ')
            if [ -z "$AVAILABLE_PACKAGE_MANAGER_LIST" ] ; then
                warn "no package manager found."
                return 1
            else
                info "Found $(list_length $AVAILABLE_PACKAGE_MANAGER_LIST) package manager : ${COLOR_GREEN}$AVAILABLE_PACKAGE_MANAGER_LIST${COLOR_OFF}"
            fi
        fi

        for pm in $AVAILABLE_PACKAGE_MANAGER_LIST
        do
            if __pmw_install_the_given_command "$pm" "$(eval __pmw_get_available_package_name_by_command_name_$(printf '%s\n' "$pm" | tr - _) $3)" "$3" $4 $5 ; then
                return 0
            fi
        done
        return 1
    else
        if [ -z "$2" ] ; then
            # if pacmakge name is empty, assume command name is equal to package name.
            __pmw_is_package_available "$1" "$3" $4 $5 || return 1
            note "${COLOR_GREEN}$(shiftn 1 $@)${COLOR_OFF} ${COLOR_YELLOW}command is required, but it is not found, I will install it via${COLOR_OFF} ${COLOR_GREEN}$1${COLOR_OFF}"
            __pmw_install_the_given_package "$1" "$3" $4 $5
        else
            __pmw_is_package_available "$1" "$2" $4 $5 || return 1
            note "${COLOR_GREEN}$(shiftn 2 $@)${COLOR_OFF} ${COLOR_YELLOW}command is required, but it is not found, I will install it via${COLOR_OFF} ${COLOR_GREEN}$1${COLOR_OFF}"
            __pmw_install_the_given_package "$1" "$2" $4 $5
        fi
    fi
}

# __install_command_via_fetch_prebuild_binary <URL> <CMD> [OP VERSION]
# __install_command_via_fetch_prebuild_binary <URL> python3 ge 3.5
# __install_command_via_fetch_prebuild_binary <URL> make
__install_command_via_fetch_prebuild_binary() {
    if [ -z "$1" ] ; then
        return 1
    fi

    note "${COLOR_GREEN}$(shiftn 1 $@)${COLOR_OFF} ${COLOR_YELLOW}command is required, but it is not found, I will install it via${COLOR_OFF} ${COLOR_GREEN}fetch prebuild binary${COLOR_OFF}"

    unset PREBUILD_BINARY_FILENAME
    unset PREBUILD_BINARY_FILEPATH

    PREBUILD_BINARY_FILENAME=$(basename "$1")

    if [ -z "$PREBUILD_BINARY_INSTALL_PREFIX_DIR" ] ; then
        PREBUILD_BINARY_INSTALL_PREFIX_DIR='/opt'
    fi

    unset PREBUILD_BINARY_INSTALL_DIR
    PREBUILD_BINARY_INSTALL_DIR="$PREBUILD_BINARY_INSTALL_PREFIX_DIR/$PREBUILD_BINARY_FILENAME.d"

    PREBUILD_BINARY_FILEPATH="$PREBUILD_BINARY_INSTALL_DIR/$PREBUILD_BINARY_FILENAME"

    if [ -d "$PREBUILD_BINARY_INSTALL_PREFIX_DIR" ] ; then
        if [ -d "$PREBUILD_BINARY_INSTALL_DIR" ] ; then
            if [ -r "$PREBUILD_BINARY_INSTALL_DIR" ] && [ -w "$PREBUILD_BINARY_INSTALL_DIR" ] && [ -x "$PREBUILD_BINARY_INSTALL_DIR" ] ; then
                rm -rf "$PREBUILD_BINARY_INSTALL_DIR" || return 1
                install -o $(whoami) -d "$PREBUILD_BINARY_INSTALL_DIR" || return 1
            else
                sudo rm -rf "$PREBUILD_BINARY_INSTALL_DIR" || return 1
                sudo install -o $(whoami) -d "$PREBUILD_BINARY_INSTALL_DIR" || return 1
            fi
        else
            if [ -r "$PREBUILD_BINARY_INSTALL_PREFIX_DIR" ] && [ -w "$PREBUILD_BINARY_INSTALL_PREFIX_DIR" ] && [ -x "$PREBUILD_BINARY_INSTALL_PREFIX_DIR" ] ; then
                     install -o $(whoami) -d "$PREBUILD_BINARY_INSTALL_DIR" || return 1
            else
                sudo install -o $(whoami) -d "$PREBUILD_BINARY_INSTALL_DIR" || return 1
            fi
        fi
    else
        if [ -r / ] && [ -w / ] && [ -x / ] ; then
                 install -o $(whoami) -d "$PREBUILD_BINARY_INSTALL_DIR" || return 1
        else
            sudo install -o $(whoami) -d "$PREBUILD_BINARY_INSTALL_DIR" || return 1
        fi
    fi

    fetch "$1" --output-dir="$PREBUILD_BINARY_INSTALL_DIR" --output-name="$PREBUILD_BINARY_FILENAME" || return 1

    case $1 in
        *.zip)
            handle_dependency required exe unzip
            ;;
        *.tar.xz)
            handle_dependency required exe tar
            handle_dependency required exe xz
            ;;
        *.tar.gz)
            handle_dependency required exe tar
            handle_dependency required exe gzip
            ;;
        *.tar.lz)
            handle_dependency required exe tar
            handle_dependency required exe lzip
            ;;
        *.tar.bz2)
            handle_dependency required exe tar
            handle_dependency required exe bzip2
            ;;
        *.tgz)
            handle_dependency required exe tar
            handle_dependency required exe gzip
            ;;
        *.txz)
            handle_dependency required exe tar
            handle_dependency required exe xz
    esac

    unset PREBUILD_BINARY_FILENAME
    unset PREBUILD_BINARY_FILEPATH

    PREBUILD_BINARY_FILENAME=$(basename "$1")

    if [ -z "$PREBUILD_BINARY_INSTALL_PREFIX_DIR" ] ; then
        PREBUILD_BINARY_INSTALL_PREFIX_DIR='/opt'
    fi

    unset PREBUILD_BINARY_INSTALL_DIR
    PREBUILD_BINARY_INSTALL_DIR="$PREBUILD_BINARY_INSTALL_PREFIX_DIR/$PREBUILD_BINARY_FILENAME.d"

    PREBUILD_BINARY_FILEPATH="$PREBUILD_BINARY_INSTALL_DIR/$PREBUILD_BINARY_FILENAME"

    case $1 in
        *.zip)
            run unzip  "$PREBUILD_BINARY_FILEPATH" -d "$PREBUILD_BINARY_INSTALL_DIR" || return 1 ;;
        *.tar.xz|*.tar.gz|*.tar.lz|*.tar.bz2|*.tgz|*.txz|*.tlz)
            run tar xf "$PREBUILD_BINARY_FILEPATH" -C "$PREBUILD_BINARY_INSTALL_DIR" --strip-components 1 || return 1 ;;
    esac

    if [ -d "$PREBUILD_BINARY_INSTALL_DIR/bin" ] ; then
        export PATH="$PREBUILD_BINARY_INSTALL_DIR/bin:$PATH"
    fi

    export PATH="$PREBUILD_BINARY_INSTALL_DIR:$PATH"

    case $2 in
        autoconf)
            for xx in $(grep '/root/.zpkg/install.d/autoconf' -rl "$PREBUILD_BINARY_INSTALL_DIR")
            do
                sed_in_place "s|/root/.zpkg/install.d/autoconf|$PREBUILD_BINARY_INSTALL_DIR|" "$xx"
            done
            ;;
    esac
}

# __get_prebuild_binary_fetch_url_by_command_name <CMD> [OP VERSION]
# __get_prebuild_binary_fetch_url_by_command_name python3 ge 3.5
# __get_prebuild_binary_fetch_url_by_command_name cmake
__get_prebuild_binary_fetch_url_by_command_name() {
    # https://github.com/leleliu008/python-prebuild
    # https://cmake.org/download
{
    cat <<EOF
python    |glibc|linux |x86_64|https://github.com/leleliu008/python-prebuild/releases/download/3.9.5/python-3.9.5-x86_64-linux-glibc.tar.xz
python3   |glibc|linux |x86_64|https://github.com/leleliu008/python-prebuild/releases/download/3.9.5/python-3.9.5-x86_64-linux-glibc.tar.xz
git       |glibc|linux |x86_64|https://github.com/leleliu008/git-prebuild/releases/download/2.30.2/git-2.30.2-x86_64-linux-glibc.tar.xz
autoconf  |glibc|linux |x86_64|https://github.com/leleliu008/autoconf-prebuild/releases/download/2.69/autoconf-2.69-glibc-linux-x86_64.tar.gz
autoreconf|glibc|linux |x86_64|https://github.com/leleliu008/autoconf-prebuild/releases/download/2.69/autoconf-2.69-glibc-linux-x86_64.tar.gz
cmake     |glibc|linux |x86_64|https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-linux-x86_64.tar.gz
cmake     |     |darwin|      |https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-macos-universal.tar.gz
ninja     |     |linux |x86_64|https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-linux.zip
ninja     |     |darwin|x86_64|https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-mac.zip
go        |     |linux |x86_64|https://golang.org/dl/go1.17.2.linux-arm64.tar.gz
go        |     |darwin|x86_64|https://golang.org/dl/go1.17.2.darwin-amd64.tar.gz
go        |     |darwin|arm64 |https://golang.org/dl/go1.17.2.darwin-arm64.tar.gz
EOF
} | while read LINE
    do
        LINE=$(printf '%s' "$LINE" | sed 's/[[:space:]]//g')

        unset __PB_COMMAND__
        unset __PB_OS_LIBC__
        unset __PB_OS_KIND__
        unset __PB_OS_ARCH__
        unset __PB_URL__

        __PB_COMMAND__=$(printf '%s' "$LINE" | cut -d '|' -f1)

        if [ "$__PB_COMMAND__" != "$1" ] ; then
            continue
        fi

        __PB_OS_LIBC__=$(printf '%s' "$LINE" | cut -d '|' -f2)

        if [ -n "$__PB_OS_LIBC__" ] && [ "$__PB_OS_LIBC__" != "$NATIVE_OS_LIBC" ] ; then
            continue
        fi

        __PB_OS_KIND__=$(printf '%s' "$LINE" | cut -d '|' -f3)

        if [ "$__PB_OS_KIND__" != "$NATIVE_OS_KIND" ] ; then
            continue
        fi

        __PB_OS_ARCH__=$(printf '%s' "$LINE" | cut -d '|' -f4)

        if [ -n "$__PB_OS_ARCH__" ] && [ "$__PB_OS_ARCH__" != "$NATIVE_OS_ARCH" ] ; then
            continue
        fi

        __PB_URL__=$(printf '%s' "$LINE" | cut -d '|' -f5)

        echo "$__PB_URL__"
    done
}

__install_command_via_run_install_script() {
    case $1 in
        rustup)
            # https://www.rust-lang.org/tools/install
            note "${COLOR_GREEN}$1${COLOR_OFF} ${COLOR_YELLOW}command is required, but it is not found, I will install it via running shell script.${COLOR_OFF}"

            handle_dependency required exe bash:zsh

            fetch 'https://sh.rustup.rs' --pipe="$(command -v bash || command -v zsh || command -v dash || command -v ash || echo sh)"

            export CARGO_HOME=$HOME/.cargo
            export PATH="$CARGO_HOME/bin:$PATH"
            ;;
        nvm)
            # https://github.com/nvm-sh/nvm
            note "${COLOR_GREEN}$1${COLOR_OFF} ${COLOR_YELLOW}command is required, but it is not found, I will install it via running bash shell script.${COLOR_OFF}"

            handle_dependency required exe bash:zsh

	        fetch "$(github_user_content_base_url)/nvm-sh/nvm/master/install.sh" --pipe="$(command -v bash || command -v zsh || echo bash)"

	        export NVM_DIR="${HOME}/.nvm"
	        . "${HOME}/.nvm/nvm.sh"
            ;;
        *)  return 1
    esac
}

__install_command_via_pip() {
    if [ -z "$(__pmw_get_available_package_name_by_command_name_pip3 "$1")" ] ; then
        return 1
    fi

    handle_dependency required exe pip3:pip

    (
        unset __PIP_COMMAND__
        __PIP_COMMAND__="$(command -v pip3.8)"

        if [ -n "$__PIP_COMMAND__" ] && [ -d '/usr/local/bin' ] ; then
            $sudo ln -sf "$__PIP_COMMAND__" /usr/local/bin/pip3
        fi
    )

    if   command_exists_in_filesystem pip3 ; then
        __pmw_install_the_given_package pip3 "$(__pmw_get_available_package_name_by_command_name_pip3 "$1")"
    elif command_exists_in_filesystem pip ; then
        __pmw_install_the_given_package pip  "$(__pmw_get_available_package_name_by_command_name_pip "$1")"
    else
        return 1
    fi
}

# __install_command <CMD> [OP VERSION]
# __install_command python3 ge 3.5
# __install_command make
__install_command() {
    if command_exists_in_filesystem_and_version_matched $@ ; then
        return 0
    fi

    if __install_command_via_run_install_script $@ ; then
        return 0
    fi

    if __install_command_via_pip $@ ; then
        return 0
    fi

    if __pmw_install_the_given_command available available $@ ; then
        return 0
    fi

    if __install_command_via_fetch_prebuild_binary "$(__get_prebuild_binary_fetch_url_by_command_name "$1")" $@ ; then
        return 0
    fi

    warn "${COLOR_GREEN}$@${COLOR_OFF} ${COLOR_YELLOW}command is required, but I found no way to install it.${COLOR_OFF}\n"
    return 1
}

# examples:
# handle_dependency required exe   pkg-config ge 0.18
# handle_dependency required exe   python     ge 3.5
# handle_dependency required py    libxml2    ge 2.19
#
# handle_dependency optional exe   pkg-config ge 0.18
# handle_dependency optional exe   python     ge 3.5
# handle_dependency optional py    libxml2    ge 2.19
handle_dependency() {
    [ "$1" = 'required' ] || return 0

    shift

    case $1 in
        exe)
            shift
            case $1 in
                *:*)
                    for command in $(echo "$1" | tr ':' ' ')
                    do
                        if command_exists_in_filesystem_and_version_matched "$command" $2 $3 ; then
                            map_set MAP_REQUIRED_DEPENDENCIES "$1" "$command"
                            return 0
                        fi
                    done
                    for command in $(echo "$1" | tr ':' ' ')
                    do
                        if __install_command "$command" $2 $3 ; then
                            map_set MAP_REQUIRED_DEPENDENCIES "$1" "$command"
                            return 0
                        fi
                    done
                    return 1
                    ;;
                *)  __install_command $@
            esac
            ;;
        py)
            shift
            python_module install "$1"
            ;;
        pm)
            shift
            perl_module install "$1"
            ;;
        *) die "handle_dependency() unrecognized argument:$1"
    esac
}

__handle_required_dependencies() {
    step "handle required dependencies"

    for dependency in $REQUIRED_DEPENDENCY_LIST
    do
        handle_dependency $(__decode_dependency "$dependency") || return 1
    done
}

# }}}
##############################################################################
# {{{ __printf_dependencies

# examples:
# __printf_dependency required exe   pkg-config ge 0.18
# __printf_dependency required exe   python     ge 3.5
# __printf_dependency required py    libxml2    ge 2.19
#
# __printf_dependency optional exe   pkg-config ge 0.18
# __printf_dependency optional exe   python     ge 3.5
# __printf_dependency optional py    libxml2    ge 2.19
__printf_dependency() {
    printf "%-10s %-15s %-2s %-10s %-10s %s\n" "$1" "$2" "$3" "$4" "$5" "$6"
}

# examples:
# printf_dependency required exe   pkg-config ge 0.18
# printf_dependency required exe   python     ge 3.5
# printf_dependency required py    libxml2    ge 2.19
#
# printf_dependency optional exe   pkg-config ge 0.18
# printf_dependency optional exe   python     ge 3.5
# printf_dependency optional py    libxml2    ge 2.19
printf_dependency() {
    case $2 in
        exe)
            case $3 in
                *:*)
                    if [ "$1" = 'required' ] ; then
                        REQUIRED_ITEM="$(map_get MAP_REQUIRED_DEPENDENCIES "$3")"
                        __printf_dependency "$2" "$REQUIRED_ITEM" "$4" "$5" "$(version_of_command $REQUIRED_ITEM)" "$(command -v $REQUIRED_ITEM)"
                    else
                        for item in $(echo "$3" | tr ':' ' ')
                        do
                            __printf_dependency "$2" "$item" "$4" "$5" "$(version_of_command $item)" "$(command -v $item)"
                        done
                    fi
                    ;;
                *)  __printf_dependency "$2" "$3" "$4" "$5" "$(version_of_command $3)" "$(command -v $3)"
            esac
            ;;
        py)
            __printf_dependency "$2" "$3" "$4" "$5" "$(python_module get version "$item")" "$(python_module get location "$item")"
            ;;
        pm)
            __printf_dependency "$2" "$3" "$4" "$5" "$(perl_module get version "$item")" "$(perl_module get location "$item")"
            ;;
        *)  die "printf_dependency() unrecognized argument: $2"
    esac
}

__printf_required_dependencies() {
    step "printf required dependencies"
    if [ -z "$REQUIRED_DEPENDENCY_LIST" ] ; then
        note "no required dependencies."
    else
        __printf_dependency TYPE NAME OP EXPECT ACTUAL LOCATION
        for dependency in $REQUIRED_DEPENDENCY_LIST
        do
            printf_dependency $(__decode_dependency "$dependency")
        done
    fi
}

__printf_optional_dependencies() {
    step "printf optional dependencies"
    if [ -z "$OPTIONAL_DEPENDENCY_LIST" ] ; then
        note "no optional dependencies."
    else
        __printf_dependency TYPE NAME OP EXPECT ACTUAL LOCATION
        for dependency in $OPTIONAL_DEPENDENCY_LIST
        do
            printf_dependency $(__decode_dependency "$dependency")
        done
    fi
}

# }}}
##############################################################################
# {{{ python_module

# examples:
# python_module is  installed libxml2
# python_module get version   libxml2
# python_module get location  libxml2
# python_module install       libxml2
python_module() {
    case $1 in
        is)
            [ $# -eq 3 ] || die "[python_module is] command accept 2 arguments."

            handle_dependency required exe python3:python3.9:python3.8:python3.7:python3.6:python3.5:python
            handle_dependency required exe pip3:pip3.9:pip3.8:pip3.7:pip3.6:pip3.5:pip

            __PYTHON_COMMAND__=$(command -v python3 || command -v python3.9 || command -v python3.8 || command -v python3.7 || command -v python3.6 || command -v python3.5 || command -v python || echo python)
            __PIP_COMMAND__=$(command -v pip3 || command -v pip3.9 || command -v pip3.8 || command -v pip3.7 || command -v pip3.6 || command -v pip3.5 || command -v pip || echo pip)

            case $2 in
                installed)  "$__PYTHON_COMMAND__" -c "import $3" 2> /dev/null ;;
                *) die "python_module is $2: not support."
            esac
            ;;
        get)
            [ $# -eq 3 ] || die "[python_module get] command accept 2 arguments."

            handle_dependency required exe python3:python3.9:python3.8:python3.7:python3.6:python3.5:python
            handle_dependency required exe pip3:pip3.9:pip3.8:pip3.7:pip3.6:pip3.5:pip

            __PYTHON_COMMAND__=$(command -v python3 || command -v python3.9 || command -v python3.8 || command -v python3.7 || command -v python3.6 || command -v python3.5 || command -v python || echo python)
            __PIP_COMMAND__=$(command -v pip3 || command -v pip3.9 || command -v pip3.8 || command -v pip3.7 || command -v pip3.6 || command -v pip3.5 || command -v pip || echo pip)

            case $2 in
                version)  "$__PIP_COMMAND__" show "$3" 2> /dev/null | grep 'Version:'  | cut -d ' ' -f2 ;;
                location) "$__PIP_COMMAND__" show "$3" 2> /dev/null | grep 'Location:' | cut -d ' ' -f2 ;;
                *) die "python_module get $2: not support."
            esac
            ;;
        install)
            if [ -z "$2" ] ; then
                die "please specify a python module name."
            fi
            if ! python_module is installed "$2" ; then
                note "${COLOR_GREEN}$2${COLOR_OFF} ${COLOR_YELLOW}python module is required, but it is not found, I will install it via${COLOR_OFF} ${COLOR_GREEN}$__PIP_COMMAND__${COLOR_OFF}"
                run "$__PIP_COMMAND__" install -U pip  || return 1
                run "$__PIP_COMMAND__" install -U "$2" || return 1
            fi
            ;;
        *)  die "python_module $1: not support."
    esac
}

# }}}
##############################################################################
# {{{ perl_module

# examples:
# perl_module is  installed libxml2
# perl_module get version   libxml2
# perl_module get location  libxml2
# perl_module install       libxml2
perl_module() {
    case $1 in
        is)
            [ $# -eq 4 ] || die "perl_module command accept 4 arguments."
            handle_dependency required exe perl
            case $2 in
                installed)  perl -M"$3" -le 'print "installed"' > /dev/null 2>&1 ;;
                *) die "perl_module is $2: not support."
            esac
            ;;
        get)
            ;;
        install)
            if ! perl_module is installed "$3" ; then
                handle_dependency required exe cpan:cpanm
                if   command_exists_in_filesystem cpan  ; then
                    cpan -i "$3"
                elif command_exists_in_filesystem cpanm ; then
                    cpanm "$3"
                else
                    die "no perl module installer found."
                fi
            fi
            ;;
        *)  die "perl_module $1: not support."
    esac
}

# }}}
##############################################################################
# {{{ encode/decode dependency

__encode_dependency() {
    if [ $# -eq 0 ] ; then
        tr ' ' '|'
    else
        printf "%s" "$*" | tr ' ' '|'
    fi
}

__decode_dependency() {
    if [ $# -eq 0 ] ; then
        tr '|' ' '
    else
        printf "%s" "$*" | tr '|' ' '
    fi
}

# }}}
##############################################################################
# {{{ regist dependency

# regist dependency required|optional exe|lib|dev|py|pm|pip|npm|gem|pub|cargo|go NAME
#
# required this is a required dependency
# optional this is a optional dependency
#
# exe  this dependency is a command
# py   this dependency is a python  module
# py2  this dependency is a python2 module
# py3  this dependency is a python3 module
# pm   this dependency is a perl module
#
# gt VERSION
# ge VERSION
# lt VERSION
# le VERSION
# eq VERSION
# ne VERSION
#
# examples:
# regist_dependency required exe pkg-config ge 0.18
# regist_dependency required exe python     ge 3.5
# regist_dependency required py  libxml2    ge 2.19
#
# regist_dependency optional exe pkg-config ge 0.18
# regist_dependency optional exe python     ge 3.5
# regist_dependency optional py  libxml2    ge 2.19
regist_dependency() {
    case $1 in
        required)
            if [ -z "$REQUIRED_DEPENDENCY_LIST" ] ; then
                REQUIRED_DEPENDENCY_LIST="$(__encode_dependency "$*")"
            else
                REQUIRED_DEPENDENCY_LIST="$REQUIRED_DEPENDENCY_LIST $(__encode_dependency "$*")"
            fi
            ;;
        optional)
            if [ -z "$OPTIONAL_DEPENDENCY_LIST" ] ; then
                OPTIONAL_DEPENDENCY_LIST=$(__encode_dependency "$*")
            else
                OPTIONAL_DEPENDENCY_LIST="$OPTIONAL_DEPENDENCY_LIST $(__encode_dependency "$*")"
            fi
    esac
}

# }}}
##############################################################################
# {{{ main

main() {
    set -e

    case $1 in
        -h|--help)
            cat <<EOF

Usage:
./setup.sh -h | --help             -- show help    of this command
./setup.sh -V | --version          -- show version of this command

./setup.sh [-x | --china]          -- perform install process

./setup.sh upgrade-self            -- update to date

EOF
            return 0
            ;;
        -V|--version)
            echo '1.0.0'
            return 0
            ;;
        upgrade-self)
            __upgrade_self 'https://raw.githubusercontent.com/leleliu008/oh-my-vim/master/setup.sh'
            return 0
            ;;
    esac

    unset CHINA

    while [ -n "$1" ]
    do
        case $1 in
	    -x)      set -x ;;
	    --china) CHINA=true ;;
	    *)       die "unrecognized option: $1"
        esac
	shift
    done

    github_base_url() {
        if [ "$CHINA" = true ] ; then
            echo 'https://github.com.cnpmjs.org'
	    else
            echo 'https://github.com'
	    fi
    }

    github_user_content_base_url() {
        if [ "$CHINA" = true ] ; then
            echo 'https://raw.githubusercontents.com'
	    else
            echo 'https://raw.githubusercontent.com'
	    fi
    }

    unset STEP_NUM
    unset STEP_MESSAGE

    unset NATIVE_OS_KIND
    unset NATIVE_OS_TYPE
    unset NATIVE_OS_NAME
    unset NATIVE_OS_VERS
    unset NATIVE_OS_ARCH
    unset NATIVE_OS_NCPU
    unset NATIVE_OS_LIBC
    unset NATIVE_OS_SUBS

    unset PREBUILD_BINARY_INSTALL_PREFIX_DIR
    PREBUILD_BINARY_INSTALL_PREFIX_DIR='/opt'

    # pip install --user <PKG>
    export PATH="$HOME/.local/bin:$PATH"

    if [ -d "$PREBUILD_BINARY_INSTALL_PREFIX_DIR" ] ; then
        for item in $(ls "$PREBUILD_BINARY_INSTALL_PREFIX_DIR")
        do
            if [ -d "$PREBUILD_BINARY_INSTALL_PREFIX_DIR/$item/bin" ] ; then
                export PATH="$PREBUILD_BINARY_INSTALL_PREFIX_DIR/$item/bin:$PATH"
            fi
        done
    fi

    step "handle essential tools"
    install_ca_certificates_on_netbsd
    regist_dependency required exe gsed:sed
    regist_dependency required exe grep
    for dependency in $REQUIRED_DEPENDENCY_LIST
    do
        handle_dependency $(__decode_dependency "$dependency") || return 1
    done

    NATIVE_OS_KIND=$(os kind)
    NATIVE_OS_TYPE=$(os type)
    NATIVE_OS_NAME=$(os name)
    NATIVE_OS_VERS=$(os vers)
    NATIVE_OS_NCPU=$(os ncpu)
    NATIVE_OS_ARCH=$(os arch)
    NATIVE_OS_LIBC=$(os libc)
    NATIVE_OS_SUBS=$(os subs)

    step "show current machine os info"
    cat <<EOF
NATIVE_OS_KIND  = $NATIVE_OS_KIND
NATIVE_OS_TYPE  = $NATIVE_OS_TYPE
NATIVE_OS_NAME  = $NATIVE_OS_NAME
NATIVE_OS_VERS  = $NATIVE_OS_VERS
NATIVE_OS_ARCH  = $NATIVE_OS_ARCH
NATIVE_OS_NCPU  = $NATIVE_OS_NCPU
NATIVE_OS_LIBC  = $NATIVE_OS_LIBC
NATIVE_OS_SUBS  = $NATIVE_OS_SUBS
EOF

    step "show current machine os effective user info"
    id | tr ' ' '\n' | head -n 2

    step "show PATH"
    for item in $(echo "$PATH" | tr ' ' '|' | tr ':' ' ')
    do
        echo "$item" | tr '|' ' '
    done

    if [ -z "$NATIVE_OS_SUBS" ] ; then
        [ "$(whoami)" = root ] || sudo=sudo
    fi

    regist_dependency required exe git
    regist_dependency required exe curl
    regist_dependency required exe python3:python3.9:python3.8:python3.7:python3.6:python ge 3.6.0
    regist_dependency required exe clang
    regist_dependency required exe clang++
    regist_dependency required exe cmake ge 3.14
    regist_dependency required exe ninja:make:gmake
    regist_dependency required exe go
    regist_dependency required exe tar
    regist_dependency required exe gzip

    step "handle required tools"
    __handle_required_dependencies
    __printf_required_dependencies
    __printf_optional_dependencies

    if [ -z "$AVAILABLE_PACKAGE_MANAGER_LIST" ] ; then
        AVAILABLE_PACKAGE_MANAGER_LIST=$(__pmw_get_available_pm_list | tr '\n' ' ')
    fi
    for pm in $AVAILABLE_PACKAGE_MANAGER_LIST
    do
        case $pm in
            apt|apt-get|apk|xbps)
               __pmw_install_the_given_package "$pm" python3-dev && break
               ;;
        esac
    done

    PYTHON=$(command -v python3 || command -v python3.9 || command -v python3.8 || command -v python3.7 || command -v python3.6 || command -v python3.5 || command -v python)

    command -v npm  > /dev/null || {
        command -v nvm > /dev/null || {
            step "install nvm"
            handle_dependency required exe nvm
	    }
    	step "install node.js v16.9.0"
        unset PREFIX
    	run nvm install v16.9.0
    }

    if [ "$CHINA" = true ] && [ "$(npm config get registry)" = "https://registry.npmjs.org/" ] ; then
        step "set npm registry to chinese mirror"
        run npm config set registry "https://registry.npm.taobao.org/"
    fi

    step "install vim-plug"
    run install -d $HOME/.vim/autoload
    fetch $(github_user_content_base_url)/junegunn/vim-plug/master/plug.vim --output-dir=$HOME/.vim/autoload

    step "install YouCompleteMe"

    VIM_PLUGIN_DIR="$HOME/.vim/bundle"
    if [ ! -d "$VIM_PLUGIN_DIR" ] ; then
        run install -d "$VIM_PLUGIN_DIR"
    fi

    YCM_INSTALL_DIR="$VIM_PLUGIN_DIR/YouCompleteMe"
    if [ -d "$YCM_INSTALL_DIR" ] ; then
        run chmod -R +w "$YCM_INSTALL_DIR"
        run rm -rf "$YCM_INSTALL_DIR"
    fi
  
    export GOPATH=$YCM_INSTALL_DIR/go
    export GO111MODULE=on
    if [ "$CHINA" = true ] ; then
        export GOPROXY='https://goproxy.io'
    fi

    run git clone --recursive "$(github_base_url)/ycm-core/YouCompleteMe.git" "$YCM_INSTALL_DIR"

    run cd "$YCM_INSTALL_DIR"

    if [ -d third_party/python-future/docs/notebooks/ ] ; then
        run rm -rf third_party/python-future/docs/notebooks/
    fi
    if [ -d third_party/ycmd/third_party/python-future/docs/notebooks/ ] ; then
        run rm -rf third_party/ycmd/third_party/python-future/docs/notebooks/
    fi

    if [ "$CHINA" = true ] ; then
        sed_in_place 's/github\.com/github.com.cnpmjs.org/g' $(grep 'github.com' -rl .)
        sed_in_place "s@download.eclipse.org@mirrors.ustc.edu.cn/eclipse@g" ./third_party/ycmd/build.py
    fi

    YCM_INSTALL_ARGS="--clang-completer --ts-completer --go-completer"

    command -v java > /dev/null && {
        YCM_INSTALL_ARGS="$YCM_INSTALL_ARGS --java-completer"
    }

    command -v ninja > /dev/null && {
        YCM_INSTALL_ARGS="$YCM_INSTALL_ARGS --ninja"
    }

    step "compile YouCompleteMe"
    run $PYTHON install.py $YCM_INSTALL_ARGS

    VIMRC="$HOME/.vimrc"

    [ -f "$VIMRC" ] && {
        step "backup $VIMRC"
        run mv "$VIMRC" "$VIMRC.$(date +%s)"
    }

    step "create new $VIMRC"
    if [ -f "$CURRENT_SCRIPT_DIR/vimrc" ] ; then
        run cp "$CURRENT_SCRIPT_DIR/vimrc" "$VIMRC"
    else
        fetch "$(github_user_content_base_url)/leleliu008/oh-my-vim/master/vimrc" --output-path=$VIMRC
    fi

    sed_in_place "s|/usr/local/bin/python|$PYTHON|g" "$VIMRC"

    [ -e ~/.ycm_extra_conf.py ] || {
        step "create ~/.ycm_extra_conf.py"
        cp "$YCM_INSTALL_DIR/third_party/ycmd/.ycm_extra_conf.py" ~/.ycm_extra_conf.py
    }

    echo
    success "All Done. open vim and run :PlugInstall command to install vim plugins!"
}

main $@
