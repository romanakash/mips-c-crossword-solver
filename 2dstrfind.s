
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
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

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
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

row_len_init:
	li $s0, 0
	j row_len

row_len:
	la $t8, grid
	
	add $t0, $t8, $s0 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register
	
	la $t5, newline
	lb $t6, 0($t5)
	
	beq $t0, $t6, strfind
	
	addi $s0, $s0, 1
	j row_len
	  
strfind:
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	li $s3, -1 # grid index
	
	li $s7, 0 # word found
	
	li $s1, 0 # col idx
	li $s2, -1 # row idx
	
strfind_grid_loop:
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	addi $s3, $s3, 1 # increment grid index
	addi $s2, $s2, 1 # increment row idx
	
	add $t0, $t8, $s3 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	beq $t0, $0, strfind_bad_exit # if grid[idx] == '\0'
	
	move $s4, $s3 # grid temp index
	li $s5, -1 # dictionary index
	
	la $t5, newline
	lb $t6, 0($t5) # \n
	
	bne $t0, $t6, strfind_dict_loop
	
	addi $s1, $s1, 1
	li $s2, -1
	
	j strfind_dict_loop
	
strfind_dict_loop:
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	addi $s5, $s5, 1 # increment dictionary index
	
	add $t1, $t9, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	beq $t1, $zero, strfind_grid_loop # run out of dictionary
	
	j contain
	
contain:
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	add $t0, $t8, $s3 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	add $t1, $t9, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	bne $t0, $t1, contain_vertical # if starting of grid idx != starting of dict word
	
	move $s4, $s3 # reset the fricking temp grid index I'm sorry this just took me a long time to figure out
	move $s6, $s5 # temp dict index
	
	j contain_helper # if grid[x] == dict[x]	

contain_next_word: # go to next word in dictionary
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	addi $s5, $s5, 1
	
	beq $t1, $zero, strfind_grid_loop # run out of dictionary
	
	add $t1, $t9, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	la $t5, newline
	lb $t6, 0($t5) # \n
	
	beq $t1, $t6, strfind_dict_loop # if dict == '\n'
	
	j contain_next_word
			
contain_helper: # if starting of grid idx == starting of dict word
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	addi $s4, $s4, 1 # increment temp grid index
	addi $s6, $s6, 1 # increment temp dictionary index
	
	add $t0, $t8, $s4 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	add $t1, $t9, $s6 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	la $t5, newline
	lb $t6, 0($t5)
	
	beq $t1, $t6, strfind_print # if dict[x] == '\n'
	
	bne $t0, $t1, contain_vertical # if grid[x] != dict[x]
	
	j contain_helper # if grid[x] == dict[x]
		

strfind_print:
	# prints 42 if exit is invoked
	#li $a0, 42
	#li $v0, 1
	#syscall
	
	li $s7, 1 # found a word
	
	#print col index
	move $a0, $s1
	li $v0, 1
	syscall
	
	# print comma
	li $a0, 44
	li $v0, 11
	syscall
	
	#print row index
	move $a0, $s2
	li $v0, 1
	syscall
	
	# print space
	li $a0, 32
	li $v0, 11
	syscall
	
	# print H
	li $a0, 72
	li $v0, 11
	syscall
	
	# print space
	li $a0, 32
	li $v0, 11
	syscall
	
	move $s6, $s5
	
	jal print_dictionary_word
	
	# print newline
	la $t0, newline
	move $a0, $t0 
	li $v0, 4
	syscall
	
	j contain_vertical
	
contain_vertical:
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	add $t0, $t8, $s3 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	add $t1, $t9, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	bne $t0, $t1, contain_diagonal # if starting of grid idx != starting of dict word
	
	move $s4, $s3 # reset the fricking temp grid index I'm sorry this just took me a long time to figure out
	move $s6, $s5 # temp dict index
	
	j contain_vertical_helper # if grid[x] == dict[x]	
			
