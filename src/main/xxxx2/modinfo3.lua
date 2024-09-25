version = '2024.09.02'
api_version = 10
dst_compatible = true
client_only_mod = true
icon = 'modicon.tex'
icon_atlas = 'modicon.xml'

local S = {
  NAME = { 'Boss Calendar Lite', zh = 'Boss 日历', zht = 'Boss 日曆' },
  AUTHOR = {
    'Boas, xaT2x, iaman2b & liolok',
    zh = 'Boas、xaT2x、iaman2b & 李皓奇',
    zht = 'Boas、xaT2x、iaman2b & 李皓奇',
  },
  DESCRIPTION = {
    'Calculate and remember when bosses respawn.\n'
      .. 'Support click-announcing and auto-reminding.\n'
      .. 'Also support binding key at bottom of Settings > Controls page.',
    zh = '帮你计算并记住 Boss 们什么时候刷新。\n支持点击宣告、自动提醒。\n'
      .. '也支持在设置 > 控制页面底部实时调整键位绑定。',
    zht = '幫你計算並記住 Boss 們何時刷新。\n支援點擊宣告、自動提醒。\n'
      .. '也支援在設定 > 控制頁面底部即時調整鍵位綁定。',
  },
  VIEW_KEY = {
    'View Key',
    zh = '查看按键',
    zht = '查看按鍵',
    DETAIL = {
      'Bind a key, press and hold to view calendar.',
      zh = '绑定一个按键，按住查看日历。',
      zht = '綁定一個按鍵，按住查看日曆。',
    },
  },
  FONT_SIZE = {
    'Font Size',
    zh = '字体大小',
    zht = '字體大小',
    DETAIL = {
      'How big should the calendar text be?',
      zh = '日历文本要多大？',
      zht = '日曆文字要多大？',
    },
    SMALL = {
      'Turn up if feeling too small.',
      zh = '如果太小就调大',
      zht = '如果太小就調大',
    },
    BIG = {
      'Text may become blank if too long.',
      zh = '文本太长可能会变成空白',
      zht = '文字太長可能會變成空白',
    },
  },
  TIME_STYLE = {
    'Time Style',
    zh = '时间格式',
    zht = '時間格式',
    DAY = { 'World Day', zh = '世界天数', zht = '世界天數' },
    DAYS = { 'Days to Go', zh = '倒计天数', zht = '倒數天數' },
    TIME = { 'Real Time', zh = '现实时间', zht = '現實時間' },
    CALENDAR = {
      'Calendar',
      zh = '日历',
      zht = '日曆',
      DETAIL = {
        'How respawn time shows up in calendar.',
        zh = '日历中如何显示刷新时间',
        zht = '日曆中如何顯示刷新時間',
      },
      AGD = { 'Day 21.10', zh = '第 21.10 天', zht = '第 21.10 天' },
      CGD = { '19.99d', zh = '19.99 天', zht = '19.99 天' },
    },
    ANNOUNCE = {
      'Announce',
      zh = '宣告',
      zht = '宣告',
      DETAIL = {
        'How to announce respawn time.',
        zh = '如何宣告刷新时间',
        zht = '如何宣告刷新時間',
      },
      AGD = {
        'Dragonfly will repsawn on day 21.10.',
        zh = '龙蝇将在第 21.10 天刷新。',
        zht = '龍蠅將在第 21.10 天刷新。',
      },
      CGD = {
        'Dragonfly will repsawn in 19.99 days.',
        zh = '龙蝇将在 19.99 天之后刷新。',
        zht = '龍蠅將在 19.99 天之後刷新。',
      },
      CRT = {
        'Dragonfly will repsawn in 1 hour 30 minutes.',
        zh = '龙蝇将在 1 小时 30 分钟之后刷新。',
        zht = '龍蠅將在 1 小時 30 分鐘之後刷新。',
      },
    },
  },
  REMIND = {
    'Remind',
    zh = '提醒',
    zht = '提醒',
    POSITION = {
      'Position',
      zh = '位置',
      zht = '位置',
      DETAIL = {
        'Where should message appear?',
        zh = '消息出现在哪里？',
        zht = '訊息出現在哪裡？',
      },
      CHAT = {
        'Chat',
        zh = '聊天',
        zht = '聊天',
        DETAIL = {
          'Message shows up in chat history, visible to yourself only.',
          zh = '消息出现在聊天记录，仅对你自己可见。',
          zht = '訊息出現在聊天記錄，僅對你自己可見。',
        },
      },
      HEAD = {
        'Head',
        zh = '头顶',
        zht = '頭頂',
        DETAIL = {
          'Message shows upon your player character.',
          zh = '消息出现在你的玩家角色上方。',
          zht = '訊息出現在你的玩家角色上方。',
        },
      },
    },
    COLOR = {
      'Color',
      zh = '颜色',
      zht = '顏色',
      DETAIL = {
        'Choose a color for message.',
        zh = '选择消息颜色',
        zht = '選擇訊息顏色',
      },
      RED = { 'Red', zh = '红', zht = '紅' },
      BLUE = { 'Blue', zh = '蓝', zht = '藍' },
      PURPLE = { 'Purple', zh = '紫', zht = '紫' },
      ORANGE = { 'Orange', zh = '橙', zht = '橙' },
      YELLOW = { 'Yellow', zh = '黄', zht = '黃' },
      GREEN = { 'Green', zh = '绿', zht = '綠' },
    },
    DURATION = {
      'Duration',
      zh = '持续时间',
      zht = '持續時間',
      DETAIL = {
        'How long does head message last? (not for chat message)',
        zh = '头顶消息持续多久？（不管聊天消息）',
        zht = '頭頂訊息持續多久？（不管聊天訊息）',
      },
      SHORT = { 'Short', zh = '更短', zht = '更短' },
      DEFAULT = { 'Default', zh = '默认', zht = '預設' },
      LONG = { 'Long', zh = '更久', zht = '更久' },
    },
  },
}
local T = ChooseTranslationTable

