
# ==================================================================================================
# Project: 
# Exploring the performance of general matrix-multiplication on an NVIDIA Tesla K40m GPU.
#
# File information:
# Institution.... SURFsara <www.surfsara.nl>
# Author......... Cedric Nugteren <cedric.nugteren@surfsara.nl>
# Changed at..... 2014-11-07
# License........ MIT license
# Tab-size....... 4 spaces
# Line length.... 100 characters
#
# ==================================================================================================

# Set the location of CUDA, OpenCL and clBlas
#CUDADIR = $(CUDA_HOME)
OPENCLDIR = $(CUDA_HOME)

# ==================================================================================================

# Compilers
CXX = g++

# Compiler flags
CXXFLAGS += -O3 -Wall
NVFLAGS += -O3 -arch=sm_35 -Xcompiler -Wall
#NVFLAGS += -maxrregcount 127

# Folders
SRCDIR = src
BINDIR = bin
OBJDIR = obj
SCRDIR = scripts

# Load OpenCL and the clBlas library
INCLUDES += -I$(OPENCLDIR)/include
LDFLAGS += -L$(OPENCLDIR)/lib64
LDFLAGS += -lOpenCL


# Set the source files
CPPSOURCES = main.cpp clGEMM.cpp #libclblas.cpp
#GPUSOURCES = cuGEMM.cu libcublas.cu

# Define the names of the object files and the binary
OBJS = $(CPPSOURCES:%.cpp=$(OBJDIR)/%.cpp.o)
BIN = $(BINDIR)/myGEMM

# ==================================================================================================

# All (default target)
all: build run

# Build the binary from the objects
build: $(OBJS)
	@mkdir -p $(BINDIR)
	$(CXX) $(CXXFLAGS) $(DEFINES) $(INCLUDES) $(OBJS) $(LDFLAGS) -o $(BIN)

# C++ sources
$(OBJDIR)/%.cpp.o: $(SRCDIR)/%.cpp $(SRCDIR)/*.h
	@mkdir -p $(OBJDIR)
	$(CXX) -c $(CXXFLAGS) $(DEFINES) $(INCLUDES) $< -o $@

## CUDA sources
#$(OBJDIR)/%.cu.o: $(SRCDIR)/%.cu $(SRCDIR)/*.h $(SRCDIR)/*.cl
#	@mkdir -p $(OBJDIR)
#	$(NVCC) -c $(NVFLAGS) $(DEFINES) $(INCLUDES) $< -o $@

## Generate assembly code from the kernels and print some statistics
#inspect:
#	$(NVCC) -cubin $(NVFLAGS) -Xptxas -v $(INCLUDES) $(SRCDIR)/cuGEMM.cu -o $(BIN).cu.cubin
#	nvdisasm -lrm narrow $(BIN).cu.cubin > $(BIN).cu.asm
#	cuobjdump $(BIN) -xptx cuGEMM
#	mv cuGEMM.sm_35.ptx $(BIN).cu.ptx
#	cuobjdump $(BIN) -sass > $(BIN).cu.sass
#	sh $(SCRDIR)/stats.sh $(BIN).cu.sass

# Execute the binary
run:
	./$(BIN)

# Clean-up
clean:
	rm -f $(OBJDIR)/*.o
	rm -f $(BIN)
	rm -f $(BIN).*

# ==================================================================================================

.PHONY: run inspect clean

# ==================================================================================================
