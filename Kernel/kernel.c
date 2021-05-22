
typedef unsigned char u8;

const int SCREEN_WIDTH = 320;
const int SCREEN_HEIGHT = 200;
const int SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT;

u8* GetVideoMemory()
{
    return (u8*)0xA0000;
}

void WritePixel(u8 colour, int posX, int posY)
{
    u8* pVideoMemory = GetVideoMemory();
    pVideoMemory[posX + (SCREEN_WIDTH * posY)] = colour;
}

void WriteChar(const char c, u8 colour, int posX, int posY)
{
    const u8 fontTbl[2][8] = {
        {0x0C, 0x1E, 0x33, 0x33, 0x3F, 0x33, 0x33, 0x00},   // U+0041 (A)
        {0x3F, 0x66, 0x66, 0x3E, 0x66, 0x66, 0x3F, 0x00},   // U+0042 (B)
    };

    for (int y = 0; y < 8; y++)
    {
        for (int x = 0; x < 8; x++)
        {
            if (fontTbl[0][y] & (1 << x))
            {
                WritePixel(colour, posX + x, posY + y);
            }
        }
    }
}

void start()
{
	// Create a char pointer and point it to first pixel in video memory
    u8* pVideoMemory = GetVideoMemory();

	// Change screen to green
	for (int i = 0; i < SCREEN_SIZE; i++)
	{
		pVideoMemory[i] = 0x0a;
	}

    WriteChar('A', 0x01, 160, 100); // Write a blue 'A' in the middle of the screen
}

// Adding a main function just to make the visual studio compiler happy. Not actually used. start() is our actual main
//void main(){}

