# Shell Function Library

This is a collection of useful shell functions for managing terminal windows on macOS.

## Features

- Control window position, size, and theme
- Works with Terminal.app and Warp.app  
- Uses AppleScript under the hood, so for now it only works for macOS

## Functions 

### `grace()`

Example function that will open a new terminal window, resize, reposition, change theme, and SSH to a remote server.

### `open_new_window()`

Open a new terminal window.

### `get_window_position()` 

Print the current window position and size as percentages and pixel values.

### `get_current_screen_bounds()`

Get the pixel bounds of the current screen.

### `move_window()`

Move the current window to a new x,y position. Accepts either pixels or percentages.

### `window_resize()`

Resize the current window to new width and height. Accepts either pixels or percentages.

### `change_terminal_theme()`

Change the theme/appearance of the current terminal.

### `get_terminal_app_id()`

Get the name of the current terminal application.

### `warp_change_theme()`

Change theme specifically for Warp.

### `terminal_change_theme()` 

Change theme specifically for Terminal.app.

## Usage

Source `dans_window_functions.sh` in your shell startup file.

```bash
# .zshrc or .bash_profile 
source dans_window_functions.sh