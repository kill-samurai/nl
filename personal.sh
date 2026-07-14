/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &&
sleep 3 &&
echo >> /Users/killsamurai/.zprofile &&
sleep 3 &&
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/killsamurai/.zprofile &&
sleep 3 &&
eval "$(/opt/homebrew/bin/brew shellenv)" &&
sleep 3 &&
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &&
git clone https://github.com/ChesterYue/ohmyzsh-theme-passion &&
cp ./ohmyzsh-theme-passion/passion.zsh-theme ~/.oh-my-zsh/themes/passion.zsh-theme &&
brew install coreutils && 
curl -O https://raw.githubusercontent.com/kill-samurai/nl/refs/heads/main/.zshrc &&
softwareupdate --install-rosetta --agree-to-license &&
#brew install --cask postman && 
#brew install --cask google-chrome && 
brew install node && 
brew install --cask visual-studio-code && 
#brew install --cask dadroit-json-viewer && 
brew install python@3.13 && 
#brew install --cask pycharm-ce && 
#brew install --cask firefox && 
brew install --cask sublime-text && 
brew install --cask spotify && 
#brew install --cask studio-3t && 
brew install htop && 
#brew install --cask 1password &&
#brew install --cask slack &&
#brew install defaultbrowser &&
brew install --cask steam &&
brew install dockutil &&
brew install --cask virtualbuddy &&
brew install --cask brave-browser &&
brew install --cask whatsapp &&
#brew install --cask telegram &&
#config below
#defaultbrowser brave &&
#defaultbrowser chrome &&
defaults write ~/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false &&
sudo defaults write /Library/Preferences/com.apple.AppleMultitouchTrackpad Clicking -bool true && 
sudo defaults write /Library/Preferences/.GlobalPreferences com.apple.mouse.tapBehavior -int 1 &&
defaults write NSGlobalDomain AppleShowAllExtensions -bool true &&
defaults write com.apple.finder FinderSpawnTab -bool false &&
defaults write com.apple.dock autohide -bool true &&
defaults write com.apple.dock autohide-time-modifier -float 0.2 &&
defaults write com.apple.dock tilesize -int 36 &&
defaults write com.apple.dock magnification -bool true &&
defaults write com.apple.dock largesize -int 64 &&
defaults write com.apple.dock persistent-apps -array &&
dockutil --remove Downloads &&
#dockutil --add "/Applications/Google Chrome.app" &&
dockutil --add "/Applications/Brave Browser.app" &&
dockutil --add /Applications/Utilities/Terminal.app &&
dockutil --add /Applications/Visual\ Studio\ Code.app &&
#dockutil --add "/Applications/Slack.app" &&
#dockutil --add "/Applications/Studio 3T.app" &&
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' &&
defaults write -g com.apple.swipescrolldirection -bool false &&
#cleanup
brew uninstall dockutil &&
brew uninstall defaultbrowser &&
softwareupdate --list &&
sudo softwareupdate --install --all &&
sudo shutdown -r now
