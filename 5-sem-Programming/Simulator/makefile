all : sample

sample : simulator
	g++ -g -o sample sample.cpp

simulator : simulator.o display
	g++ -c simulator.cpp -o simulator

display : display.o counter
	g++ -c display.cpp -o display

queue_sim : queue_sim.o person
	g++ -c queue_sim.cpp -o queue_sim.o

counter : counter.o queue_sim
	g++ -c counter.cpp -o counter.o

person : person.o
	g++ -c person.cpp -o person.o
