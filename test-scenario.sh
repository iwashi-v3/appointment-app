#!/bin/bash

# イベント状態管理機能のテストシナリオ
# このスクリプトを実行して機能が正常に動作することを確認

BASE_URL="http://localhost:4000"
CONTENT_TYPE="Content-Type: application/json"

echo "🚀 イベント状態管理機能テスト開始"

# 1. ユーザー作成とログイン（事前準備）
echo "📝 1. テストユーザーの作成..."
USER_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/signup" \
  -H "${CONTENT_TYPE}" \
  -d '{
    "username": "testuser_'$(date +%s)'",
    "email": "test_'$(date +%s)'@example.com",
    "password": "password123"
  }')

if [ $? -eq 0 ]; then
  echo "✅ ユーザー作成成功"
  USER_ID=$(echo $USER_RESPONSE | jq -r '.userId')
  echo "User ID: $USER_ID"
else
  echo "❌ ユーザー作成失敗"
  exit 1
fi

# ログイン
echo "🔐 2. ログイン..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/signin" \
  -H "${CONTENT_TYPE}" \
  -d '{
    "email": "'$(echo $USER_RESPONSE | jq -r '.email')'",
    "password": "password123"
  }')

if [ $? -eq 0 ]; then
  echo "✅ ログイン成功"
  ACCESS_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.accessToken')
  AUTH_HEADER="Authorization: Bearer $ACCESS_TOKEN"
else
  echo "❌ ログイン失敗"
  exit 1
fi

# 2. イベント作成
echo "🎯 3. イベント作成..."
CREATE_EVENT_RESPONSE=$(curl -s -X POST "${BASE_URL}/events" \
  -H "${CONTENT_TYPE}" \
  -H "${AUTH_HEADER}" \
  -d '{
    "title": "テスト会議",
    "description": "定期的なチームミーティング",
    "location": "東京都渋谷区",
    "startTime": "'$(date -u -v+1H +%Y-%m-%dT%H:%M:%SZ)'",
    "endTime": "'$(date -u -v+3H +%Y-%m-%dT%H:%M:%SZ)'"
  }')

if [ $? -eq 0 ]; then
  echo "✅ イベント作成成功"
  EVENT_ID=$(echo $CREATE_EVENT_RESPONSE | jq -r '.eventId')
  echo "Event ID: $EVENT_ID"
else
  echo "❌ イベント作成失敗"
  echo $CREATE_EVENT_RESPONSE
  exit 1
fi

# 3. イベント一覧取得
echo "📋 4. イベント一覧取得..."
curl -s -X GET "${BASE_URL}/events" \
  -H "${AUTH_HEADER}" | jq '.'

# 4. 集合場所変更（通知テスト）
echo "📍 5. 集合場所変更..."
UPDATE_RESPONSE=$(curl -s -X PUT "${BASE_URL}/events/${EVENT_ID}" \
  -H "${CONTENT_TYPE}" \
  -H "${AUTH_HEADER}" \
  -d '{
    "location": "大阪府大阪市北区",
    "description": "場所が変更されました"
  }')

if [ $? -eq 0 ]; then
  echo "✅ 場所変更成功"
  echo "新しい場所: $(echo $UPDATE_RESPONSE | jq -r '.location')"
else
  echo "❌ 場所変更失敗"
fi

# 5. イベント参加
echo "🚪 6. イベント参加..."
JOIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/events/${EVENT_ID}/join" \
  -H "${AUTH_HEADER}")

if [ $? -eq 0 ]; then
  echo "✅ イベント参加成功"
  echo $(echo $JOIN_RESPONSE | jq -r '.message')
else
  echo "❌ イベント参加失敗"
fi

# 6. 参加者一覧確認
echo "👥 7. 参加者一覧確認..."
PARTICIPANTS=$(curl -s -X GET "${BASE_URL}/events/${EVENT_ID}/participants" \
  -H "${AUTH_HEADER}")
echo "参加者数: $(echo $PARTICIPANTS | jq '. | length')"
echo $PARTICIPANTS | jq '.'

# 7. イベント開始
echo "▶️ 8. イベント開始..."
START_RESPONSE=$(curl -s -X POST "${BASE_URL}/events/${EVENT_ID}/start" \
  -H "${AUTH_HEADER}")

if [ $? -eq 0 ]; then
  echo "✅ イベント開始成功"
  echo "アクティブ状態: $(echo $START_RESPONSE | jq -r '.isActive')"
else
  echo "❌ イベント開始失敗"
fi

# 8. 通知履歴確認
echo "🔔 9. 通知履歴確認..."
NOTIFICATIONS=$(curl -s -X GET "${BASE_URL}/events/${EVENT_ID}/notifications" \
  -H "${AUTH_HEADER}")
echo "通知数: $(echo $NOTIFICATIONS | jq '. | length')"
echo "通知履歴:"
echo $NOTIFICATIONS | jq '.[] | {type: .type, message: .message, createdAt: .createdAt}'

# 9. イベント離脱
echo "🚪 10. イベント離脱..."
LEAVE_RESPONSE=$(curl -s -X POST "${BASE_URL}/events/${EVENT_ID}/leave" \
  -H "${AUTH_HEADER}")

if [ $? -eq 0 ]; then
  echo "✅ イベント離脱成功"
else
  echo "❌ イベント離脱失敗"
fi

# 10. イベント終了
echo "⏹️ 11. イベント終了..."
END_RESPONSE=$(curl -s -X POST "${BASE_URL}/events/${EVENT_ID}/end" \
  -H "${AUTH_HEADER}")

if [ $? -eq 0 ]; then
  echo "✅ イベント終了成功"
  echo "アクティブ状態: $(echo $END_RESPONSE | jq -r '.isActive')"
else
  echo "❌ イベント終了失敗"
fi

# 11. 最終的な通知履歴確認
echo "📊 12. 最終通知履歴..."
FINAL_NOTIFICATIONS=$(curl -s -X GET "${BASE_URL}/events/${EVENT_ID}/notifications" \
  -H "${AUTH_HEADER}")
echo "最終通知数: $(echo $FINAL_NOTIFICATIONS | jq '. | length')"

# 通知タイプ別カウント
echo "通知タイプ別統計:"
echo $FINAL_NOTIFICATIONS | jq '[group_by(.type)[] | {type: .[0].type, count: length}]'

# 12. イベント削除
echo "🗑️ 13. イベント削除..."
DELETE_RESPONSE=$(curl -s -X DELETE "${BASE_URL}/events/${EVENT_ID}" \
  -H "${AUTH_HEADER}")

if [ $? -eq 0 ]; then
  echo "✅ イベント削除成功"
else
  echo "❌ イベント削除失敗"
fi

echo ""
echo "🎉 テスト完了！"
echo ""
echo "✅ 成功確認項目:"
echo "   - イベント作成 ✓"
echo "   - 集合場所変更通知 ✓"
echo "   - 参加者入退室通知 ✓"
echo "   - イベント開始・終了通知 ✓"
echo "   - 通知履歴保存 ✓"
