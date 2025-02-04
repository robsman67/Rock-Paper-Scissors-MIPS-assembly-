# Rock Paper Scissors (MIPS Assembly)

## Overview
This project is an implementation of the classic Rock Paper Scissors game in MIPS Assembly. Unlike the traditional two-player game, this version features an automated match where the computer plays against itself. The game relies on a pseudorandom number generator to select moves for each player and determine the outcome.

## Features
- Random move generation using MIPS random number syscalls.
- Game simulation for a single round.
- Alternative random number generation using Elementary Cellular Automata (ECA).
- Output of the game results as `W` (Win), `L` (Loss), or `T` (Tie).


## Installation and Setup
1. Clone this project repository:
2. Download MARS (MIPS Assembler and Runtime Simulator) : *https://github.com/dpetersanderson/MARS/?tab=readme-ov-file*
3. Place `Mars4_5.jar` into the project root directory.
4. Ensure MARS settings:
   - Enable `Assemble all files in directory`.
   - Enable `Initialize Program Counter to global 'main'`.

## Implementation Details
### 1. Generating Random Numbers
- Uses the MARS syscall service for pseudorandom number generation.
- `gen_bit`: Returns a single bit using the random number generator.
- `gen_byte`: Generates a random byte ensuring uniform probability among rock, paper, and scissors moves.

### 2. Simulating the Game
- Function `play_game_once` generates moves for both players using `gen_byte`.
- Determines the winner based on the following rules:
  - Rock (`00`) beats Scissors (`10`)
  - Paper (`01`) beats Rock (`00`)
  - Scissors (`10`) beats Paper (`01`)
  - Matching values result in a tie.
- Prints `W`, `L`, or `T` based on the result.

### 3. Cellular Automata for Randomness
- Implemented using Elementary Cellular Automaton (ECA).
- Uses a rule-based approach to evolve a 1D tape structure and derive random bits.
- `simulate_automaton`: Updates the ECA tape to generate new random values.
- `print_tape`: Displays the current tape configuration.
- Modified `gen_bit` to use ECA-based randomness when enabled.

## Running and Testing
### Running the Program
1. Open MARS and load `main.s`.
2. Assemble the program.
3. Run the program and observe the results in the console.

### Running Tests
1. Install Python 3 if not already installed.
2. Run the provided test script:
   ```sh
   python run_tests
   ```
3. For verbose output:
   ```sh
   python run_tests -v
   ```
4. Debug a specific test case:
   ```sh
   python run_tests {path_to_test.s} --debug
   ```
## Notes
- Adhere to **MIPS calling conventions**.
- Ensure `random.s` and `automaton.s` work independently.
- Comments in assembly code are required for readability.