name = T(S.NAME)
author = T(S.AUTHOR)
description = T(S.DESCRIPTION)

local keyboard = { -- from STRINGS.UI.CONTROLSSCREEN.INPUTS[1] of strings.lua, need to match constants.lua too.
  { 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Print', 'ScrolLock', 'Pause' },
  { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' },
  { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M' },
  { 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' },
  { 'Escape', 'Tab', 'CapsLock', 'LShift', 'LCtrl', 'LSuper', 'LAlt' },
  { 'Space', 'RAlt', 'RSuper', 'RCtrl', 'RShift', 'Enter', 'Backspace' },
  { 'Tilde', 'Minus', 'Equals', 'LeftBracket', 'RightBracket', 'Backslash', 'Semicolon', 'Period', 'Slash' }, -- punctuation
  { 'Up', 'Down', 'Left', 'Right', 'Insert', 'Delete', 'Home', 'End', 'PageUp', 'PageDown' }, -- navigation
  { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'Period', 'Divide', 'Multiply', 'Minus', 'Plus' }, -- numberic keypad
}
local key_disabled = { description = 'Disabled', data = 'KEY_DISABLED' }
keys = { key_disabled }
for i = 1, #keyboard do
  for j = 1, #keyboard[i] do
    local str = keyboard[i][j]
    local desc = i == #keyboard and 'NumPad ' .. str or str
    keys[#keys + 1] = { description = desc, data = 'KEY_' .. str:upper() }
  end
  keys[#keys + 1] = key_disabled
end

local function H(title) return { name = T(title), options = { { description = '', data = 0 } }, default = 0 } end -- header

configuration_options = {
  {
    label = T(S.VIEW_KEY),
    hover = T(S.VIEW_KEY.DETAIL),
    options = keys,
    default = 'KEY_V',
    name = 'key_to_view',
  },
  {
    label = T(S.FONT_SIZE),
    hover = T(S.FONT_SIZE.DETAIL),
    options = {
      { data = 24, description = '24', hover = T(S.FONT_SIZE.SMALL) },
      { data = 26, description = '26' },
      { data = 28, description = '28' },
      { data = 30, description = '30' },
      { data = 32, description = '32', hover = T(S.FONT_SIZE.BIG) },
    },
    default = 28,
    name = 'calendar_font_size',
  },

  H(S.TIME_STYLE),
  {
    label = T(S.TIME_STYLE.CALENDAR),
    hover = T(S.TIME_STYLE.CALENDAR.DETAIL),
    options = { -- function names from BossCalendar class
      { data = 'AbsoluteGameDay', description = T(S.TIME_STYLE.DAY), hover = T(S.TIME_STYLE.CALENDAR.AGD) },
      { data = 'CountdownGameDays', description = T(S.TIME_STYLE.DAYS), hover = T(S.TIME_STYLE.CALENDAR.CGD) },
      { data = 'CountdownRealTime', description = T(S.TIME_STYLE.TIME), hover = 'hh:mm:ss' },
    },
    default = 'CountdownGameDays',
    name = 'calendar_time_style',
  },
  {
    label = T(S.TIME_STYLE.ANNOUNCE),
    hover = T(S.TIME_STYLE.ANNOUNCE.DETAIL),
    options = { -- function names from BossCalendar class
      { data = 'AbsoluteGameDay', description = T(S.TIME_STYLE.DAY), hover = T(S.TIME_STYLE.ANNOUNCE.AGD) },
      { data = 'CountdownGameDays', description = T(S.TIME_STYLE.DAYS), hover = T(S.TIME_STYLE.ANNOUNCE.CGD) },
      { data = 'CountdownRealTime', description = T(S.TIME_STYLE.TIME), hover = T(S.TIME_STYLE.ANNOUNCE.CRT) },
    },
    default = 'AbsoluteGameDay',
    name = 'announce_time_style',
  },

  H(S.REMIND),
  {
    label = T(S.REMIND.POSITION),
    hover = T(S.REMIND.POSITION.DETAIL),
    options = {
      { data = 'chat', description = T(S.REMIND.POSITION.CHAT), hover = T(S.REMIND.POSITION.CHAT.DETAIL) },
      { data = 'head', description = T(S.REMIND.POSITION.HEAD), hover = T(S.REMIND.POSITION.HEAD.DETAIL) },
    },
    default = 'chat',
    name = 'remind_position',
  },
  {
    label = T(S.REMIND.COLOR),
    hover = T(S.REMIND.COLOR.DETAIL),
    options = { -- will use PLAYERCOLOURS from constants.lua
      { data = 'RED', description = T(S.REMIND.COLOR.RED) },
      { data = 'BLUE', description = T(S.REMIND.COLOR.BLUE) },
      { data = 'PURPLE', description = T(S.REMIND.COLOR.PURPLE) },
      { data = 'ORANGE', description = T(S.REMIND.COLOR.ORANGE) },
      { data = 'YELLOW', description = T(S.REMIND.COLOR.YELLOW) },
      { data = 'GREEN', description = T(S.REMIND.COLOR.GREEN) },
    },
    default = 'GREEN',
    name = 'remind_color',
  },
  {
    label = T(S.REMIND.DURATION),
    hover = T(S.REMIND.DURATION.DETAIL),
    options = {
      { data = 3, hover = '3s', description = T(S.REMIND.DURATION.SHORT) },
      { data = 5, hover = '5s', description = T(S.REMIND.DURATION.DEFAULT) },
      { data = 7, hover = '7s', description = T(S.REMIND.DURATION.LONG) },
    },
    default = 5,
    name = 'talk_duration',
  },
}
