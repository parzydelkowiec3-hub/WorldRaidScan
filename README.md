# WorldRaidScan (1.12.1)

**WorldRaidScan** is a chat parser and organizer for World of Warcraft 1.12.1 (Vanilla). It scans public channels (World, Say, Yell) for group finding messages and presents them in a clean, sortable table.

## Features

### 🔍 Smart Scanning
*   **Automatic categorizing**: Raids, Dungeons, Quests, and Guild Recruitments are automatically detected.
*   **Group Sorting**: Raids and Dungeons are grouped by instance (e.g., all "MC" or "BWL" messages together).
*   **Role Parsing**: Detects if a group needs Tank, Heal, or DPS.
*   **Advanced Info**: Detects "Summon" availability, Hard Reserves (HR), Soft Reserves (SR), and Discord links.

### 🖥️ Enhanced GUI
*   **Sortable Columns**: Click headers to sort by Time, Sender, Summon, Reserves, Discord, or Role Info.
*   **Dedicated Tabs**:
    *   **RAID / DUNGEON**: Grouped view by instance.
    *   **QUEST**: Flat list showing clickable Quest Links.
    *   **GUILD**: Directory style list of recruiting guilds (merges multiple recruiters from the same guild).
*   **Tooltips**: Hover over headers for help, hover over rows for full original message.
*   **One-Click Whisper**: Select an entry and click "Whisper" to auto-fill the chat.

### ⚙️ Management
*   **Auto-Cleanup**: Entries older than 3 hours are automatically removed.
*   **Reset Command**: Type `/wrs reset` to clear the entire list.
*   **Settings**: Configure scanning behavior (e.g., scan while closed).

## Commands

*   `/wrs` - Toggle the main window.
*   `/wrs reset` (or `/wrs clear`) - Clear all current data.

## Installation

1.  Extract the `WorldRaidScan` folder into your `Interface\AddOns\` directory.
2.  Restart WoW.
