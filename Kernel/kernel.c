#include "font.h"
#include "screen.h"

void start()
{
	// Create a char pointer and point it to first pixel in video memory
    u8* pVideoMemory = GetVideoMemory();

	// Change screen to green
	for (int i = 0; i < SCREEN_SIZE; i++)
	{
		pVideoMemory[i] = 0x0a;
	}

    //FontChar('#', 0x01, 160, 100); // Write a blue 'A' in the middle of the screen
    const char helloWorld[] = "Hello World";
    FontString(helloWorld, 0x01, 160, 100);
}

// Adding a main function just to make the visual studio compiler happy. Not actually used. start() is our actual main
//void main(){}

