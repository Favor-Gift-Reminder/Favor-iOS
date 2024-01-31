#!/bin/sh

echo "Xcode Cloud 빌드를 위한 환경을 세팅합니다..."

cd ..

plutil -replace INSTAGRAM_APP_ID -string $INSTAGRAM_APP_ID "FavorNetworkKit/Sources/FavorNetworkKit/API-Info.plist"
plutil -replace API_BASEURL -string $API_BASEURL "FavorNetworkKit/Sources/FavorNetworkKit/API-Info.plist"

exit 0
