#include "screen.h"

u8* GetVideoMemory()
{
    return (u8*)0xA0000;
}

void WritePixel(u8 colour, int posX, int posY)
{
    u8* pVideoMemory = GetVideoMemory();
    pVideoMemory[posX + (SCREEN_WIDTH * posY)] = colour;
}

