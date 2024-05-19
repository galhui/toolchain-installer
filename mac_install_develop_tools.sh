#!/bin/bash

# LC_CTYPE 환경 변수 설정
export LC_CTYPE=en_US.UTF-8

# Homebrew 설치 여부 확인
if ! command -v brew &> /dev/null; then
    echo "Homebrew를 설치합니다..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrew 설치 후 실행 경로 추가
    echo "Homebrew의 실행 경로를 추가합니다..."
    if [[ $(uname -m) == 'arm64' ]]; then
        # Apple Silicon Macs
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Intel Macs
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo "Homebrew 설치가 완료되었습니다."
else
    echo "Homebrew가 이미 설치되어 있습니다."
fi

# 필요한 프로그램 설치 함수 정의
install_program() {
    local program_name=$1
    local brew_name=$2
    local is_cask=$3

    echo "${program_name}을(를) 설치하시겠습니까? [y/n]"
    read user_choice
    if [ "$user_choice" != "${user_choice#[Yy]}" ]; then
        if [[ "$is_cask" == "true" ]]; then
            echo "$program_name 설치 중..."
            brew install --cask "$brew_name"
        else
            echo "$program_name 설치 중..."
            brew install "$brew_name"
        fi
    else
        echo "$program_name 설치를 건너뜁니다."
    fi
}


# 프로그램 설치 여부를 확인하는 함수 정의 (개선된 버전)
check_installed() {
    local program_name=$1
    # Formula와 Cask 모두에서 검색
    if (brew list --formula | grep -qi "$program_name") || (brew list --cask | grep -qi "$program_name"); then
        return 0
    else
        return 1
    fi
}


# 프로그램 설치
declare -a programs=(
    "wget|wget|false"
    "Tree|tree|false"
    "Google Chrome|google-chrome|true"
    "Visual Studio Code|visual-studio-code|true"
    "Android Studio|android-studio|true"
    "GitHub Desktop|github|true"
    "Notion|notion|true"
    "Slack|slack|true"
    "IntelliJ IDEA|intellij-idea|true"
    "iTerm2|iterm2|true"
    "Microsoft Remote Desktop|microsoft-remote-desktop|true"
    "Docker|docker|true"
    "Postman|postman|true"
    "Node.js|node|false"
    "Python|python|false"
    "Telegram|telegram|true"
    # "KakaoTalk|kakao-talk|true"
    "Secure Pipes|secure-pipes|true"
    "MySQL Workbench|mysqlworkbench|true"
    "Yarn|yarn|false"
    "GitKraken|gitkraken|true"
    "Watchman|watchman|false"
    "Dbeaver Community|dbeaver-community|true"
    "Eclipse IDE|eclipse-java|true"
)

for entry in "${programs[@]}"; do
    IFS='|' read -r program_name brew_name is_cask <<< "$entry"
    if ! check_installed "$brew_name"; then
        install_program "$program_name" "$brew_name" "$is_cask"
    else
        echo "$program_name 이미 설치되어 있습니다."
    fi
done

# NVM (Node Version Manager) 설치
if [ ! -d "$HOME/.nvm" ]; then
    echo "NVM을(를) 설치하시겠습니까? [y/n]"
    read user_choice
    if [ "$user_choice" != "${user_choice#[Yy]}" ]; then
        echo "NVM 설치 중..."
        /bin/bash -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh)"

        # NVM 환경 변수를 ~/.zshrc에 추가
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.zshrc
        source ~/.zshrc

        # 즉시 적용을 위해 환경 변수 설정
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        echo "NVM 설치가 완료되었습니다."
    else
        echo "NVM 설치를 건너뜁니다."
    fi
else
    echo "NVM이(가) 이미 설치되어 있습니다."
fi

# pyenv (Python 버전 관리 프로그램) 설치
if ! command -v pyenv &> /dev/null; then
    echo "pyenv을(를) 설치하시겠습니까? [y/n]"
    read user_choice
    if [ "$user_choice" != "${user_choice#[Yy]}" ]; then
        echo "pyenv 설치 중..."
        brew install pyenv
        echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
        echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
        echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
        source ~/.zshrc
        echo "pyenv 설치가 완료되었습니다."
    else
        echo "pyenv 설치를 건너뜁니다."
    fi
else
    echo "pyenv이(가) 이미 설치되어 있습니다."
fi

# Flutter 설치
if ! command -v flutter &> /dev/null; then
    echo "Flutter를 설치하시겠습니까? [y/n]"
    read user_choice
    if [ "$user_choice" != "${user_choice#[Yy]}" ]; then
        echo "Flutter 설치 중..."
        # Flutter tap 추가
        brew tap dart-lang/dart
        # Flutter 설치
        brew install flutter
        dart pub global activate fvm
        
        echo "Flutter 설치가 완료되었습니다."
    else
        echo "Flutter 설치를 건너뜁니다."
    fi
else
    echo "Flutter가 이미 설치되어 있습니다."
fi

#!/bin/bash

# Apple Silicon Macs에서만 Rosetta 설치를 시도합니다.
if [[ $(uname -m) == 'arm64' ]]; then
    # Rosetta 설치 여부를 확인합니다.
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        echo "Rosetta가 이미 설치되어 있습니다."
    else
        echo "Rosetta를 설치하시겠습니까? [y/n]"
        read user_choice
        if [ "$user_choice" != "${user_choice#[Yy]}" ]; then
            echo "Rosetta 설치 중..."
            # 소프트웨어 업데이트 도구를 사용하여 Rosetta를 설치합니다.
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license
            
            if [ $? -eq 0 ]; then
                echo "Rosetta 설치가 완료되었습니다."
            else
                echo "Rosetta 설치에 실패하였습니다."
            fi
        else
            echo "Rosetta 설치를 건너뜁니다."
        fi
    fi
else
    echo "이 Mac은 Apple Silicon 기반 Mac이 아니므로 Rosetta를 설치할 필요가 없습니다."
fi

# Xcode 설치 여부 확인 및 설치 유도
if ! mdfind "kMDItemContentType == 'com.apple.application-bundle' && kMDItemFSName == 'Xcode.app'" | grep -q 'Xcode.app'; then
    echo "Xcode 앱을 설치해야 합니다."
    echo "App Store에서 Xcode를 설치해 주세요. 링크를 열고 있습니다..."
    open "https://apps.apple.com/us/app/xcode/id497799835"
else
    echo "Xcode 앱이 이미 설치되어 있습니다."
fi


# Zulu OpenJDK 17 설치 여부 확인 및 설치
if ! /usr/libexec/java_home -V 2>&1 | grep -q 'Zulu 17'; then
    echo "Zulu OpenJDK 17을 설치하시겠습니까? [y/n]"
    read -r user_choice
    if [[ "$user_choice" == [Yy] ]]; then
        echo "Zulu OpenJDK 17을 설치합니다..."
        brew tap homebrew/cask-versions
        brew install --cask zulu17
        echo 'export JAVA_HOME=$(/usr/libexec/java_home -v17)' >> ~/.zshrc
        source ~/.zshrc
        echo "Zulu OpenJDK 17 설치가 완료되었습니다."
    else
        echo "Zulu OpenJDK 17 설치를 건너뜁니다."
    fi
else
    echo "Zulu OpenJDK 17이(가) 이미 설치되어 있습니다."
fi

echo "설치가 완료되었습니다!"
