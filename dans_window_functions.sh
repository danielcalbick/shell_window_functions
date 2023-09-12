#!/bin/zsh

function grace(){

    open_new_window; sleep .1
    mvwin .10 .12 ; sleep .01  # Move Window
    winresize .39 .39; sleep .01  # Resize
    theme red; sleep .1  # Change Theme
    ssh -i ~/.ssh/id_rsa psyc261_dc938@grace.ycrc.yale.edu

}

function open_new_window(){

    # Get the terminal application name
    terminal_app=$(get_terminal_app_id)

    osascript <<EOD
    tell application "System Events"
        tell application process "$terminal_app"
            tell window 1
                keystroke "n" using {command down}
            end tell
        end tell
    end tell
EOD
}; alias newwin=open_new_window

function get_window_position(){
    
    # Get the terminal application name
    terminal_app=$(get_terminal_app_id)

    # Get current window position and size
    current_position=$(osascript -e "tell application \"System Events\" to tell application process \"$terminal_app\" to tell window 1 to get position")
    current_size=$(osascript -e "tell application \"System Events\" to tell application process \"$terminal_app\" to tell window 1 to get size")
    
    read cur_x cur_y <<< $(echo $current_position | tr "," " ")
    read cur_width cur_height <<< $(echo $current_size | tr "," " ")

    # Get the screen bounds
    screen_bounds=$(get_current_screen_bounds)
    read x0 y0 xf yf <<< $(echo $screen_bounds | tr "," " ")

    screen_width=$(echo "scale=2; ($xf - $x0)" | bc)
    screen_height=$(echo "scale=2; ($yf - $y0 )" | bc)

    # Calculate relative percentages for position
    x_percent=$(echo "scale=2; ($cur_x - $x0) / $screen_width" | bc)
    y_percent=$(echo "scale=2; ($cur_y - $y0) / $screen_height" | bc)

    # Calculate relative percentages for size
    width_percent=$(echo "scale=2; $cur_width / $screen_width" | bc)
    height_percent=$(echo "scale=2; $cur_height / $screen_height" | bc)

    # Output the results
    echo "Current Window Position (x y w h)"
    echo "Relative Percent: ($x_percent $y_percent $width_percent $height_percent)"
    echo "Pixel Value: ($cur_x $cur_y $cur_width $cur_height)"
}; alias winpos=get_window_position

function get_current_screen_bounds() {
    terminal_app=$(get_terminal_app_id)
    terminal_position=$(osascript -e "tell application \"System Events\" to tell application process \"$terminal_app\" to get position of front window")

  
    # Parse the position to get x and y coordinates
    x=$(echo $terminal_position | awk -F ', ' '{print $1}')
    y=$(echo $terminal_position | awk -F ', ' '{print $2}')

    # Get the dimensions of the MacBook display from system_profiler
    macbook_dims=$(system_profiler SPDisplaysDataType | awk -F': ' '/Resolution/{print $2; exit}' | awk '{print $1, $3}')
    macbook_x2=$(echo $macbook_dims | awk '{print $1}')
    macbook_y2=$(echo $macbook_dims | awk '{print $2}')

    # Get the bounds of the primary display from AppleScript
    primary_bounds=$(osascript -e 'tell application "Finder" to get bounds of window of desktop')
    primary_x1=$(echo $primary_bounds | awk -F', ' '{print $1}')
    primary_y1=$(echo $primary_bounds | awk -F', ' '{print $2}')
    primary_x2=$(echo $primary_bounds | awk -F', ' '{print $3}')
    primary_y2=$(echo $primary_bounds | awk -F', ' '{print $4}')

    # Determine which screen the Terminal window is on and print the bounds
    if [ "$x" -ge 0 ] && [ "$x" -le "$macbook_x2" ] && [ "$y" -ge 0 ] && [ "$y" -le "$macbook_y2" ]; then
        echo "0,0,$macbook_x2,$macbook_y2"
    elif [ "$x" -ge "$primary_x1" ] && [ "$x" -le "$primary_x2" ] && [ "$y" -ge "$primary_y1" ] && [ "$y" -le "$primary_y2" ]; then
        echo "$primary_x1,$primary_y1,$primary_x2,$primary_y2"
    else
        echo "Terminal position is out of known bounds." 
        return
    fi
}; alias screenpos=get_current_screen_bounds

