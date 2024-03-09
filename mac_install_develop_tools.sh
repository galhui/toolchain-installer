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
)

for entry in "${programs[@]}"; do
    IFS='|' read -r program_name brew_name is_cask <<< "$entry"
    if ! check_installed "$brew_name"; then
        install_program "$program_name" "$brew_name" "$is_cask"
    else
        echo "$program_name 이미 설치되어 있습니다."
    fi
done

# Xcode 설치 여부 확인 및 설치 유도
if ! mdfind "kMDItemContentType == 'com.apple.application-bundle' && kMDItemFSName == 'Xcode.app'" | grep -q 'Xcode.app'; then
    echo "Xcode 앱을 설치해야 합니다."
    echo "App Store에서 Xcode를 설치해 주세요. 링크를 열고 있습니다..."
    open "https://apps.apple.com/us/app/xcode/id497799835"
else
    echo "Xcode 앱이 이미 설치되어 있습니다."
fi

echo "설치가 완료되었습니다!"