contain_vertical_helper: # if starting of grid idx == starting of dict word
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	add $s4, $s4, $s0 # increment temp grid index
	addi $s4, $s4, 1 # account for space
	addi $s6, $s6, 1 # increment temp dictionary index
	
	add $t0, $t8, $s4 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	add $t1, $t9, $s6 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	la $t5, newline
	lb $t6, 0($t5)
	
	beq $t1, $t6, strfind_vertical_print # if dict[x] == '\n'
	
	bne $t0, $t1, contain_diagonal # if grid[x] != dict[x]
	
	j contain_vertical_helper # if grid[x] == dict[x]	

strfind_vertical_print:
	# prints 42 if exit is invoked
	#li $a0, 42
	#li $v0, 1
	#syscall
	
	li $s7, 1 # found a word
	
	#print col index
	move $a0, $s1
	li $v0, 1
	syscall
	
	# print comma
	li $a0, 44
	li $v0, 11
	syscall
	
	#print row index
	move $a0, $s2
	li $v0, 1
	syscall
	
	# print space
	li $a0, 32
	li $v0, 11
	syscall
	
	# print V
	li $a0, 86
	li $v0, 11
	syscall
	
	# print space
	li $a0, 32
	li $v0, 11
	syscall
	
	move $s6, $s5
	
	jal print_dictionary_word
	
	# print newline
	la $t0, newline
	move $a0, $t0 
	li $v0, 4
	syscall
	
	j contain_diagonal
	
contain_diagonal:
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	add $t0, $t8, $s3 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	add $t1, $t9, $s5 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	bne $t0, $t1, contain_next_word # if starting of grid idx != starting of dict word
	
	move $s4, $s3 # reset the fricking temp grid index I'm sorry this just took me a long time to figure out
	move $s6, $s5 # temp dict index
	
	j contain_diagonal_helper # if grid[x] == dict[x]	
			
contain_diagonal_helper: # if starting of grid idx == starting of dict word
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	add $s4, $s4, $s0 # increment temp grid index
	addi $s4, $s4, 1 # account for space
	addi $s4, $s4, 1 # account for next diagonal
	
	addi $s6, $s6, 1 # increment temp dictionary index
	
	add $t0, $t8, $s4 # offset grid one byte at a time
	lb $t0, 0($t0)	# load grid byte into register

	add $t1, $t9, $s6 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	la $t5, newline
	lb $t6, 0($t5)
	
	beq $t1, $t6, strfind_diagonal_print # if dict[x] == '\n'
	
	bne $t0, $t1, contain_next_word # if grid[x] != dict[x]
	
	j contain_diagonal_helper # if grid[x] == dict[x]	

strfind_diagonal_print:
	# prints 42 if exit is invoked
	#li $a0, 42
	#li $v0, 1
	#syscall
	
	li $s7, 1 # found a word
	
	#print col index
	move $a0, $s1
	li $v0, 1
	syscall
	
	# print comma
	li $a0, 44
	li $v0, 11
	syscall
	
	#print row index
	move $a0, $s2
	li $v0, 1
	syscall
	
	# print space
	li $a0, 32
	li $v0, 11
	syscall
	
	# print D
	li $a0, 68
	li $v0, 11
	syscall
	
	# print space
	li $a0, 32
	li $v0, 11
	syscall
	
	move $s6, $s5
	
	jal print_dictionary_word
	
	# print newline
	la $t0, newline
	move $a0, $t0 
	li $v0, 4
	syscall
	
	j contain_next_word

print_dictionary_word:
	la $t8, grid # grid
	la $t9, dictionary  # dictionary
	
	add $t1, $t9, $s6 # offset dictionary one byte at a time
	lb $t1, 0($t1)	# load dictionary byte into register
	
	la $t5, newline
	lb $t6, 0($t5) # '\n'
	
	beq $t1, $t6, print_dictionary_exit
	
	move $a0, $t1
	li $v0, 11
	syscall
	
	addi $s6, $s6, 1
	
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
