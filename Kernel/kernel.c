
const int SCREEN_WIDTH = 320;
const int SCREEN_HEIGHT = 200;
const int SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT;

void start()
{
	// Create a char pointer and point it to first pixel in video memory
	char* pVideoMemory = (char*)0xA0000;

	// Change screen to green
	for (int i = 0; i < SCREEN_SIZE; i++)
	{
		pVideoMemory[i] = 0x0a;
	}
}

// Adding a main function just to make the visual studio compiler happy. Not actually used. start() is our actual main
//void main(){}

