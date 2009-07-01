CC=gcc
# CXX=g++-4.0.2 	# Originally this compiler is used by S. Kudoh
CXX=g++
#CXX=g++
MOC=moc
UIC=uic
TAR=tar

CSRCS=
CXXSRCS=c3d2vpm.cpp c3d.cpp
QTHDRS=
QTUIS=
QTSRCS=$(QTHDRS:.h=.cpp) $(QTUIS:.ui=.cpp) $(addprefix moc_, $(QTHDRS:.h=.cpp) $(QTUIS:.ui=.cpp))
SRCS=$(CSRCS) $(CXXSRCS) $(QTSRCS)
OBJS=$(CSRCS:.c=.o) $(CXXSRCS:.cpp=.o) $(QTSRCS:.cpp=.o)

CFLAGS=-g -Wall
CXXFLAGS=-g -Wall -ftemplate-depth-30
#CFLAGS=-O3 -Wall
#CXXFLAGS=-O3 -Wall -ftemplate-depth-30
LIBS=

c3d2vpm : $(OBJS)
	$(CXX) -o $@ $(OBJS) $(LIBS)

moc_%.cpp : %.h
	$(MOC) -o $@ $<

%.h : %.ui
	$(UIC) -o $@ $<

%.cpp : %.ui %.h
	$(UIC) -o $@ -i $(<:.ui=.h) $<

%.o : %.cpp
	$(CXX) -c $(CXXFLAGS) $<

%.o : %.c
	$(CC) -c $(CFLAGS) $<

include make.dep

depend : $(SRCS)
	$(CXX) -MM $(SRCS) > make.dep

clean :
	rm -rf *.o moc_* $(QTUIS:.ui=.h) $(QTUIS:.ui=.cpp)

#EOF
