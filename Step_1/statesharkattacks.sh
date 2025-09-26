#!/bin/bash

# --- Data Storage ---
# We use an associative array to store the shark attack data.
# This is a much better way to handle many states than using individual variables.
declare -A shark_attacks

# Populate the array with state names and their shark attack counts.
# The number 0 signifies no attacks, which we'll handle below.
shark_attacks[Florida]=21
shark_attacks[Hawaii]=5
shark_attacks[California]=2
shark_attacks[SouthCarolina]=1
shark_attacks[Texas]=0
shark_attacks[Tennessee]=0
shark_attacks[Ohio]=0
shark_attacks[Pennsylvania]=0

# --- User Input ---
# Prompt the user for a state name and store the input.
read -p "Please enter a state name to check for shark attacks: " state_input

# Convert the user's input to Title Case.
# This ensures that "florida," "FLORIDA," or "Florida" will all match the key in our array.
# The 'sed' command with 's/\(.\)/\U\1/g' capitalizes the first letter of each word.
# The 'tr' command converts the rest of the string to lowercase.
# We then combine them to get the desired title case.
formatted_input=$(echo "$state_input" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

# --- Logic ---
# First, check if the state name entered by the user exists as a key in our array.
if [[ -v shark_attacks["$formatted_input"] ]]; then
    # If the state exists, get the number of attacks.
    count=${shark_attacks["$formatted_input"]}

    # Check if the number of attacks is greater than 0.
    if [[ "$count" -gt 0 ]]; then
        # Print a message with the number of attacks.
        echo "There are $count shark attacks in $formatted_input."
        
        # Ask the follow-up question.
        read -p "Would you like to see where? (Y/N): " see_locations
        
        # Handle the Y/N response using a case statement.
        case "$see_locations" in
            [Yy]* )
                echo "Displaying the locations of the shark attacks..."
                echo "..." # You can list specific locations here if you have them.
                ;;
            [Nn]* )
                echo "Okay, no problem."
                ;;
            * )
                echo "Invalid input. Please respond with Y or N next time."
                ;;
        esac
    else
        # This handles states that are in the array but have a count of 0.
        echo "This area has no shark attacks."
    fi
else
    # This handles any state name that is not in our array.
    echo "Sorry, I do not have data for that state."
fi
