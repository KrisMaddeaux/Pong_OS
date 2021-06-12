#ifndef SCREEN_H
#define SCREEN_H

#include "util.h"

static const int SCREEN_WIDTH = 320;
static const int SCREEN_HEIGHT = 200;
static const int SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT;

u8* GetVideoMemory();
void WritePixel(u8 colour, int posX, int posY);

#endif