function move_window(){

    # Get the x and y from the arguments
    x_input=$1
    y_input=$2

    # Get the screen bounds
    screen_bounds=$(get_current_screen_bounds)
    read x0 y0 xf yf <<< $(echo $screen_bounds | tr "," " ")

    screen_width=$(echo "scale=2; ($xf - $x0)" | bc)
    screen_height=$(echo "scale=2; ($yf - $y0 )" | bc)

    # Check if the inputs are percentages or pixel positions
    if (( $(echo "$x_input < 1 && $x_input > -1" | bc -l) )); then
        new_x=$(echo "$x0 + ($screen_width * $x_input)" | bc)
        new_x=$(printf "%.0f" $new_x)
    else
        new_x=$x_input
    fi

    if (( $(echo "$y_input < 1 && $y_input > -1" | bc -l) )); then
        new_y=$(echo "$y0 + ($screen_height * $y_input)" | bc)
        new_y=$(printf "%.0f" $new_y)
    else
        new_y=$y_input
    fi
    
    
    # Get the terminal application name
    terminal_app=$(get_terminal_app_id)

    # Move the window
    osascript <<EOD
    tell application "System Events"
        tell application process "$terminal_app"
            tell window 1
                set position to {$new_x, $new_y}
            end tell
        end tell
    end tell
EOD
}; alias mvwin=move_window

function window_resize() {

    width=$1
    height=$2

    # Get the terminal application name
    terminal_app=$(get_terminal_app_id)

    # Get current window position and size
    current_position=$(osascript -e "tell application \"System Events\" to tell application process \"$terminal_app\" to tell window 1 to get position")
    current_size=$(osascript -e "tell application \"System Events\" to tell application process \"$terminal_app\" to tell window 1 to get size")

    read cur_x cur_y <<< $(echo $current_position | tr "," " ")
    read cur_width cur_height <<< $(echo $current_size | tr "," " ")

    # Get the screen bounds
    screen_bounds=$(get_current_screen_bounds)
    read x0 y0 xf yf <<< $(echo $screen_bounds | tr "," " ")

    # Check if the inputs are percentages or pixel positions
    if (( $(echo "$width < 1 && $width > -1" | bc -l) )); then # if the width is a percentage
        
        # Calculate width
        screen_width=$(echo "scale=2; ($xf - $x0)" | bc)
        screen_height=$(echo "scale=2; ($yf - $y0 )" | bc)

        # Calculate New Width
        new_width=$(echo "($screen_width * $width)" | bc)
        new_width=$(printf "%.0f" $new_width)

    else
        new_width=$width
    fi

    if (( $(echo "$height < 1 && $height > -1" | bc -l) )); then # if the height is a percentage
        # Calculate height
        screen_height=$(echo "scale=2; ($yf - $y0 )" | bc)

        # Calculate new height
        new_height=$(echo "($screen_height * $height)" | bc)
        new_height=$(printf "%.0f" $new_height)
    else
        new_height=$height
    fi

    new_x=$(echo "scale=2; ($cur_x + ($cur_width / 2) - ($new_width / 2) )" | bc)
    new_y=$(echo "scale=2; ($cur_y + ($cur_height / 2) - ($new_height / 2) )" | bc)

    osascript <<EOD
    tell application "System Events"
        tell application process "$terminal_app"
            tell window 1
                set size to {$new_width, $new_height}
                set position to {$new_x, $new_y}
            end tell
        end tell
    end tell
EOD
}; alias winresize=window_resize

function change_terminal_theme(){

    if [[ $# -eq 0 ]]; then
        echo 'Hey! I need a theme idiot!'
        return
    fi

    theme_name=$1
    terminal_app=$(get_terminal_app_id)


    if [[ $terminal_app == *"Warp"* ]]; then
        warp_change_theme "$theme_name"
    else
        terminal_change_theme "$theme_name"
    fi

}; alias theme=change_terminal_theme

function get_terminal_app_id(){

    # Get the parent process ID
    parent_pid=$(ps -o ppid= -p $$)

    # Get the parent process name based on the parent PID
    parent_process_name=$(ps -o comm= -p $parent_pid)

    # Determine the terminal application name for AppleScript
    if [[ $parent_process_name == *"/Warp.app/"* ]]; then
        terminal_app="Warp"
    else
        terminal_app="Terminal"
    fi

    echo $terminal_app
}; alias termid=get_terminal_app_id


function warp_change_theme(){

theme_name=$1

osascript <<EOD
    tell application "System Events"
        key down {control}
        key down {command}
        keystroke "t"
        key up {command}
        key up {control}
        keystroke "$theme_name"
        delay .1
        keystroke (key code 125)
        keystroke return
    end tell
    delay .1
EOD
    
}

function terminal_change_theme(){

theme_name=$1

osascript <<EOD
    tell application "Terminal"        
        set current settings of window 1 to settings set "$theme_name"       
    end tell
EOD
    
}




