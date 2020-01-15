
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
	

# You can add your code here!
	  
strfind:
	la $s1, grid # grid
	la $s2, dictionary  # dictionary
	
	li $s3, -1 # grid index
	
	li $s7, 0 # word found
	
strfind_grid_loop:
	addi $s3, $s3, 1 # increment grid index
	
	add $t0, $s1, $s3 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	beq $t0, $0, strfind_bad_exit # if grid[idx] == '\0'
	
	move $s4, $s3 # grid temp index
	li $s5, -1 # dictionary index
	
	j strfind_dict_loop
	
strfind_dict_loop:
	addi $s5, $s5, 1 # increment dictionary index
	
	add $t1, $s2, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	beq $t1, $zero, strfind_grid_loop # run out of dictionary
	
	j contain
	
contain:
	add $t0, $s1, $s3 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	add $t1, $s2, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	bne $t0, $t1, contain_next_word # if starting of grid idx != starting of dict word
	
	move $s4, $s3 # reset the fricking temp grid index I'm sorry this just took me a long time to figure out
	move $s6, $s5 # temp dict index
	
	j contain_helper # if grid[x] == dict[x]	

contain_next_word: # go to next word in dictionary
	addi $s5, $s5, 1
	
	beq $t1, $zero, strfind_grid_loop # run out of dictionary
	
	add $t1, $s2, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	la $t5, newline
	lb $t6, 0($t5) # \n
	
	beq $t1, $t6, strfind_dict_loop # if dict == '\n'
	
	j contain_next_word
			
contain_helper: # if starting of grid idx == starting of dict word
	addi $s4, $s4, 1 # increment temp grid index
	addi $s6, $s6, 1 # increment temp dictionary index
	
	add $t0, $s1, $s4 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	add $t1, $s2, $s6 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	la $t5, newline
	lb $t6, 0($t5)
	
	beq $t1, $t6, strfind_print # if dict[x] == '\n'
	
	bne $t0, $t1, contain_next_word # if grid[x] != dict[x]
	
	j contain_helper # if grid[x] == dict[x]

strfind_print:
	# prints 42 if exit is invoked
	#li $a0, 42
	#li $v0, 1
	#syscall
	
	li $s7, 1 # found a word
	
	#print grid index
	move $a0, $s3
	li $v0, 1
	syscall
	
	# print space
	li $a0, 32
	li $v0, 11
	syscall
	
	jal print_dictionary_word
	
	# print newline
	la $t0, newline
	move $a0, $t0 
	li $v0, 4
	syscall
	
	j contain_next_word

print_dictionary_word:
	add $t1, $s2, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	la $t5, newline
	lb $t6, 0($t5) # '\n'
	
	beq $t1, $t6, print_dictionary_exit
	
	move $a0, $t1
	li $v0, 11
	syscall
	
	addi $s5, $s5, 1
	
	j print_dictionary_word

print_dictionary_exit:
	jr $ra
			
strfind_bad_exit:
	# prints 69 when bad_exit is invoked
	#li $a0, 69
	#li $v0, 1
	#syscall
	
	bne $s7, 0, main_end
	
	# print -1
	li $a0, -1
	li $v0, 1
	syscall

	#print new line
	la $t0, newline
	move $a0, $t0 
	li $v0, 4
	syscall 
	
	j main_end
 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
