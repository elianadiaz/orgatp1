################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/bufferFunctions.c \
../src/memoryFunctions.c \
../src/palindromeFunctions.c \
../src/tp1.c 

OBJS += \
./src/bufferFunctions.o \
./src/memoryFunctions.o \
./src/palindromeFunctions.o \
./src/tp1.o 

C_DEPS += \
./src/bufferFunctions.d \
./src/memoryFunctions.d \
./src/palindromeFunctions.d \
./src/tp1.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


