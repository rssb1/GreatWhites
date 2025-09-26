#!/bin/bash

# --- Data Storage ---
# We use an associative array to store the shark attack data.
# Note that keys like "South Carolina" now include spaces.
declare -A shark_attacks

# Populate the array with state names and their shark attack counts.
shark_attacks[Alabama]=21
shark_attacks[Alaska]=5
shark_attacks[Arizona]=2
shark_attacks[Arkansas]=1
shark_attacks[California]=0
shark_attacks[Colorado]=0
shark_attacks[Connecticut]=0
shark_attacks[Delaware]=0
shark_attacks[Florida]=21
shark_attacks[Georgia]=5
shark_attacks[Hawaii]=2 
shark_attacks[Idaho]=1
shark_attacks[Illinois]=0
shark_attacks[Indiana]=0
shark_attacks[Iowa]=0
shark_attacks[Kansas]=0
shark_attacks[Kentucky]=21
shark_attacks[Louisiana]=5
shark_attacks[Maine]=2
shark_attacks[Maryland]=1
shark_attacks[Massachusetts]=0
shark_attacks[Michigan]=0
shark_attacks[Minnesota]=0
shark_attacks[Mississippi]=0
shark_attacks[Missouri]=21
shark_attacks[Montana]=5
shark_attacks[Nebraska]=2
shark_attacks[Nevada]=1
shark_attacks[New\ Hampshire]=0
shark_attacks[New\ Jersey]=0
shark_attacks[New\ Mexico]=0
shark_attacks[New\ York]=0
shark_attacks[North\ Carolina]=21
shark_attacks[North\ Dakota]=5
shark_attacks[Ohio]=2
shark_attacks[Oklahoma]=1
shark_attacks[Oregon]=0
shark_attacks[Pennslyvania]=0
shark_attacks[Rohode\ Island]=0
shark_attacks[South\ Carolina]=0
shark_attacks[South\ Dakota]=21
shark_attacks[Tennessee]=5
shark_attacks[Texas]=2
shark_attacks[Utah]=1
shark_attacks[Vermont]=0
shark_attacks[Virginia]=0
shark_attacks[Washington]=0
shark_attacks[West Virginia]=0
shark_attacks[Wisconsin]=21
shark_attacks[Wyoming]=5
shark_attacks[District\ of\ Columbia]=2
shark_attacks[South\ Carolina]=1
shark_attacks[American\ Samoa]=0
shark_attacks[Guam]=0
shark_attacks[North\ Mariana\ Islands]=0
shark_attacks[Puerto\ Rico]=0
shark_attacks[U.S.\ Virgin\ Islands]=21

# --- User Input ---
# Prompt the user for a state name and store the input.
read -p "Please enter a state name to check for shark attacks: " state_input

# --- Logic ---
# First, we format the user's input to match the keys in our array.
# The 'sed' command capitalizes the first letter of each word.
formatted_input=$(echo "$state_input" | sed 's/\b[a-z]/\U&/g')

# Now, we check if the formatted state name exists as a key in our array.
# We use double brackets [[...]] for the check and quote the variable.
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
                # You can list specific locations here if you have them.
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
