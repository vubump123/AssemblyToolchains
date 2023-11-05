#! /bin/bash

# Script created by Lubos Kuzma
# For the ISS Program at SADT, SAIT
# August 2022

# Check if at least one argument is provided, if not show usage
if [ $# -lt 1 ]; then
	echo "Usage:"
	echo ""
	echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
	echo ""
	echo "-v | --verbose                Show some information about steps performed."
	echo "-g | --gdb                    Run gdb command on executable."
	echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
	echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb environment."
	echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
	echo "-64| --x86-64                 Compile for 64bit (x86-64) system."
	echo "-o | --output <filename>      Specify the output filename."
	exit 1
fi

# Initialize variables for arguments and flags
POSITIONAL_ARGS=() # Array to hold the positional arguments
GDB=False          # Flag to indicate if GDB should be run
OUTPUT_FILE=""     # The name of the output file, empty by default
VERBOSE=False      # Flag to indicate if verbose output is enabled
BITS=False         # Flag for 64-bit compilation mode
QEMU=False         # Flag to indicate if QEMU should be run
BREAK="_start"     # Default breakpoint location
RUN=False          # Flag to indicate if the program should be run automatically in GDB

# Loop over all arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		-g|--gdb)
			GDB=True          # Set GDB flag to true
			shift             # Move past the argument
			;;
		-o|--output)
			OUTPUT_FILE="$2"  # Set the output file to the specified name
			shift             # Move past the argument
			shift             # Move past the value
			;;
		-v|--verbose)
			VERBOSE=True      # Enable verbose output
			shift             # Move past the argument
			;;
		-64|--x86-64)
			BITS=True         # Set 64-bit compilation flag
			shift             # Move past the argument
			;;
		-q|--qemu)
			QEMU=True         # Set QEMU flag to true
			shift             # Move past the argument
			;;
		-r|--run)
			RUN=True          # Set the run flag to true
			shift             # Move past the argument
			;;
		-b|--break)
			BREAK="$2"        # Set the breakpoint to the specified location
			shift             # Move past the argument
			shift             # Move past the value
			;;
		-*|--*)
			echo "Unknown option $1"  # Inform the user of an unknown option
			exit 1                    # Exit the script with an error
			;;
		*)
			POSITIONAL_ARGS+=("$1")   # Save positional argument
			shift                     # Move past the argument
			;;
	esac
done
# Continue the script with further processing...

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ ! -f $1 ]]; then
	echo "Specified file does not exist"
	exit 1
fi

if [ "$OUTPUT_FILE" == "" ]; then
	OUTPUT_FILE=${1%.*}
fi

if [ "$VERBOSE" == "True" ]; then
	echo "Arguments being set:"
	echo "	GDB = ${GDB}"
	echo "	RUN = ${RUN}"
	echo "	BREAK = ${BREAK}"
	echo "	QEMU = ${QEMU}"
	echo "	Input File = $1"
	echo "	Output File = $OUTPUT_FILE"
	echo "	Verbose = $VERBOSE"
	echo "	64 bit mode = $BITS" 
	echo ""

	echo "NASM started..."

fi

if [ "$BITS" == "True" ]; then

	nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""


elif [ "$BITS" == "False" ]; then

	nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""

fi

if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
	
fi

if [ "$VERBOSE" == "True" ]; then

	echo "NASM finished"
	echo "Linking ..."
fi

if [ "$BITS" == "True" ]; then

	ld -m elf_x86_64 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""


elif [ "$BITS" == "False" ]; then

	ld -m elf_i386 $OUTPUT_FILE.o -o $OUTPUT_FILE && echo ""

fi


if [ "$VERBOSE" == "True" ]; then

	echo "Linking finished"

fi

if [ "$QEMU" == "True" ]; then

	echo "Starting QEMU ..."
	echo ""

	if [ "$BITS" == "True" ]; then
	
		qemu-x86_64 $OUTPUT_FILE && echo ""

	elif [ "$BITS" == "False" ]; then

		qemu-i386 $OUTPUT_FILE && echo ""

	fi

	exit 0
	
fi

if [ "$GDB" == "True" ]; then

	gdb_params=()
	gdb_params+=(-ex "b ${BREAK}")

	if [ "$RUN" == "True" ]; then

		gdb_params+=(-ex "r")

	fi

	gdb "${gdb_params[@]}" $OUTPUT_FILE

fi
