#!/bin/bash - 
# This script has been tested only on Debian and macOS. You are recommended to use a Debian-like Linux dist or macOS.

set -o nounset                              # Treat unset variables as an error

VERSION=130.0.6722.0
NTHREADS=32 # Number of *gclient sync* threads
BUILD_DIR=Observer # Change this if you want to build at a different directory, e.g., Release
PATCH_DIR="patch" # Change this if you put the .patch files at a different directory



is_darwin=0
is_linux=0
UNAME=$(uname)
case $UNAME in
    "Darwin") is_darwin=1;;
    "Linux") is_linux=1;;
esac

# HELP
print_help ()
{
  echo "Usage : ./build_chromium.sh options"
  echo "  e.g., ./build_chromium.sh --all"
  echo ""
  echo "options:"
  echo "  --help          print this message"
  echo "    please install the necessary development tools (depot_tools) first following the instructions at"
  echo "    https://chromium.googlesource.com/chromium/src/+/master/docs/linux_build_instructions.md#Install"
  echo ""
  echo "  --all           execute all the necessary steps automatically, from downloading the source code, to building Chromium;"
  echo "    you should only run with this option at most ONCE and ONLY when you have not downloaded the source code"
  echo ""
  echo "  --fetch         fetch the source files of chromium (version $VERSION) and check out to a custom local development branch"
  echo "  --sync          run gclient sync to synchronize all files with (version $VERSION)"
  echo "  --deps          install the dependencies, e.g., CCACHE"
  echo "    you have to install the necessary packages yourself if this step fails"
  echo ""
  echo "  --patch         fetch the source files from our development repositories to replace parts of the Chromium source"
  echo "  --run-hooks     run the Chromium-specific hooks to download additional binaries and other things you might need"
  echo "    you should install the dependencies manually in case this step fails"
  echo ""
  echo "  --conf-local    create the $BUILD_DIR build directory with build arguments; use ONLY for a LOCAL build"
  echo "  --build-local   build Chromium locally using only your own machine"
} # ----------  end of function print_help ----------

# CHECK OUT CHROMIUM SRC
fetch_source ()
{
  git config --global core.precomposeUnicode true
  fetch --nohooks chromium
  cd "$CHROMIUM/src" || return
  git checkout -b dev $VERSION
  COMMIT_DATE=$(git log -n 1 --pretty=format:%ci)
  if [[ -n "$DEPOT_TOOLS_PATH" && -d "$DEPOT_TOOLS_PATH" ]] ; then
    cd "$DEPOT_TOOLS_PATH" || return
    DEPOT_TOOLS_VERSION=$(git rev-list -n 1 --before="$COMMIT_DATE" main)
    git checkout "$DEPOT_TOOLS_VERSION"
    export DEPOT_TOOLS_UPDATE=0
    cd "$CHROMIUM/src" || return
    git clean -ffd
  else
    echo "\$DEPOT_TOOLS_PATH does not been set correctly. Please set up compaatible depot_tools manually following the instruction from https://chromium.googlesource.com/chromium/src/+/HEAD/docs/building_old_revisions.md"
    exit
  fi
} # ----------  end of function fetch_source ----------

# SYNC ALL FILES WITH THE CHECKOUT VERSION
gclient_sync ()
{
  gclient sync --with_branch_heads --jobs $NTHREADS --force --reset
} # ----------  end of function gclient_sync ----------

# INSTALL BUILD DEPENDENCIES
install_deps ()
{
  if [ $is_darwin = 1 ]; then
    xcode-select --install # You can comment this line if you have installed XCode already
    if hash port 2>/dev/null; then
      sudo port install wget ccache docbook2X autoconf automake libtool
      sudo mkdir -p /usr/local/opt/lzo/lib/
      cd /usr/local/opt/lzo/lib/ || exit
      sudo ln -s /opt/local/lib/liblzo2.2.dylib . 2>/dev/null
    elif hash brew 2>/dev/null; then
      brew install wget ccache autoconf automake libtool
      echo ""
    else
      echo "Please install HomeBrew or MacPorts before you proceed!"
      exit 1
    fi

  elif [ $is_linux = 1 ]; then
    sudo apt-get install ccache
    echo ""
    cd "$CHROMIUM/src" || exit
    sudo ./build/install-build-deps.sh --no-syms --no-arm --no-chromeos-fonts --no-nacl
  fi
} # ----------  end of function install_deps ----------


# RUN Chromium-specific hooks
run_hooks ()
{
  cd "$CHROMIUM/src" || exit
  gclient runhooks
} # ----------  end of function run_hooks ----------


# APPLY OBSERVER PATCHES
apply_patch ()
{
  cd "$CHROMIUM/src" && patch -p1 < "$ROOT/$PATCH_DIR/blink.patch"

} # ----------  end of function apply_patch ----------

# BUILD
conf_local_build ()
{
  cd "$CHROMIUM/src" || exit
  mkdir -p out/$BUILD_DIR
  gn gen out/$BUILD_DIR '--args=cc_wrapper="ccache" use_jumbo_build=true is_debug=false enable_nacl=false'
} # ----------  end of function conf_local_build ----------

build_local ()
{
  export CCACHE_BASEDIR=$CHROMIUM
  cd "$CHROMIUM/src" || exit
  time autoninja -C out/$BUILD_DIR chrome
} # ----------  end of function build_local ----------


mkdir -p chromium
ROOT=$PWD
cd chromium || exit
CHROMIUM=$PWD

if [ $# -gt 0 ]; then
  if [ "$1" != "" ] ; then
    case "$1" in
      --fetch|--sync|--deps|--patch|--run-hooks|--conf-local|--build-local|--all|--help )
        if [ "$1" = "--fetch" ] || [ "$1" = "--all" ]; then
          fetch_source
        fi
        if [ "$1" = "--sync" ] || [ "$1" = "--all" ]; then
          gclient_sync
        fi
        if [ "$1" = "--deps" ] || [ "$1" = "--all" ]; then
          install_deps
        fi
        if [ "$1" = "--patch" ] || [ "$1" = "--all" ]; then
          apply_patch
        fi
        if [ "$1" = "--run-hooks" ] || [ "$1" = "--all" ]; then
          run_hooks
        fi
        if [ "$1" = "--conf-local" ] || [ "$1" = "--all" ]; then
          conf_local_build
        fi
        if [ "$1" = "--build-local" ] || [ "$1" = "--all" ]; then
          build_local
        fi
        if [ "$1" = "--help" ]; then
          print_help
        fi
        ;;

      *)
        echo "Your option \"$1\" is invalid"
        exit
        ;;

    esac    # --- end of case ---
  fi
else
  print_help
fi
